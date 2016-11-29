from ac_utils.general import vfkp


def accuracy1(data, method, sound_ids=None, tolerance=0.04, skip_zeroed_values=False):
    """
    Compares estimated bpm with annotated bpm of provided data. Considers as good matches values that do not differ
    more than the tolerance parameter (default toleracne = 0, 0 bpm max diff, i.e., exact match)
    :param data: sound data with annotations and analysis
    :param method: analysis algorithm name to compare with annotation
    :param sound_ids: ids of the sounds to include in comparison (default=None, all found in data)
    :param tolerance: max % deviation of bpm to consider a good match (default=0.04)
    :param skip_zeroed_values: whether to take into account sounds annotated with ground truth bpm=0.0
    :return: list with 1 for sounds that match and 0 for sounds that do not match
    """
    return accuracy2(data, method, sound_ids, tolerance, skip_zeroed_values, allowed_multiples=[1.0])


def accuracy2(data, method, sound_ids=None, tolerance=0.04, skip_zeroed_values=False,
                         allowed_multiples=[1.0, 1.0/3, 0.5, 1.0, 2.0, 3.0]):
    """
    Compares estimated bpm with annotated bpm of provided data. Considers as good matches values that are either the
    same or multiples as listed in 'allowed_multiples' parameter.
    See: Gouyon, F., Klapuri, A., andM. Alonso, S. D., Tzanetakis, G., & Uhle, C. (2006). An Experimental Comparison
    of Audio Tempo Induction Algorithms. IEEE Transactions on Audio, Speech and Language Processing, 14(5), 1832-1844.
    :param data: sound data with annotations and analysis
    :param method: analysis algorithm name to compare with annotation
    :param sound_ids: ids of the sounds to include in comparison (default=None, all found in data)
    :param tolerance: max % deviation of bpm to consider a good match (default=0.04)
    :param skip_zeroed_values: whether to take into account sounds annotated with ground truth bpm=0.0
    :param allowed_multiples: multiples of the ground truth bpm value which are to be accepted as good estimates
    :return: list with 1 for sounds that match and 0 for sounds that do not match
    """
    if sound_ids is None:
        sound_ids = data.keys()
    output = list()
    for sound_id in sound_ids:
        ground_truth_value = data[sound_id]['annotations']['bpm']
        if ground_truth_value is None:
            continue
        try:
            estimated_value = vfkp(data[sound_id]['analysis'], method + '.bpm', ignore_non_existing=False)
            if skip_zeroed_values and estimated_value == 0.0:
                continue
        except KeyError:
            # Method produced no estimation
            if not skip_zeroed_values:
                output.append(0)
            continue

        threshold = tolerance * float(ground_truth_value)
        found_match = 0
        for multiple in allowed_multiples:
            delta = abs(float(ground_truth_value) * multiple - estimated_value)
            if delta <= threshold:
                found_match = 1
                break
        output.append(found_match)

    return output


def accuracy1e(data, method, sound_ids=None, skip_zeroed_values=False):
    """
    Compares estimated bpm with annotated bpm of provided data. Considers as good matches values that, after rounder,
     are exatcly that of the ground truth.
    :param data: sound data with annotations and analysis
    :param method: analysis algorithm name to compare with annotation
    :param sound_ids: ids of the sounds to include in comparison (default=None, all found in data)
    :param skip_zeroed_values: whether to take into account sounds annotated with ground truth bpm=0.0
    :return: list with 1 for sounds that match and 0 for sounds that do not match
    """
    if sound_ids is None:
        sound_ids = data.keys()
    output = list()
    for sound_id in sound_ids:
        ground_truth_value = data[sound_id]['annotations']['bpm']
        if ground_truth_value is None:
            continue
        try:
            estimated_value = vfkp(data[sound_id]['analysis'], method + '.bpm', ignore_non_existing=False)
            if skip_zeroed_values and estimated_value == 0.0:
                continue
        except KeyError:
            # Method produced no estimation
            if not skip_zeroed_values:
                output.append(0)
            continue

        if int(round(estimated_value)) == int(round(ground_truth_value)):
            output.append(1)
        else:
            output.append(0)

    return output
