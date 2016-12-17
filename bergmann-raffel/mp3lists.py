import get7digital
import os
import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Get the 7digital track ids for a list of songs.')
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
    
    with open("midi-dataset/lists/songlist.txt","r") as songlist:
        songs = songlist.read().splitlines()

    with open("midi-dataset/lists/idlist.txt", "w") as idlist:
        for song in songs:
            id = get7digital.search_trackid(song, key=args.key, secret=args.secret)
            print>>idlist, str(id)