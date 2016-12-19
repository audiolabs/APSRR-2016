# -*- coding: utf-8 -*-
"""
Created on Sun Dec  4 12:28:23 2016

@author: OrnelaP
"""
# -*- coding: utf-8 -*-
import shutil
import os.path
from os import listdir
from os.path import isfile, join

wavFilesPath = os.path.abspath(os.path.join(os.pardir, 'Pali-Boeck/dataset/wavFiles'))
annotationsPathPre = os.path.abspath(os.path.join(os.pardir, 'Pali-Boeck/onset_db'))
annotationsPathPost = os.path.abspath(os.path.join(os.pardir, 'Pali-Boeck/output/annotations'))

print annotationsPathPre
print annotationsPathPost

#Read the .wav files names into an output file
file_list = [f for f in listdir(wavFilesPath) if isfile(join(wavFilesPath, f))]

myfile = open(os.path.abspath(os.path.join(os.pardir,'Pali-Boeck/dataset/fileList.txt')), 'w')

for i in file_list:
    myfile.write(" %s" % i) 
myfile.close()

#Move the respective used dataset annotations to the output/annotations folder
annotations = os.listdir(annotationsPathPre)
for ann in annotations: 
    if ann.startswith('jg_', 0, len(ann)):
        shutil.move((os.path.join(annotationsPathPre, ann)), annotationsPathPost)
