import os
import sys
from pathlib import Path
from datetime import datetime

from pypdf import PdfReader, PdfWriter

from .SGSActions import SGSActions


def read_pdf_metadata(pdf_path):
    return PdfReader(pdf_path).metadata


class PDF(SGSActions):
    dialog_data = None
    writer = None
    reader = None
    files_path = ''
    subfix = "shrink"
    output = ''

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
            ("", "PDF Title:",
             origin_metadata.get('/Title', self.working_files[0].stem)),
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

        if dialog_data is None:
            sys.exit(0)

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

    def pdf_shrink(self):
        self.reader = PdfReader(self.working_files[0])
        self.writer = PdfWriter(clone_from=self.working_files[0])

        self.files_path = self.working_files[0].parent

        self.dialog_fields = (
            ("CB", "Remove duplicates:", ("YES", "^NO")),
            ("CB", "Remove images:", ("YES", "^NO")),
            ("CB", "Image Quality:", ("Low", "^Medium", "High")),
            ("CB", "Compress files", ("YES", "^NO")),
            ("CB", "Shrink filename:", ("DateTime", "^Subfix")),
            ("LBL",
             "Some PDF documents contain the same object multiple times."),
            ("LBL", "Removing all the images from pdf file"),
            ("LBL", "Change image resolution 72/150/300dpi"),
            ("LBL", "Compress files using zlib/deflate compression method"),
            ("LBL", "Subfix for the output file"),
        )

        self.dialog_data = self.form(
            f'Config PDF shrink',
            self.dialog_fields
        )

        if self.dialog_data is None:
            sys.exit(0)

        if self.dialog_data.get(0) == "NO" and self.dialog_data.get(1) == "NO" and self.dialog_data.get(2) == "Medium" and self.dialog_data.get(3) == "NO" and self.dialog_data.get(4) == "Subfix":
            self.error("No Modification!",
                       "Quit the shrink operation!", width=450, height=120)
            sys.exit(0)

        self.progress("Progress PDF", "Waiting to process", self.run_tasks)
        self.check_size()

    def run_tasks(self):

        remove_duplicate = self.dialog_data.get(0, "NO")
        remove_images = self.dialog_data.get(1, "NO")
        resolution = self.dialog_data.get(2, "Medium")
        compression = self.dialog_data.get(3, "NO")
        filename_subfix = self.dialog_data.get(4, "Subfix")

        match resolution:
            case 'Low':
                img_quality = 72
            case 'Medium':
                img_quality = 150
            case "High":
                img_quality = 300
            case _:
                img_quality = 150

        if filename_subfix == "DateTime":
            self.subfix = datetime.now().strftime("%H%M%S%d%m%Y")

        if remove_duplicate == "YES":
            for page in self.reader.pages:
                self.writer.add_page(page)

            if self.reader.metadata is not None:
                self.writer.add_metadata(self.reader.metadata)

        if remove_images == "YES":
            self.writer.remove_images()

        if remove_images == "NO":
            for page in self.writer.pages:
                for img in page.images:
                    img.replace(img.image, quality=img_quality)

        if compression == "YES":
            for page in self.writer.pages:
                page.compress_content_streams()  # This is CPU intensive!

        self.output = f"{self.files_path}/{self.working_files[0].stem}_{self.subfix}{self.working_files[0].suffix}"

        with open(self.output, "wb") as f:
            self.writer.write(f)

    def check_size(self):
        input_size = os.path.getsize(self.working_files[0])
        output_size = os.path.getsize(self.output)

        if output_size >= input_size:
            error_dialog = self.question(
                title='File is smaller?',
                text='The shrink file is not smaller that the original '
                     'file.\nDo you want to delete the shrunk file?',
                width=450,
                height=60)
            if error_dialog:
                os.remove(self.output)
