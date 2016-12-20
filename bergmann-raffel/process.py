'''
create cqts for mp3 files
'''

import os
import sys
sys.path.append("midi-dataset")
import feature_extraction
import pretty_midi
import librosa
import deepdish
import scipy

def process_mp3(filename):
    mp3_filename = os.path.join('data', 'mp3', filename)
    sr = feature_extraction.AUDIO_FS
    #load the mp3 file
    audio_data, _ = librosa.load(mp3_filename, sr=sr)
    cqt = feature_extraction.audio_cqt(audio_data)
    cqt = librosa.logamplitude(cqt, ref_power=cqt.max())
    cqt = librosa.util.normalize(cqt, norm=2., axis=0)
    #create the output folder if it doesn't exist
    if not os.path.exists(os.path.join('data','mp3cqts')):
        os.makedirs(os.path.join('data','mp3cqts'))
    output_filename = os.path.join('data','mp3cqts',filename.replace('.mp3', '.h5'))    
    deepdish.io.save(output_filename, cqt)
    return cqt

def process_mid(filename):
    mid_filename = os.path.join('data', 'mid', filename)
    mid_data = pretty_midi.PrettyMIDI(mid_filename)
    cqt = feature_extraction.midi_cqt(mid_data)
    cqt = librosa.logamplitude(cqt, ref_power=cqt.max())
    cqt = librosa.util.normalize(cqt, norm=2., axis=0)
    if not os.path.exists(os.path.join('data','midcqts')):
        os.makedirs(os.path.join('data','midcqts'))
    output_filename = os.path.join('data','midcqts',filename.replace('.mid', '.h5'))    
    deepdish.io.save(output_filename, cqt)
    return cqt   
    
def distance_matrix(mp3cqt, midcqt, title):
    dist_matrix = scipy.spatial.distance.cdist(mp3cqt.T, midcqt.T, 'cosine')
    if not os.path.exists(os.path.join('data','distance_matrices')):
        os.makedirs(os.path.join('data','distance_matrices'))
    output_filename = os.path.join('data','distance_matrices', "%s.h5" % title)
    deepdish.io.save(output_filename, dist_matrix)
    
    
if __name__ == '__main__':
    with open('lists/songlist.txt') as songlist:
        songs = songlist.read().splitlines()  
    for song in songs:
        filename = song.replace(" ", "_").lower()
        mp3_cqt = process_mp3('%s.mp3' % filename)        
        mid_cqt = process_mid('%s.mid' % song)
        distance_matrix(mp3_cqt, mid_cqt, filename)
    