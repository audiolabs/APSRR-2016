# Bergmann-Raffel "Large-Scale Content-Based Matching of MIDI and Audio Files"


 This is an example report for the evaluation of a paper.

## Installation


* OS: Ubuntu 16.04.1
* Python 2.7.12

To install the toolkit published with the paper, run

    git clone git@github.com/bergmann-fau/APSRR-2016.git
    cd APSRR-2016/bergmann-raffel/
    pip install -r requirements.txt

additional requirements are:

	fluidsynth
	ffmpeg
	
	
	
## Download Dataset and preprocess data
  
Please apply for a 7Digital API key and set it like
  
	export DIGITAL7_KEY=yourkey
	export DIGITAL7_SECRET=yoursecret
  
run the following commands to download the dataset

	./gitProjects
	./download.sh
	python get7digital.py


## Process results

the following commands will process the data and create the plots in the APSRR-2016/bergmann-raffel/output folder
  
	python process_cqts.py
	python plot_cqts.py
  

## Evaluation

### Problems so far

