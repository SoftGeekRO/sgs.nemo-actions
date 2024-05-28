import sys
import platform
from pathlib import Path

from .yad import yad

uname = platform.uname()


class SGSActions:

	raw_files = sorted(sys.argv[1:])[0].split(',')
	working_files = [Path(_file) for _file in raw_files]

	default_producer = f'sgs.nemo-actions_{uname.system}_{uname.node}_{uname.machine}'

	dialog_fields = ()

	def __init__(self, *args, **kwargs):
		self.dialog = yad.YAD(exefile='/usr/bin/yad --fixed')

	def form(self, title, fields, width="800", height="150", cols=2, **kwargs):
		return self.dialog.Form(
			fields=fields,
			title=title,
			width=width,
			height=height,
			cols=cols,
			**kwargs
		)

