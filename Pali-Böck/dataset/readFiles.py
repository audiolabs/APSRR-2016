# -*- coding: utf-8 -*-
"""
Created on Sun Dec  4 12:28:23 2016

@author: perdorues
"""
# -*- coding: utf-8 -*-
mypath = 'Pali-Böck/dataset/wavFiles'

from os import listdir
from os.path import isfile, join
file_list = [f for f in listdir(mypath) if isfile(join(mypath, f))]

myfile = open('fileList.txt', 'w')

for i in file_list:
    myfile.write(" %s" % i)
    
myfile.close()