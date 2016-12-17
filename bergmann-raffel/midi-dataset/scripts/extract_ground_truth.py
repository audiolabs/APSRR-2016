"""
Code for extracting ground truth from aligned MIDI results.
"""

import sys
sys.path.append('..')
import numpy as np
import librosa
import feature_extraction
import pretty_midi
import deepdish
import jams
import os
import glob
import joblib
import subprocess
import whoosh_search
import collections
import shutil

# Pre-load the MSD index as a list
MSD_IDX = whoosh_search.get_whoosh_index(
    os.path.join('..', 'data', 'msd', 'index'))
with MSD_IDX.searcher() as searcher:
    MSD_LIST = dict((e['id'], e) for e in searcher.documents())
# Threshold above which alignments are considered correct
SCORE_THRESHOLD = .5


def interpolate_times(times, old_timebase, new_timebase, labels=None,
                      shift_start=False):
    '''
    Linearly interpolate a set of times (and optionally labels) to a new
    timebase.  All returned times will fall within the range of
    ``new_timebase``, and only times which fall within ``old_timebase`` will be
    interpolated.

    Parameters
    ----------
    - times : np.ndarray
        Times of some events to be interpolated.
    - old_timebase : np.ndarray
        The original timebase of ``times``.
    - new_timebase : np.ndarray
        The new timebase to resample ``times`` to.
    - labels : list or NoneType
        Labels of the events in ``times``; if ``None``, no interpolated labels
        will be generated.
    - shift_start : bool
        Whether to create an additional interpolated event with time
        ``new_timebase[0]`` when any entry of ``times`` is before
        ``old_timebase[0]`` and ``new_timebase[0]``

    Returns
    -------
    - interpolated_times : np.ndarray
        Interpolated times.
    - interpolated_labels : list
        Interpolated labels.  Only returned when ``labels`` is not ``None``.
    '''
    # Remove all times which fall outside of the range of the original timebase
    valid_times = [time for time in times
                   if (time >= old_timebase[0]
                       and time <= old_timebase[-1])]
    # When labels are provided, also remove labels whose time falls outside of
    # the range of the original timebase
    if labels is not None:
        valid_labels = [label for (time, label) in zip(times, labels)
                        if (time >= old_timebase[0]
                            and time <= old_timebase[-1])]
    # Linearly interpolate the provided times to the new timebase
    interped_times = np.interp(valid_times, old_timebase, new_timebase)
    # If we have been told to add a time when an event falls before the
    # timebases...
    if (shift_start and np.any(times < new_timebase[0])
            and np.any(times < old_timebase[0])
            and not np.any(times == old_timebase[0])):
        # Add an event at the beginning of the new timebase
        interped_times = np.append(new_timebase[0], interped_times)
        # If labels were provided, find the label of the first event before
        # the old timebase and add it to the output labels
        if labels is not None:
            first_label = np.argmin(times < old_timebase[0]) - 1
            valid_labels = [labels[first_label]] + valid_labels
    # When labels were not provided, just return interpolated times
    if labels is None:
        return interped_times
    # When labels were provided, return interpolated times and labels
    else:
        return interped_times, valid_labels


def extract_ground_truth(diagnostics_group):
    """
    Extract ground-truth information from one or more MIDI files about a single
    MIDI file based on the results in one or more diagnostics files and return
    a JAMS object with all of the annotations compiled.

    Parameters
    ----------
    - diagnostics_group : list of dict
        List of dicts of diagnostics, each about a successful alignment of a
        different MIDI file to a single audio file.
    """
    # Construct the JAMS object
    jam = jams.JAMS()
    # Load in the first diagnostics (doesn't matter which as they all
    # should correspond the same audio file)
    diagnostics = diagnostics_group[0]
    # Load in the audio file to get its duration for the JAMS file
    audio, fs = librosa.load(
        diagnostics['audio_filename'], feature_extraction.AUDIO_FS)
    jam.file_metadata.duration = librosa.get_duration(y=audio, sr=fs)
    # Also store metadata about the audio file, retrieved from the MSD
    jam.file_metadata.identifiers = {'track_id': diagnostics['audio_id']}
    jam.file_metadata.artist = MSD_LIST[diagnostics['audio_id']]['artist']
    jam.file_metadata.title = MSD_LIST[diagnostics['audio_id']]['title']

    # Iterate over the diagnostics files supplied
    for diagnostics in diagnostics_group:

        # Create annotation metadata object, shared across annotations
        commit = subprocess.check_output(['git', 'rev-parse', 'HEAD']).strip()
        commit_url = "http://github.com/craffel/midi-dataset/tree/" + commit
        annotator = {'midi_md5': diagnostics['midi_md5'],
                     'commit_url': commit_url,
                     'confidence': diagnostics['score']}
        annotation_metadata = jams.AnnotationMetadata(
            curator=jams.Curator('Colin Raffel', 'craffel@gmail.com'),
            version='0.0.1b', corpus='Million Song Dataset MIDI Matches',
            annotator=annotator,
            annotation_tools=(
                'MIDI files were matched and aligned to audio files using the '
                'code at http://github.com/craffel/midi-dataset.  Information '
                'was extracted from MIDI files using pretty_midi '
                'https://github.com/craffel/pretty-midi.'),
            annotation_rules=(
                'Beat locations and key change times were linearly '
                'interpolated according to an audio-to-MIDI alignment.'),
            validation=(
                'Only MIDI files with alignment confidence scores >= .5 were '
                'considered "correct".  The confidence score can be used as a '
                'rough guide to the potential correctness of the annotation.'),
            data_source='Inferred from a MIDI file.')

        # Load the extracted features
        midi_features = deepdish.io.load(diagnostics['midi_features_filename'])
        audio_features = deepdish.io.load(
            diagnostics['audio_features_filename'])
        # Load in the original MIDI file
        midi_object = pretty_midi.PrettyMIDI(diagnostics['midi_filename'])
        # Compute the times of the frames (will be used for interpolation)
        midi_frame_times = feature_extraction.frame_times(
            midi_features['gram'])[diagnostics['aligned_midi_indices']]
        audio_frame_times = feature_extraction.frame_times(
            audio_features['gram'])[diagnostics['aligned_audio_indices']]

        # Get the interpolated beat locations and add them to the JAM
        adjusted_beats = interpolate_times(
            midi_object.get_beats(), midi_frame_times, audio_frame_times)
        # Create annotation record for the beats
        beat_a = jams.Annotation(namespace='beat')
        beat_a.annotation_metadata = annotation_metadata
        # Add beat timings to the annotation record
        for t in adjusted_beats:
            beat_a.append(time=t, duration=0.0)
        # Add beat annotation record to the JAMS file
        jam.annotations.append(beat_a)

        # Get key signature times and their string names
        key_change_times = [c.time for c in midi_object.key_signature_changes]
        key_names = [pretty_midi.key_number_to_key_name(c.key_number)
                     for c in midi_object.key_signature_changes]
        # JAMS requires that the key name be supplied in the form e.g.
        # "C:major" but pretty_midi returns things in the format "C Major",
        # so the following code converts to JAMS format
        key_names = [name.replace(' ', ':').replace('M', 'm')
                     for name in key_names]
        # Compute interpolated event times
        adjusted_key_change_times, adjusted_key_names = interpolate_times(
            key_change_times, midi_frame_times, audio_frame_times, key_names,
            True)
        # Create JAMS annotation for the key changes
        if len(adjusted_key_change_times) > 0:
            key_a = jams.Annotation(namespace='key_mode')
            key_a.annotation_metadata = annotation_metadata
            # We only have key start times from the MIDI file, but JAMS wants
            # durations too, so create a list of "end times"
            end_times = np.append(adjusted_key_change_times[1:],
                                  jam.file_metadata.duration)
            # Add key labels into the JAMS file
            for start, end, key in zip(adjusted_key_change_times, end_times,
                                       adjusted_key_names):
                key_a.append(time=start, duration=end - start, value=key)
            jam.annotations.append(key_a)

    return jam

if __name__ == '__main__':

    # Output paths for JAMS, unaligned MIDI and aligned MIDI
    output_jams_path = os.path.join(
        '..', 'results', 'extracted_ground_truth', 'jams')
    if not os.path.exists(output_jams_path):
        os.makedirs(output_jams_path)
    output_midi_path = os.path.join(
        '..', 'results', 'extracted_ground_truth', 'mid')
    if not os.path.exists(output_midi_path):
        os.makedirs(output_midi_path)
    output_aligned_midi_path = os.path.join(
        '..', 'results', 'extracted_ground_truth', 'mid_aligned')
    if not os.path.exists(output_aligned_midi_path):
        os.makedirs(output_aligned_midi_path)

    # Currently grabbing results from clean_midi, eventually more
    diagnostics_path = os.path.join(
        '..', 'results', 'clean_midi_aligned', 'h5')
    # Keep track of groups of correct alignments of the same MSD IDs
    diagnostics_groups = collections.defaultdict(list)
    # And the MIDI
    for diagnostics_file in glob.glob(os.path.join(diagnostics_path, '*.h5')):
        diagnostics = deepdish.io.load(diagnostics_file)
        if (diagnostics['score'] > SCORE_THRESHOLD
                and diagnostics['audio_dataset'] == 'msd'):
            diagnostics_groups[diagnostics['audio_id']].append(diagnostics)

    # Construct JAMS objects for all groups of alignments
    jams_objects = joblib.Parallel(n_jobs=10, verbose=51)(
        joblib.delayed(extract_ground_truth)(diagnostics_group)
        for diagnostics_group in diagnostics_groups.values())

    # Write out all results
    for (id, diagnostics_group), jams_object in zip(diagnostics_groups.items(),
                                                    jams_objects):
        # Iterate over entries in the diagnostics group
        for diagnostics in diagnostics_group:
            # Create the subdirectory for the MSD ID if it doesn't exist
            output_midi_id_path = os.path.join(output_midi_path, id)
            if not os.path.exists(output_midi_id_path):
                os.makedirs(output_midi_id_path)
            # Copy over the unaligned MIDI
            shutil.copy(diagnostics['midi_filename'],
                        os.path.join(output_midi_id_path,
                                     diagnostics['midi_md5'] + '.mid'))

            # Same for aligned MIDI
            output_aligned_midi_id_path = os.path.join(
                output_aligned_midi_path, id)
            if not os.path.exists(output_aligned_midi_id_path):
                os.makedirs(output_aligned_midi_id_path)
            shutil.copy(diagnostics['output_midi_filename'],
                        os.path.join(output_aligned_midi_id_path,
                                     diagnostics['midi_md5'] + '.mid'))

        # Write out the JAMS file
        with open(os.path.join(output_jams_path, id + '.jams'), 'wb') as f:
            jams_object.save(f)
