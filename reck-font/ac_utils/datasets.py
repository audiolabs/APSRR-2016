from ac_utils.general import combine_json_files_into_dictionary, load_from_json, vfkp
import os
try:
    import settings
except ImportError:
    pass


def load_and_combine_metadata_and_analysis_files(dataset_path, exclude_files=None):
    metadata = load_from_json(os.path.join(dataset_path, "metadata.json"))
    if exclude_files is None:
        exclude_files = list()
    analysis_files_to_load = [os.path.join(dataset_path, filename) for filename
                                                   in os.listdir(dataset_path) if filename.startswith('analysis_') and
                                                   filename not in exclude_files]

    data = metadata.copy()
    if analysis_files_to_load:
        analysis = combine_json_files_into_dictionary(analysis_files_to_load)
        for key, value in data.items():
            try:
                value[u'analysis'] = analysis[key]
            except KeyError:
                value[u'analysis'] = dict()

    return data, analysis_files_to_load


def load_dataset(dataset_name):
    try:
        dataset_path = os.path.join(settings.DATA_PATH, dataset_name)
    except NameError:
        dataset_path = dataset_name
    return load_and_combine_metadata_and_analysis_files(dataset_path)[0]


def filter_data(data, filters=None, condition=None):
    """
    Returns a dictionary with all keys and values in data that passes one of the given filters (OR).
    Filters are given as a list of tuples in the filters parameter. Each tuple contains a filter_term and
    filter_values. Filter terms contain a key_path that will be used to get the corresponding value from
    each elements' dict in data, and the operation that will be performed against the given filter values.
    Key path and operation are separated by '__', and filter_values contain all values required to carry out
    the operation. For example:
    >> filtered_data = filter_data(data, filters=[('analysis.RhythmExtractor2013.bpm__>=' , 120)])

    Alternatively, the filter_data also accepts a function as a condition parameter. This function will be
    passed the key and current item being filtered as well as the rest of the data as a third argument. The
    function must return True or False to decide whether to add or not the item to the filtered data.
    >> def condition_func(key, item, data):
    >>     return item['property1'] == item['property2']
    >> filtered_data = filter_data(data, condition=condition_func)

    Remember that if any of the filters or the condition passes, the element is added to the output.
    To get AND filtering you should call this method in "cascade".

    :param data: data dictionary
    :param filters: list of tuples specifying filter_term and filter_values (optional)
    :param condition: function for which current item must return True in order to be returned
    :return: filtered dictionary
    """
    out_data = dict()
    for key, item in data.items():
        passes_filter = False
        if filters is not None:
            for filter_term, filter_values in filters:
                key_path, operation = filter_term.split('__')
                if operation == '>':
                    if vfkp(item, filter_term.replace('__' + operation, '')) > filter_values:
                        passes_filter = True
                elif operation == '>=':
                    if vfkp(item, filter_term.replace('__' + operation, '')) >= filter_values:
                        passes_filter = True
                elif operation == '<':
                    if vfkp(item, filter_term.replace('__' + operation, '')) < filter_values:
                        passes_filter = True
                elif operation == '<=':
                    if vfkp(item, filter_term.replace('__' + operation, '')) <= filter_values:
                        passes_filter = True
                elif operation == '==':
                    if vfkp(item, filter_term.replace('__' + operation, '')) == filter_values:
                        passes_filter = True
                else:
                    raise Exception("Filter term could not be parsed correctly")
        if condition is not None:
            passes_filter = condition(key, item, data)
        if passes_filter:
            out_data[key] = item
    return out_data


class Dataset(object):

    name = None
    short_name = None
    dirname = None
    data = None
    loaded_analysis_files = None

    def __init__(self, dirname=None, data=None, name=None, short_name=None, exclude_files=None, loaded_analysis_files=None):
        if dirname is None and data is None:
            raise Exception(u'Either \'dirname\' or \'data\' parameter must not be None!')

        self.dirname = dirname
        self.name = name
        self.short_name = short_name

        if self.name is None or self.short_name is None:
            try:
                info = load_from_json(os.path.join(self.dataset_path, 'dataset_info.json'))
                if 'name' in info and self.name is None:
                    self.name = info['name']
                if 'short_name' in info and self.short_name is None:
                    self.short_name = info['short_name']
            except IOError:
                pass

        if self.name is None:
            self.name = dirname

        if self.short_name is None:
            self.short_name = self.name

        if data is None:
            self.load_data(exclude_files=exclude_files)
        else:
            self.data = data

        if loaded_analysis_files is not None:
            self.loaded_analysis_files = loaded_analysis_files

    def __unicode__(self):
        return u'<Dataset: %s, %i instances>' % (self.short_name, len(self.data))

    def info(self):
        print self.__unicode__()
        if self.loaded_analysis_files is not None:
            for analysis_file in self.loaded_analysis_files:
                print u'  - %s' % analysis_file
        else:
            print u'  Info for loaded analysis files not available'

    @property
    def dataset_path(self):
        return os.path.join(settings.DATA_PATH, self.dirname)

    def load_data(self, exclude_files=None):
        self.data, self.loaded_analysis_files \
            = load_and_combine_metadata_and_analysis_files(self.dataset_path, exclude_files=exclude_files)

    def filter_data(self, filters=None, condition=None):
        return Dataset(dirname=self.dirname, data=filter_data(self.data, filters=filters, condition=condition),
                       name=self.name, short_name=self.short_name, loaded_analysis_files=self.loaded_analysis_files)

    def get_data(self, key_path, format=list, ignore_non_existing=True):
        if format == list:
            return vfkp(self.data.values(), key_path, ignore_non_existing=ignore_non_existing)
        elif format == dict:
            out_dict = dict()
            for key, item in self.data.items():
                value = vfkp(item, key_path, ignore_non_existing=ignore_non_existing)
                if value is not None:
                    out_dict[key] = value
            return out_dict
        else:
            raise Exception(u'Unknown format \'%s\'' % format)

    def get_sound_path(self, sound_id):
        try:
            sound = self.data[str(sound_id)]
        except KeyError:
            raise Exception(u'Sound with id %s does not exist' % str(sound_id))
        return "%s%s/%s" % (settings.DATA_PATH, self.dirname , sound['original_sound_path'])
