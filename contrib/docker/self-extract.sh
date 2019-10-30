#!/bin/bash

sed '0,/^#MASOCIST_EOF#$/d' $0 | tar xz; exit 0
#MASOCIST_EOF#
