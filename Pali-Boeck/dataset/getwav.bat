@echo off
python dataset/modalexport dataset/onsets1.1.hdf5 dataset/wavFiles/
MKDIR wavFiles
python modalexport onsets1.1.hdf5 wavFiles
pause