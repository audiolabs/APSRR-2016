#!/usr/bin/env bash

# You should use curl(1) or wget(1) to download the data automatically

# Extract the data using unzip(1) or unrar(1)

mkdir -p data/msd
mkdir -p data/unique_midi/mid
mkdir -p data/clean_midi/mid

#wget "http://hog.ee.columbia.edu/craffel/lmd/lmd_full.tar.gz" -P "data/unique_midi/mid"
#wget "http://hog.ee.columbia.edu/craffel/lmd/clean_midi.tar.gz" -P "data/clean_midi/mid"
wget "http://static.echonest.com/millionsongsubset_full.tar.gz" -P "data/msd"

#tar -xzf data/unique_midi/mid/lmd_full.tar.gz -C data/unique_midi/mid
#tar -xzf data/clean_midi/mid/lmd_full.tar.gz -C data/clean_midi/mid
tar -xzf data/msd/millionsongsubset_full.tar.gz -C data/msd

# rm data/unique_midi/mid/lmd_full.tar.gz
# rm data/clean_midi/mid/clean_midi.tar.gzbset_full.tar.gz
rm data/msd/millionsongsubset_full.tar.gz

