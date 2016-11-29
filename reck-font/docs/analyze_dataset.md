# Instructions for analyzing datasets

Every folder in the `settings.DATA` directory is treated as a dataset.
Initially, each dataset should contain the following file structure (see [Instructions for setting up datasets](create_dataset.md)):

```
dataset_name/
    dataset_info.json  <- JSON file including the name and short name of the dataset
    metadata.json  <- JSON file including metadata about sounds in the datasets (ids, annotations, etc...)
    audio/wav/  <- folder with 44100, 16 bit, mono PCM audio files for each entry in metadata.json
```

Before running the notebooks with the experiments of the paper, all the datasets must be analysed with a number of 
algorithms. These algorithms include the tempo estimation algorithms that we compare in the paper and some extra algorithms which are useful to quickly compute the confidence measure. 
To analyse the datasets we use the script `analyze_dataset.py` found in the `scripts` folder. 
The simplest way to run this is script is as follows:

```
python scripts/analyze_dataset.py dataset_folder_path
```

*Note:* check the [source code of the script](https://github.com/ffont/ismir2016/blob/master/scripts/analyze_dataset.py) for extra running options (including the [use of celery to speed-up computation time](#celery)).

After running the script, a number of `JSON` files will be generated inside the dataset folder with the results of the different analyses:

```
dataset_name/
    dataset_info.json
    metadata.json
    audio/wav/
    analysis_durations.json  <- results of the estimated duration of the files
    analysis_rhythm_essentia_basic.json  <- results of Zapata14 and Degara12 methods (from Essentia)
    analysis_rhythm_gkiokas12.json  <- results of Gkiokas12
    analysis_rhythm_madmom.json  <- results of Bock15
    analysis_rhythm_percival14.json  <- results of Percival14
```
 
If the algorithms are not properly set up some of this files might 
be empty or the whole analysis script might fail (see [Instructions for setting up algorithms](setting_up_algorithms.md)). The notebooks will only consider for evaluation the methods that have been used to
successfully annotate the datasets.


<a name="rekbox"></a>
## Rekordbox (RekBox) algorithm

Rekordbox does not provide any command line utility or software bindings to systematically analyse a collection of files.
For this reason, getting RekBox results for a dataset must be done manually following these steps:

 * 1) Download Rekordbox software from [their website](https://rekordbox.com). For this paper we used version 4.0.5.
 * 2) Drag all the files in the `audio/wav` folder of a dataset into Rekordbox (to create a new collection)
 * 3) Select all the tracks in the collection and click `Analyze Track` in the `Track` menu.
 * 4) Once finished (it might take a while for big datasets), click on `File` menu and `Export collection in xml format...`.
      Save the file in the dataset folder with the name `rekordbox_rhythm.xml`.
 * 5) Run the script `rekordbox_xml_to_analysis_rhythm_rekordbox_file.py` in the `scripts` folder:
 
 ```
 python scripts/rekordbox_xml_to_analysis_rhythm_rekordbox_file.py dataset_folder_path
 ```
 
This will create the file `analysis_rhythm_rekordbox.json` that can be loaded in the same way as the other generated analysis files.


<a name="celery"></a>

## Use Celery to speed-up analysis

The analysis script has an option to use [Celery](http://www.celeryproject.org) for distributing the analsyis and making it faster taking advantage of multiple CPU cores.
In order to use Celery, you must [install](http://www.celeryproject.org/install/) it along with a broker backend (we use [RabbitMQ](http://docs.celeryproject.org/en/latest/getting-started/first-steps-with-celery.html#rabbitmq)). Then you must start the borker and start the Celery task queue:

```
sudo rabbitmq-server -detached  # Start broker (RabbitMQ in this case)
celery -A tasks worker --concurrency=NUM_WORKERS  # Start Celery specifying NUM_WORKERS to work in parallel
``` 

Once Celery is running you can call the analysis script passing the option `--use_celery`.