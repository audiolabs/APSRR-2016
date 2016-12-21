## Getting the wav files from 'Musical Onset Database And Library (Modal)'

* #### From the repository of the modal library: [modal](https://github.com/johnglover/modal]) -> get the *modalexport* file

* #### On download section - get the .hdf5 format file: [onsets1.1](http://dl.dropbox.com/u/9444913/onsets1.1.hdf5)

*Side Note*: the file can be automatically downloaded also from download.bat file on /Pali-Boeck

* #### When using the download.bat file, the onsets1.1.hdf5 file will be directly downloaded into the dataset folder
*Side Note*: If the download is computed manually, please copy the onsets1.1.hdf5 into the /dataset folder
   
* #### After the execution of getwav.bat file, on wavFiles folder will be saved the .wav files taken from the hdf5 format 

*Side Note:* I commented out the part on the code wich gets the yaml representer, since I got as an output only one of the wav files and the following error:
  ```
  File "~\Anaconda3\lib\site-packages\yaml\representer.py", line 229, in represent_undefined
    raise RepresenterError("cannot represent an object: %s" % data)
yaml.representer.RepresenterError: cannot represent an object: [161]
  ```

------------------------------------------------------------------------

#### *readFiles.py* script reads the names of wav Files which are going to be the input for the batch mode in SuperFlux

------------------------------------------------------------------------