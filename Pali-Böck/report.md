# Maximum Filter Vibrato Suppression for Onset Detection

## Report Instructions

*** Installation
To install the toolkit published with the paper, run: 
	git clone git@github.com/CPJKU/SuperFlux
	pip install -r requirements.txt

*** Download the dataset
    ./download.bat
	Copy the onsets1.1.hdf5 from your local C:\Temp folder -> to the /dataset folder
**** Get the wav data from onsets1.1.hdf5
	./dataset/getwav.bat

*** Run the .py file to read the wavFiles from the created folder on /dataset
	python readFiles.py
		-on the same folder will be created a new file (fileList) which contains the names of wavFiles to be evaluated
		
*** Evaluation
	./run.bat
			Short note: This batch file goes to 'code' folder and runs the runSuperflux.py file ~ explanation of the runSuperflux.py on README on code Folder
	
*** Output
	The output files containing the onset detection for each file will be saved on /output/resultOnsets

During the evaluation of the paper "Maximum Filter Vibrato Suppression for Onset Detection" I came across the following issues:
- The file SuperFlux.py doesn't work on Python 3.5 version
