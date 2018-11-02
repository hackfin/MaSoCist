#!/bin/bash

sed '0,/^#EOF#$/d' $0 | tar zx; exit 0
#EOF#
