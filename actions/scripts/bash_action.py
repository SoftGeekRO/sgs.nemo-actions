#!/usr/bin/env python3

import subprocess
import sys

ZENITY_WITH_OPTIONS = 'zenity --progress --title=Working... --auto-close'


def exec_command(command):
	log = ''
	print(f"Executing \"{command}\"")
	log += f"\n\n=> Executing \"{command}\"\n"
	try:
		result = subprocess.run(command, shell=True, capture_output=True, text=True,
														check=True)
		log += result.stdout
	except subprocess.CalledProcessError as e:
		log += e.output
		raise
	return log


def percent(done, total):
	percent = (done / total) * 100
	print(f"\n--- {percent} %\n")
	return percent


if __name__ == "__main__":
	if len(sys.argv) < 3:
		print("Usage: script.py <command_line> <filenames>...")
		sys.exit(1)

	command_line = sys.argv[1]
	filenames = sys.argv[2:]

	print(f"Will apply command \"{command_line}\" on {len(filenames)} files\n\n")

	try:
		with subprocess.Popen(ZENITY_WITH_OPTIONS.split(), stdin=subprocess.PIPE,
													text=True, bufsize=1) as process:
			done = 0
			for filepath in filenames:
				print('=> file: ' + filepath)
				file_command_line = command_line.replace('{}', filepath)
				exec_command(file_command_line)
				done += 1
				process.stdin.write(str(percent(done, len(filenames))))
				process.stdin.write('\n')
				process.stdin.flush()
	except subprocess.CalledProcessError as e:
		print(f"Error received: {e}")
		output = e.output.replace('\"', '\\\"')
		subprocess.run(
			["zenity", "--width", "500", "--error", "--no-wrap", "--text",
			 f"Subprocess error:\n\n{output}"])
		sys.exit(1)

	print("\nEND")
	subprocess.run(["zenity", "--info", "--text", "End"])
