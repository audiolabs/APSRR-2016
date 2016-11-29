import vlc
from freesound import FreesoundClient
import settings
import essentia.standard as estd


class SoundPlayer:
    """
    Util class fpr playing audio files from python. Requires VLC installed.
    Supports playing from online urls, local urls and freesound ids.
    Example usage:
    >> sp = SoundPlayer()
    >> sp.play(freesound_id=1234)
    >> sp.play(url="http://www.freesound.org/data/previews/1/1234_600-lq.mp3")

    You can set the 'blocking' parameter of 'play' method to False to avoid
    making your code wait until the end of the file (or until user hits a key).
    """

    sound_vlc = None
    verbose = None
    name = None
    fs_client = None

    def __init__(self, verbose=False):
        self.verbose = verbose
        self.fs_client = FreesoundClient()
        self.fs_client.set_token(settings.FREESOUND_API_KEY)

    def play(self, url=None, freesound_id=None, blocking=True):
        if url is not None:
            self.load_from_url(url)
        if freesound_id is not None:
            self.load_from_freesound_id(freesound_id)
        if self.sound_vlc:
            self.sound_vlc.stop()
            if self.verbose:
                print "Playing sound %s." % self.name,
            self.sound_vlc.play()
            if blocking:
                raw_input("Press any key to stop..." if self.verbose else "")
                self.sound_vlc.stop()
        else:
            if self.verbose:
                print "Cannot play sound, no sound has been loaded"

    def stop(self):
        if self.sound_vlc:
            if self.verbose:
                print "Stopping sound %s. " % self.name
            self.sound_vlc.stop()

    def load_from_url(self, url):
        if self.verbose:
            print "Loading sound from url: %s." % url
        self.name = url
        if not url.startswith('http'):
            url = 'file://' + url  # If not online url, add file:// protocol so vlc loads properly
        self.sound_vlc = vlc.MediaPlayer(url)

    def load_from_freesound_id(self, id):
        if self.fs_client is not None:
            if self.verbose:
                print "Getting info for freesound sound with id %i." % id
            s = self.fs_client.get_sound(id)
            self.load_from_url(url=s.previews.preview_hq_ogg)
        else:
            if self.verbose:
                print "Could not load from freesound (API client not set up)."


def load_audio_file(file_path, sample_rate=44100):
    """
    Load audio file using essentia's EasyLoader class
    :param file_path: audio file path
    :param sample_rate: audio sample rate
    :return: audio data (numpy.ndarray of float32)
    """
    audio_file = estd.EasyLoader(filename=file_path, sampleRate=sample_rate)
    audio = audio_file.compute()
    return audio
