#!/bin/sh
DEVICE=/dev/ttyUSB0
DIR=`dirname $0`

stty -F $DEVICE raw icanon eof \^d 115200
st-flash write $DIR/speed.bin 0x8000000

echo ""
echo "============== STARTING Benchmark =============="
echo ""


cat < $DEVICE
