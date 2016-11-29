# Need this to import from parent directory when running outside pycharm
import os
import sys
sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), os.pardir))

from ac_utils.general import save_to_json, load_from_json
import click
import xml.etree.ElementTree
from urllib import unquote


def find_corresponding_rekordbox_entry(sound_metadata, rekordbox_file):
    collection = rekordbox_file.find('COLLECTION')
    found = False
    for document in collection:
        if str(sound_metadata['id']) in document.attrib['Location'].split('/')[-1]:
            found = document
            break
        if str(sound_metadata['wav_sound_path'].split('/')[-1]) in document.attrib['Location'].split('/')[-1]:
            found = document
            break
        if str(sound_metadata['wav_sound_path'].split('/')[-1]) in unquote(document.attrib['Location'].split('/')[-1]):
            found = document
            break
    return found


@click.command()
@click.argument('dataset_path')
def rekordbox_file_to_analysis_file(dataset_path):
    """
    Read information from rekordbox_rhythm.xml present in dataset_path and convert it into
    analsysis_rhythm_rekordbox.json to be stored in the same folder and compatible with our evaluation
    framework.
    """
    rekordbox_file = xml.etree.ElementTree.parse(os.path.join(dataset_path, 'rekordbox_rhythm.xml')).getroot()
    metadata_file = load_from_json(os.path.join(dataset_path, 'metadata.json'))
    out_file_path = os.path.join(dataset_path, 'analysis_rhythm_rekordbox.json')

    analysis = dict()
    with click.progressbar(metadata_file.keys(), label="Converting...") as metadata_keys:
        for key in metadata_keys:
            entry = find_corresponding_rekordbox_entry(metadata_file[key], rekordbox_file)
            if entry is not False:
                tempo_entry = entry.find('TEMPO')
                if tempo_entry is not None:
                    bpm_raw = float(tempo_entry.attrib['Bpm'])
                else:
                    bpm_raw = 0.0
                analysis[key] = {"RekBox": {
                        "bpm": bpm_raw,
                    }
                }
    save_to_json(out_file_path, analysis, verbose=True)

if __name__ == '__main__':
    rekordbox_file_to_analysis_file()
