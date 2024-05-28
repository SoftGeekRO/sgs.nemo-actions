#!/bin/env python3
import os
import sys

dir_path = os.path.dirname(os.path.realpath(__file__))
parent_dir_path = os.path.abspath(os.path.join(dir_path, os.pardir))
sys.path.insert(0, os.path.dirname(os.path.dirname(parent_dir_path)))

from actions.scripts.lib import PDF

if __name__ == "__main__":
	_pdf = PDF()
	_pdf.merge_files()
	sys.exit(0)
