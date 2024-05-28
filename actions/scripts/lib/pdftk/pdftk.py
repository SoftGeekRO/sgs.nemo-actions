""" pypdftk_extend

Python extended module to drive the awesome pdftk binary.
See https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/

"""

import os
import subprocess
import logging
import itertools

log = logging.getLogger(__name__)

if os.getenv('PDFTK_PATH'):
	PDFTK_PATH = os.getenv('PDFTK_PATH')
else:
	PDFTK_PATH = '/usr/bin/pdftk'
	if not os.path.isfile(PDFTK_PATH):
		PDFTK_PATH = 'pdftk'


def check_output(*popenargs, **kwargs):
	if 'stdout' in kwargs:
		raise ValueError('stdout argument not allowed, it will be overridden.')
	process = subprocess.Popen(stdout=subprocess.PIPE, *popenargs, **kwargs)
	output, unused_err = process.communicate()
	retcode = process.poll()
	if retcode:
		cmd = kwargs.get("args")
		if cmd is None:
			cmd = popenargs[0]
		raise subprocess.CalledProcessError(retcode, cmd, output=output)
	return output


def run_command(command, shell=False):
	""" run a system command and yield output """
	p = check_output(command, shell=shell)
	return p.decode("utf-8").splitlines()


try:
	run_command([PDFTK_PATH])
except OSError:
	logging.warning('pdftk test call failed (PDFTK_PATH=%r).', PDFTK_PATH)


def dump_data(pdf_path, add_id=False):
	""" Return list of dicts of all fields in a PDF.
	If multiple values with the same key are provided for some fields (like
	FieldStateOption), the data for that key will be a list.
	If id is True, a unique numeric ID will be added for each PDF field.
  """

	cmd = "%s %s dump_data" % (PDFTK_PATH, pdf_path)
	field_data = map(lambda x: x.split(': ', 1), run_command(cmd, True))
	fields = [list(group) for k, group in
						itertools.groupby(field_data, lambda x: len(x) == 1) if not k]
	field_data = []  # Container for the whole dataset
	for i, field in enumerate(
		fields):  # Iterate over datasets for each PDF field.
		d = {}  # Use a dictionary as a container for the data from one PDF field.
		if add_id:
			d = {'id': i}
		for i in sorted(
			field):  # Sort the attributes of the PDF field, then loop through them.
			# Each item i has 2 elements: i[0] is the key (attribute name), i[1] is
			# the data (value).
			if i[0] in d:  # If the key is already present in the dictionary...
				if isinstance(d[i[0]], list):  # ...and the value is already a list...
					d[i[0]].append(i[1])  # ...just append to it.
				else:  # Otherwise (if the value isn't already a list)...
					d[i[0]] = [d[i[0]], i[
						1]]  # ...create a new list with the original and new values.
			else:  # Otherwise (the key isn't already present in the dictionary)...
				d[i[0]] = i[1]  # ...simply add it to the dictionary.
		field_data.append(
			d)  # Finally, add the dictionary for this field to the big container.
	return field_data


def update_info(pdf_path, metadata_file, output_file):
	"""

	:param pdf_path:
	:param metadata_file:
	:param output_file:
	:return:
	"""

	args = [PDFTK_PATH, pdf_path, 'update_info', metadata_file, 'output',
					output_file]
	try:
		run_command(args)
	except:
		raise
