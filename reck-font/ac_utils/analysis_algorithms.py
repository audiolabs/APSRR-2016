from ac_utils.sound import load_audio_file
import numpy as np
import essentia.standard as estd
import essentia

SOUND_FILE_KEY = 'file_path'


def algorithm_durations(sound):
    """
    Returns the duration of a file according to its length in number of samples and according to an envelope
    computation (See FFont ismir paper TODO: cite correctly).
    :param sound: sound dictionary from dataset
    :return: dictionary with results per different methods
    """
    results = dict()
    sample_rate = 44100
    n_channels = 1
    audio = load_audio_file(file_path=sound[SOUND_FILE_KEY], sample_rate=sample_rate)
    length_samples = len(audio)
    duration = float(len(audio))/(sample_rate * n_channels)
    # NOTE: load_audio_file will resample to the given sample_rate and downmix to mono

    # Effective duration
    env = estd.Envelope(attackTime=10, releaseTime=10)
    envelope = env(essentia.array(audio))
    threshold = envelope.max() * 0.05
    envelope_above_threshold = np.where(envelope >= threshold)
    start_effective_duration = envelope_above_threshold[0][0]
    end_effective_duration = envelope_above_threshold[0][-1]
    length_samples_effective_duration = end_effective_duration - start_effective_duration

    results['durations'] = {
        'duration': duration,
        'length_samples': length_samples,
        'length_samples_effective_duration': length_samples_effective_duration,
        'start_effective_duration': start_effective_duration,
        'end_effective_duration': end_effective_duration
    }
    return results
