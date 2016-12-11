Getting the wav files from 'Musical Onset Database And Library (Modal)'
-----------------------------------------------------------------------

- From the repository of the modal library: https://github.com/johnglover/modal -> got the modalexport file

- On download section - get the .hdf5 format file: http://dl.dropbox.com/u/9444913/onsets1.1.hdf5
	Side Note: the file can be download also from download.bat file 

- Please input the onsets.hdf5 file into the dataset Folder

- Execute getwav.bat file

- Afterwards a new folder will be created (wavFiles) which contains all the .wav files

Side Note: I commented out the part on the code wich gets the yaml representer, since I got as an output only one of the wav files and the following error:
  File "C:\Users\perdorues\Anaconda3\lib\site-packages\yaml\representer.py", line 229, in represent_undefined
    raise RepresenterError("cannot represent an object: %s" % data)
yaml.representer.RepresenterError: cannot represent an object: [161]

------------------------------------------------------------------------

readFiles.py - serves as a script to read the names of wav Files in a Folder in order to Pass them 
as an argument for the batch mode in SuperFlux

------------------------------------------------------------------------