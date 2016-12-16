# Reproduction of "Tempo Estimation for Music Loops and a Simple Confidence Measure"

This is a reproduction of the paper "Tempo Estimation for Music Loops and a Simple Confidence Measure" with only the FSL4 database used.

## Requirements

### System Setup

* OS:	Ubuntu 16.04.1 LTS

* Python 2.7.12

### Software needed
* FFmpeg

* Octave

* Vlc

* RekordBox
* Python Packages specified in requirements.txt

* Python Custom Package Essentia

## Instructions

###Installation

To install the codebase published with the paper, run

    git clone git@github.com/reckjn/APSRR-2016.git
    cd paper/
    pip install -r requirements.txt

### Download Dataset and preprocess data

   ./download.sh

### Preprocess Dataset

   ./data_preprocessing.sh

### Analyse Dataset   

   ./run_analysis.sh

### Evaluation

   ./run_analysis.sh


