# "Large-Scale Content-Based Matching of MIDI and Audio Files"

## About

- Paper author: Colin Raffel
- Report author: Michael Bergmann

## Usage guide

### Setup

The required environment is described in the requirements.txt

To setup the environment install the given Software and run:

	pip install numpy
    pip install -r requirements.txt
	git clone https://github.com/bergmann-fau/midi-dataset
	
### Download Dataset and preprocess data
  
Please apply for a [7Digital API key](https://api-signup.7digital.com/) and set it like:
  
	export DIGITAL7_KEY=yourkey
	export DIGITAL7_SECRET=yoursecret
  
Run the following commands to download the dataset:

	./download.sh
	python download7digital.py

### Process results

To process the MIDI and mp3 files run:

	python process.py
	
To create the plots run:
	
	python plot.py
  
The plots are now placed in the output folder. For every Song there are 3 plots: One shows the CQT of the audio from the mp3 file, one shows the CQT from the MIDI file and one shows the distance matrix for the two CQTs.

## Evaluation

The Evaluation of the reproducability is based on "Reproducible Research in Signal Processing" by P. Vandewalle. Since only figures 2(a), 2(b) and 2(e) are reproduced in this work, only the parts pertaining to those figures are evaluated. Some of the results, e.g. concerning the dataset, can be applied to the paper as a whole.

### Code

The entire code for reproducing the end results of the paper is available online in a github repository. Sadly the code for generating the figures is not part of the repository. As a result some modifications and additions to the code were neccessary to aquire the plots.

The main problems:
- It is hard to extract the required data from the code since many code parts are not designed very flexible. For Example taken from [the authors repository](https://github.com/craffel/midi-dataset/blob/master/feature_extraction.py#L87) at line 87:

		def audio_cqt(audio_data):
			# Some computations
			return post_process_cqt(audio_gram)
	
	This processes the audio data and post-processes the resulting Constant-Q-Transform whenever audio_cqt is called. For the plotting of the CQT the signal before post-processing is required, therefore the following change was needed:

		def audio_cqt(audio_data):
			# Some computations
			return audio_gram
	
	and then calling the function like:
		
		post_process_cqt(audio_cqt(audio_data))

- In some scripts function calls are made on all the datasets, without checking if the dataset is available. This makes applying the given code to a smaller subset unneccessarily complicated.

Other issues for further analysis of the paper:
- The code is sometimes very specific towards the authors test environment. For Example:
	* Parallelization is done for a fixed number of processor cores. This complicates the reproduction of the results on a different setup.
	* The python code executes bash commands and can therefore only be executed on Unix Systems

	
### Dataset

The acquisition of the dataset is the main problem in reproducing the results of the paper. For the evaluation a set of MIDI files is required, as well as audio files corresponding to the Million Song Database.
The MIDI files are made available by the author online.
The mp3 files have to be aquired from 7digital, an onlineshop for music. The [7digital API](http://docs.7digital.com/) allows the download of 30-60 second preview clips of their songs.

The main problems:
- The [code](https://github.com/tbertinmahieux/MSongsDB/blob/master/Tasks_Demos/Preview7digital/get_preview_url.py#L181) provided on the Million Song Database website to download preview clips from the 7digital API is outdated, as the API call does not utilize OAuth, which was added by 7digital and the API has to be accessed in another way.
- The 7digital API only allows 4000 requests per day for free users which means for a million songs with 2 requests per song, downloading the dataset takes 500 days. 

### Results

Comparing Figure 2(a) and 2(b) from the Paper with the CQT plots for "Billy Idol - Dancing with myself" in the output folder one can see that the CQTs general form looks similar. The audio sample is taken from a different part of the song and the time axis is represented in frames not beats. This is due to the fact that in this work no beat information was retrieved.

When comparing the CQT distance matrix for the same song with Figure 2(e) similar effects can be observed. The general form of the CQT looks similar, the axis are again scaled differently.

While the results appear very similar to the paper, the differences show that a full reconstruction was not achieved, due to the aforementioned problems with the implementation.

### Conlusion

> 1: The results cannot seem to be reproduced by an independent
researcher.

This is based on the fact that acquiring the dataset in a reasonable time is almost impossible using the given free tools.
