# Need this to import from parent directory when running outside pycharm
import os
import sys
sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), os.pardir))

FREESOUND_API_KEY = ''
FREESOUND_ACCESS_TOKEN = ''

"""
This script searches sounds in Freesound using the query terms 'loop' and 'bpm'.
Then downloads a preview for each sound and guesses its bpm by analysing sound name, description and tags.
This is intended to create a ground truth of loops for tempo estimation.
"""

from ac_utils.freesound import FreesoundClient, FSRequest, URIS
from ac_utils.general import save_to_json, print_progress, promt_user_to_abort_if_file_exists, create_directories, \
    title
from scripts.convert_audio_files_to_wav import convert_audio_files_to_wav
import collections
import urllib
import re
import click
from fsl4_ids import FSL4_IDS


def estimate_bpm_from_metadata(name, description, tags, min_bpm=25, max_bpm=300):
    """
    Estimate the bpm of a sound by looking at its description, tags and name.
    :param name: sound filename (or name given by user)
    :param description: sound textual description
    :param tags: list of sound tags
    :param min_bpm: minimum bpm
    :param max_bpm: maximum bpm
    :return: estimated bpm (int)
    """
    bpm_candidates = list()

    # Find sequences like 120bpm, bpm120, 120 bpm or bpm 120 in all fields
    description = description.lower()
    name = name.lower()
    tags = [tag.lower() for tag in tags]
    for candidate in re.findall(r'\d+[\s]?bpm', description + ' ' + name + ' ' + ' '.join(tags)) \
            + re.findall(r'bpm[\s]?\d+', description + ' ' + name + ' ' + ' '.join(tags)):
        try:
            bpm = int(candidate.replace('bpm', '').replace(' ', ''))
            if min_bpm <= bpm <= max_bpm:
                bpm_candidates.append(bpm)
        except ValueError:
            continue

    # Find tags corresponding to single numbers and in a range
    for tag in tags:
        try:
            bpm = int(tag)
            if min_bpm <= bpm <= max_bpm:
                bpm_candidates.append(bpm)
        except ValueError:
            continue

    if not bpm_candidates:
        return 0

    # Return the most common candidate
    return collections.Counter(bpm_candidates).most_common(1)[0][0]


@click.command()
@click.argument('dataset_path')
@click.option('--max_sounds', default=20, help='Size of the created dataset.')
@click.option('--group_by_pack', default=1, help='Defines whether to only include one sound from a same '
                                                 'freesound pack or more (default=1, True).')
def create_freesound_loops_dataset(dataset_path, max_sounds, group_by_pack):

    print title('Creating freesound loops dataset')
    out_file_path = os.path.join(dataset_path, "metadata.json")
    promt_user_to_abort_if_file_exists(out_file_path)
    original_sounds_path = os.path.join(dataset_path, 'audio', 'original')
    create_directories([dataset_path, original_sounds_path])
    metadata = dict()
    fs_client = FreesoundClient()
    try:
        fs_client.set_token(FREESOUND_ACCESS_TOKEN, auth_type="oauth")
        auth_type = 'oauth'
    except:
        fs_client.set_token(FREESOUND_API_KEY)
        auth_type = 'token'

    ids_to_retrieve = FSL4_IDS[:max_sounds]
    page_size = 100
    for i in range(0, len(ids_to_retrieve), page_size):
        current_ids = ids_to_retrieve[i:i + page_size]
        ids_filter = ' OR '.join(['id:%i' % sid for sid in current_ids])
        pager = fs_client.text_search(fields="id,name,tags,description,previews,username,pack,type,license",
                                      filter=ids_filter,
                                      page_size=page_size)

        for j, sound in enumerate(pager):
            print_progress('Downloading and/or processing sound %i' %
                           sound.id, len(metadata) + 1, len(ids_to_retrieve))
            estimated_bpm = estimate_bpm_from_metadata(sound.name, sound.description, sound.tags)
            if estimated_bpm:
                metadata[sound.id] = {
                    'id': sound.id,
                    'name': sound.name,
                    'tags': sound.tags,
                    'annotations': {'bpm': estimated_bpm},
                    'description': sound.description,
                    'preview_url': sound.previews.preview_hq_mp3,
                    'username': sound.username,
                    'pack': sound.pack,
                    'type': sound.type,
                    'license': sound.license,
                }
                original_sound_path = os.path.join(dataset_path, "audio/original/%i.%s" % (sound.id, sound.type))
                if not os.path.exists(original_sound_path) and auth_type == 'oauth':
                    # Retrieve original sound
                    try:
                        uri = URIS.uri(URIS.DOWNLOAD, sound.id)
                        FSRequest.retrieve(uri, fs_client, original_sound_path)
                    except Exception as e:
                        # If original sound could not be retrieved, try with preview
                        try:
                            preview_path = os.path.join(dataset_path, "audio/original/%i.mp3" % sound.id)
                            urllib.urlretrieve(sound.previews.preview_hq_mp3, preview_path)
                            original_sound_path = preview_path
                        except urllib.ContentTooShortError:
                            # Skip this sound (no preview or original could be downloaded)
                            del metadata[sound.id]
                            continue

                metadata[sound.id]['original_sound_path'] = original_sound_path.replace(dataset_path, '')
                metadata[sound.id]['wav_sound_path'] = os.path.join(dataset_path, 'audio', 'wav', '%i.wav' % sound.id)
                save_to_json(out_file_path, metadata)

    save_to_json(out_file_path, metadata)
    print ''

    # Create wav versions of the sounds if these do not already exist
    wav_sounds_path = os.path.join(dataset_path, 'audio', 'wav')
    if not os.path.exists(wav_sounds_path):
        print 'Creating wav versions of downloaded files...'
        create_directories([wav_sounds_path])
        convert_audio_files_to_wav(original_sounds_path, wav_sounds_path, 44100, 16, 1, '')

    print 'Created dataset with %i sounds' % len(metadata)
    print 'Saved in %s' % dataset_path


if __name__ == "__main__":
    create_freesound_loops_dataset()
