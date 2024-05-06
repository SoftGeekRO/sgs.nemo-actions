#!/bin/env python3
import os
import sys
import subprocess

from pathlib import Path

files_to_process = sorted(sys.argv[1:])
out_path = os.path.dirname(sys.argv[1])

# Ex: 'page1.jpg', 'page2.jpg', 'page3.jpg' -> 'page1_page2_page3.pdf'
out_filename = "_".join([Path(i).stem for i in files_to_process]) + '.pdf'

subprocess.run([
	"img2pdf", *files_to_process,
	"--output", f"{out_path}/{out_filename}",
	"--creator", f"SoftGeek Romania",
	"--producer", f"SGS Nemo Actions"
], capture_output=True, text=True)
