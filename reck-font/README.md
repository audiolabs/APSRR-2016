# Reproduction of "Tempo Estimation for Music Loops and a Simple Confidence Measure"

This is a reproduction of the paper "Tempo Estimation for Music Loops and a Simple Confidence Measure" with only the FSL4 database used.

## Requirements

### System Setup

* OS:	Ubuntu 16.04.1 LTS

* Python 2.7.12

* Software and packages needed are listed in requirements.txt


## Instructions

###Installation

To install the codebase, run

    git clone git@github.com/reckjn/APSRR-2016.git
    cd APSRR-2016/
    pip install -r requirements.txt

### Download Dataset

    ./download.sh

### Preprocess Dataset

    ./data_preprocessing.sh

### Analyse Dataset   

    ./run_analysis.sh

### Evaluation

    ./evaluation.sh

The figures 2-4, which correspond to the figures from the paper, will be saved as 'Figure2.png', 'Figure3.png' and 'Figure4.png'.


