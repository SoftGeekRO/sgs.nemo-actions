import os
from pathlib import Path

from pypdf import PdfReader, PdfWriter


from .SGSActions import SGSActions


def read_pdf_metadata(pdf_path):
	return PdfReader(pdf_path).metadata


class PDF(SGSActions):

	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)

	def merge_files(self):
		merger = PdfWriter()

		out_filename = "_".join(
			[i.stem.replace(" ", "_") for i in self.working_files])

		files_path = self.working_files[0].parent

		self.dialog_fields = (
			("", "Output filename(omit extension)", out_filename),
			("CB", "Delete source files?", ("Accept", "^Deny")),
		)

		dialog_data = self.form(
			f'Config the PDF merge files',
			self.dialog_fields,
			cols=1,
			width=500,
			height=100
		)

		for pdf in self.working_files:
			merger.append(pdf)

		merger.write(f"{files_path}/{dialog_data.get(0)}.pdf")
		merger.close()

		if dialog_data.get(1) == "Accept":
			for file in self.working_files:
				os.remove(file)

	def metadata_editor(self):
		reader = PdfReader(self.working_files[0])
		writer = PdfWriter()

		origin_metadata = reader.metadata

		metadata_dialog_map = ['Title', 'Author', 'Creator', 'Producer']

		if origin_metadata is None:
			origin_metadata = {}

		self.dialog_fields = (
			("", "PDF Title:", origin_metadata.get('/Title', self.working_files[0].stem)),
			("", "PDF Author:", origin_metadata.get('/Author', "")),
			("", "PDF Creator:", origin_metadata.get('/Creator', "")),
			("", "PDF Producer:", origin_metadata.get('/Producer', "")),
			("LBL", "If empty, fallback to filename"),
			("LBL", "Authors name that edited the file"),
			("LBL", "Original app that created the pdf file"),
			("LBL", "Application name that converted the file")
		)

		dialog_data = self.form(
			f'Edit Metadata of {self.working_files[0].name}',
			self.dialog_fields
		)

		final_metadata = {}

		for ndx, md in enumerate(metadata_dialog_map):
			dialog_val = dialog_data.get(ndx)

			match md:
				case 'Title':
					if dialog_val == "":
						dialog_val = self.working_files[0].stem
				case 'Producer':
					if dialog_val == "":
						dialog_val = self.default_producer

			final_metadata.update({f'/{md}': dialog_val})

		for page in reader.pages:
			writer.add_page(page)

		if reader.metadata is not None:
			writer.add_metadata(reader.metadata)

		writer.add_metadata(final_metadata)

		os.remove(self.working_files[0])

		with open(self.working_files[0], "wb") as f:
			writer.write(f)
