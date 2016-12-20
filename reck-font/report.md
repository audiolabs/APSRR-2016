# Report on the reproducibility of "Tempo Estimation for Music Loops and a Simple Confidence Measure"

This is a reproduction of the paper "Tempo Estimation for Music Loops and a Simple Confidence Measure" from Frederic Font and Xavier Serra for the Audiolabs Audio Processing Seminar WS 2016/2017 by Julian Reck.

## Installation

### System Setup and Requirements

* OS:	Ubuntu 16.04.1 LTS

* Python 2.7.12

* Software and packages needed are listed in requirements.txt

### Installation

To download this repository and install the required python packages run:

    git clone https://github.com/faroit/APSRR-2016.git
    cd APSRR-2016/
    cd reck-font/
    pip install -r requirements.txt
    
Despite the python packages, the software listed in requirements needs to be installed manually.

### Download Dataset

    ./download.sh

### Preprocess Dataset

    ./data_preprocessing.sh

### Analyse Dataset   

    ./run_analysis.sh

### Evaluation

    ./evaluation.sh

The figures 2-4 from the paper, will be saved as 'Figure2.png', 'Figure3.png' and 'Figure4.png'.


## Evaluation

During the evaluation of the paper "Tempo Estimation for Music Loops and a Simple Confidence Measure" I came across the following issues:

* If the database FSL4 is downloaded via the provided link from the authors, the metadata json file contains fixed path names from the authors, leading to errors 

* Typo in the the script analysis_algorithms.py leads to errors in the evaluation


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

Before: 4. Can be reproduced, requiring considerable effort.

After: 5. Can be easily reproduced with at most 15 minutes of user effort, requiring some proprietary source packages.


