import sys
import platform
from pathlib import Path

from .yad import yad

from sgzenity import question, error
from sgzenity.SGProgresBar import ProgressBar, Gtk
from sgzenity.thread import WorkerThread

uname = platform.uname()


class ProgressThread(WorkerThread):
    def payload(self):
        loading = self.data
        self.callback()
        if self.stop:
            print('Working thread canceled.')
        else:
            print('Working thread ended.')
        loading.close()


class SGSActions:
    raw_files = sorted(sys.argv[1:])[0].split(',')
    working_files = [Path(_file) for _file in raw_files]

    default_producer = f'sgs.nemo-actions_{uname.system}_{uname.node}_{uname.machine}'

    dialog_fields = ()

    progress_state = 0.0

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

    def question(self, title, text, width=330, height=120,
                 timeout=None):
        return question(title=title, text=text, width=width, height=height,
                        timeout=timeout)

    def error(self, title, text, width=330, height=120, timeout=None):
        return error(title=title, text=text, width=width, height=height,
                     timeout=timeout)

    def progress_callback(self, progress=None):
        return self.progress_state >= 1

    def progress(self, title, text, callback=None):
        loading = ProgressBar(title, text, pulse_mode=True)

        workthread = ProgressThread(loading, callback)
        loading.show(workthread)
        workthread.start()

        Gtk.main()
