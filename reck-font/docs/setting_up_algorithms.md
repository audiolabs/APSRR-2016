# Instructions for setting up analysis algorithms

#### Percival14

This algorithm is described in *Graham Percival and George Tzanetakis. Streamlined tempo estimation based on autocorrelation and cross-correlation with pulses. IEEE/ACM Transac- tions on Audio, Speech, and Language Processing, 22(12):1765–1776, 2014*.

In our repository we include the Python version of the code which was originally provided by the authors and can be found [http://opihi.cs.uvic.ca/tempo/](http://opihi.cs.uvic.ca/tempo/). Code from the authors can also be found in the [Marsyas](http://marsyas.info) audio analysis library [code repository](https://github.com/marsyas/marsyas/tree/master/scripts/large-evaluators/tempo-reference-implementation).

The algorithm has depenencies on typical Python science packages (numpy, scipy) which will be installed when installing the packages listed in the ```requirements.txt``` file found in the root of this repository.


#### Gkiokas12

This algorithm is described in *Aggelos Gkiokas, Vassilis Katsouros, George Carayannis, and Themos Stafylakis. Music Tempo Estimation and Beat Tracking By Applying Source Separation and Metrical Relations. In Proc. of the Int. Conf. on Acoustics, Speech and Signal Processing (ICASSP), volume 7, pages 421–424, 2012*.

In our repository we include an Octave version of the algorithm kindly provided by the original authors. The algorithm is used by calling Octave from the command line. Hence, in order to set it up you should install Octave and make sure that you can successfully call the algorithm via command line (you'll probably need to install Octave packages *control*, *signal* and *image*). Test the algorithm running this command:

```
octave --eval "cd /path/to/this/repository/folder/algorithms/Gkiokas12/; extractTempo /path/to/this/repository/folder/algorithms/Gkiokas12/test.wav"
```

This should print ```tempo = 123``` in the command line.


#### Degara12 and Zapata14

These algorithms are described in *Norberto Degara, Enrique Argones Rua, Antonio Pena, Soledad Torres-Guijarro, Matthew EP Davies, and Mark D Plumbley. Reliability-Informed Beat Tracking of Musical Signals. IEEE Transactions on Audio, Speech, and Language Processing, 20(1):290– 301, 2012*, and 
*Jose R Zapata, Matthew EP Davies, and Emilia Gómez. Multi-Feature Beat Tracking. IEEE/ACM Transactions on Audio, Speech, and Language Pro- cessing, 22(4):816–825, 2014*, respectively.

In our evaluation we use the implementation of both algorithms provided in the open-source [Essentia audio analysis library](http://essentia.upf.edu). To set it up you'll need to install Essentia (see [installation instructions](http://essentia.upf.edu/documentation/installing.html) including its python bindings.
Once this is done the algorithms will be properly set up.

Essentia is devloped by the [Music Technology Group of Universitat Pompeu Fabra](http://mtg.upf.edu).
In our paper we used Essentia version ```2.1 beta2```.


#### Böck15

This algorithm is described in *Böck Sebastian, Florian Krebs, and Gerhard Widmer. Accurate Tempo Estimation based on Recurrent Neu- ral Networks and Resonating Comb Filters. In Proc. of the Int. Conf. on Music Information Retrieval (ISMIR), 2015*.

An implementation of this alorithm provided by the original authors can be found in the oepn source audio analysis Python package [Madmom](https://madmom.readthedocs.io/en/latest/). The source code can be found in this [source code repository](https://github.com/CPJKU/madmom). To set up the algorithm please follow the instructions described in their repository. Once set up, the algorithm will be available as a command line utility which we call from our code. You can test that the algorithm is properly set up running this command:

```
TempoDetector --mirex --method comb single /path/to/this/repository/folder/algorithms/Gkiokas12/test.wav"
```

This should print ```100.00 200.00 0.46``` in the command line.

Madmom is devloped by the [Department of Computational Perception of Johannes Kepler Universität](http://www.cp.jku.at).
In our paper we used Madmom version ```0.13```.


#### RekBox

This is the algorithm used in [Rekordbox](http://rekordbox.com) software.
Rekordbox does not provide any command line utility or software bindings to systematically analyse a collection of files.
Please follow [these instructions](analyze_dataset.md#rekbox) to get a collection annotated with RekBox algorithm.

For our analyses we used Rekordbox version 4.0.5.
