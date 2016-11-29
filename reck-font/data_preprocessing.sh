#!/usr/bin/env bash

# Alternatively a shell script that invokes several other Python scripts is
# possible. You should aim for as few commands as possible.

#create folder structure for database
mkdir ismir2016/data/FSL4
mkdir ismir2016/data/FSL4/audio

#convert audio data to mono wavs
python ismir2016/scripts/convert_audio_files_to_wav.py FSL4/audio/original --outdir ismir2016/data/FSL4/audio

#change the metadata.json wav file path to match the users path
dot="$(cd "$(dirname "$0")"; pwd)"
path1="$dot/ismir2016/data/FSL4/audio"
path2="$dot/ismir2016/data/FSL4"
sed -i -e "s#/Users/ffont/ResearchRepos/ffont-ismir2016/data/fsdataset/audio/wav#${path1}#g" FSL4/metadata.json

#copy the json file to the required directory
cp FSL4/metadata.json $path2

#edit the evaluation notebook to match the given dataset name and the algorithms wished to be displayed
sed -i -e "s#'freesound_loops_db_4000', 'apple_loops_db', 'mixcraft_loops_db', 'looperman'#'FSL4'#g" 'ismir2016/Tempo estimation results.ipynb'
sed -i -e "s# 'Bock15ACF', 'Bock15DBN,'##g" 'ismir2016/Tempo estimation results.ipynb'
