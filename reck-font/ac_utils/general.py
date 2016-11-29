import json
import yaml
import os
import datetime
import sys
import numpy as np
import time


# File IO, directories, etc...
##############################

def save_to_json(path="", data="", verbose=False, indent=4):
    """
    Save python object to json file.
    :param path: output file path
    :param data: object to be written
    :param verbose:
    :return:
    """
    with open(path, mode='w') as f:
        if verbose:
            print "Saving data to '" + path + "'"
        json.dump(data, f, indent=indent)


def load_from_json(path, verbose=False):
    """
    Load python object stored in json file.
    :param path: file path to load
    :param verbose:
    :return: loaded object
    """
    with open(path, 'r') as f:
        if verbose:
            print "Loading data from '" + path + "'"
        return json.load(f)


def load_from_yaml(path, verbose=False):
    """
    Load python object stored in yaml file.
    :param path: file path to load
    :param verbose:
    :return: loaded object
    """
    with open(path, 'r') as f:
        if verbose:
            print "Loading data from '" + path + "'"
        return yaml.load(f, Loader=yaml.CLoader)


def save_to_file(path="", data="", verbose=False):
    """
    Save python object to file.
    :param path: output file path
    :param data: object to be written
    :param verbose:
    :return:
    """
    with open(path, mode='w') as f:
        if verbose:
            print "Saving data to '" + path + "'"
        f.write(data)


def create_directories(path_list, verbose=False):
    """
    Create a number of directories as specified in path_list.
    :param path_list: list of directories to create
    :param verbose:
    :return:
    """
    for path in path_list:
        if not os.path.exists(path):
            if verbose:
                print "Creating directory " + str(path)
            os.makedirs(path)


def remove_directories(path_list, must_be_empty=True, verbose=False):
    """
    Remove a number of directories as specified in path_list.
    :param path_list: list of directories to remove
    :param must_be_empty: only remove directories that are empty (default=True)
    :param verbose:
    :return:
    """
    for path in path_list:
        if path[-1] == "/":
            path = path[0:-1]
        path = os.path.split(path)[0]
        files = os.listdir(path)
        for f in files:
            full_path = os.path.join(path, f)
            if os.path.isdir(full_path):
                must_be_removed = True
                if must_be_empty and os.listdir(full_path):
                    must_be_removed = False
                    if verbose:
                        print "Omitting directory %s (not empty)" % full_path
                if must_be_removed:
                    if verbose:
                        print "Removing directory %s" % full_path
                    os.rmdir(full_path)


def promt_user_to_abort_if_file_exists(file_path, throw_exception=True):
    if os.path.exists(file_path):
        key = raw_input("%s already exists, do you really want to proceed? [y for yes]: " % file_path)
        if key.lower() != 'y':
            if throw_exception:
                raise Exception("Aborted script execution because user cancelled")
            else:
                return False
    return True


def combine_json_files_into_dictionary(file_paths):
    """
    Reads the json files included in file_paths and combines them into a single dictionary.
    The different files are expected to contain dictionaries of dictionaries, and hence the item
    in each key at the main level is populated with the combination of all corresponding dictionaries
    from the second level of all files. For example, given the files a.json and b.json:
    # File a.json
    {"main_key1": {"sub_key1": 1, "sub_key2":2}, "main_key2": {}}
    # File b.json
    {"main_key1": {"sub_key3": 3, "sub_key4":4}, "main_key2": {"sub_key5": 5}}
    The returned dict would be:
    {"main_key1": {"sub_key1": 1, "sub_key2":2, "sub_key3": 3, "sub_key4":4}, "main_key2": {"sub_key5": 5}}
    If a sub key for a given main key is present in more than one file, the value corresponding to the
    last file in file_paths is the one that prevails.
    :param file_paths: paths of the json files that will be loaded
    :return: dictionary with combined dicts from file_paths
    """
    out_dict = dict()
    for file_path in file_paths:
        try:
            data = load_from_json(file_path)
            for key, value in data.items():
                if key not in out_dict:
                    out_dict[key] = value
                else:
                    out_dict[key].update(value)
        except ValueError:
            print 'Warning: Could not load %s into combined dictionary' % file_path
            continue

    return out_dict


def value_for_key_path(dictionary, key_path, ignore_non_existing=True):
    """
    Returns the value of a dictionary given the corresponding key(s). Nested keys can be specified in a single
    string separated by dots, allowing access to nested dictionary values. If a list of dictionaries is passed,
    then a list of corresponding values is returned.
    :param dictionary: data dictionary (or list of dictionaries)
    :param key_path: key(s) to access (e.g. key_path="key1.subkey1.subsubkey1")
    :param ignore_non_existing: whether to raise an exception or not when a key does not exist in dictionary.
    :return: corresponding value
    """
    if type(dictionary) == dict:
        if key_path is None:
            return None
        keys = key_path.split(".")
        try:
            return reduce(lambda d, k: d[k], keys, dictionary)
        except KeyError as e:
            if ignore_non_existing:
                return None
            else:
                raise e
    else:
        output = list()
        if key_path is None:
            return output
        keys = key_path.split(".")
        for item in dictionary:
            try:
                output.append(reduce(lambda d, k: d[k], keys, item))
            except KeyError as e:
                if ignore_non_existing:
                    continue
                else:
                    raise e
        return output


def vfkp(*args, **kwargs):
    return value_for_key_path(*args, **kwargs)


def values_sorted_by_key_list(dictionary, key_list, ignore_non_existing=True):
    """
    This function returns the values of a dictionary accorded to a list of keys. The key list should contain
    keys that the dictionary has. For example:
    >> d = {'a': 1, 'b': 2, 'c': 3}
    >> values_sorted_by_key_list(d, ['b', 'a'])
    >> [2, 1]
    :param dictionary: data dictionary
    :param key_list: keys whose values must be returned
    :param ignore_non_existing: whether to raise an exception or not when a key does not exist in dictionary
    :return: list
    """
    output = list()
    for key in key_list:
        try:
            output.append(dictionary[key])
        except KeyError as e:
            if ignore_non_existing:
                continue
            else:
                raise e
    return output


def vskl(*args, **kwargs):
    return values_sorted_by_key_list(*args, **kwargs)


# Strings and text
##################

def string_with_fixed_length(s="", l=30):
    """
    Return a string with the contents of s plus white spaces until length l.
    :param s: input string
    :param l: total length of the string (will crop original string if longer than l)
    :return:
    """
    s_out = ""
    for i in range(0, l):
        if i < len(s):
            s_out += s[i]
        else:
            s_out += " "
    return s_out


def make_line(c='-', l=10):
    """
    Return a string with the character c repeated l times.
    :param c: character to be repeated
    :param l: length of the string (default=10)
    :return:
    """
    out = ''
    for i in range(0, l):
        out += '%s' % c
    return out


def title(message, c='-'):
    """
    Return the given message with a the format of a title
    :param message: message to return
    :return: formatted message
    """
    return '\n%s\n%s\n' % (message, make_line(c=c, l=len(message)))


def print_table(table_header, table_rows, column_margin=3, sort_column=False, reverse=True, max_column_width=None,
                shorten_header=True, highlight_max=False, latex=False):
    """
    Prints provided data with table format
    :param table_header: header titles (list of strings)
    :param table_rows: rows data (list of lists of strings)
    :param column_margin: number of spaces between columns (int)
    :param sort_column: number of column to sort the rows of the table (default=False)
    :param reverse: whether to reverse the order when sort_column is on (default=True)
    :param max_column_width: max width characters taken by a column
    :param shorten_header: whether to abbreviate or not the header title in case is is too long
    :param highlight_max: highlight maximum value in numeric columns
    :param latex: output format so that that it can be copied and pasted to a latex document
    """

    def value_to_string(value):
        if type(element) == str or type(element) == unicode:
            return element
        elif type(element) == int:
            return "%i" % element
        elif type(element) == float or type(element) == np.float64:
            return "%.2f" % element
        return str(element)

    header_lengths = list()
    header = ""
    for count, item in enumerate(table_header):
        max_length = max([len(item)] +
                         [len(value_to_string(element)) for element in get_nth_column_from_list_of_lists(table_rows, count)])
        if max_column_width is not None:
            max_length = min(max_length, max_column_width)
        header_lengths.append(max_length + column_margin)
        if shorten_header and len(item) > max_length:
            margin = int(max_length/2) - 3
            item = item[0:margin] + "..." + item[-margin:]
        header += string_with_fixed_length(item, header_lengths[count])
    print header
    print make_line(l=len(header))
    if sort_column:
        table_rows = sorted(table_rows, key=lambda x: x[sort_column], reverse=reverse)
    latex_table_content = ""
    for table_row in table_rows:
        row = ""
        for count, element in enumerate(table_row):
            needs_highlighting = False
            if highlight_max:
                max_col = sorted(table_rows, key=lambda x: x[count], reverse=reverse)[0][count]
                if (type(max_col) == float or type(max_col) == int or type(max_col) == np.float64) \
                        and element == max_col:
                    needs_highlighting = True
            value = string_with_fixed_length(
                string_with_fixed_length(value_to_string(element), header_lengths[count] - 3), header_lengths[count])
            if needs_highlighting:
                value = tc_blue(value)
            row += value
        latex_table_content += ' & '.join([value_to_string(element) for element in table_row]) + ' \\\\ \n'
        print row
    latex_output = "\\begin{tabular}{ %s }\n" % " ".join(['c' for i in range(0, len(table_header))])
    latex_output += ' & '.join(table_header) + ' \\\\ \\hline \n'
    latex_output += latex_table_content
    latex_output += "\\end{tabular}\n"

    if latex:
        print '\n' + latex_output

# Lists and dictionaries
########################

def get_nth_column_from_list_of_lists(list_of_lists, n):
    out = []
    for element in list_of_lists:
        out.append(element[n])
    return out


def sort_list_of_arrays_by_key(list_of_arrays, prop, reverse=True):
    out = sorted(list_of_arrays, key=lambda k: k[prop])
    if reverse:
        out.reverse()
    return out


# Terminal and colours
######################

COLORS = ['#FF4500', '#FFA500', '#6B8E23', '#32CD32', '#FFD700', '#008B8B', '#00008B', '#B22222', '#1E90FF', '#FF1493',
          '#008000', '#DAA520', '#2F4F4F', '#8B0000', '#FF8C00', '#8B008B', '#A9A9A9', '#B8860B', '#00FFFF', '#6495ED',
          '#FF7F50', '#D2691E', '#7FFF00', '#DEB887', '#8A2BE2', '#0000FF', '#000000']
ALL_COLORS = ['#F0F8FF', '#FAEBD7', '#00FFFF', '#7FFFD4', '#F0FFFF', '#F5F5DC', '#FFE4C4', '#000000', '#FFEBCD',
              '#0000FF', '#8A2BE2', '#A52A2A', '#DEB887', '#5F9EA0', '#7FFF00', '#D2691E', '#FF7F50', '#6495ED',
              '#FFF8DC', '#DC143C', '#00FFFF', '#00008B', '#008B8B', '#B8860B', '#A9A9A9', '#006400', '#BDB76B',
              '#8B008B', '#556B2F', '#FF8C00', '#9932CC', '#8B0000', '#E9967A', '#8FBC8F', '#483D8B', '#2F4F4F',
              '#00CED1', '#9400D3', '#FF1493', '#00BFFF', '#696969', '#1E90FF', '#B22222', '#FFFAF0', '#228B22',
              '#FF00FF', '#DCDCDC', '#F8F8FF', '#FFD700', '#DAA520', '#808080', '#008000', '#ADFF2F', '#F0FFF0',
              '#FF69B4', '#CD5C5C', '#4B0082', '#FFFFF0', '#F0E68C', '#E6E6FA', '#FFF0F5', '#7CFC00', '#FFFACD',
              '#ADD8E6', '#F08080', '#E0FFFF', '#FAFAD2', '#D3D3D3', '#90EE90', '#FFB6C1', '#FFA07A', '#20B2AA',
              '#87CEFA', '#778899', '#B0C4DE', '#FFFFE0', '#00FF00', '#32CD32', '#FAF0E6', '#FF00FF', '#800000',
              '#66CDAA', '#0000CD', '#BA55D3', '#9370DB', '#3CB371', '#7B68EE', '#00FA9A', '#48D1CC', '#C71585',
              '#191970', '#F5FFFA', '#FFE4E1', '#FFE4B5', '#FFDEAD', '#000080', '#FDF5E6', '#808000', '#6B8E23',
              '#FFA500', '#FF4500', '#DA70D6', '#EEE8AA', '#98FB98', '#AFEEEE', '#DB7093', '#FFEFD5', '#FFDAB9',
              '#CD853F', '#FFC0CB', '#DDA0DD', '#B0E0E6', '#800080', '#FF0000', '#BC8F8F', '#4169E1', '#8B4513',
              '#FA8072', '#F4A460', '#2E8B57', '#FFF5EE', '#A0522D', '#C0C0C0', '#87CEEB', '#6A5ACD', '#708090',
              '#FFFAFA', '#00FF7F', '#4682B4', '#D2B48C', '#008080', '#D8BFD8', '#FF6347', '#40E0D0', '#EE82EE',
              '#F5DEB3', '#FFFFFF', '#F5F5F5', '#FFFF00']


TERMINAL_COLORS = {
    'HEADER': '\033[95m',
    'OKBLUE': '\033[36m',
    'OKGREEN': '\033[92m',
    'WARNING': '\033[93m',
    'FAIL': '\033[91m',
    'ENDC': '\033[0m',
}


def tc_blue(s):
    """
    Returns string s wrapped in terminal blue color codes
    """
    return TERMINAL_COLORS['OKBLUE'] + s + TERMINAL_COLORS['ENDC']


def tc_red(s):
    """
    Returns string s wrapped in terminal red color codes
    """
    return TERMINAL_COLORS['FAIL'] + s + TERMINAL_COLORS['ENDC']


def tc_green(s):
    """
    Returns string s wrapped in terminal green color codes
    """
    return TERMINAL_COLORS['OKGREEN'] + s + TERMINAL_COLORS['ENDC']


def t_bold(s):
    """
    Returns string s wrapped in terminal bold font code
    """
    return '\033[1m' + s + '\033[0m'


def print_progress(message, current=None, total=None, start_time=None, show_progress_bar=False):
    """
    Immediatly prints in std out given message plus current iteration number with respect to total and percentage.
    :param message: Message to print
    :param current: Current iteration number
    :param total: Total number of iterations
    :param start_time: If provided, progress will show estimated time (start_time should be as returned by time.time())
    :param show_progress_bar: Whether to show a progress bar
    """
    to_show = "\r%s " % message
    if current is not None and total is not None:
        percentage = float(current)/total
        pbar = ''
        if show_progress_bar:
            bar_length = 35
            points_ok = int(bar_length*percentage)
            pbar = "[%s%s] " % ('#'*points_ok, '-'*(bar_length-points_ok))
        to_show += "%s[%i/%i] %.2f%%" % (pbar, current, total, 100 * percentage)
    if start_time:
        elapsed_time = time.time() - start_time
        try:
            remaining_time = (elapsed_time * float(total)/current) - elapsed_time
        except ZeroDivisionError:
            remaining_time = 0.0
        to_show += " %s" % seconds_to_day_hour_minute_second(remaining_time)
    sys.stdout.write(string_with_fixed_length(to_show, 100))
    sys.stdout.flush()


# Dates and times
#################

def datetime_to_str(d):
    return d.strftime("%d-%m-%Y %H-%M")


def str_to_datetime(s):
    s0, s1 = s.split(' ')
    s0 = s0.split('-')
    s1 = s1.split('-')
    return datetime.datetime(year=int(s0[2]), month=int(s0[1]), day=int(s0[0]), hour=int(s1[0]), minute=int(s1[1]))


def seconds_to_day_hour_minute_second(seconds):
    td = datetime.timedelta(seconds=seconds)
    dt = datetime.datetime(1, 1, 1) + td
    return "%dd %.2d:%.2d:%.2d" % (dt.day-1, dt.hour, dt.minute, dt.second)
