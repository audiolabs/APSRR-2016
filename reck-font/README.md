
This is a reproduction of the paper "Tempo Estimation for Music Loops and a Simple Confidence Measure" with only the FSL4 database used. The codebase can be found under:
https://github.com/ffont/ismir2016

To reproduce the results, download this repository and follow the following steps:
1. execute download.sh (downloads the codebase and the database)
2. execute data_preprocessing.sh (converts the audio, fixes some paths used in the codebase and prepares the evaluation notebook)
3. execute run_analysis.sh (analyses the whole database, takes long...)
alternative:
3. execute simulate_analysis.sh (copies the results from my own analysis in the corresponding folder, including the rekordbox data, which needs to created manually otherwise. For an instruction check: https://github.com/ffont/ismir2016/blob/master/docs/setting_up_algorithms.md)
4. execute evaluation.sh (opens the results in an iphyton notebook)

