#!/usr/bin/env bash

# run analysis with all algorithms, takes approximatly 18 hours without using parallelization methods like the authors proposed celery on Intel(R) Core(TM) i5-4670K CPU @ 3.40GHz
python ismir2016/scripts/analyze_dataset.py ismir2016/data/FSL4

# use --max_sounds 10 for testing with only 10 wav files
#python ismir2016/scripts/analyze_dataset.py ismir2016/data/FSL4 --max_sounds 10
