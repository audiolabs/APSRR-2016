# Maximum Filter Vibrato Suppression for Onset Detection
- Reproducible Audio Research 
- Audio Processing Seminar 2016-2017

## Requirements
- OS: Windows 10 
- Python 2.7.0
- Anaconda 2.4.0
- Git 2.11.0
- [Microsoft Visual C++ Compiler for Python 2.7](http://www.microsoft.com/en-us/download/confirmation.aspx?id=44266)
- Other optional packages on `requirements.txt`

## The reproducibility of this paper is designed to be completed in three basic steps:
##### On the main folder, run: <br />
	 1. download.bat 
	 2. getwav.bat 
	 3. run.bat 
  
## Instructions

## 1. Installation
To install the required packages to reproduce the paper, run: 
* `pip install -r requirements.txt`

- *Side Note* on `requirements.txt`: In order to get all the packages mentioned on the requirements file, please run: 
* `pip install Cython==0.24.1`
* `pip install -r requirements.txt`

### 1.1. Download the dataset 
The second most important step, is to download the dataset. This can be done by running the following file: 
* `download.bat`
* In the .bat script, the command to get toolkit published with the paper is included as well:
	* `git clone git@github.com/CPJKU/SuperFlux`

### 1.2. Retreave the annotations
Furthermore by running the `download.bat` file, we retreive the annotation onsets by the command:
* `git clone https://github.com/CPJKU/onset_db`

## 2. The downloaded dataset is in hdf5 format. 
In order to extract the .wav files from `onsets1.1.hdf5`, run:
* `getwav.bat`

###  2.1. Read wav Files
In the following steps, we need to use these .wav files as an input to the SuperFlux file. 
- In order to get file names from `wavFiles/dataset`, another command is included in `getwav.bat`
	 - `python readFiles.py`

- This command runs the script: `readFiles.py`. 
- As a result, on the same folder will be created a new file (named: `fileList`) which contains the names of wavFiles to be evaluated
- In this script is inlcuded the functionality to automatically move the respective annotations of the used dataset -> to the `/output/annotations` folder
		
## 3. Onset Detection
- The final step is to run the SuperFlux, in order to get the onset detections: 
	 - `run.bat`
- This batch file goes to `/code` folder and runs the `runSuperflux.py` file 
- A detailed explanation of the `runSuperflux.py` can be found on `/code/readme_code.md`
- The SuperFlux offers also the online onset detection. This is achieved by adding `--online` option to the SuperFlux
	 - `run_online.bat`
	
# Output
The output files containing the onset detection for each file and for each method will be saved on:
- `/output/resultOnsets`
- `/output/resultOnsetsOnline`
	
#Evaluation
**Up to this step, we have:**
1. Retreived and converted the dataset
2. Detected the onsets for the available dataset in two ways: offline and online method
3. Saved the results to the /output folder

#### The remaining step is to evaluate the results. 
According to the paper the Superflux algorithm is estimated based on: <br />
**Precision; Recall; F-measure**

- In order to compute these measurements, the module **onsets** on **madmom** library is used. 
- In the output folder, there are two python scripts, namely: `evaluation.py` and `evaluation_online.py` which compute these measurements for the offline and online methods
- Each of the scripts is called by the respective `run` batch file: `run.bat` and `run_online.bat`
- As a result, two output files will be created: `outputEval.txt` and `outputEvalOnline.txt`
- Each of latter files contains results of: Precision; Recall; F-measure for each of the .wav files
*Side Note*: in order to estimate the accuracy of the algorithm, the files of the onset detections are compared to the respective annotations
 which are [freely available](https://github.com/CPJKU/onset_db)
- In our case, since not the full dataset of the paper is used, the respective annotations for the used dataset can be found at: `Pali-Boeck/output/annotations`

#### In the following, the results are included in a table:

|                | Precision | Recall |F-measure|
|----------------|-----------|--------|---------|
| Offline        | 0.360     | 0.402  | 0.254   |
| Online         | 0.244     | 0.548  | 0.229   |

**Here must be noted that there are some differences to the actual results of the paper. One of the possible reasons can be the different dataset used for the evaluation. In this case, the freely available dataset is used.**

### Issues
During the evaluation of the paper "Maximum Filter Vibrato Suppression for Onset Detection" I came across the following issues:
 - The file SuperFlux.py doesn't write the output files (onset detections) on Python 3.5 version

### Reproducibility
[4] Can be reproduced, requiring considerable effort.
* Evaluation of the reproducibility considering a basic knowledge of Python

#### Easy to reproduce parts
* The evaluation of the accuracy of the algorithm was one of the easiest part to reproduce. The evaluation is done through the madmom library, by `madmom.evaluation.onsets` module. When running the included classes, one have to take care only for the correct respective inputs. 

#### Difficult to reproduce parts
* One of the difficulties on the SuperFlux reproduction, are the output results. 
	* As mentioned on the issues as well, SuperFlux works only on Python 2.7. No output is received when runned on Python 3.5. So we can conclude that for Python 3.5. SuperFlux needs some fixes. 
* Furthermore, the available dataset of the paper is not complete. This is a drawback for the final and accurate results. 
* Many libraries had to be used to reproduce the results. This takes time to find the appropriate module/classes and their respective functionality. 

#### Parts that needed fixing
* While converting the .hdf5 file to different .wav files, on the `modalexport` file I commented out the part on the code wich gets the yaml representer, since I got as an output only one of the wav files and the following error: <br />
  ```
  File "~\Anaconda3\lib\site-packages\yaml\representer.py", line 229, in represent_undefined
    raise RepresenterError("cannot represent an object: %s" % data)
yaml.representer.RepresenterError: cannot represent an object: [161]
  ```
