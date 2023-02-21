#!/bin/bash

# MD5 of the key, get the first 2 bytes and convert to number
md5_2="$(echo $1 | openssl dgst -md5 -binary | xxd -ps -b -l 2 | sed 's/[^0-9]*//g')"
echo $(echo "obase=10;ibase=2;$md5_2" | bc)
