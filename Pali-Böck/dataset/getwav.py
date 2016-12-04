# -*- coding: utf-8 -*-
"""
Created on Sun Dec  4 20:45:29 2016
@author: perdorues
"""
import sys
import os
import h5py
import yaml
from scipy.io.wavfile import write
import numpy as np
sys.path.append('Pali-Böck/code')
import modalexport
directory = 'Pali-Böck/dataset'
fileName = os.path.join(directory, 'onsets.hdf5')

modalexport._extract_file(fileName, directory, None)