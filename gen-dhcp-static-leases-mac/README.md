[![Blog](https://img.shields.io/website?down_color=blue&down_message=infrati.dev&label=Blog&logo=ghost&logoColor=green&style=for-the-badge&up_color=blue&up_message=infrati.dev&url=https%3A%2F%2Finfrati.dev)](https://infrati.dev)

## 📋 infratidev

### Geração de um lease dhcp estático baseado em uma entrada .csv 

Houve a necessidade de alocar estaticamente os IPs baseado no MAC, para uma migração de pabx com muitos ramais. 

Extraimos do banco de dados um .csv com os campos

| Ramal |  Nome  | IP  | MAC |
| ----- |  ----- | --- | --- |
| 4001  | Nome1 | 192.168.187.45 | 00:0c:83:bc:9a:83 |
| 4002  | Nome2 | 192.168.187.46 | 00:0c:83:bc:9a:84 |
| 4003  | Nome3 | 192.168.187.47 | 00:0c:83:bc:9a:85 |
| 4004  | Nome4 | 192.168.187.48 | 00:0c:83:bc:9a:86 |

Arquivo ```list-mac-ip.csv``` foi removido a linha com os nomes das colunas deixando apenas as informações como abaixo separado por virgula.

```list-mac-ip.csv``` deve terminar com uma nova linha ou os dados após a última nova linha podem não ser lidos corretamente (ISO/IEC 9899:2011 §7.21.2 Streams)

~~~
4001,Nome1,192.168.187.45,00:0c:83:bc:9a:83
4002,Nome2,192.168.187.46,00:0c:83:bc:9a:84
4003,Nome3,192.168.187.47,00:0c:83:bc:9a:85
4004,Nome4,192.168.187.48,00:0c:83:bc:9a:86
Linha em branco
~~~

Executando script.

```chmod +x gen-static-dhcp-leases-mac-ip.sh```

```./gen-static-dhcp-leases-mac-ip.sh```

Output para visualização:

~~~
Ramal: 4001
Nome : Nome1
IP : 192.168.187.45
MAC : 00:0c:83:bc:9a:83
Ramal: 4002
Nome : Nome2
IP : 192.168.187.46
MAC : 00:0c:83:bc:9a:84
Ramal: 4003
Nome : Nome3
IP : 192.168.187.47
MAC : 00:0c:83:bc:9a:85
Ramal: 4004
Nome : Nome4
IP : 192.168.187.48
MAC : 00:0c:83:bc:9a:86
~~~

lease gerado no formato no arquivo ```readyfile.txt```

~~~
host 4001-Nome1 { hardware ethernet 00:0c:83:bc:9a:83; fixed-address 192.168.187.45;}
host 4002-Nome2 { hardware ethernet 00:0c:83:bc:9a:84; fixed-address 192.168.187.46;}
host 4003-Nome3 { hardware ethernet 00:0c:83:bc:9a:85; fixed-address 192.168.187.47;}
host 4004-Nome4 { hardware ethernet 00:0c:83:bc:9a:86; fixed-address 192.168.187.48;}
~~~



<br>

[![Blog](https://img.shields.io/website?down_color=blue&down_message=infrati.dev&label=Blog&logo=ghost&logoColor=green&style=for-the-badge&up_color=blue&up_message=infrati.dev&url=https%3A%2F%2Finfrati.dev)](https://infrati.dev)