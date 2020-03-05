#!/bin/bash

echo "nr cwiczenia"
read nr_cwiczenia
echo "nr grupy"
read grupa
echo "nr komputera"
read komputer

nr_grupy=$(($grupa*32))
nr_komputera=$(($komputer*4+2))
faktyczny=$(($nr_grupy+$nr_komputera))

echo "ssh pwsz@172.22.$nr_cwiczenia.$faktyczny"
ssh "pwsz@172.22.$nr_cwiczenia.$faktyczny"
