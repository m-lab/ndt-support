#!/usr/bin/python
"""logger.py reads from stdin and writes a log. Log files are rotated daily.

At most two backup files are preserved.
"""

import sys
import logging
import logging.handlers


SIZE_100_MB = 100000000


if len(sys.argv) == 1:
  sys.stderr.write('Please provide filename for writing logs.')
  sys.exit(1)

# Rotate the log file when it contains SIZE_100_MB bytes, keeping at most 2
# backups. This means there can be three files: current, backup 1, backup 2
# whose total disk usage is 300 MB.
handler = logging.handlers.RotatingFileHandler(
    sys.argv[1], maxBytes=SIZE_100_MB, backupCount=2)

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
