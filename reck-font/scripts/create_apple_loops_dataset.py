# Need this to import from parent directory when running outside pycharm
import os
import sys
sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), os.pardir))

from scripts.convert_audio_files_to_wav import convert_to_wav
from ac_utils.general import save_to_json, create_directories, load_from_json
import click
import hashlib


def parse_audio_file_metatada(metadata_file_path):
    try:
        metadata = load_from_json(metadata_file_path)
        metadata['name'] = metadata['file_path'].split('/')[-1]
        metadata['annotations'] = {
            'bpm': int(metadata['meta']['tempo']),
            'time_signature': metadata['meta']['timeSignature'],
            'beat_count': int(metadata['meta']['beatCount']),
        }
        metadata['id'] = hashlib.md5(b'%s' % metadata['file_path']).hexdigest()
        del metadata["transients"]  # Delete this as we don't need it and it takes a lot of space
    except KeyError:
        return False
    return metadata


@click.command()
@click.argument('dataset_path')
def create_apple_loops_dataset(dataset_path):
    """
    Analyze audio and metadata folder from apple_loops dataset path and create matadata.json file with all gathered
    information. If downsampled wav files are not present, this command will also create them.
    The dataset_path that is given needs to already contain a directory structure with metadata files extracted
    from .caf files (we used https://github.com/jhorology/apple-loops-meta-reader and added file_path property to
    each extracted file).
    """
    metadata_files_path = os.path.join(dataset_path, 'metadata')
    converted_audio_path = os.path.join(dataset_path, 'audio', 'wav')
    create_directories([dataset_path, converted_audio_path])

    metadata = dict()
    with click.progressbar([fname for fname in os.listdir(metadata_files_path)],
                           label="Gathering metadata and convertig to wav (if needed)...") as dir_filenames:
        for filename in dir_filenames:
            if filename.startswith('.'):
                continue
            sound_metadata = parse_audio_file_metatada(os.path.join(metadata_files_path, filename))
            if sound_metadata:
                sound_metadata['original_sound_path'] = sound_metadata['file_path']
                filesize = os.path.getsize(sound_metadata['original_sound_path'])
                if filesize < 1024 * 5:
                    # Original filesize is lower than 5KB, ignore this file as it probably is just midi data
                    continue
                filename, extension = os.path.splitext(filename)
                wav_sound_path = "audio/wav/%s.wav" % filename
                sound_metadata['wav_sound_path'] = wav_sound_path
                if not os.path.exists(os.path.join(dataset_path, sound_metadata['wav_sound_path'])):
                    out_filename = os.path.join(converted_audio_path, "%s.wav" % filename)
                    convert_to_wav(sound_metadata['original_sound_path'], out_filename,
                                   samplerate=44100, nbits=16, nchannels=1)
                metadata[sound_metadata['id']] = sound_metadata

    save_to_json(os.path.join(dataset_path, 'metadata.json'), metadata)
    click.echo('Created dataset with %i sounds' % len(metadata))
    click.echo('Saved in %s' % dataset_path)

if __name__ == '__main__':
    create_apple_loops_dataset()
