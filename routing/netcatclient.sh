#!/bin/bash

SECONDS=0
nc $1 9999 -q 0 < pliktestowy.bin
duration=$SECONDS
echo "$(($duration/60)) min $(($duration%60))s";
