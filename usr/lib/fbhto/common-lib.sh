#!/bin/bash
####
##  common-lib.sh  From black hole to organized
##
##  Algumas rotinas comuns usadas em meus scripts
##
##  (c) 2015 by Antonio Augusto de Cintra Batista <antonio@unesp.br>
##  Licensed under GNU GPL v3
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

PATH=/bin:/usr/bin:/sbin:/usr/sbin
processoId=$$
argumento="$1"
nomeDoScript=$(basename "$0")
hostName=$(hostname -f)
pastaShm="$(df |grep "shm$" |sed -e 's#.*\(/.*/shm$\)#\1#g')"

# testa se algumas variáveis foram declaradas antes da chamada desta biblioteca
if [[ -z ${nivelLimiteDeDebugParaNaoEscreverNoLog+x} ]]; then
  # nivelLimiteDeDebugParaNaoEscreverNoLog não é ainda uma variável declarada
  nivelLimiteDeDebugParaNaoEscreverNoLog=3
fi
if [[ -z ${nivelDeDebugEscolhidoParaExecucao+x} ]]; then
  # nivelDeDebugEscolhidoParaExecucao não é ainda uma variável declarada
  nivelDeDebugEscolhidoParaExecucao=3
fi
####################################################
# serão mostradas as mensagens executadas em       #
# nível inferior ao                                #
# nivelLimiteDeDebugParaNaoEscreverNoLog           #
#                                                  #
# Ele deve ser um número inteiro maior que 0.      #
####################################################
if [[ -z ${arquivoDeLog+x} ]]; then
  # arquivoDeLog não é ainda uma variável declarada
  arquivoDeLog="/var/log/fbhto.log"
fi


fAgora() {
  agora=$(date +%Y-%m-%d_%H.%M.%S-%s)
  hoje=$(date +%Y-%m-%d)
  hora=$(date +%H)
  minutos=$(date +%M)
  nanoSegundosDesde1970=$(date +%s%N)
  segundosDesde1970=$(date +%s)
  ano=$(date +%Y)
  semana=$(date +%U)
  diaDoAno=$(date +%Y-%m-%d)
}

fNesteNivelDeDebugEscrever() {
  local localLevel="$1" localMessage="$2" tempo="" script=""
  tempo=$(date +%s"; "%Y.%m.%d-%Hh%Mm%Ss)
  script="$(basename "$0")"
  if [[ $nivelLimiteDeDebugParaNaoEscreverNoLog -gt $localLevel ]]; then
    horario=$(date +%s"; "%Y.%m.%d-%Hh%Mm%Ss)
    printf "%s; %s; %s\n" "$script" "$horario" "$localMessage"
    printf "%s; %s; %s\n" "$script" "$horario" "$localMessage" >>$arquivoDeLog
  fi
}

fMostraLinha() {
  # esta rotina é útil para debugar o código
  # Se ela for chamada exatamente assim: fMostraLinha "$BASH_SOURCE" $LINENO
  # ela mostrará a linha onde foi executada
  if $mostraLinhas; then
    NOME_ARQUIVO=$1
    LINHA=$2
    nomeDoScript=$(basename "$NOME_ARQUIVO")
    extensao="${nomeDoScript##*.}"
    nomeDoScript="${nomeDoScript%.*}"
    fNesteNivelDeDebugEscrever $nivelDeDebugEscolhidoParaExecucao "$nomeDoScript  $LINHA"
  fi
}

vaiMasVolta() {
  trap - SIGHUP SIGINT SIGTERM SIGQUIT
  houveInterrupcao=1
  echo
  echo "Interrupção solicitada."
  return
}

fechaTudo() {
  trap - SIGHUP SIGINT SIGTERM SIGQUIT
  echo
  echo -n "Fechando tudo ... "
  echo "OK."
  kill -- -$$
  exit 1
}


