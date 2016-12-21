@echo off

python dataset/modalexport dataset/onsets1.1.hdf5 dataset/wavFiles

python dataset/readFiles.py

pause