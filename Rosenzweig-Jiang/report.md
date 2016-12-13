# Report "Analyzing Chroma Feature Types for Automated Chord Recognition"

## About
- Author of paper: Nanzhu Jiang et al.
- Author of report: Sebastian Rosenzweig
- Supervisor: Christof Weiß
- Audio Processing Seminar WS 2016/2017
- Reproduction of Tb-graph of figure 4 (page 8)

## Requirements
Recommended: MATLAB 2016b or higher

Minimum: MATLAB 2011a

## Installation

### Download and prepare tools/dataset
Execute download.m

This will download and extract the dataset and the Chroma Toolbox in given folder structure.

If you use a MATLAB version before 2012b please convert all mp3 files to wav files (Samplingrate: 22050Hz) with a converter of your choice, e.g. ffmpeg!

### Process results
Execute ReproduceTbFigure4.m

This will reproduce the Tb-graph of figure 4 in paper.

Execution time: This may take about 30 Minutes

## Evaluation of reproducability
The reproducability of the given paper will be evaluated in the following using the criteria of "Reproducible Research in Signal Processing - What, why, and how" by Vandewalle et al. (https://infoscience.epfl.ch/record/136640/files/VandewalleKV09.pdf).

### Reproducibility of the algorithm
- Is the algorithm described in sufficient detail?
	- 1 Point: Yes, although it takes some time to implement the details 
- Are exact parameter values given?
	- 1 Point: Yes
- Is there a block diagram?
	- 0 Points: No
- Is there a pseudocode?
	- 0.5 Points: Demo script available for Chroma Toolbox; Overall procedure is described in paper
- Are there proofs for all the theorems?
	- 1 Point: Not in the paper directly, but one can find them in the sources
- Is the algorithm compared to other algorithms?
	- 0.5 Points: Proposed algorithms are compared among each other


### Reproducibility of the code
- Are implementation details (programming language, platform, compiler flags, etc.) given?
	- 0.5 Points: MATLAB as programming language not explicitly recommended in paper
- Is the code available online?
	- 0 Points: Only the Chroma toolbox is available online, not the code for reproducing the figure


### Reproducibility of the data
- Is there an explanation of what the data represents?
	- 1 Point: Yes
- Is the size of the data set acceptable?
	- 1 Point: Yes, 180 songs
- Is the data set available online?
	- 0.5 Points: Yes, but hard to find. No explicit link to data is given!


### Summary
**Reproducability of algorithm:** Better compared to reference papers (table 1)

**Reproducability of Code:** Equal to reference in paper

**Data:** Better compared to references

**Issues which occurred during evaluation:**
- Chroma Toolbox is not mentioned in paper (it has not been released at the time the paper was written), though, this toolbox is essential to reproduce the paper (saves hours of work)!!!
- folder structure of dataset is unhandy and has to be dissolved
- audio files are in mp3 format and might have to be converted when using older MATLAB versions
- chord labels/annotations are in ASCII/lab format -> unusual, CSV is preferred and easier to process
- chord labels contain more than just minor and major chords -> chord labeler had to be implemented that maps all chords to major/minor/none chords
- song 'Ask_me_why.mp3' hat to be excluded, because time interval in chord annotation was missing

**Work:** ~25h

**Results:** The F-measure results differ slightly from the ones in the paper (s. Table below). One possible reason could be a different parameter setting used by the authors.

|            | Tb Paper | Tb Reproduced | Difference |
|------------|:--------:|:-------------:|:----------:|
| CP         |   0.460  |     0.435     |    0.025   |
| CLP[1]     |   0.508  |     0.472     |    0.036   |
| CLP[10]    |   0.544  |     0.501     |    0.043   |
| CLP[100]   |   0.553  |     0.505     |    0.048   |
| CLP[1000]  |   0.541  |     0.493     |    0.048   |
| CLP[10000] |   0.521  |     0.472     |    0.049   |

**Degree of reproducability:**

With background knowledge: **3** - The results can be reproduced by an independent researcher, requiring considerable effort.

Without background knowledge: **2** - The results could be reproduced by an independent researcher, requiring extreme effort.