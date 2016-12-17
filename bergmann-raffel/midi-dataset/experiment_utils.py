''' Shared utility functions for downsampled hash sequence experiments. '''

import lasagne
import numpy as np
import os
import collections
import deepdish
import traceback
import functools
import glob
import sys
import simple_spearmint
import pse
import dhs
import theano
import msgpack
import msgpack_numpy
msgpack_numpy.patch()

N_BITS = 32
OUTPUT_DIM = 128
N_HIDDEN = 2048


def run_trial(params, data_directory, train_function):
    '''
    Train a network given the task and hyperparameters and return the result.

    Parameters
    ----------
    params : dict
        Dictionary of model hyperparameters
    data_directory : str
        Path to training/validation set directory.  Should have two
        subdirectories, one called 'train' and one called 'validate', each of
        which contain subdirectories called 'h5', which contain training files
        created by `deepdish`.
    train_function : callable
        This function will be called with the constructed network, training
        data, and hyperparameters to create a model.

    Returns
    -------
    best_objective : float
        Lowest objective value achieved.
    best_epoch : dict
        Statistics about the epoch during which the lowest objective value was
        achieved.
    best_params : dict
        Parameters of the model for the best-objective epoch.
    '''
    # We will be modifying params, so make a copy of it
    params = dict(params)
    print ',\n'.join(['\t{} : {}'.format(k, v) for k, v in params.items()])
    # Fill in default parameter values which may not be used by all experiments
    params['n_conv'] = params.get('n_conv', 3)
    params['downsample_frequency'] = params.get('downsample_frequency', True)
    params['output_l2_penalty'] = params.get('output_l2_penalty', 0.0)
    # Load in data as dictionary of dictionaries
    data = {'X': collections.defaultdict(list),
            'Y': collections.defaultdict(list)}
    for set in ['train', 'validate']:
        for f in glob.glob(os.path.join(data_directory, set, 'h5', '*.h5')):
            for k, v in deepdish.io.load(f).items():
                data[k][set].append(v)

    # Build networks
    layers = {}
    for network in ['X', 'Y']:
        # Get # of features (last dimension) from first training sequence
        input_shape = (None, 1, None, data[network]['train'][0].shape[-1])
        # Get training set statistics for standardization
        input_mean = np.mean(
            np.concatenate(data[network]['train'], axis=1), axis=1)
        input_std = np.std(
            np.concatenate(data[network]['train'], axis=1), axis=1)
        # Choose network structure based on network param
        if params['network'] == 'dhs_big_filter':
            build_network = build_dhs_net_big_filter
        elif params['network'] == 'dhs_small_filters':
            build_network = build_dhs_net_small_filters
        elif params['network'] == 'pse_big_filter':
            # PSE networks have an additional n_attention parameter which must
            # be factored out here
            build_network = functools.partial(
                build_pse_net_big_filter, n_attention=params['n_attention'])
        elif params['network'] == 'pse_small_filters':
            build_network = functools.partial(
                build_pse_net_small_filters, n_attention=params['n_attention'])
        else:
            raise ValueError('Unknown network {}'.format(params['network']))
        layers[network] = build_network(
            input_shape, input_mean, input_std,
            downsample_frequency=params['downsample_frequency'],
            n_conv=params['n_conv'])

    # Create updates-creating function
    updates_function = functools.partial(
        lasagne.updates.rmsprop, learning_rate=params['learning_rate'],
        rho=params['momentum'])

    # Create a list of epochs
    epochs = []
    # Keep track of lowest objective found so far
    best_objective = np.inf
    try:
        for epoch in train_function(
                data, layers, params['negative_importance'],
                params['negative_threshold'], params['output_l2_penalty'],
                updates_function):
            # Stop training if a nan training cost is encountered
            if not np.isfinite(epoch['train_cost']):
                break
            epochs.append(epoch)
            if epoch['validate_objective'] < best_objective:
                best_objective = epoch['validate_objective']
                best_epoch = epoch
                best_model = {
                    'X': lasagne.layers.get_all_param_values(layers['X']),
                    'Y': lasagne.layers.get_all_param_values(layers['Y'])}
            print "{}: {}, ".format(epoch['iteration'],
                                    epoch['validate_objective']),
            sys.stdout.flush()
    # If there was an error while training, report it to whetlab
    except Exception:
        print "ERROR: "
        print traceback.format_exc()
        return np.nan, {}, {}
    print
    # Check that all training costs were not NaN; return NaN if any were.
    success = np.all([np.isfinite(e['train_cost']) for e in epochs])
    if np.isinf(best_objective) or len(epochs) == 0 or not success:
        print '    Failed to converge.'
        print
        return np.nan, {}, {}
    else:
        for k, v in best_epoch.items():
            print "\t{:>35} | {}".format(k, v)
        print
        return best_objective, best_epoch, best_model


def parameter_search(space, trial_directory, model_directory, data_directory,
                     train_function):
    '''
    Run parameter optimization given some train function, writing out results

    Parameters
    ----------
    space : dict
        Hyperparameter space (in the format used by `simple_spearmint`) to
        optimize over
    trial_directory : str
        Directory where parameter optimization trial results will be written
    model_directory : str
        Directory where the best-performing model will be written
    data_directory : str
        Path to training/validation set directory.  Should have two
        subdirectories, one called 'train' and one called 'validate', each of
        which contain subdirectories called 'h5', which contain training files
        created by `deepdish`.
    train_function : callable
        This function will be called with the constructed network, training
        data, and hyperparameters to create a model.
    '''
    # Create parameter trials directory if it doesn't exist
    if not os.path.exists(trial_directory):
        os.makedirs(trial_directory)
    # Same for model directory
    if not os.path.exists(model_directory):
        os.makedirs(model_directory)

    # Create SimpleSpearmint suggester instance
    ss = simple_spearmint.SimpleSpearmint(space)

    # Load in previous results for "warm start"
    for trial_file in glob.glob(os.path.join(trial_directory, '*.h5')):
        trial = deepdish.io.load(trial_file)
        ss.update(trial['hyperparameters'], trial['best_objective'])

    # Run parameter optimization forever
    while True:
        # Get a new suggestion
        suggestion = ss.suggest()
        # Train a network with these hyperparameters
        best_objective, best_epoch, best_model = run_trial(
            suggestion, data_directory, train_function)
        # Update spearmint on the result
        ss.update(suggestion, best_objective)
        # Write out a result file
        trial_filename = ','.join('{}={}'.format(k, v)
                                  for k, v in suggestion.items()) + '.h5'
        deepdish.io.save(
            os.path.join(trial_directory, trial_filename),
            {'hyperparameters': suggestion, 'best_objective': best_objective,
             'best_epoch': best_epoch})
        # Also write out the entire model when the objective is the smallest
        # We don't want to write all models; they are > 100MB each
        if (not np.isnan(best_objective) and
                best_objective == np.nanmin(ss.objective_values)):
            deepdish.io.save(
                os.path.join(model_directory, 'best_model.h5'), best_model)


def _build_input(input_shape, input_mean, input_std):
    layers = [lasagne.layers.InputLayer(shape=input_shape)]
    # Utilize training set statistics to standardize all inputs
    layers.append(lasagne.layers.standardize(
        layers[-1], input_mean, input_std, shared_axes=(0, 2)))
    return layers


def _build_small_filters_frontend(layers, downsample_frequency, n_conv):
    # Construct the pooling size based on whether we pool over frequency
    if downsample_frequency:
        pool_size = (2, 2)
    else:
        pool_size = (2, 1)
    # Add three groups of 2x 3x3 convolutional layers followed by a pool layer
    filter_size = (3, 3)
    # Up to three conv layer groups will be made, with the following # filters
    filters_per_layer = [16, 32, 64]
    # Add in n_conv groups of 2x 3x3 filter layers and a max pool layer
    for num_filters in filters_per_layer[:n_conv]:
        n_l = num_filters*np.prod(filter_size)
        layers.append(lasagne.layers.Conv2DLayer(
            layers[-1], stride=(1, 1), num_filters=num_filters,
            filter_size=filter_size,
            nonlinearity=lasagne.nonlinearities.rectify,
            W=lasagne.init.Normal(np.sqrt(2./n_l)), pad='same'))
        layers.append(lasagne.layers.Conv2DLayer(
            layers[-1], stride=(1, 1), num_filters=num_filters,
            filter_size=filter_size,
            nonlinearity=lasagne.nonlinearities.rectify,
            W=lasagne.init.Normal(np.sqrt(2./n_l)), pad='same'))
        layers.append(lasagne.layers.MaxPool2DLayer(
            layers[-1], pool_size, ignore_border=False))
    return layers


def _build_hash_sequence_dense(layers, n_bits):
    # A dense layer will treat any dimensions after the first as feature
    # dimensions, but the third dimension is really a timestep dimension.
    # We can only squash adjacent dimensions with a ReshapeLayer, so we
    # need to place the time stpe dimension after the batch dimension
    layers.append(lasagne.layers.DimshuffleLayer(
        layers[-1], (0, 2, 1, 3)))
    conv_output_shape = layers[-1].output_shape
    # Reshape to (n_batch*n_time_steps, n_conv_output_features)
    layers.append(lasagne.layers.ReshapeLayer(
        layers[-1], (-1, conv_output_shape[2]*conv_output_shape[3])))
    # Add dense hidden layers
    for hidden_layer_size in [N_HIDDEN, N_HIDDEN]:
        layers.append(lasagne.layers.DenseLayer(
            layers[-1], num_units=hidden_layer_size,
            nonlinearity=lasagne.nonlinearities.rectify))
    # Add output layer
    layers.append(lasagne.layers.DenseLayer(
        layers[-1], num_units=n_bits,
        nonlinearity=lasagne.nonlinearities.tanh))
    return layers


def build_dhs_net_small_filters(input_shape, input_mean, input_std,
                                downsample_frequency, n_conv=3,
                                n_bits=N_BITS):
    '''
    Construct a list of layers of a network for mapping sequences of feature
    vectors to downsampled sequences of binary vectors which has three groups
    of two 3x3 convolutional layers followed by a max-pooling layer.

    Parameters
    ----------
    input_shape : tuple
        In what shape will data be supplied to the network?
    input_mean : np.ndarray
        Training set mean, to standardize inputs with.
    input_std : np.ndarray
        Training set standard deviation, to standardize inputs with.
    downsample_frequency : bool
        Whether to max-pool over frequency
    n_conv : int
        Number of convolutional/pooling layer groups
    n_bits : int
        Output dimensionality

    Returns
    -------
    layers : list
        List of layer instances for this network.
    '''
    # Use utility functions to construct input, frontend, and dense output
    layers = _build_input(input_shape, input_mean, input_std)
    layers = _build_small_filters_frontend(
        layers, downsample_frequency, n_conv)
    layers = _build_hash_sequence_dense(layers, n_bits)
    return layers


def _build_big_filter_frontend(layers, downsample_frequency, n_conv):
    # Construct the pooling size based on whether we pool over frequency
    if downsample_frequency:
        pool_size = (2, 2)
    else:
        pool_size = (2, 1)
    # The first convolutional layer has filter size (5, 12), and Lasagne
    # doesn't allow same-mode convolutions with even filter sizes.  So, we need
    # to explicitly use a pad layer.
    filter_size = (5, 12)
    num_filters = 16
    if n_conv > 0:
        layers.append(lasagne.layers.PadLayer(
            layers[-1], width=((int(np.ceil((filter_size[0] - 1) / 2.)),
                            int(np.floor((filter_size[0] - 1) / 2.))),
                            (int(np.ceil((filter_size[1] - 1) / 2.)),
                            int(np.floor((filter_size[1] - 1) / 2.))))))
        # We will initialize weights to \sqrt{2/n_l}
        n_l = num_filters*np.prod(filter_size)
        layers.append(lasagne.layers.Conv2DLayer(
            layers[-1], stride=(1, 1), num_filters=num_filters,
            filter_size=filter_size,
            nonlinearity=lasagne.nonlinearities.rectify,
            W=lasagne.init.Normal(np.sqrt(2./n_l))))
        layers.append(lasagne.layers.MaxPool2DLayer(
            layers[-1], pool_size, ignore_border=False))
    # Add n_conv 3x3 convlayers with 32 and 64 filters and pool layers
    filter_size = (3, 3)
    filters_per_layer = [32, 64]
    for num_filters in filters_per_layer[:n_conv - 1]:
        n_l = num_filters*np.prod(filter_size)
        layers.append(lasagne.layers.Conv2DLayer(
            layers[-1], stride=(1, 1), num_filters=num_filters,
            filter_size=filter_size,
            nonlinearity=lasagne.nonlinearities.rectify,
            W=lasagne.init.Normal(np.sqrt(2./n_l)), pad='same'))
        layers.append(lasagne.layers.MaxPool2DLayer(
            layers[-1], pool_size, ignore_border=False))
    return layers


def build_dhs_net_big_filter(input_shape, input_mean, input_std,
                             downsample_frequency, n_conv=3,
                             n_bits=N_BITS):
    '''
    Construct a list of layers of a network for mapping sequences of feature
    vectors to downsampled sequences of binary vectors which has a ``big'' 5x12
    input filter and two 3x3 convolutional layers, all followed by max-pooling
    layers.

    Parameters
    ----------
    input_shape : tuple
        In what shape will data be supplied to the network?
    input_mean : np.ndarray
        Training set mean, to standardize inputs with.
    input_std : np.ndarray
        Training set standard deviation, to standardize inputs with.
    downsample_frequency : bool
        Whether to max-pool over frequency
    n_conv : int
        Number of convolutional/pooling layer groups
    n_bits : int
        Output dimensionality

    Returns
    -------
    layers : list
        List of layer instances for this network.
    '''
    # Use utility functions to construct input, frontend, and dense output
    layers = _build_input(input_shape, input_mean, input_std)
    layers = _build_big_filter_frontend(
        layers, downsample_frequency, n_conv)
    layers = _build_hash_sequence_dense(layers, n_bits)
    return layers


def _build_ff_attention_dense(layers, n_attention, output_dim):
    # Combine the "n_channels" dimension with the "n_features"
    # dimension
    layers.append(lasagne.layers.DimshuffleLayer(layers[-1], (0, 2, 1, 3)))
    layers.append(lasagne.layers.ReshapeLayer(layers[-1], ([0], [1], -1)))
    # Function which constructs attention layers
    attention_layer_factory = lambda: pse.AttentionLayer(
        layers[-1], N_HIDDEN,
        # We must force He initialization because Lasagne doesn't like 1-dim
        # shapes in He and Glorot initializers
        v=lasagne.init.Normal(1./np.sqrt(layers[-1].output_shape[-1])),
        # We must also construct the bias scalar shared variable ourseves
        # because deepdish won't save numpy scalars
        c=theano.shared(np.array([0.], theano.config.floatX),
                        broadcastable=(True,)))
    # Construct list of attention layers for later concatenation
    attention_layers = [attention_layer_factory() for _ in range(n_attention)]
    # Add all attention layers into the list of layers
    layers += attention_layers
    # Concatenate all attention layers
    layers.append(lasagne.layers.ConcatLayer(attention_layers))
    # Add dense hidden layers
    for hidden_layer_size in [N_HIDDEN, N_HIDDEN]:
        layers.append(lasagne.layers.DenseLayer(
            layers[-1], num_units=hidden_layer_size,
            nonlinearity=lasagne.nonlinearities.rectify))
    # Add output layer
    layers.append(lasagne.layers.DenseLayer(
        layers[-1], num_units=output_dim,
        nonlinearity=lasagne.nonlinearities.tanh))
    return layers


def build_pse_net_big_filter(input_shape, input_mean, input_std,
                             downsample_frequency, n_attention,
                             n_conv=3, output_dim=OUTPUT_DIM):
    '''
    Construct a list of layers of a network which embeds sequences in a
    fixed-dimensional output space using feedforward attention, which has a
    ``big'' 5x12 input filter and two 3x3 convolutional layers, all followed by
    max-pooling layers.

    Parameters
    ----------
    input_shape : tuple
        In what shape will data be supplied to the network?
    input_mean : np.ndarray
        Training set mean, to standardize inputs with.
    input_std : np.ndarray
        Training set standard deviation, to standardize inputs with.
    downsample_frequency : bool
        Whether to max-pool over frequency
    n_attention : int
        Number of attention layers
    n_conv : int
        Number of convolutional/pooling layer groups
    output_dim : int
        Output dimensionality

    Returns
    -------
    layers : list
        List of layer instances for this network.
    '''
    # Use utility functions to construct input, frontend, and dense output
    layers = _build_input(input_shape, input_mean, input_std)
    layers = _build_big_filter_frontend(
        layers, downsample_frequency, n_conv)
    layers = _build_ff_attention_dense(
        layers, n_attention, output_dim)
    return layers


def build_pse_net_small_filters(input_shape, input_mean, input_std,
                                downsample_frequency, n_attention,
                                n_conv=3, output_dim=OUTPUT_DIM):
    '''
    Construct a list of layers of a network which embeds sequences in a
    fixed-dimensional output space using feedforward attention, which has
    groups of two 3x3 convolutional layers and max-pooling layers.

    Parameters
    ----------
    input_shape : tuple
        In what shape will data be supplied to the network?
    input_mean : np.ndarray
        Training set mean, to standardize inputs with.
    input_std : np.ndarray
        Training set standard deviation, to standardize inputs with.
    downsample_frequency : bool
        Whether to max-pool over frequency
    n_attention : int
        Number of attention layers
    n_conv : int
        Number of convolutional/pooling layer groups
    output_dim : int
        Output dimensionality

    Returns
    -------
    layers : list
        List of layer instances for this network.
    '''
    # Use utility functions to construct input, frontend, and dense output
    layers = _build_input(input_shape, input_mean, input_std)
    layers = _build_small_filters_frontend(
        layers, downsample_frequency, n_conv)
    layers = _build_ff_attention_dense(
        layers, n_attention, output_dim)
    return layers


def get_valid_matches(pair_file, score_threshold, diagnostics_path):
    '''
    Reads in a CSV file listing text-matched pairs, finds the pairs
    corresponding to the MSD, and then returns only those pairs which were
    successfully aligned.

    Parameters
    ----------
    pair_file : str
        Full path to a CSV file listing text-matched pairs (generated by
        scripts/text_match_datasets.py)

    score_threshold : float
        Alignments will only be considered correct if their normalized DTW
        score was above this threshold.

    diagnostics_path : str
        Full path to where alignment diagnostics files have been written

    Returns
    -------
    pairs : dict
        Mapping from MIDI MD5s to list of MSD IDs which match it
    '''
    midi_msd_mapping = collections.defaultdict(list)
    with open(pair_file) as f:
        for line in f.readlines():
            midi_md5, dataset, msd_id = line.strip().split(',')
            # The pairs.csv files will include pairs from all datasets
            # Only grab those for the MSD
            if dataset == 'msd':
                # Only include if the alignment was successful
                alignment_file = os.path.join(
                    diagnostics_path, 'msd_{}_{}.h5'.format(msd_id, midi_md5))
                if os.path.exists(alignment_file):
                    diagnostics = deepdish.io.load(alignment_file)
                    if diagnostics['score'] > score_threshold:
                        midi_msd_mapping[midi_md5].append(msd_id)
    return dict(midi_msd_mapping)


def match_sequence(midi_data, msd_data, msd_match_indices, gully, penalty):
    '''
    Match a MIDI sequence against the MSD and evaluate whether a good match was
    found

    Parameters
    ----------
    midi_data : dict
        Dict of MIDI data, including hash sequence
    sequences : list of dict
        List of MSD entries (hash sequences, metadata) to match against
    msd_match_indices : list-like of int
        Indices of entries in the sequences this MIDI should potentially match
    gully : float
        Proportion of shorter sequence which must be matched by DTW
    penalty : int
        Non-diagonal move penalty

    Returns
    -------
    results : dict
        Dictionary with diagnostics about whether this match was successful
    '''
    # Create a separate list of the sequences
    msd_sequences = [d['hash_sequence'] for d in msd_data]
    # Match this MIDI sequence against MSD sequences
    matches, scores, n_pruned_dist = dhs.match_one_sequence(
        midi_data['hash_sequence'], msd_sequences, gully, penalty, prune=False)
    # Store results of the match
    results = {}
    results['midi_md5'] = midi_data['id']
    results['msd_match_ids'] = [msd_data[n]['id'] for n in msd_match_indices]
    # Compile the rank and score for each MSD entry which should match the MIDI
    results['msd_match_ranks'] = [
        matches.index(msd_index) for msd_index in msd_match_indices]
    results['msd_match_scores'] = [
        scores[rank] for rank in results['msd_match_ranks']]
    results['n_pruned_dist'] = n_pruned_dist
    return results


def match_embedding(midi_data, msd_data, msd_match_indices):
    '''
    Match a MIDI embedding against the MSD and evaluate whether a good match was
    found

    Parameters
    ----------
    midi_data : dict
        Dict of MIDI data, including embedding
    sequences : list of dict
        List of MSD entries (embedding, metadata) to match against
    msd_match_indices : list-like of int
        Indices of entries in the sequences this MIDI should potentially match

    Returns
    -------
    results : dict
        Dictionary with diagnostics about whether this match was successful
    '''
    # Create a big matrix of the embeddings
    msd_embeddings = np.concatenate([d['embedding'] for d in msd_data], axis=0)
    # Get the distance between the MIDI embedding and all MSD entries
    distances = np.sum((msd_embeddings - midi_data['embedding'])**2, axis=1)
    # Get the indices of MSD entries sorted by their embedded distance to the
    # query MIDI embedding.
    matches = np.argsort(distances)
    # Store results of the match
    results = {}
    results['midi_md5'] = midi_data['id']
    results['msd_match_ids'] = [msd_data[n]['id'] for n in msd_match_indices]
    # Compile the rank and score for each MSD entry which should match the MIDI
    results['msd_match_ranks'] = [np.flatnonzero(matches == msd_index)[0]
                                  for msd_index in msd_match_indices]
    results['msd_match_distances'] = [
        distances[rank] for rank in results['msd_match_ranks']]
    return results


def load_valid_midi_datas(midi_msd_mapping, msd_data, midi_list, data_path):
    """
    Load precomputed represented for all valid-matched MIDI files, and also
    find the index of the correct entry to match to in msd_data

    Parameters
    ----------
    midi_msd_mapping : list
        List of valid MIDI-MSD match pairs
    msd_data : list of dict
        List of precomputed data entries for the MSD, from
        :func:`load_precomputed_data`
    midi_list : list of dict
        List of entries in the clean MIDI dataset, retrieved from the Whoosh
        index
    data_path : str
        Path where the precomputed MIDI data lives

    Returns
    -------
    midi_datas : dict of dict
        Mapping from MIDI MD5s to precomputed MIDI data entries
    midi_index_mapping : dict of list
        Mapping from MIDI MD5s to lists of matching indices in msd_data
    """
    # Create a separate list of the IDs of each entry in msd_data
    msd_data_ids = [d['id'] for d in msd_data]
    # Collect a list of valid MIDI entries in the provided mapping
    valid_midi_list = []
    for midi_md5 in midi_msd_mapping:
        midi_entry = [entry for entry in midi_list if entry['id'] == midi_md5]
        # Edge case - no entry in the MIDI list for this md5
        if len(midi_entry) == 0:
            continue
        else:
            valid_midi_list.append(midi_entry[0])
    # We will create a new dict which only contains indices of correct matches
    # in the msd_sequences list, and only for matches we could load in
    midi_index_mapping = {}
    # Also create dict of loaded MIDI data
    midi_datas = {}
    # For each precomputed MIDI data entry which is loaded in, add to the
    # midi_datas dict and populate the corresponding midi_index_mapping entry
    for midi_data in load_precomputed_data(valid_midi_list, data_path):
        midi_md5 = midi_data['id']
        midi_datas[midi_md5] = midi_data
        midi_index_mapping[midi_md5] = [msd_data_ids.index(i)
                                        for i in midi_msd_mapping[midi_md5]]
    return midi_datas, midi_index_mapping

def load_precomputed_data(index_list, path):
    """
    Load in all precomputed representation of entries in the provided list

    Paraneters
    ----------
    index_list : list of dict
        List of entries in a dataset, retrieved from the Whoosh index
    path : str
        Path to where the precomputed data lives

    Returns
    -------
    data : list of dict
        List of loaded data
    """
    # Load in hash sequences (and metadata) for all index entries
    data = []
    for entry in index_list:
        mpk_file = os.path.join(path, entry['path'] + '.mpk')
        # If creating a CQT or hashing failed, there will be no file
        if os.path.exists(mpk_file):
            try:
                with open(mpk_file) as f:
                    d = msgpack.unpackb(f.read())
                data.append(d)
            except Exception as e:
                print "Error loading {}: {}".format(mpk_file, e)
    return data
