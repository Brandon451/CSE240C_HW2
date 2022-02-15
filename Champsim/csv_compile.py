from glob import glob
from os.path import join

def compile(input_filepath, output_filepath):
    with open(in_csv_path, 'r') as infile:
        lines = [infile.readline() for _ in range(2)]
        with open(out_csv_path, 'a') as outfile:
            outfile.writelines(lines)

BASE_DIR = 'results_compile'
PREFIX = 'champsim_'

dirs = glob(join(BASE_DIR, PREFIX+'*'))
dirs = [directory for directory in dirs if directory[-1].isnumeric()]

for directory in dirs:
    dirname = directory.split('/')[-1]
    in_csv_path = join(directory, dirname + '_ipc.csv')
    out_csv_path = directory[::-1].split('_', maxsplit=2)[-1][::-1] + '_ipc.csv'
    compile(in_csv_path, out_csv_path)      
    in_csv_path = join(directory, dirname + '_mpki.csv')
    out_csv_path = directory[::-1].split('_', maxsplit=2)[-1][::-1] + '_mpki.csv'
    compile(in_csv_path, out_csv_path)       