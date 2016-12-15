# Maximum Filter Vibrato Suppression for Onset Detection
- Reproducible Audio Research 
- Audio Processing Seminar 2016-2017

## Requirements
- OS: Windows 10 
- Python 2.7.0
- Anaconda 2.4.0
  Other optional packages on requirements.txt 

# Instructions

## 1. Installation
To install the toolkit published with the paper, run: 
	```
	- git clone git@github.com/CPJKU/SuperFlux
	- pip install -r requirements.txt
        ```
### 2. Download the dataset
    ./download.bat
	
### 2.1. Get the wav data from onsets1.1.hdf5
	./dataset/getwav.bat

### 3. Run the .py file to read the wavFiles from the created folder on /dataset
	python readFiles.py
		-on the same folder will be created a new file (fileList) which contains the names of wavFiles to be evaluated
		
### 4. Evaluation
	./run.bat
			*Side note*: This batch file goes to 'code' folder and runs the runSuperflux.py file ~ explanation of the runSuperflux.py on README on code Folder
	
### 5. Output
	The output files containing the onset detection for each file will be saved on /output/resultOnsets
	
### 6. Issues
    During the evaluation of the paper "Maximum Filter Vibrato Suppression for Onset Detection" I came across the following issues:
- The file SuperFlux.py doesn't work on Python 3.5 version

###	7. Reproducibility
    4- Can be reproduced, requiring considerable effort.
