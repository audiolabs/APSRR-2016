# Instructions for setting up datasets

In out paper we analyse  four datasets:

 * **FSL4**: This dataset contains user-crontributed loops uploaded to [Freesound](http://www.freesoud.org). It has been built in-house by searching Freesound for sounds with the query terms *loop* and *bpm*, and then automatically parsing the returned sound filenames, tags and textual descriptions to identify tempo annotations made by users. For example, a sound containing the tag *120bpm* is considered to have a ground truth of 120 BPM. 
 * **APPL**: This dataset is composed of the audio loops bundled in [Apple's Logic Pro](http://apple.com/logic-pro/) music production software. We parsed the metadata embedded in the audio files using source code available in a [public repository](http://github.com/jhorology/apple-loops-meta-reader), and extracted in this way tempo annotations for all the loops.
 * **MIXL**: This dataset contains all the loops bundled with Acoustica's [Mixcraft 7 music production software](http://acoustica.com/mixcraft/). Tempo annotations are provided in its loop browser and can be easily exported into a machine-readable format.
 * **LOOP**: This dataset is composed of loops downloaded from [Looperman](http://looperman.com), an online loop sharing community. It was previously used for research purposes in [1]. Tempo annotations are available as metadata provided by the site.

[1] Gerard Roma. Algorithms and representations for supporting online music creation with large-scale audio databases. PhD thesis, Universitat Pompeu Fabra, 2015.

Due to license restrictions, we can only directly provide the contents of **FSL4** dataset.
We provide two ways of getting the dataset, either by [downloading a single zip file](#zip_file) or [running a script](#script) that gets the contents from Freesound.
Instructions for both options can be found below.

Two of the other datasets, **APPL** and **MIXL**, are in general easy to reproduce if owning the corresponding music production software.
You'll also find instructions below on how to recreate these datasets assuming you own the software.


<a name="zip_file"></a>
## Getting FSL4 from a ZIP file 

The whole dataset can be downloaded from [here](http://labs.freesound.org/static_data/FSL4/FSL4.zip). 
It contains the audios for all sounds in their original format plus the metadata (including BPM annotations) for each file.
Once downloaded you can use the `convert_audio_files_to_wav.py` script to convert all sounds to 44.1 kHz, mono, 16 bit PCM format:

 ```
 python scripts/convert_audio_files_to_wav.py SOURCE_FOLDER --outdir OUTPUT_FOLDER 
 ```
 
This conversion uses `ffmpeg` command line utility, therefore you'll need to have it installed in your system.


<a name="script"></a>
## Getting FSL4 by downloading content from Freesound 

Alternatively, **FSL4** can be recreated running a script that downloads all audio files and metadata directly from Freesound.
Be aware that using this script the resulting dataset might not be exactly the same as the one we used in our experiments as there exists the
possibility that some files are missing or their descriptions have been altered.

The script is named `create_freesound_loops_dataset.py` and can be found in the `scripts` folder.
Before running the script you'll have to set the `FREESOUND_API_KEY` and `FREESOUND_ACCESS_TOKEN` parameters found in the first lines of the script.
To do that you'll need to create a Freesound account and follow these steps:

 * 1) Apply for Freesound APIv2 credentials accessing [this url](http://www.freesound.org/apiv2/apply/). The credentials are given instantly upon filling the form.
 * 2) Fill `FREESOUND_API_KEY` with the alphanumeric string of the `Client secret/Api key` column that will be shown after filling the form in step 1.
 * 3) Copy the `Client id` alphanumeric string (shorter than `Client secret/Api key`) that is also given after filling the form.
 * 4) Go to the following url: 

 ```
 https://www.freesound.org/apiv2/oauth2/authorize/?client_id=YOUR_GIVEN_CLIENT_ID&response_type=code
 ``` 
 
 (replace `YOUR_GIVEN_CLIENT_ID` with the contents of `Client id` from step 3) and click `Authorize!`. Introduce your Freesound account credentials and copy the authorization code that will be given to you.
 * 5) Run the following command replacing `YOUR_GIVEN_CLIENT_ID` (as in the previous step), `YOUR_GIVEN_FREESOUND_APY_KEY` with the contents of `FREESOUND_API_KEY`, and `AUTHORIZATION_CODE` with the code you got in step 4.
 
 ```
 curl -X POST -d "client_id=YOUR_GIVEN_CLIENT_ID&client_secret=YOUR_GIVEN_FREESOUND_APY_KEY&grant_type=authorization_code&code=AUTHORIZATION_CODE" https://www.freesound.org/apiv2/oauth2/access_token/
 ```
 This will return something similar to this:
 
 ```
 {"access_token": "e22ce72c0b18bf76a7da9d41ad1d7e146f3af309", "token_type": "Bearer", "expires_in": 86399, "refresh_token": "31cbd0fd394f7381a70b73befd4b97e7a9afdad9", "scope": "read write read+write"}
 ```
  
 * 6) Fill `FREESOUND_ACCESS_TOKEN` with the contents of the alphanumeric string `access_token` of the response.  
 
By following this process you'll get an access token that will allow to download freesound audio files in their original format.
This access token will be valid for 24 hours. If you run the script when the access token has expired, you'll need to follow again these steps to get a new token.
  
Once you have filled `FREESOUND_API_KEY` and `FREESOUND_ACCESS_TOKEN` you can now run the script to recreate the FSL4 dataset.
 
```
python scripts/create_freesound_loops_dataset.py --max_sounds 4000 path_where_you_want_to_store_the_dataset
```

Note that it might take a while to download all the sounds and metadata. 
Note also that because of throttling limits of the Freesound API the script might not be able to download all the sounds in one day. By default Freesound API allows 2000 requests per day, meaning that no more than 2000 sounds can be downloaded per day in their original quality. The solutions around that are either to run the script in consecutive days (sounds already downloaded won't be downloaded again) or to ask for more permissive limits to the Freesound API maintainers (see [API documentation](http://www.freesound.org/docs/api/)). 
Once sounds are downloaded the script will also convert the audio files to 44.1 kHz, mono, 16 bit PCM format.
This conversion uses `ffmpeg` command line utility, therefore you'll need to have it installed in your system.


## Getting the other datasets

Although we can not release the other datasets, **APPL** and **MIXL** can be rather easily reproduced if owning [Apple's Logic Pro](http://apple.com/logic-pro/) and/or [Mixcraft 7 music production software](http://acoustica.com/mixcraft/) music production software.
If that is the case, the following instructions should help you getting the dataset ready.

### APPL

Apple's Logic Pro comes with a number of audio loops bundled with the software. These loops are in `.caf` format and typically come with metadata embedded.
To create **APPL** dataset you can follow these steps:

 * 1) Install Logic Pro (only available for OSX)
 * 2) Create a folder for the db in your data directory
 * 3) Extract the metadata from the `.caf` files using the software hosted in this [public repository](http://github.com/jhorology/apple-loops-meta-reader). Apple loops files are typically located in `/Library/Audio/Apple Loops/Apple/`.
 * 4) Save the `.json` file created for each loop in a folder called `metadata` inside the dataset folder.
 * 5) Run the script `create_apple_loops_dataset.py` that you'll find in the `scripts` folder. You'll probably have to tweak some bits of the script to provide the full path to the original audio files.
 
```
python scripts/create_apple_loops_dataset.py created_db_folder_in_step_1
```
  
The script will take care of creating 44.1 kHz, mono, 16 bit PCM format versions of the files and save them into the `audio/wav` folder of the dataset.
After running it, the dataset should be ready for use.


### MIXL

Similarly to Logic Pro, Mixcraft 7 also comes with a number of loops bundled. 
To create the **MIXL** dataset you can follow these steps:

 * 1) Install and open Mixcraft 7 (only available for Windows)
 * 2) Create an empty project
 * 3) Click on the `Library` tab at the bottom
 * 4) Select the `Loops` library and wait untill all sounds are imported/downloaded. When finished you can close Mixcraft.
 * 5) Create a folder for the db in your data directory and inside a folder create `audio/original` subfolders.
 * 6) Copy the contents of Mixcraft loops folder in `audio/original`. Mixcraft loops folder should be found in `C:\ProgramData\Acoustica\Mixcraft\loops\`.
 * 7) Locate the file `Loops.mldb7` (also in the same Mixcraft loops folder) and copy it to the root db folder. Rename it to `original_metadata.csv`.
 * 8) Run the script `create_mixcraft_loops_db.py` that you'll find in the `scripts` folder.

```
python scripts/create_mixcraft_loops_db.py created_db_folder_in_step_1
```
  
The script will take care of creating 44.1 kHz, mono, 16 bit PCM format versions of the files and save them into the `audio/wav` folder of the dataset.
After running it, the dataset should be ready for use.
