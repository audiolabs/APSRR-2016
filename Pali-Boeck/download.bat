@echo off
bitsadmin /create downloadJob
bitsadmin /transfer downloadJob /download /priority normal http://dl.dropbox.com/u/9444913/onsets1.1.hdf5 %cd%/dataset/onsets1.1.hdf5

git clone https://github.com/CPJKU/onset_db

pause