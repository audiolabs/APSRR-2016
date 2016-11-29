import os
import sys
import IPython
import numpy as np
import matplotlib.pyplot as plt
import seaborn
import settings
import inspect
import random
import math
from ac_utils.general import *
from ac_utils.evaluation import *
from ac_utils.processing import *
from ac_utils.datasets import *
from ac_utils.sound import *
from ac_utils.plotting import *
from evaluation_metrics import *
from sklearn.externals import joblib

seaborn.set(style="whitegrid")

TEMPO_ESTIMATION_ALGORITHM_NAMES = {
    'rekordbox_bpm': 'RekBox',
    'Gkiokasq8_bpm': 'Gkiokas12',
    'Percival14_bpm': 'Percival14',
    'Madmom_bpm': 'Bock15',
    'RE13m_bpm': 'Zapata14',
    'RE13d_bpm': 'Degara12'
}


def condition_instance_acceptable(key, item, data):
    annotated_bpm = vfkp(item, 'annotations.bpm')
    if annotated_bpm == 0 or annotated_bpm is None:
        return False
    if annotated_bpm < 30 or annotated_bpm > 300:
        return False
    return True


def load_datasets(dirnames=None, clean=False, exclude_files=None):
    if dirnames is None:
        raise Exception("No dataset directory names sepecified!")
    datasets = list()
    for dirname in dirnames:
        dataset = Dataset(dirname=dirname, exclude_files=exclude_files)
        if clean:
            dataset = dataset.filter_data(condition=condition_instance_acceptable)
        datasets.append(dataset)
    return datasets


def confidence_measure_audio_length(bpm, length_samples, length_samples_effective_duration,
                                    sample_rate=44100, beat_range=range(1, 128), k=0.5):
    if bpm == 0:
        # This condition is to skip computing other steps if estimated bpm is 0, we already know that the
        # output will be 0
        return 0

    beat_duration = (60.0 * sample_rate)/bpm
    L = [beat_duration * n for n in beat_range]
    thr_lambda = k * beat_duration
    al = length_samples
    delta_l = min([abs(l - al) for l in L])
    if delta_l > thr_lambda:
        confidence_delta_l = 0.0
    else:
        confidence_delta_l = 1.0 - float(delta_l) / thr_lambda

    if confidence_delta_l == 1.0:
        # If confidence is already 1, skip computing confidence based on effective duration
        return confidence_delta_l
    else:
        al_alt = length_samples_effective_duration
        delta_l_alt = min([abs(l - al_alt) for l in L])
        if delta_l_alt > thr_lambda:
            confidence_delta_l_alt = 0.0
        else:
            confidence_delta_l_alt = 1.0 - float(delta_l_alt) / thr_lambda
        return max(confidence_delta_l, confidence_delta_l_alt)


def compute_confidence_measure(estimated_bpm,
                       duration_samples,
                       start_effective_duration,
                       end_effective_duration,
                       sample_rate=44100, beat_range=range(1, 128), k=0.5):
    if estimated_bpm == 0:
        # This condition is to skip computing other steps if estimated bpm is 0, we already know that the
        # output will be 0
        return 0

    durations_to_check = [
        duration_samples,
        duration_samples - start_effective_duration,
        end_effective_duration,
        end_effective_duration - start_effective_duration
    ]

    beat_duration = (60.0 * sample_rate)/estimated_bpm
    L = [beat_duration * n for n in beat_range]
    thr_lambda = k * beat_duration
    confidences = list()
    for duration in durations_to_check:
        delta_l = min([abs(l - duration) for l in L])
        if delta_l > thr_lambda:
            confidences.append(0.0)
        else:
            confidences.append(1.0 - float(delta_l) / thr_lambda)
    return max(confidences)



loaded_classifiers = dict()


def confidence_measure_classifier(conf_1, data_item, dataset_short_name, depth):
    filename = 'tree_clf_%s_depth_%i.pkl' % (dataset_short_name, depth)
    if filename in loaded_classifiers:
        clf = loaded_classifiers[filename]
    else:
        clf = joblib.load(os.path.join(settings.TEMPO_ESTIMATION_OUT_PATH, filename))
        loaded_classifiers[filename] = clf
    features = ['analysis.FS_onset_rate_count.rhythm.onset_rate', 'analysis.FS_onset_rate_count.rhythm.onset_count']
    vector = list()
    for fpath in features:
        vector.append(vfkp(data_item, fpath))
    y = np.array(vector).reshape(1, -1)
    result = clf.predict(y)
    if result == 'good estimate':
        return conf_1
    else:
        return 0.0

