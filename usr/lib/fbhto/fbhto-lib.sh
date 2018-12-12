#!/bin/bash
####
##  fbhto-lib.sh
##
##  Rotinas específicas do fbhto - From black hole to organized
##  Estas rotinas implementam o que fazer com cada tipo de arquivo
##  colocado no buraco negro.
##
##  (c) 2017 by Antonio Augusto de Cintra Batista <antonio.a.c.batista@gmail.com>
##  Licensed under GNU GPL v3
##
##  2017-10-13: first version
##
####
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, version 3 of the License.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see http://www.gnu.org/licenses/
##
####
regExpImage='bmp$|fpx$|gif$|ico$|j2c$|j2k$|jfif$|jif$|jp2$|jpe?g$|jpx$|nef$|odg$|pbm$|pcd$|pgm$|png$|pnm$|ppm$|svg$|tif$|tiff$|xcf$'
regExpVideo='avi$|dhmov$|dvx$|f4v$|flv$|gifv$|gvi$|gvp$|h264$|hdv$|ivr$|ivs$|m15$|m1v$|m21$|m2ts?$|m2v$|m4e$|m4v$|m75$|mgv$|mjp$|mjpe?g$|mk3d$|mkv$|mob$|mov$|movie$|mp21$|mp2v$|mp4$|mp4v$|mpe$|mpe?g$|mpeg[124]$|mpg[24]$|og[mvx]$|qtm?$|rm$|rv$|thm$|vid$|vob$|vro$|webm$|wm$|wmv$|wvm$|xvid$|3gp$'
regExpOffice='docx?$|odp$|ods$|odt$|pdf$|pptx?$|ps$|rtf$|sxw$|tex$|wp$|wp[d7]$|xlsx?$'
regExpText='te?xt$|asc$'


extensaoDoArquivo() {
  local arquivo="$1"
  extensao=''
  if [[ "$arquivo" =~ \. ]]; then
    extensao="${arquivo##*.}"
    extensaoParaComparacao=$(echo "$extensao" |tr '[:upper:]' '[:lower:]')
  fi
  nomeDoArquivo=$(basename "$arquivo" |sed -e 's#\(.*\)\.'$extensao'#\1#g')
}

recuperaMetatag() {
  local arquivo="$1"
  if [ "$extensaoParaComparacao" = "part" ]; then
    return
  fi
  metaTag=$(exiftool -d %Y-%m-%d_%H.%M.%S "$arquivo" |grep -i date |egrep -vi '^zip|^link' |grep '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}_[0-9]\{2\}.[0-9]\{2\}.[0-9]\{2\}' |awk -F ":" '{ print $2 }' |sort -n |head -1)
}

extraiFileTime() {
  fileTime=""
  if [ "$extensaoParaComparacao" = "part" ]; then
    return
  fi
  if [[ $nomeDoArquivo =~ ^WhatsApp ]]; then
    fileTime=$(echo $nomeDoArquivo |sed -e 's#.*\([1-9][0-9]\{3\}-[0-9]\{2\}-[0-9]\{2\}\).*\([0-9]\{2\}.[0-9]\{2\}.[0-9]\{2\}\).*#\1_\2#g')
  elif [[ "$metaTag" != "" ]]; then
    fileTime=$(echo "$metaTag" |sed -e 's#^.*\([1-9][0-9]\{3\}-[0-9]\{2\}-[0-9]\{2\}_[0-9]\{2\}.[0-9]\{2\}.[0-9]\{2\}\).*$#\1#g')  # example: 2017-10-13_19.52.15
  fi
}

decideOndeColocar() {
  local arquivo="$1"
  if [ "$extensaoParaComparacao" = "part" ]; then
    return
  fi
  if   [[ $extensaoParaComparacao =~ $regExpImage ]]; then
    pastaParaExtensao="imagem"
  elif [[ $extensaoParaComparacao =~ $regExpOffice ]]; then
    pastaParaExtensao="office"
  elif [[ $extensaoParaComparacao =~ $regExpText ]]; then
    pastaParaExtensao="texto"
  elif [[ $extensaoParaComparacao =~ $regExpVideo ]]; then
    pastaParaExtensao="video"
  else
    pastaParaExtensao="other-file-types"
  fi
  if [[ "$fileTime" != "" ]]; then
    destinoFinal="$pastaDestino"'/'$pastaParaExtensao'/'${fileTime:0:4}'/'${fileTime:5:2}'/'${fileTime:8:2}
    [ -d "$destinoFinal" ] || mkdir -p "$destinoFinal"
    arquivoNoDestino="$destinoFinal"'/'$fileTime'-'"$nomeDoArquivo"
  else
    arquivoNoDestino="$pastaDestinoIncerto""/""$nomeDoArquivo"
  fi
  if [[ "$extensao" != "" ]]; then
    arquivoNoDestino="$arquivoNoDestino"'.'"$extensao"
  fi
  fNesteNivelDeDebugEscrever 7 "arquivoNoDestino: ""$arquivoNoDestino"
  comando='mv -f "'"$arquivo"'" "'"$arquivoNoDestino"'"'
  # move the file to its organized place
  sleep 1
  eval "$comando"
  fNesteNivelDeDebugEscrever 0 "moved: ""$arquivo"" TO ""$arquivoNoDestino"
  echo
}

posProcessa() {
  local arquivoNoDestino="$1"
  if [ "$extensaoParaComparacao" = "part" ]; then
    return
  fi
  /snap/bin/nextcloud.occ files:scan "$bhAccName"
  /snap/bin/nextcloud.occ files:scan "$destAccName"
}

