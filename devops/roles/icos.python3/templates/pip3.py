#!{{ python3_command }}
# -*- coding: utf-8 -*-
# This is a copy of /usr/local/bin/pip3.
import re
import sys
from pip._internal.cli.main import main
if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(main())
