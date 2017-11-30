#!/bin/bash

################
## fbhto.sh ##
################

####
##  fbhto
##  From black hole to organized
##  
##  Script para monitorar, em tempo real, o aparecimento
##  de arquivos numa pasta de entrada, também chamada de
##  buraco negro ou pasta da bagunça, e para transferir este
##  arquivo de forma organizada para a sua devida pasta e com
##  um nome que ajude na organização e recuperação posterior
##  dos arquivos.
##
##  (c) 2017 by Antonio Augusto de Cintra Batista <antonio.a.c.batista@gmail.com>
##  Licensed under GNU GPL v3
##  Version 0.2.0 - 2017-10-08
##  Version 0.2.3 - 2017-10-23
##  Version 0.2.4 - 2017-10-24
##
####

source /usr/lib/fbhto/common-lib.sh
source /usr/lib/fbhto/fbhto-lib.sh

###
# read the configuration files
###
# regular expression: expected configuration line sintax
regExpConf='^[a-zA-Z0-9\._-]+=[a-zA-Z0-9\.\$/_"-]'
numLinha=0
while read -r linha; do
  ((numLinha++))
  linha=$(echo "$linha" |sed -e 's#^[[:space:]]*##g' |sed -e 's/^\(.*\)#.*$/\1/g' |sed -e 's#[[:space:]]*$##g')
  if [[ "${linha:0:1}" != "#" && "${linha:0:1}" != "" ]]; then
  # skip comments
    if [[ "$linha" =~ $regExpConf ]]; then
    # conf line will be accepted
      fNesteNivelDeDebugEscrever 7 "linha $numLinha: ""$linha"
      eval "$linha"
    else
      fNesteNivelDeDebugEscrever 0 "SINTAX ERROR found at line $numLinha of /etc/fbhto/fbhto.conf"
      fNesteNivelDeDebugEscrever 0 "$linha"
      exit 1
    fi
  fi
done </etc/fbhto/fbhto.conf

monitoraPasta() {
  # inotify events: modify attrib moved_to moved_from move_self create delete delete_self unmount
  deviceNumberBh=$(stat -c '%d' "$pastaBh")
  local pasta="$1"
  houveInterrupcao=0
  trap fechaTudo SIGHUP SIGINT SIGTERM SIGQUIT
  while read -r linha; do
    trap vaiMasVolta SIGHUP SIGINT SIGTERM SIGQUIT
    fNesteNivelDeDebugEscrever 7 "linha gerada pelo inotifywait: ""$linha"
    agora=$(date +%Y-%m-%d_%H.%M.%S-%s)
    arquivo=$(echo "$linha" |awk -F ";" '{ print $2 }')
    if ! [[ "$arquivo" =~ \.part$ || "$(basename "$arquivo")" == "$(basename "$arquivoListaDeNovidades")" ]]; then
      deviceNumberArquivo=$(stat -c '%d' "$arquivo")
      fNesteNivelDeDebugEscrever 7 "linha gerada pelo inotifywait: ""$linha"
      fNesteNivelDeDebugEscrever 0 "arquivo que chegou ao bh: ""$arquivo"
      fNesteNivelDeDebugEscrever 5 "pastaBh/: ""$pastaBh""/"
      if [[ ( "$pastaBh""/" != "$arquivo" ) && ( ! -d "$arquivo" ) ]]; then
        extensaoDoArquivo "$arquivo"
        recuperaMetatag "$arquivo"
        extraiFileTime
        decideOndeColocar "$arquivo"
        posProcessa "$arquivoNoDestino"
        # echo "$agora"";""$arquivo"" transferido para ""$pastaDestino" >> "$arquivoDeLog"
      elif [[ ( -d "$arquivo" ) && ( $deviceNumberArquivo -eq $deviceNumberBh ) ]]; then
        # $arquivo é uma pastae estáno mesmo device number que o blackhole
        while IFS= read -d $'\0' -r arq ; do
          extensaoDoArquivo "$arq"
          recuperaMetatag "$arq"
          extraiFileTime
          decideOndeColocar "$arq"
          posProcessa "$arquivoNoDestino"
        done < <(find "$arquivo" -type f -print0)
      fi
    fi
    [[ $houveInterrupcao == 1 ]] && fechaTudo
    trap fechaTudo SIGHUP SIGINT SIGTERM SIGQUIT
  done < <(inotifywait -m -r -e close_write -e moved_to "$pasta" --format "%e;%w%f;" --quiet --fromfile "$arquivoComListaDeExclusao" --excludei "tmp$")
  trap fechaTudo SIGHUP SIGINT SIGTERM SIGQUIT
}

apresentacao() {
  printf "\nEste script irá monitorar, em tempo-real, a pasta %s\n\nCaso algum arquivo colocado nesta pasta, ele será transferido imediatamente para a pasta %s, caso seja possível organizá-lo, ou para a pasta %s, caso este aplicativo ainda não saiba como fazer para o organizar.\n\nOs logs correspondentes serão gerados e deverão estar disponíveis para consulta no arquivo:\n\t%s\n\n" "$pastaBh" "$pastaDestino" "$pastaDestinoIncerto" "$arquivoDeLog"
}

##############
####      ####
###  main  ###
####      ####
##############

# testa se as pastas existem
[ -d "$pastaDeConfiguracao" ] || { mkdir -p "$pastaDeConfiguracao" ;touch "$arquivoComListaDeExclusao" ;}
[ -e "$arquivoComListaDeExclusao" ] || touch "$arquivoComListaDeExclusao"
[ -d "$pastaBh" ] || { mkdir -p "$pastaBh" ;}
[ -d "$pastaDestino" ] || { mkdir -p "$pastaDestino" ;}
[ -d "$pastaDestinoIncerto" ] || mkdir -p "$pastaDestinoIncerto"
[ -d "$pastaBaseDeLog" ] || mkdir -p "$pastaBaseDeLog"

if [[ "$(which exiftool)" == "" ]]; then
  echo
  echo "ERRO!!! exiftool não foi instalado ainda."
  echo "Em sistemas Debian GNU/Linux é necessário instalar o pacote libimage-exiftool-perl"
  echo "ERRO!!! exiftool não foi instalado ainda." >>"$arquivoDeLog"
  echo "Em sistemas Debian GNU/Linux é necessário instalar o pacote libimage-exiftool-perl" >>"$arquivoDeLog"
  exit 1
fi

if [[ "$(which inotifywait)" == "" ]]; then
  echo
  echo "ERRO!!! inotifywait não foi instalado ainda."
  echo "Em sistemas Debian GNU/Linux é necessário instalar o pacote inotify-tools"
  echo "ERRO!!! inotifywait não foi instalado ainda." >>"$arquivoDeLog"
  echo "Em sistemas Debian GNU/Linux é necessário instalar o pacote inotify-tools" >>"$arquivoDeLog"
  exit 1
fi

if [ -e "$pastaBh" ]; then
  if [ ! -d "$pastaBh" ]; then
    echo
    echo "ERRO!!! Favor verificar:"
    echo "$pastaBh"" existe e deveria ser um diretório, mas não é."
    echo "ERRO!!! Favor verificar:" >>"$arquivoDeLog"
    echo "$pastaBh"" existe e deveria ser um diretório, mas não é." >>"$arquivoDeLog"
    echo
    exit 1
  fi
else
  mkdir -p "$pastaBh"
fi

apresentacao

# seta permissões, owner e group
chown -R www-data:www-data "$pastaBh"
while IFS= read -d $'\0' -r arq ;do
  [ -d "$arq" ] && chmod 755 "$arq"
  [ -f "$arq" ] && chmod 644 "$arq"
done < <(find "$pastaBh" -print0)

trap fechaTudo SIGHUP SIGINT SIGTERM SIGQUIT

# monitoraPasta "$pastaBh" &
monitoraPasta "$pastaBh"

