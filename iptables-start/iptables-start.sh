#!/bin/bash


#Variaveis#########################################################################
host=XXX
infrati=IP
sshport=XXX
###################################################################################

#Listas ###########################################################################
LSSH=($infrati)
###################################################################################

case "$1" in
  start)
    printf "Iniciando o servico $host  de %s:       [  OK  ]" "IPTables"

    # Habilitando Roteamento
    echo
    echo 1 > /proc/sys/net/ipv4/ip_forward

    #Política de base
    /sbin/iptables -P INPUT DROP
    /sbin/iptables -P FORWARD DROP

    #Não bloquear o tráfego interno no dispositivo de loopback
    /sbin/iptables -A INPUT -i lo -j ACCEPT

    #Continue as conexões que já estão estabelecidas ou relacionadas a um estabelecido conexão
    /sbin/iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    #Elimine pacotes não conformes, como cabeçalhos malformados, etc.
    /sbin/iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

    #Bloqueia pacotes remotos que afirmam ser de um endereço de loopback
    /sbin/iptables -A INPUT -s 127.0.0.0/8 ! -i lo -j DROP

    #Elimine todos os pacotes que vão transmitir, broadcast, multicast ou endereço anycast
    /sbin/iptables -A INPUT -m addrtype --dst-type BROADCAST -j DROP
    /sbin/iptables -A INPUT -m addrtype --dst-type MULTICAST -j DROP
    /sbin/iptables -A INPUT -m addrtype --dst-type ANYCAST -j DROP
    /sbin/iptables -A INPUT -d 224.0.0.0/4 -j DROP

    # Evitar inundação de ping - até 6 pings por segundo de um único source
    # com limitação de log. Também nos impede de inundações ICMP REPLY
    # alguma vítima ao responder ao ICMP ECHO de uma fonte falsificada
    /sbin/iptables -N ICMPFLOOD
    /sbin/iptables -A ICMPFLOOD -m recent --set --name ICMP --rsource
    /sbin/iptables -A ICMPFLOOD -m recent --update --seconds 1 --hitcount 6 --name ICMP --rsource --rttl -m limit --limit 1/sec --limit-burst 1 -j LOG --log-prefix "/sbin/iptables[ICMP-flood]: "
    /sbin/iptables -A ICMPFLOOD -m recent --update --seconds 1 --hitcount 6 --name ICMP --rsource --rttl -j DROP
    /sbin/iptables -A ICMPFLOOD -j ACCEPT

    #Atendendo a RFC 792 todos hosts devem responder requisicoes de ICMP ECHO
    /sbin/iptables -A INPUT -p icmp -m icmp --icmp-type 0  -m conntrack --ctstate NEW -j ACCEPT
    /sbin/iptables -A INPUT -p icmp -m icmp --icmp-type 3  -m conntrack --ctstate NEW -j ACCEPT
    /sbin/iptables -A INPUT -p icmp -m icmp --icmp-type 8  -m conntrack --ctstate NEW -j ICMPFLOOD
    /sbin/iptables -A INPUT -p icmp -m icmp --icmp-type 11 -m conntrack --ctstate NEW -j ACCEPT

    #A boa prática é rejeitar explicitamente o tráfego AUTH para que ele falhe rapidamente
    /sbin/iptables -A INPUT -p tcp -m tcp --dport 113 --syn -m conntrack --ctstate NEW -j REJECT --reject-with tcp-reset

    #Previnir DOS pelo preenchimenton de arquivos de logs
    /sbin/iptables -A INPUT -m limit --limit 1/second --limit-burst 100 -j LOG --log-prefix "iptables[DOS]: "

    #Protecao contra port scanners ocultos
    /sbin/iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
    /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
    /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
    /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
    /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
    /sbin/iptables -A INPUT   -p tcp --tcp-flags ACK,FIN FIN -j DROP
    /sbin/iptables -A INPUT   -p tcp --tcp-flags ACK,PSH PSH -j DROP
    /sbin/iptables -A INPUT   -p tcp --tcp-flags ACK,URG URG -j DROP
    /sbin/iptables -A INPUT   -p tcp --tcp-flags ALL ALL -j DROP
    /sbin/iptables -A INPUT   -p tcp --tcp-flags ALL NONE -j DROP

    ############################################################################################################
    # Liberando SSH
    for ((i = 0; i<${#LSSH[@]}; i++))
    do
        /sbin/iptables -A INPUT -p tcp -s "${LSSH[i]}"  --dport $sshport --syn -m conntrack --ctstate NEW -j ACCEPT
    done
    ###########################################################################################################

  ;;
  stop)
    printf "Parando o servico $host de %s:         [  OK  ]" "IPTables"
    echo
    /sbin/iptables -P INPUT ACCEPT
    /sbin/iptables -P FORWARD ACCEPT
    /sbin/iptables -F
    /sbin/iptables -t nat -F
    /sbin/iptables -X

  ;;
  *)
     printf "Parar ou iniciar o servico $host: iptables-start (start|stop)"
     echo
  ;;
esac
exit 0
