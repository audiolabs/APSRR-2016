@echo off
set mypath=%cd%
cd %mypath%\dataset
MKDIR wavFiles
python modalexport onsets1.1.hdf5 wavFiles
pause