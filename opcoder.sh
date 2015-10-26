#!/bin/bash
# Obviously you need objdump and grep for this. Make sure egrep is an alias for grep -e
# This script will convert an assembled/compiled file into shellcode (provided some assumptions are met)
if [ $# -lt 1 ]; then
	echo "Please supply a parameter." 1>&2
	exit -1
fi
if [ ! -f ${1} ]; then
	echo "'${1}' is not a valid file." 1>&2
	exit -1
fi
SHOW=1
if [ $# -ge 2 ]; then
	if [[ "${2}" == "-q" ]]; then
		SHOW=0
	fi
fi
if [ $SHOW -eq 1 ]; then
	objdump -M intel -D $1
fi
LENGTH=0
echo -e "Shellcode:"
for i in `objdump -D $1|tr '\t' ' '|tr ' ' '\n'|egrep '^[0-9a-f]{2}$' `; do echo -n "\x$i"; LENGTH=$((LENGTH+1)); done
echo -e "\n\nLength: ${LENGTH} Bytes"
exit 0
