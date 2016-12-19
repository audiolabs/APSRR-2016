# Bergmann-Raffel "Large-Scale Content-Based Matching of MIDI and Audio Files"

## Setup

The required environment is described in the requirements.txt

To setup the environment install the given Software and run:

	pip install numpy
    pip install -r requirements.txt
	git clone https://github.com/bergmann-fau/midi-dataset
	
## Download Dataset and preprocess data
  
Please apply for a 7Digital API key and set it like:
  
	export DIGITAL7_KEY=yourkey
	export DIGITAL7_SECRET=yoursecret
  
Run the following commands to download the dataset:

	./download.sh
	python download7digital.py

## Process results

To process the MIDI and mp3 files run:

	python process.py
	
To create the plots run:
	
	python plot.py
  
The plots are now placed in the output folder.
For every Song there are 3 plots: One shows the CQT of the audio from the mp3 file,
one shows the CQT from the MIDI file and one shows the distance matrix for the two CQTs.
