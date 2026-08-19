import argparse
import sys
import subprocess
from pathlib import Path


def encrypt_file(filename:str) -> Path:
    file = Path(filename)
    outfile = Path(file.parent, file.stem + '_enc' + file.suffix)

    cmd = f"sops encrypt {file}"
    result = subprocess.check_output(cmd, shell=True)

    #if compress:
    #    with gzip.open(f'{outfile}.gz', 'wb') as f:
    #        f.write(result)
    #else:
    with open(outfile, 'wb') as f:
        f.write(result)

    return outfile


def path_stem(file:Path) -> str:
    """Remove all trailing suffixes from a Path object to get the true stem."""
    p = file
    while p.suffix:  # Loop until there are no more suffixes
        p = p.with_suffix('')
    return p.name


def decrypt_file(filename:str) -> Path:
    """Decrypt a file and return a Path to the new file"""
    file = Path(filename)
    suffix = file.suffix

    if file.stem.endswith('_enc'):
        name = file.stem[:-len('_enc')]
    else:
        print(f"Error: File not encrypted: {file}")
        return file

    # if file.suffix == '.gz':
    #     # compressed => expand
    #     with gzip.open(file, 'rb') as f:
    #         content = f.read()

    outfile = Path(file.parent, name + suffix)

    # Invoke 'sops' with the key.txt
    cmd = f"SOPS_AGE_KEY_FILE=key.txt sops decrypt {file}"
    result = subprocess.check_output(cmd, shell=True)
    with open(outfile, 'wb') as f:
        f.write(result)

    return outfile


def neighborhood_files(neighborhood_dir:Path):
    """Given a directory, iterate thru the files used to populate a db"""
    # given the interesting files
    file_globs = {"*.json", "*.geojson"}
    neighborhood_dir = Path(neighborhood_dir)
    # yield each
    for glob_exp in file_globs:
        for file in neighborhood_dir.glob(glob_exp):
            yield file


def encrypt_neighborhood(neighborhood_dir:Path):
    for file in neighborhood_files(neighborhood_dir):
        encrypted_filename = encrypt_file(file)
        print(f"Wrote encrypted contents to {encrypted_filename}")


def decrypt_neighborhood(neighborhood_dir:Path):
    for file in neighborhood_files(neighborhood_dir):
        filename = decrypt_file(file)
        print(f"Wrote decrypted contents to {filename}")


def main() -> int:
    # parse args
    parser = argparse.ArgumentParser()
    parser.add_argument("-L", "--location", help="Directory containing neighborhood files")
    args = parser.parse_args()

    if args.location:
        neighborhood = Path(args.location)
        if neighborhood.exists() and neighborhood.is_dir():
            encrypt_neighborhood(neighborhood)
            return 0
        else:
            print(f"{neighborhood} is not a valid directory.")
            return 1
    else:
        print("Neighborhood directory nor set.")
        return 1


if __name__ == '__main__':
    sys.exit(main())