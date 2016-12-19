# Title "Repeating Pattern Extraction Technique (REPET): a simple method for voice/source separation"

## About
- Author of paper: Zafar Rafii, Bryan Pardo
- Author of report: Arjola Hysneli
- Audio Processing Seminar WS 2016/2017


## Requirements
Recommended: 
* MATLAB 2015a
* Windows 7

## Download tools/dataset and process results 

1.Execute 'download_install.bat'

* The file is found in the 'dataset' folder.
* The script downloads WinRAR(used to extract the dataset needed) and extracts the audio files used (MIR-1K set).

2.Execute repetSem.m 

* The REPET method is used to separate the repeating background(music) from a non-repeating foreground. 
* Further 'bss_eval' toolbox is used to measure the performance in source separation. 
* This will reproduce the SDR values for three voice-to-music ratios(-5,0,5).



## Reproducional research study
Reference on: "Reproducible Research in Signal Processing - What, why, and how" by Vandewalle et al. (https://infoscience.epfl.ch/record/136640/files/VandewalleKV09.pdf).
According to the evaluation steps considered in the paper, in the following part the reproduction level of 'REPET,  simple method for sound/music separation' is explained.

### Reproducibility of the algorithm
- Is the algorithm described in sufficient detail?
	- 1 Point: Yes
- Are exact parameter values given?
	- 1 Point: Yes(The voice-to-music mixing ratio)
- Is there a block diagram?
	- 0 Points: No
- Is there a pseudocode?
	- 0 Points: No
- Are there proofs for all the theorems?
	- 0 Point: There is no theorem to be proved,but every step is explained mathematically in details.
- Is the algorithm compared to other algorithms?
	- 1 Points: Yes, it is compared to 1. Hsu et al.
                                           2. Durrieu et al.
                                           3. Durrieu+ Highpass filtering
                                           4. REPET + highpass filtering

### Reproducibility of the code
- Are implementation details (programming language, platform, compiler flags, etc.) given?
	- 1 Points:  programming language: MATLAB 
- Is the code available online?
	- 0.5 Points: There is no code available for the reproduction of the figure (just the REPET code and the evaluation toolbox)


### Reproducibility of the data
- Is there an explanation of what the data represents?
	- 1 Point: Yes (also the results of the comparison with the different methods are given)
- Is the size of the data set acceptable?
	- 0.5 Point: In my opinion it is too big (1000 songs)
- Is the data set available online?
	- 1 Points: Yes, it is easy to access (MIR-1K)!

### Summary

**General remarks on the reproductivity:**
- By excuting bss_eval as an output SDR is generated. In paper, when using the competetive method 1 the results are given in terms of GNSDR --> means can't reproduce Fig.2
- The dataset used is in .rar format. (Since matlab toolbox doesn't contain the unrar function, it is difficult create the download.m file to automatially uncompress the sounds used. )
- The codes of the competetive methods used are not provided.
- Boxplot command used to plot the graphs is not available without the Statistics and Machine Learning Toolbox
- Both codes(REPET & bss_eval) provided were reproducable (but since the number of songs used is high, it requires more time to execute the codes)



**Degree of reproducability:**

 **3** - The results can be reproduced by an independent researcher, requiring considerable effort.


