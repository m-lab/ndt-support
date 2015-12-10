#!/usr/bin/python
"""logger.py reads from stdin and writes a log. Log files are rotated daily.

At most two backup files are preserved.
"""

import sys
import logging
import logging.handlers


if len(sys.argv) == 1:
  sys.stderr.write('Please provide filename for writing logs.')
  sys.exit(1)

# Rotate the log file every 1 day ('d'), keeping at most 2 backups.
# This means there can be three files: current, backup 1, backup 2.
handler = logging.handlers.TimedRotatingFileHandler(
    sys.argv[1], interval=1, when='d', backupCount=2, utc=True)

# Default logger config does not prefix log messages with any extra information.
log = logging.getLogger()
log.setLevel(logging.INFO)
log.addHandler(handler)

while True:
  line = sys.stdin.readline()
  if not line:
    break
  # Strip line to prevent double newlines in output.
  log.info(line.rstrip())
