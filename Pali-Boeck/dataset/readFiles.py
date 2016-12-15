# -*- coding: utf-8 -*-
"""
Created on Sun Dec  4 12:28:23 2016

@author: OrnelaP
"""
# -*- coding: utf-8 -*-

import os.path
mypath = os.path.abspath(os.path.join(os.pardir, 'dataset/wavFiles'))

from os import listdir
from os.path import isfile, join
file_list = [f for f in listdir(mypath) if isfile(join(mypath, f))]

myfile = open('fileList.txt', 'w')

for i in file_list:
    myfile.write(" %s" % i)
    
myfile.close()