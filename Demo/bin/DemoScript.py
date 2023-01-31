#!/usr/bin/env python

import os, sys, argparse, pandas
from pyfiglet import Figlet


parser = argparse.ArgumentParser(
    description = 'Docker Demo Script',
    prog       = os.path.basename(__file__),
    usage      = '%(prog)s [options]',
    epilog     = 'see readme for further details.', )

script_dir = os.path.dirname(__file__).rstrip('/')

parser.add_argument( '-input',  metavar='</path/to/directory>', type=str, default=f'{script_dir}/inputs/input_table.csv',   help='specify path to input file')
parser.add_argument( '-output', metavar='</path/to/directory>', type=str, default=f'{script_dir}/outputs/output_table.csv', help='specify path to output file')
parser.add_argument( '-value',  metavar='<value>',              type=str, default=0,                                        help='specify path to working directory')

INPUT_PATH, OUTPUT_PATH, VALUE, = vars(parser.parse_args()).values() # define user inputs



print('\nPYTHON SCRIPT START\n')


print(Figlet(font='standard').renderText('HELLO WORLD!'))

data_table = pandas.read_csv(INPUT_PATH, sep=',')
is_link = os.path.islink(INPUT_PATH)

print(f'\n{INPUT_PATH} (symlink: {is_link}) -> INPUT DATA')
print(data_table)


data_table.iloc[:,:] = VALUE

print(f'\nOUTPUT DATA -> {OUTPUT_PATH}')
print(data_table)

#os.makedirs( os.path.dirname(OUTPUT_PATH), exist_ok=True )

with open(OUTPUT_PATH, mode='w') as output:

    print( data_table, file=output )

print('\nPYTHON SCRIPT END\n')
