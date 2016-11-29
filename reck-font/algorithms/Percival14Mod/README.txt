
Here's the structure:

  * tempo_stem_file.py : main entry point; give it a .wav filename
      or a .mf filename.
      * mar_collection.py : handles .mf files (reading, saving,
          iterating)
      * defs_class.py : settings to control the algorithm, such
          as windowsize or whether to check against the reference
          output.

  * onset_strength.py : first part of the algorithm (Figure 2 in the
      paper).
      * overlap.py: a helper script which splits the audio into
          distinct frames
  * beat_period_detection.py : figure 3 in the paper
  * accumulator_overall.py : figure 4 in the paper



