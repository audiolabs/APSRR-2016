Getting the wav files from 'Musical Onset Database And Library (Modal)'
-----------------------------------------------------------------------

- Get repository https://github.com/johnglover/modal 

- On download section - get the .hdf5 format file: http://dl.dropbox.com/u/9444913/onsets1.1.hdf5

- Exectute modalexport.py with the following syntax on Prompt:

python modalexport fileName.hdf5 outputDirectory wavFileName
wavFileName is optional, in case we want to extract only a known wavFile, rather than all Files

Side Note: I commented out the part on the code wich gets the yaml representer, since I got as an output only one of the wav files and the following error:
  File "C:\Users\perdorues\Anaconda3\lib\site-packages\yaml\representer.py", line 229, in represent_undefined
    raise RepresenterError("cannot represent an object: %s" % data)
yaml.representer.RepresenterError: cannot represent an object: [161]

or use getwav.py script (which has the same function as mentioned above)
------------------------------------------------------------------------

readFiles.py - serves as a script to read the names of wav Files in a Folder in order to Pass them 
as an argument for the batch mode in SuperFlux

------------------------------------------------------------------------