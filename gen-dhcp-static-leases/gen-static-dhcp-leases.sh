#!/bin/bash
#Autor:Andrei


##VARIAVEIS
FX=NOMEOUTPUT
BASE=/home/user


#COLOR
CY='\033[01;33m'        # bold yellow
CR='\033[01;31m'        # bold red
RST='\033[00;00m'       # normal white

echo
echo -en ${CY}"Qual o INICIO DO RANGE IP: ex: 172.16.0.10: "${RST}
read inirange
echo


INI=`echo $inirange | awk -F'.' '{print $4}'`;


BI3=`echo $inirange | awk -F'.' '{print $3}'`;

echo
echo -en ${CY}"Qual o FIM DO RANGE IP ex: 172.16.4.100: "${RST}
read fimrange
echo

FIMU=`echo $fimrange | awk -F'.' '{print $4}'`;


echo
echo -en ${CY}"Qual o ALIAS: "${RST}
read alias
echo


#getIP
BF1=`echo $inirange | awk -F'.' '{print $1}'`;
BF2=`echo $inirange | awk -F'.' '{print $2}'`;
BF3=`echo $fimrange | awk -F'.' '{print $3}'`;

LADD=2
FIM=255

#INICIANDO VARIAVEL
cp -f $BASE/list.empty $BASE/listapronta-$FX

for ((i = $BI3; i<=$BF3; i++))
do
if [ $BI3 == $BF3  ]; then
    for ((j = $INI; j<=$FIMU; j++))
    do
        sed -i ''$LADD'i\#host '$alias' { hardware ethernet 00:00:00:00:00:00; fixed-address '$BF1'.'$BF2'.'$i'.'$j';}\'  $BASE/listapronta-$FX

        LADD=`expr $LADD + 1`
    done
else
    if [ $i == $BF3  ]; then
            FIM=$FIMU
    fi
    for ((j = $INI; j<=$FIM; j++))
    do
        sed -i ''$LADD'i\#host '$alias' { hardware ethernet 00:00:00:00:00:00; fixed-address '$BF1'.'$BF2'.'$i'.'$j';}\'  $BASE/listapronta-$FX
        LADD=`expr $LADD + 1`
    done
    INI=1
fi
done

sed -i '/^$/d' $BASE/listapronta-$FX

