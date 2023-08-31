#!/usr/bin/env python3
import argparse
import tempfile
import dbus
import sys

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--include-cursor", action="store_true", default=False)
	parser.add_argument("--flash", action="store_true", default=False)
	args = parser.parse_args()

	bus = dbus.SessionBus()

	bus.request_name("org.gnome.Screenshot", dbus.bus.NAME_FLAG_REPLACE_EXISTING)

	with tempfile.NamedTemporaryFile() as tf:
		(success, filename) = bus.call_blocking("org.gnome.Shell",
							"/org/gnome/Shell/Screenshot",
							"org.gnome.Shell.Screenshot",
							"Screenshot",
							"bbs", [args.include_cursor, args.flash, tf.name])

		assert success

		with open(filename, "rb") as f:
			while (data := f.read(1 << 20)):
				sys.stdout.buffer.write(data)

if __name__ == "__main__":
	try:
		main()
	except:
		# Catch-all: prevent errors (due to no open display) being found by apport crash reporter
		import logging
		logging.basicConfig()
		logging.error('Error: ', exc_info=True)
		pass
