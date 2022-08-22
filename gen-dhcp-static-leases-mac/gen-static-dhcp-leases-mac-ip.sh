#!/bin/bash
#Autor:Andrei

##VARS
LADD=1
FILENAME=readyfile.txt
INPUT=list-mac-ip.csv

LINES=$(sed -n '$=' $INPUT)
EMPTYFILE=$(printf '\n%.0s' {1,$LINES} > $FILENAME)
OLDIFS=$IFS
IFS=','

[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read ramal nome ip mac
do

sed -i ''$LADD'i\host '$ramal-$nome' { hardware ethernet '$mac'; fixed-address '$ip';}'  $FILENAME

	echo "Ramal: $ramal"
	echo "Nome : $nome"
	echo "IP : $ip"
	echo "MAC : $mac"

LADD=$((LADD+1))

done < $INPUT
IFS=$OLDIFS
