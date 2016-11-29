# Need this to import from parent directory when running outside pycharm
import os
import sys
sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), os.pardir))

from scripts.convert_audio_files_to_wav import convert_to_wav
from ac_utils.general import save_to_json, create_directories
import click
import csv


CSV_HEADER = ['Genre', 'Style', 'Final Loop File Name', 'Instrument', 'Keywords', 'IsLoop', 'Number of Bars',
              'Has Key (Y/N)', 'Key (# for sharp)', 'IsMajor (Y/N)', 'Time Signature Numerator',
              'Time Signature Denominator', 'Comments', 'Artist', 'URL', 'Acoustica Sound ID', 'Tempo', 'Date']


def parse_audio_file_metatada(csv_row):

    metadata = dict()
    metadata['name'] = csv_row[CSV_HEADER.index('Final Loop File Name')]
    metadata['username'] = csv_row[CSV_HEADER.index('Artist')]
    metadata['genre'] = csv_row[CSV_HEADER.index('Genre')]
    metadata['style'] = csv_row[CSV_HEADER.index('Style')]
    annotations = dict()
    if csv_row[CSV_HEADER.index('Has Key (Y/N)')] == 'Y':
        annotations['key'] = csv_row[CSV_HEADER.index('Key (# for sharp)')]
        if csv_row[CSV_HEADER.index('IsMajor (Y/N)')]:
            annotations['key'] += ' major'
        else:
            annotations['key'] += ' minor'
    else:
        annotations['key'] = None
    if csv_row[CSV_HEADER.index('Time Signature Numerator')]:
        annotations['time_signature'] = "%i/%i" % (int(csv_row[CSV_HEADER.index('Time Signature Numerator')]),
                                                   int(csv_row[CSV_HEADER.index('Time Signature Denominator')]))
    else:
        annotations['time_signature'] = None
    if csv_row[CSV_HEADER.index('Number of Bars')]:
        annotations['beat_count'] = int(csv_row[CSV_HEADER.index('Number of Bars')]) * \
                                    int(csv_row[CSV_HEADER.index('Time Signature Numerator')])
    else:
        annotations['beat_count'] = None
    if csv_row[CSV_HEADER.index('Tempo')]:
        try:
            annotations['bpm'] = int(csv_row[CSV_HEADER.index('Tempo')])
        except ValueError:
            return None  # If tempo is not integer or can not be converted to an integer number
    else:
        annotations['bpm'] = None
    annotations['instrument'] = csv_row[CSV_HEADER.index('Instrument')]
    metadata['annotations'] = annotations
    metadata['id'] = int(csv_row[CSV_HEADER.index('Acoustica Sound ID')])

    return metadata


@click.command()
@click.argument('dataset_path')
def create_mixcraft_loops_dataset(dataset_path):
    """
    Analyze audio and metadata folder from mixcraft_loops dataset path and create matadata.json file with all gathered
    information. If downsampled wav files are not present, this command will also create them.
    The dataset_path provided needs to contain an original_metadata.csv file with metadata from the Mixcraft library
    as well as the original audio as present in the 'loops' folder of the application.
    """
    converted_audio_path = os.path.join(dataset_path, 'audio', 'wav')
    create_directories([dataset_path, converted_audio_path])
    csv_data = [row for row in csv.reader(open(os.path.join(dataset_path, 'original_metadata.csv')), delimiter=';')]
    csv_data = csv_data[1:]  # Remove header

    metadata = dict()
    with click.progressbar(csv_data,
                           label="Gathering metadata and convertig to wav (if needed)...") as original_metadata:
        for csv_row in original_metadata:

            sound_metadata = parse_audio_file_metatada(csv_row)
            if sound_metadata:
                sound_metadata['original_sound_path'] = os.path.join(dataset_path, 'audio', 'original',
                                                                     sound_metadata['style'],
                                                                     sound_metadata['name'] + '.ogg')
                wav_sound_path = "audio/wav/%i.wav" % sound_metadata['id']
                sound_metadata['wav_sound_path'] = wav_sound_path
                if not os.path.exists(os.path.join(dataset_path, sound_metadata['wav_sound_path'])):
                    out_filename = os.path.join(converted_audio_path, "%i.wav" % sound_metadata['id'])
                    convert_to_wav(sound_metadata['original_sound_path'], out_filename,
                                   samplerate=44100, nbits=16, nchannels=1)
                metadata[sound_metadata['id']] = sound_metadata

    save_to_json(os.path.join(dataset_path, 'metadata.json'), metadata)
    click.echo('Created dataset with %i sounds' % len(metadata))
    click.echo('Saved in %s' % dataset_path)

if __name__ == '__main__':
    create_mixcraft_loops_dataset()
