#!/bin/env python3

import os
import sys
from pathlib import Path

import pypdftk

files_to_process = sorted(sys.argv[1:])[0].split(",")
abs_path = Path(files_to_process[0]).parent

out_filename = "_".join([Path(i).stem.replace(" ", "_") for i in files_to_process]) + '.pdf'

pypdftk.concat(files_to_process, f'{abs_path}/{out_filename}')

