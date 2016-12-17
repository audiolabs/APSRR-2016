mkdir -p midi-dataset/data/mp3
mkdir -p midi-dataset/data/mid

wget "http://hog.ee.columbia.edu/craffel/lmd/clean_midi.tar.gz" -P "midi-dataset/data/mid"

#echo "running in test mode"
#cp -a ../clean_midi.tar.gz midi-dataset/data/mid/clean_midi.tar.gz


cd midi-dataset/data/mid

tar --wildcards -xzf clean_midi.tar.gz "clean_midi/Michael Jackson/"*
tar --wildcards -xzf clean_midi.tar.gz "clean_midi/AC DC/"*
tar --wildcards -xzf clean_midi.tar.gz "clean_midi/Billy Idol/"*

cd "clean_midi/Michael Jackson"
rename "s/^/Michael Jackson /" *
cd "../AC DC"
rename "s/^/AC DC /" *
cd "../Billy Idol"
rename "s/^/Billy Idol /" *
cd ../../..

mv "mid/clean_midi/Michael Jackson/"* mid
mv "mid/clean_midi/AC DC/"* mid
mv "mid/clean_midi/Billy Idol/"* mid

rm mid/clean_midi.tar.gz
rm mid/*.*.mid
rm -r mid/clean_midi

cd ../..
