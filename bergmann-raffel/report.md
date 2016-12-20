# "Large-Scale Content-Based Matching of MIDI and Audio Files"

## About

- Paper author: Colin Raffel
- Report author: Michael Bergmann

## Evaluation

The Evaluation of the reproducability is based on 
"Reproducible Research in Signal Processing" by P. Vandewalle.
Since only figures 2(a), 2(b) and 2(e) are reproduced in this work, 
only the parts pertaining to those figures are evaluated. Some of
the results, e.g. concerning the dataset, can be applied to the paper as a whole.


### Code

The entire code for reproducing the end results of the paper is available online in a github repository.
Sadly the code for generating the figures is not part of the repository. As a result some modifications
and additions to the code were neccessary to aquire the plots.

The main problems:
- It is hard to extract the required data from the code since many code parts are not designed very flexible.
For example:

		def audio_cqt(audio_data):
			# Some computations
			return post_process_cqt(audio_gram)
	
	This processes the audio data and post-processes the resulting Constant-Q-Transform
	whenever audio_cqt is called. For the plotting of the CQT the signal before post-processing is 
	required, therefore the following change was needed:

		def audio_cqt(audio_data):
			# Some computations
			return audio_gram
	
	and then calling the function like:
		
		post_process_cqt(audio_cqt(audio_data))

- In some scripts function calls are made on all the datasets, without checking if the dataset is available.
This makes applying the given code to a smaller subset unneccessarily complicated.

Other issues for further analysis of the paper:
- The code is sometimes very specific towards the authors test environment. For Example: Parallelization
is done for a fixed number of processor cores. This complicates the reproduction of the results
on a different setup.

	
### Dataset

The acquisition dataset is the main problem in reproducing the results of the paper.
For the evaluation a set of MIDI files is required, as well as audio files corresponding to the 
Million Song Database.
The MIDI files are madeavailable by the author online.
The mp3 files have to be aquired from 7digital, an onlineshop for music. The 7digital API allows 
the download of 30-60 second preview clips of their songs.

The main problems:
- The code provided on the Million Song Database website to download preview clips from the 
7digital API is outdated, and the API has to be accessed in another way . 
- The 7digital API only allows 4000 requests per day for free users which means
for a million songs with 2 requests per song, downloading the dataset takes 500days.

### Results

The results produced in this work appear somewhat similar to the plots in the paper.
The differences may appear for several reasons:
- The paper does not state the exact way to reproduce the plots shown.
- The dataset might differ as the exact files are not referenced and th 7digital preview might have changed.

### Conlusion

1: The results cannot seem to be reproduced by an independent
researcher.

This is based on the fact that acquiring the dataset in a reasonable time is almost impossible using the
given free tools.