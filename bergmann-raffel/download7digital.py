import os
import argparse
import requests
from requests_oauthlib import OAuth1


def search_trackid(search, key, secret):
    url = 'https://api.7digital.com/1.2/track/search'
    auth = OAuth1(key, secret, signature_type='query')

    params = {
        'q': search,
        'country': 'ww',
    }

    headers = {
        'accept': 'application/json',
    }

    try:
        r = requests.get(url, auth=auth, params=params, headers=headers)
        data = r.json()
    except ValueError:
        print r.content
        raise

    if data['status'] != 'ok':
        return None

    return data['searchResults']['searchResult'][0]['track']['id']


def get_file(trackid, handle, key, secret):
    url = "http://previews.7digital.com/clip/%s" % trackid
    auth = OAuth1(key, secret, signature_type='query')

    params = {
        'country': 'ww',
    }

    r = requests.get(url, auth=auth, params=params, stream=True)

    if not r.ok:
        raise RuntimeError("Download of %s failed" % trackid)

    for block in r.iter_content(1024):
        handle.write(block)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Download 7digital previews for a list of songs.')
    parser.add_argument(
        '--key',
        help='7digital key, optional',
        nargs='?',
        default=os.environ.get('DIGITAL7_KEY'),
    )
    parser.add_argument(
        '--secret',
        help='7digital secret, optional',
        nargs='?',
        default=os.environ.get('DIGITAL7_SECRET'),
    )
    
    args = parser.parse_args()
    with open("lists/songlist.txt", "r") as songlist:
        songs = songlist.read().splitlines()
        for song in songs:
            trackid = search_trackid(song, key=args.key, secret=args.secret)
            title = song.replace(" ", "_").lower()
            outfile = 'data/mp3/%s.mp3' % title
            with open(outfile, 'wb') as f:
                get_file(trackid, f, key=args.key, secret=args.secret)
                print outfile
