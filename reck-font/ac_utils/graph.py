from StringIO import *
import re


def simplify_dot_tree(file_path, class_names, remove_gini=False):
    """
    Edits a .dot file exported from a decision tree classifier using scikits-learn and adds useful information
    such as class names. See http://scikit-learn.org/stable/modules/tree.html#classification)
    :param file_path: file path to load
    :param class_names: class names in the same order as introduced in the classifier
    :param remove_gini: whether to show or not the gini measure at each box
    :return:
    """

    in_fid = open(file_path, 'r')
    data = StringIO(in_fid.read()).getvalue()
    in_fid.close()

    if remove_gini:
        finished = False
        while not finished:
            current_pos = data.find('gini =')
            if current_pos == -1:
                finished = True
                break
            next_pos = data.find('\\n',current_pos)
            data = data[0:current_pos] + data[next_pos + 2:]

    # Add class name in box
    current_pos = 0
    rex = re.compile(r'\W+')
    while current_pos != -1:
        current_pos = data.find('value = [', current_pos)
        next_pos = data.find(']', current_pos)
        n_samples_per_class = [int(x) for x in rex.sub(' ', data[current_pos:next_pos].split('[')[1]).split(' ') if x]
        class_name = class_names[n_samples_per_class.index(max(n_samples_per_class))]
        label = '\\n%s' % class_name
        data = data[:next_pos + 1] + label + data[next_pos + 1:]
        current_pos = data.find('value = [', next_pos + len(label))

    out_filename = file_path.replace('.dot', '.simp.dot')
    out_fid = open(out_filename, 'w')
    out_fid.write(data)
    out_fid.close()

    return out_filename
