# SoftGeek Romania internal Nemo actions

This collection of Nemo actions are used in our internal workflow to make our
lives better.
All our company workflows are bases on Linux and opensource resources.

In this repo we have collected all the Nemo actions that are used to post, edit,
and optimize of documents, images, blog, post, online store images and
descriptions.

## Audio / Video

## Images
* **image_resize_*** : use **convert** (ImageMagick) to resize images on specific sizes and put the images in a **resize**/ subdir
* **convert_to_*** : use **mogrify** (ImageMagick) to convert images to specific format WebP, PNG, GIF with 90% quality

## PDF actions
* **pdf2images** : use **pdfimages** command (`poppler-utils` package in Debian) to convert PDF pages in images and place them in "pdf2images" subdir
* **img2pdf** : use [img2pdf utility](https://pypi.org/project/img2pdf/) to create a PDF file from selected images


## Others actions
* **print** : print selected file using default printer settings
* **printlibreoffice** : print LibreOffice files with default LibreOffice print settings
* **refresh** : refresh the Nemo interface, basically is a right click menu shortcut for CTRL+R
* **python3** : Run any python file using python3 exec

## Nemo Action installation

These instructions assume a Debian/Ubuntu based distro for the commands to
install dependencies. For users of other distros please replace `sudo apt`
with the equivalent for your distro's package management system.

First install git

```bash
sudo apt install git
```

Then clone this repo

```bash
git clone https://github.com/SoftGeekRO/sgs.nemo-actions.git
```

Having cloned the repo you can either install all the actions using the
commands below or refer to the index of actions to install individual actions.

To install all the nemo actions use the install.sh bash file. Make sure that the
file is executable.

```bash
chmod a+x install.sh
```
For install.sh you have three options: _install_, _uninstall_ and _reinstall_.

```bash
./install.sh install
```
this command will crate soft links of all the actions inside you home profile Nemo
actions folder, under `/~.local/share/nemo/actions`

### Other installation needed
  - install zenity
  - install lame (to use audio conversion scripts)
  - restart nemo (`nemo -q; nemo`)

### Other dependencies

  - Imagemagick (`apt install imagemagick`) to use images resizing
  - ffmpeg (`apt install ffmpeg`) to use video tools
  - sox (`apt install sox`) to use wav's concatenation tools
  - lame (`apt install lame`) to use audio conversions tools
  - flac (`apt install flac`) to use flac compression tools
  - pdfimages (`apt install poppler-utils`) to use PDF images extraction tools
  - pdf_repair (`apt install qpdf`) to use PDF file repairing tools
  - pdf2djvu (`apt install pdf2djvu`) to use PDF to DJVU conversion tool
  - img2pdf (`apt install img2pdf`) to convert any image to pdf
  - Thunar (`apt install thunar`) to use mass rename action

All in one:

```bash
apt install imagemagick ffmpeg sox lame flac pdfimages pdf_repair poppler-utils pdf2djvu thunar img2pdf
```

## Nemo Action updating

In a terminal navigate to the `sgs.nemo-actions` folder created when you
originally cloned the repo

e.g `cd sgs.nemo-actions`

Once in the correct folder update your local copy with the latest commits,
before reinstalling your actions.

`git pull origin; cd ..`

## Debug

`nemo -q; NEMO_DEBUG=Actions NEMO_ACTION_VERBOSE=5 nemo --debug`

## Write an action

To make scripts executed to multiple files with a progress bar,
use `bash_action.sh`. Simple example:
  - execute `ls` command on each selected files:
    `Exec=<scripts/bash_action.py "ls {}" %F>`
  - same effect, but adding a bash variable:
    `Exec=<scripts/bash_action.py "filename={}; ls \"$filename\"" %F>`

Take a look to existing actions. Particularly `flac_to_wav.nemo_action` is a simple real-world example.

To specify icon you can use `Icon-Name`. Available icons are located in `/usr/share/icons/gnome/32x32/actions`.

## Debug actions (show actions logs and Nemo errors about actions)

```
nemo -q; NEMO_ACTION_VERBOSE=1 nemo --no-desktop
```

### Some tricks:
- the space between `"` and `%F>` is important; ie `"%F>` will **not** work