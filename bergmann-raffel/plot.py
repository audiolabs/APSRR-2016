'''
plot cqts
'''

import os
import sys
sys.path.append('midi-dataset')
import deepdish
import librosa
import feature_extraction
import matplotlib.pyplot as plt

def plot_mp3_cqt(filename):
    sr = feature_extraction.AUDIO_FS
    # load mp3 cqt from h5 file
    cqt_filename = os.path.join('data', 'mp3cqts', '%s.h5' % filename)
    cqt = deepdish.io.load(cqt_filename)
    plt.figure(figsize=(8,5))
    librosa.display.specshow(cqt, sr=sr, x_axis='frames', 
                             y_axis='cqt_note', fmin = librosa.core.midi_to_hz(feature_extraction.NOTE_START),
                             hop_length = feature_extraction.AUDIO_HOP)
    plt.title('CQT of mp3 file for %s' % filename)
    plt.tight_layout()
    plt.savefig(os.path.join('output', '%s_mp3.png' % filename))
    plt.clf()
    
def plot_mid_cqt(filename):
    sr = feature_extraction.MIDI_FS
    # load mid cqt from h5 file
    cqt_filename = os.path.join('data', 'midcqts', '%s.h5' % filename)
    cqt = deepdish.io.load(cqt_filename)
    plt.figure(figsize=(25,5))
    librosa.display.specshow(cqt, sr=sr, x_axis='frames',
                             y_axis='cqt_note', fmin = librosa.core.midi_to_hz(feature_extraction.NOTE_START),
                             hop_length = feature_extraction.MIDI_HOP)
    plt.title('CQT of midi file for %s' % filename)
    plt.tight_layout()
    plt.savefig(os.path.join('output', '%s_mid.png' % filename))
    plt.clf()
    
def plot_dist_matrix(filename):
    mat_filename = os.path.join('data', 'distance_matrices', '%s.h5' % filename)
    dist_mat = deepdish.io.load(mat_filename)
    plt.figure(figsize=(25,8))
    plt.matshow(dist_mat)
    plt.title('CQT Distance Matrix %s' % filename)
    plt.savefig(os.path.join('output', '%s_distance.png' % filename))
    plt.clf()
    
    
if __name__ == '__main__':
    with open('lists/songlist.txt') as songlist:
        songs = songlist.read().splitlines()
    filenames = [song.replace(" ", "_").lower() for song in songs]
    for filename in filenames:
        plot_mp3_cqt(filename)
    for song in songs:
        plot_mid_cqt(song)
    for filename in filenames:
        plot_dist_matrix(filename)