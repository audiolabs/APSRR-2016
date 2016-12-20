# Report on the reproducibility of "Tempo Estimation for Music Loops and a Simple Confidence Measure"

This is a reproduction of the paper "Tempo Estimation for Music Loops and a Simple Confidence Measure" from Frederic Font and Xavier Serra for the Audiolabs Audio Processing Seminar WS 2016/2017 by Julian Reck.

## Installation

### System Setup and Requirements

* OS:	Ubuntu 16.04.1 LTS

* Python 2.7.12

* Software and packages needed are listed in requirements.txt

### Installation

To download this toolkit and install the required python packages run:

    git clone https://github.com/faroit/APSRR-2016.git
    cd APSRR-2016/
    cd reck-font/
    pip install -r requirements.txt
    
Despite the python packages, the software listed in requirements.txt needs to be installed manually.

### Download Dataset

    ./download.sh
    
Downloads the code from the paper and the Freesound loop database (FSL4).

### Preprocess Dataset

    ./data_preprocessing.sh
    
Preprocesses the data, creates folder structure and fixes some errors in the code from the authors.

### Analyse Dataset   

    ./run_analysis.sh
    
Analyses the FSL4 dataset with all the tempo estimation algorithms used in the paper.

### Evaluation

    ./evaluation.sh

The figures 2-4 from the paper, will be saved as 'Figure2.png', 'Figure3.png' and 'Figure4.png'.


## Evaluation

During the evaluation of the paper "Tempo Estimation for Music Loops and a Simple Confidence Measure" I came across the following issues:

* Setting up and working with a Linux system takes effort, but things work much easier than on Windows once you get used to it

* Installing python packages is pretty cumbersome without pip install -r requirements.txt, which I unfortunatly didn't know about before

* The installation of the codebase from the paper is very well described with only a few exceptions

* If the database FSL4 is downloaded via the provided link from the authors, the metadata json file contains fixed path names from the authors, leading to errors, which i fixed with a script

* All python algorithms except Gkiokas12 were easily runable. Gkiokas12, which was written with octave, took a bit longer to install.

* Due to the big dataset, computation time is high, especially for the Gkiokas12. Without parallelization it took about 18 hours. 

* A Typo in the the script analysis_algorithms.py leads to errors in the evaluation

* The evaluation scripts are nicely written with iPhyton notebooks, but for a simpler extraction of the result plots, I converted it to a python script, which saves the desired plots as pngs

## Reproducibility

### 1) Reproducibility of the algorithm

a) Is the algorithm described in sufficient detail? 1

b) Are exact parameter values given? 1

c) Is there a block diagram? 0

d) Is there a pseudocode? 0

e) Are there proofs for all the theorems? 0

f) Is the algorithm compared to other algorithms? 1


### 2) Reproducibility of the code

a) Are implementation details (programming language,

platform, compiler flags, etc.) given? 1

b) Is the code available online? 1


###  3) Reproducibility of the data

a) Is there an explanation of what the data represents? 1

b) Is the size of the data set acceptable? 1

c) Is the data set available online? 0.5


## Degree of Reproducibility

Without this toolkit: 

* 4. Can be reproduced, requiring considerable effort.

With this toolkit: 

* 5. Can be easily reproduced with at most 15 minutes of user effort, requiring some proprietary source packages.


