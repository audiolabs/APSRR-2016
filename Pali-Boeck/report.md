# Maximum Filter Vibrato Suppression for Onset Detection
- Reproducible Audio Research 
- Audio Processing Seminar 2016-2017

## Requirements
- OS: Windows 10 
- Python 2.7.0
- Anaconda 2.4.0
  Other optional packages on requirements.txt 

## The reproducibility of this paper is designed to be completed in three basic steps:
### On the main folder, run:
	 1. ./download.bat  
	 2. ./getwav.bat
	 3. ./run.bat
  
## Instructions

### Installation
To install the toolkit published with the paper, run: 
* git clone git@github.com/CPJKU/SuperFlux
* pip install -r requirements.txt

### Download the dataset
The second most important step, is to download the dataset. This can be done by running the following file: 
* ./download.bat

####  The downloaded dataset is in hdf5 format. In order to extract the .wav files from onsets1.1.hdf5, run:
* ./getwav.bat

####  In the following steps, we need to use these .wav files as an input to the SuperFlux file. 
- In order to get file names from wavFiles/dataset, another command is included in getwav.bat
	 - python readFiles.py

- This command runs the script: readFiles.py. 
- As a result,on the same folder will be created a new file (named: fileList) which contains the names of wavFiles to be evaluated
		
## Evaluation
- The final step is to run the SuperFlux, in order to evaluate the onset detection: 
	 - ./run.bat
- This batch file goes to /code folder and runs the runSuperflux.py file 
- A detailed explanation of the runSuperflux.py can be found on ./code/README.md
	
### Output
The output files containing the onset detection for each file will be saved on 
	 - /output/resultOnsets
	
### Issues
During the evaluation of the paper "Maximum Filter Vibrato Suppression for Onset Detection" I came across the following issues:
	 - The file SuperFlux.py doesn't work on Python 3.5 version

### Reproducibility
[4] Can be reproduced, requiring considerable effort.
* Evaluation of the reproducibility considering a basic knowledge of Python
		

