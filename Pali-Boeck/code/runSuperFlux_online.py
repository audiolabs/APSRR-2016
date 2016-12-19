# -*- coding: utf-8 -*-
"""
Created on Sun Dec 11 13:09:18 2016

@author: OrnelaP
"""

"""This script executes SuperFlux.py and saves the onset files to a new folder"""

import SuperFlux
import os
import os.path
import shutil
from subprocess import call

my_path = os.path.abspath(os.path.join(os.pardir, 'Pali-Boeck'))

newPath = os.path.join(my_path, 'output/resultOnsetsOnline')

if not os.path.exists(newPath):
    os.makedirs(newPath)

readPath = os.path.join(my_path, 'dataset/fileList.txt')
filesPath = os.path.join(my_path, 'dataset/wavFiles')

wavFiles = open(readPath, 'r')

inFlux = wavFiles.read().split()

for i in inFlux:
    call('python code/SuperFlux.py -s --online ' + os.path.join(filesPath, i))

wavFiles.close()

files = os.listdir(filesPath)
for f in files:
    if f.endswith(".jpg", 0, len(f)):
         #print(f)
         os.remove(os.path.join(filesPath, f))          
    if f.endswith(".superflux.txt", 0, len(f)):
         #print(f)
         shutil.move((os.path.join(filesPath, f)), newPath)