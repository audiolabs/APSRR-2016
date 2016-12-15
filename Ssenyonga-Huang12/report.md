# Singing-Voice Separation From Monaural Recordings Using Robust Principal Component Analysis 

This is a report on the reproducibility of the above paper by Huang et al. by Robin Ssenyonga for the Audio Processing Seminar 2016/17. The aim of this project was to reproduce the evaluation results plots of the paper.

## Installation

### Installation

Use at least MATLAB_R2012b

### Download Dataset and preprocess data

Execute download.sh.

### Process results

Run rpca_mask_script.m (assuming all included code and dataset are downloaded). 

Execution time: This takes a long time, so it might need some code optimisation or use of the parallel computing toolbox.

### Evaluation

The resulting figures (in output/figures) are meant to be the ones on the last two pages of the paper.

## Evaluation

During the evaluation of the paper *Singing-Voice Separation From Monaural Recordings Using Robust Principal Component Analysis* I came across the following issues:
- I had an initial issue with automatic download of the dataset and codes using MATLAB so went for the manual option. This part has been resolved though.
- The code uploaded was meant to be a demo so was lacking in many ways, I had to adapt the script and add many other components.
- I was originally unfamiliar with the dataset so was confused about how to extract the different SNRs.
- It is a really huge dataset and I have been running the code for the whole dataset for a long time.

## Reproducible research study

### Reproducibility of the algorithm
- Is the algorithm described in sufficient detail? 1
- Are exact parameter values given? 0.5
- Is there a block diagram? 1
- Is there a pseudocode? 0.5 ( demo script for one file, no plots)
- Are there proofs for all the theorems? 1
- Is the algorithm compared to other algorithms? 1


### Reproducibility of the code
- Are implementation details (programming language, platform, compiler flags, etc.) given? 1
- Is the code available online? 0.5, only a demo

### Reproducibility of the data
- Is there an explanation of what the data represents? 1
- Is the size of the data set acceptable? 1
- Is the data set available online? 1


### My version
**Reproducibility of algorithm:** Same as the original paper

**Reproducibility of Code:** It is better reproducible compared to the original paper

**Data:** More files for the demo ,i.e. user-defined compared to 2, with an option to use all files (1000), so better in that sense

**Degree of reproducibility:**

Before: **3** - The results can be reproduced by an independent researcher, requiring considerable effort. For the exact plots, this requires patience too since the dataset is very large.

After: **4** - The results can be easily reproduced by an independent researcher with at most 15 minutes of user effort, requiring some proprietary source packages, i.e. MATLAB.
