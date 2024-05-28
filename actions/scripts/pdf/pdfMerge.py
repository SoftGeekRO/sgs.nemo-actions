#!/bin/env python3
import os
import sys
import pypdftk
from pathlib import Path

from pypdf import PdfReader, PdfWriter

dir_path = os.path.dirname(os.path.realpath(__file__))
parent_dir_path = os.path.abspath(os.path.join(dir_path, os.pardir))
sys.path.insert(0, os.path.dirname(os.path.dirname(parent_dir_path)))

from actions.scripts.lib import yad
from actions.scripts.lib import PDF

files_to_process = sorted(sys.argv[1:])[0].split(",")
abs_path = Path(files_to_process[0]).parent

out_filename = "_".join(
	[Path(i).stem.replace(" ", "_") for i in files_to_process])


def config_dialog():
	_yad = yad.YAD()

	fields = (
		("", "Output filename(omit extension)", out_filename),
		("CB", "Delete source files?", ("Accept", "^Deny")),
	)
	form = _yad.Form(
		fields=fields,
		title="Config the PDF merge files",
		geometry="500x100"
	)
	return form


dialog = config_dialog()

if dialog is not None:
	pypdftk.concat(files_to_process, f'{abs_path}/{dialog.get(0)}.pdf')

	if dialog.get(1) == "Accept":
		for file in files_to_process:
			os.remove(file)

if __name__ == "__main__":
	_pdf = PDF()

	sys.exit(0)
