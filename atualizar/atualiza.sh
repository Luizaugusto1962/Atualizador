#!/usr/bin/env bash
# set -xv
#set -e
#-----------------------------------------------------------------------------------------------------------------#
##  Rotina para atualizar programas e bibliotecas da SAV                                                          #
##  Feito por Luiz Augusto   email luizaugusto@sav.com.br                                                         #
##  Versao do atualiza.sh                                                                                         #
## UPDATE 03/10/2023                                                                                              #  
#                                                                                                                 #
# INCLUIR PROCEDIMENTO PARA ATUALIZA PROGRAMA CLASS9 , VARIAVEL 9DIG  											  #
# incluir PACOTE de programas                                                                                     #
#-----------------------------------------------------------------------------------------------------------------#
# Arquivos de trabalho:                                                                                           #
# "atualizac" = Contem a configuracao de diretorios e de qual tipo de                                             #
#               sistema esta sendo utilizado pela a Empresa.                                                      #
# "atualizaj" = Lista de arquivos principais do sistema. "Usado no menu Ferramentas"                              #
# "atualizat" = Lista de arquivos temporarios a ser exclu dos da pasta de dados.                                  #
#               "Usado no menu Ferramentas"                                                                       #
#                                                                                                                 #
# Menus                                                                                                           #
# 1 - Atualizacao de Programas                                                                                    #
# 2 - Atualizacao de Biblioteca                                                                                   #
# 3 - Desatualizando                                                                                              #
# 4 - Versao do Iscobol                                                                                           #
# 5 - Versao do Linux                                                                                             #
# 6 - Ferramentas                                                                                                 #
#                                                                                                                 #
#      1 - Atualizacao de Programas                                                                               #
#            1 - ON-Line                                                                                          #
#      Acessa o servidor da SAV via scp com o usuario ATUALIZA                                                    #
#      Faz um backup do programa que esta em uso e salva na pasta ?/sav/tmp/olds                                  #
#      com o nome "Nome do programa-anterior.zip" descompacta o novo no diretorio                                 #
#      dos programa e salva o a atualizacao na pasta ?/sav/tmp/progs.                                             #
#            2 - OFF-Line                                                                                         #
#      Atualiza o arquivo de programa ".zip" que deve ter sido colocado em ?/sav/tmp.                             #
#      O processo de atualizacao e id ntico ao passo acima.                                                       #
#      2 - Atualizacao de Biblioteca                                                                              #
#            1 - Atualizacao do Transpc                                                                           #
#      Atualiza a biblioteca que esta no diretorio /u/varejo/trans_pc/ do servidor da SAV.                        #
#      Faz um backup de todos os programas que esta em uso e salva na pasta ?/sav/tmp/olds                        #
#      com o nome "backup-(versao Informada).zip" descompacta os novos no diretorio                               #
#      dos programas e salva os zips da biblioteca na pasta ?/sav/tmp/biblioteca mudando a                        #
#      extensao de .zip para .bkp.                                                                                #
#            2 - Atualizacao do Savatu                                                                            #
#      Atualiza a biblioteca que esta no diretorio /home/savatu/biblioteca/temp/(diretorio                        #
#      conforme  sistema que esta sendo usado.                                                                    #
#      Mesmo procedimento acima.                                                                                  #
#            3 - Atualizacao9 OFF-Line                                                                             #
#      Atualiza a biblioteca que deve estar salva no diretorio ?/sav/tmp                                          #
#      Mesmo procedimento acima.                                                                                  #
#                                                                                                                 #
#      3 - Desatualizando                                                                                         #
#            1 - Voltar programa Atualizado                                                                       #
#      Descompacta o arquivo salvo anteriormente em ?/sav/tmp/olds com o nome de ("programa"-anterior.zip)        #
#      na pasta dos programas.                                                                                    #
#                                                                                                                 #
#            2 - Voltar antes da Biblioteca                                                                       #
#      Descompacta o arquivo salvo anteriormente em ?/sav/tmp/olds com nome ("backcup-versao da biblioteca".zip)  #
#      na pasta dos programas.                                                                                    #
#                                                                                                                 #
#      4 - Versao do Iscobol                                                                                      #
#            Verifica qual a versao do iscobol que esta sendo usada.                                              #
#                                                                                                                 #
#      5 - Versao do Linux                                                                                        #
#            Verifica qual o Linux em uso.                                                                        #
#                                                                                                                 #
#      6 - Ferramentas                                                                                            #
#           1 - Limpar Temporarios                                                                                #
#               Le os arquivos da lista "atualizat" compactando na pasta ?/sav/tmp/backup                         #
#               com o nome de Temp(dia+mes+ano) e excluindo da pasta de dados.                                    #
#                                                                                                                 #
#           2 - Recuperar arquivos                                                                                #
#               1 - Um arquivo ou Todos                                                                           #
#                   Opcao pede para informa um arquivo espec fico, somente o nome sem a extensao                  #
#                   ou se deixar em branco o nome do arquivo vai recuperar todos os arquivos com as extens es,    #
#                   "*.ARQ.dat" "*.DAT.dat" "*.LOG.dat" "*.PAN.dat"                                               #
#                                                                                                                 #
#               2 - Arquivos Principais                                                                           #
#                   Roda o Jtuil somente nos arquivos que estao na lista "atualizaj"                              #
#                                                                                                                 #
#           3 - Backup da base de dados                                                                           #
#               Faz um backup da pasta de dados  e tem a opcao de enviar para a SAV                               #
#           4 - Restaurar Backup da base de dados                                                                 #
#               Volta o backup feito pela opcao acima                                                             #
#           5 - Enviar Backup                                                                                     #
#               Enviar ZIP feito pela opcao 3                                                                     #
#           6 - Expurgar                                                                                          #
#               Excluir, zips e bkps com mais de 30 dias processado                                               #
#                                                                                                                 #
#                                                                                                                 #
#-----------------------------------------------------------------------------------------------------------------#

#-------------------------- VARIAVEIS ----------------------------#
destino=""
pasta=""
base=""
logs=""
exec=""
class=""
telas=""
xml=""
olds=""
progs=""
backup=""
sistema=""
SAVATU1=""
SAVATU2=""
SAVATU3=""
SAVATU4=""

#### configurar as variaveis em ambiente no arquivo abaixo:    ####
source ./atualizac

#-----------------------------------------------------------------#
## Comandos 
cmd_unzip=""
cmd_unzip="unzip"
##
cmd_find=""
cmd_find="find"
##
cmd_scp=""
cmd_scp="scp"
##

### Lista de mensagens ###

### Mensagens em YELLOW

M01="Compactando os arquivos Anteriores" 
#M02="Voltando a versao anterior do programa" 
M03="Volta do(s) programa(s) Concluida(s)" 
M04="Volta do(s) Arquivo(s) Concluida" 
M05="Sistema nao e IsCOBOL" 
M06="Sera criado mais um backup para o mesmo dia"  
M07="Programa(s) a ser(em) atualizado(s) -"
M08="Opcao Invalida"  
M09="O programa tem que estar no diretorio"   
#M10="O backup de nome \"""$ARQ""\"" 
M11="Movendo arquivos Temporarios" 
M12="Arquivo(s) recuperado(s)..."
M13="De *.zip para *.bkp"
M14="Criando Backup.."
#M15="Backup enviado para a pasta, \"""$ENVBASE""\"."
M16="Backup Concluido!"
M17="Atualizacao Completa"
M18="Arquivo(s) recuperado(s)..."
M19="ATUALIZANDO OS PROGRAMAS..."
M20="Alterando a extensao da atualizacao"
#M21="A atualizacao tem que esta no diretorio ""$tools"
#M22=".. Criando o diretorio temp do backup em $DIRBACK.." 
#M23=".. Criando o diretorio dos backups em $DIRDEST.."
M24=".. BACKUP do programa efetuado .." 
M25="... Voltando versao anterior ..." 
M26="... Agora, ATUALIZANDO ..." 
M27=" .. Backup Completo .." 
M28="Arquivo encontrado no diretorio" 
M29="Informe a senha do usuario do SCP"
#M30="o programas $vprog da ${NORM}${RED} ""$VVERSAO"
#M31="o programas da versao: ${NORM}${RED} ""$VVERSAO"
#M32="foi criado em ""$DIRDEST"
M33="Voltando Backup anterior  ..."
#M34="O arquivo ""$VARQUIVO"
M35="Deseja voltar todos os ARQUIVOS do Backup ? (N/s):"


## Mensagens em RED
#M40="Versao atualizada - ""$VERSAO" 
#M41="Programa nao encontrado no diretorio" 
#M42="Programa, ""$NOMEPROG"" nao encontrado no diretorio" 
M43="Programa ""$prog""-anterior.zip nao encontrado no diretorio." 
#M44="Nao foi encontrado o diretorio ""$exec" 
M45="Backup nao encontrado no diretorio" 
M46="Backup da Biblioteca nao encontrado no diretorio"
M47="Backup Abortado!"
M48="Atualizacao nao encontrado ou incompleta."
M49="Arquivo nao encontrado no diretorio"
#M50="Informe o nome do programa a ser atualizado:"
M51="Verificando e/ou excluido arquivos com mais de 30 dias criado."
M52="Informe de qual o Backup que deseja enviar."
M53="Informe de qual o Backup que deseja voltara o(s) arquivo(s)."
#M54="Programa na versao 9 digitos nao encontrada baixar da class20"

## Mensagens em cyan
M60="..Checando estrutura dos diretorios do atualiza.sh.." 
M61="..Encontrado o diretorio do sistema .." 
#M62="Ja existe um backup em ""$DIRDEST"" nos ultimos dias."

### Variavel para identificar o programa ou versao a atualizada ###
#-----------------------------------------------------------------#
tput bold
VERSAO=""
JUTIL="/sav/savisc/iscobol/bin/jutil"
ARQUIVO=""
PEDARQ=""
prog=""
VVERSAO=""
tools="$destino""$pasta"
dir="$destino""$base"
#TEMPROGS="$tools""$progs"
#### EXTENSAO QUE SERA INCLUIDA NO NOME DO PROGRAMA QUE A SER SALVO.
ANTERIOR="anterior"
#### PARAMETRO PARA O LOGS
LOG_ATU="$tools""$logs"/atualiza.$(date +'%Y-%m-%d').log
LOG_LIMPA="$tools""$logs"/limpando.$(date +'%Y-%m-%d').log

#-----------------------------------------------------------------#
###############################
# Variaveis de cores          #
###############################
ESC=$(printf '\033') RED="${ESC}[31m"
GREEN="${ESC}[32m" YELLOW="${ESC}[33m" BLUE="${ESC}[34m" PURPLE="${ESC}[35m"
CYAN="${ESC}[36m" WHITE="${ESC}[37m" NORM="${ESC}[39m"

COLUMNS=$(tput cols)
#----------------------------- TESTE de CONFIGURACOES--------------------#

[ ! -e "atualizac" ] && printf "ERRO. Arquivo nao existe."    && exit 1
[ ! -r "atualizac" ] && printf "ERRO. Sem acesso de leitura." && exit 1
#------------------------------------------------------------------------#
##########################################################################

#### - Configuracao para acesso ao scp - #####
PORTA="41122"
USUARIO="atualiza"
IPSERVER="177.102.143.23"
DESTINO2SERVER="/u/varejo/man/"
DESTINO2SAVATUISC="/home/savatu/biblioteca/temp/ISCobol/sav-5.0/"
DESTINO2SAVATUMF="/home/savatu/biblioteca/temp/Isam/sav-3.1"
DESTINO2TRANSPC="/u/varejo/trans_pc/"
DESTINO2=""

##########################################################################

###################################################
# Funcao de espera                                #
###################################################
_press () {
    printf "\n"
    read -t 15 -n 1 -s -r -p  "${YELLOW}""          <<   Pressione qualquer tecla para continuar... >>""${NORM}"
    clear
}

###########################
# Linha tracejada         #
###########################

_linha () {
    printf -v Espacos %60s # quantidade de tracos por linha
    printf -v Traco "*"
    linhas=${Espacos// /$Traco}
	printf "%*s\n" $(((${#linhas}+COLUMNS)/2)) "$linhas"
}
 
###############################################
# Verificacoes de parametro e diretorio       #
###############################################
 clear
    if [ -d "$exec" ]; then
# "..Encontrado o diretorio do sistema .."  	
_linha
printf "%*s""${CYAN}" ;printf "%*s\n" $(((${#M61}+COLUMNS)/2)) "$M61" ;printf "%*s""${NORM}"
_linha
    sleep 1
    else
M44="Nao foi encontrado o diretorio ""$exec"    
_linha
printf "%*s""${RED}" ;printf "%*s\n" $(((${#M44}+COLUMNS)/2)) "$M44" ;printf "%*s""${NORM}"
_linha  
    sleep 2
    exit
    fi

if [ -d "$tools" ]; then
_linha
printf "%*s""${CYAN}" ;printf "%*s\n" $(((${#M60}+COLUMNS)/2)) "$M60" ;printf "%*s""${NORM}"
_linha  

        if [ -d "$tools""$olds" ]; then
            printf " Diretorio olds ... ok \n"
            else
            mkdir olds
        fi  
        if [ -d "$tools""$progs" ]; then
            printf " Diretorio progs ... ok \n"
            else  
            mkdir progs
        fi  
        if [ -d "$tools""$logs" ]; then
            printf " Diretorio logs ... ok \n"         
            else 
            mkdir logs
        fi  
        if [ -d "$tools""$backup" ]; then
            printf " Diretorio backups ... ok \n" 
            else
            mkdir backup
        fi  
    else
    exit
fi  
clear

_principal () {
    clear
    printf "${GREEN}     +-----------------------------------------------+${NORM}%s\n" 
    printf "${GREEN}     |${NORM}      ${RED}       Menu de Opcoes                    ${GREEN}|${NORM}%s\n" 
    printf "${GREEN}     +-----------------------------------------------+${NORM}%s\n"
    printf "${GREEN}     |${NORM}   ${BLUE}.. Sistema: ""$sistema"" ..Empresa: ""$EMPRESA"" ..  ${GREEN}|${NORM}%s\n"
    printf "${GREEN}     +-----------------------------------------------+${NORM}%s\n"
    printf "\n"
    printf " ${PURPLE}    Escolha a opcao: ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}1${NORM} - ${WHITE}Atualizacao de Programas ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}2${NORM} - ${WHITE}Atualizacao de Biblioteca ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}3${NORM} - ${WHITE}Desatualizando ${NORM}%s\n"
    printf "\n"
    if [ "$sistema" = "iscobol" ]; then
              printf "     ${GREEN}4${NORM} - ${WHITE}Versao do Iscobol ${NORM}%s\n"
         else
               printf "     ${GREEN}4${NORM} - ${NORM}%s\n"
         fi
    printf "\n"
    printf "     ${GREEN}5${NORM} - ${WHITE}Versao do Linux ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}6${NORM} - ${WHITE}Ferramentas ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}9${NORM} - ${RED}Sair${NORM}%s\n"
    printf "\n"
    printf " ${YELLOW}    Digita a opcao desejada -> ${NORM}%s"
    read -r OPCAO
    case $OPCAO in
        1) _atualizacao ;;
        2) _biblioteca ;;
        3) _desatualizado ;;
        4) _iscobol ;;
        5) _linux ;;
        6) _ferramentas ;;
        9) clear; tput sgr0; exit ;;
        *) clear ; _principal ;;
    esac
}


##############################################################
#       Procedimento da atualizacao de programas             # 
##############################################################
_atualizacao () {
    clear
    printf "${GREEN}     +--------------------------------------------+${NORM}%s\n"
    printf "${GREEN}     |${NORM}      ${RED}       Menu de Programas              ${GREEN}|${NORM}%s\n"
    printf "${GREEN}     +--------------------------------------------+${NORM}%s\n"
    printf "\n"
    printf "     ${PURPLE}Escolha o tipo de Atualizacao: ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}1${NORM} - ${WHITE}Programa ou Pacote ON-Line${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}2${NORM} - ${WHITE}Programa ou Pacote em OFF-Line${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}9${NORM} - ${RED}Menu Anterior${NORM}%s\n"
    printf "\n" 
    printf "     ${YELLOW}Digite o numero da OPCAO desejada -> ${NORM}%s"
    read -r OPCAO
    case $OPCAO in
		1) _pacoteon ;;
		2) _pacoteoff ;;
                9) clear ; _principal ;;
                *) Opcao Invalida ; printf ; _principal ;;
    esac
}

_qualprograma () {
    clear
     printf "
      \033c\033[10;10H${RED}Informe o nome do programa a ser atualizado: ${NORM}
%s\n"
   _linha
   read -rp "${YELLOW}""        Informe o programa em maiuculo: ""${NORM}" prog
   _linha

   while [[ "$prog" =~ [^A-Z0-9] || -z "$prog" ]]; do
   clear
   printf "
     \033c\033[10;10H${RED}Voce nao informou o nome do programa a ser atualizado
      ou o nome do programa esta em minusculo ${NORM}
%s\n" 
_press
_principal
    done
}
   
###############################
#   PROGRAMAS E/OU PACOTES    # 
###############################

_run_scp () {
     "$cmd_scp" -r -P "$PORTA" "$USUARIO"@"$IPSERVER":"$DESTINO2SERVER""$prog""$class".zip .
}

_pacoteon () {
     _qualprograma
#             Informe a senha do usuario do scp 
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M29}+COLUMNS)/2)) "$M29" ;printf "%*s""${NORM}"
    _linha
_run_scp
_atupacote 
_press 
_principal

}
###################################

_pacoteoff () {
     _qualprograma
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M09}+COLUMNS)/2)) "$M09" ;printf "%*s""${NORM}"
     _linha
#             O programa tem que estar no diretorio

local NOMEPROG="$prog""$class".zip
    sleep 1
_atupacote
_press 
_principal

}

_atupacote () {

NOMEPROG="$prog""$class".zip

    if  test ! -f "$NOMEPROG" ; then
        clear
M42="Programa, ""$NOMEPROG"" nao encontrado no diretorio" 
    _linha
    printf "%*s""${RED}" ;printf "%*s\n" $(((${#M42}+COLUMNS)/2)) "$M42" ;printf "%*s""${NORM}"
    _linha
    exit
    fi
### Limpando diretorio temporario ###


## Descompactando o programa baixado
    unzip -o "$prog""$class".zip >> "$LOG_ATU"
    sleep 1
    clear

# Verificando nome do arquivo com a extens o .class ou .int

     if [ "$sistema" = "iscobol" ]; then 
        for pprog in *.class
        do
        zip "$prog"-$ANTERIOR "$exec"/"$pprog"   
        sleep 2		
        mv -f -- "$pprog" "$exec" >> "$LOG_ATU"
		done
     else 
        for pprog in *.int
        do
          zip "$prog"-$ANTERIOR "$exec"/"$pprog"
        done
        sleep 2
	 fi	
             
        for pprog in *.TEL
        do
          zip -r "$prog"-$ANTERIOR "$telas"/"$pprog"
         sleep 2 
          mv -f -- "$pprog" "$telas" >> "$LOG_ATU"
        done
#               ..   BACKUP do programa efetuado   ..
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M24}+COLUMNS)/2)) "$M24" ;printf "%*s""${NORM}"
    _linha
     sleep 1
 # Atualizando o novo programa.
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M26}+COLUMNS)/2)) "$M26" ;printf "%*s""${NORM}"
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M07}+COLUMNS)/2)) "$M07" ;printf "%*s""${NORM}"
    _linha
 
# ALTERANDO A EXTENSAO DA ATUALIZACAO...  De *.zip para *.bkp
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M20}+COLUMNS)/2)) "$M20" ;printf "%*s""${NORM}"
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M13}+COLUMNS)/2)) "$M13" ;printf "%*s""${NORM}"
     _linha

     for f in *"$prog""$class".zip; do
         mv -f -- "$f" "${f%.zip}.bkp"
     done

#                      Atualizacao COMPLETA$
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M17}+COLUMNS)/2)) "$M17" ;printf "%*s""${NORM}"
    _linha
 
    mv -f -- "$prog""$class".bkp "$tools""$progs"
    mv -f -- "$prog"-$ANTERIOR.zip "$tools""$olds"
    clear

##########################################
#       Escolha de multi programas       # 
##########################################
    printf "
      \033c\033[10;10H${YELLOW}Deseja informar mais algum programa para ser atualizado? (N/s): ${NORM}%s\n"
    read -r -n1 CONT 
    printf "\n"
    printf "\n"
    if [ "$CONT" = N ] || [ "$CONT" = n ] || [ "$CONT" = "" ] ; then
_principal
    elif [ "$CONT" = S ] || [ "$CONT" = s ] ; then
    source ./atualizac
      if [ "$OPCAO" = 1 ] ; then
         _pacoteon
      else
        _pacoteoff
      fi
_atupacote
    else
#            Opcao Invalida
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M08}+COLUMNS)/2)) "$M08" ;printf "%*s""${NORM}"
    _linha
_press 
_principal
    fi  
    _principal
}

##########################################
#       Desatualizacao de programas      # 
##########################################
_desatualizado () {
    clear
    printf "${GREEN}     +--------------------------------------------+${NORM}%s\n"
    printf "${GREEN}     |${NORM}      ${RED}      Menu Desatualizacao             ${GREEN}|${NORM}%s\n"
    printf "${GREEN}     +--------------------------------------------+${NORM}%s\n"
    printf "\n"
    printf "\n"
    printf "     ${PURPLE}Escolha opcao: ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}1${NORM} - ${WHITE}Voltar programa Atualizado ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}2${NORM} - ${WHITE}Voltar antes da Biblioteca  ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}9${NORM} - ${RED}Menu Anterior${NORM}%s\n"
    printf "\n" 
    printf "    ${YELLOW}Digite o numero da OPCAO desejada -> ${NORM}%s"
    read -r OPCAO1
    case $OPCAO1 in
        1) _voltaprog ;;
        2) _voltabibli ;;
        9) clear ; _principal ;;
        *) Opcao Invalida ; printf ; _desatualizado ;;
    esac
}

##############################################################
#       Procedimento da desatualizacao de programas          # 
##############################################################
_voltaprog () {
    clear
     printf "
      \033c\033[10;10H${RED}Informe o nome do programa a ser desatualizado: ${NORM}
%s\n"
    read -rp "${YELLOW}""         Informe o programa em maiusculo: ""${NORM}" prog
    while [[ "$prog" =~ [^A-Z0-9] || -z "$prog" ]]; do

     printf "
     \033c\033[10;10H${RED}Voce nao informou o nome do programa 
      ou o nome do programa esta em minusculo ${NORM}
%s\n" 
_press
_principal
    done

    if test ! -r "$tools$olds"/"$prog"-"$ANTERIOR".zip ; then
        clear
M43="Programa ""$prog""-anterior.zip nao encontrado no diretorio."
    _linha
    printf "%*s""${RED}" ;printf "%*s\n" $(((${#M43}+COLUMNS)/2)) "$M43" ;printf "%*s""${NORM}"
    _linha
_press
_principal
    fi

M02="Voltando a versao anterior do programa ""$prog"
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M02}+COLUMNS)/2)) "$M02" ;printf "%*s""${NORM}"
    _linha
    
    unzip -o "$tools$olds"/"$prog"-"$ANTERIOR".zip -d /  >> "$LOG_ATU"
    sleep 2
        clear
#                   VOLTA DE PROGRAMA CONCLUIDA
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M03}+COLUMNS)/2)) "$M03" ;printf "%*s""${NORM}"
    _linha
_press
_principal
}

####################################################################
# Procedimento da desatualizacao de programas antes da biblioteca  # 
####################################################################

_voltabibli () {
    clear
     printf "
      \033c\033[10;10H${RED}Informe de qual a ultima versao que foi feita a atualizacao da
     biblioteca para voltar todos os programas.${NORM}
%s\n"
    read -rp "${YELLOW}""         1- Informe apos qual versao da BIBLIOTECA: ""${NORM}" VVERSAO
    while [[ "$VVERSAO" = [0-9] || -z "$VVERSAO" ]]; do 
    clear
    printf "
     \033c\033[10;18H${RED}* * * < < Versao nao foi informada > > * * *${NORM}
%s\n"
    _linha 
_press
_desatualizado
    done

    if test ! -r "$tools""$olds"/"$INI-$VVERSAO"*.zip ; then

#    Backup da Biblioteca nao encontrado no diretorio
    _linha
    printf "%*s""${RED}" ;printf "%*s\n" $(((${#M46}+COLUMNS)/2)) "$M46" ;printf "%*s""${NORM}"
    _linha
_press
_desatualizado
    fi

    printf "\n"
    printf "%*s\n""${YELLOW}""Deseja volta todos os programas para antes da atualizacao? (N/s):""${NORM}"
    read -r -n1 CONT 
    printf "\n"
    printf "\n"

    if [ "$CONT" = N ] || [ "$CONT" = n ] || [ "$CONT" = "" ] ; then
	    _linha
_volta_progx
#
    elif [ "$CONT" = S ] || [ "$CONT" = s ] ; then
	    _linha
_volta_geral
#
    else
#            Opcao Invalida
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M08}+COLUMNS)/2)) "$M08" ;printf "%*s""${NORM}"
    _linha
_press	
_desatualizado
    fi	
}

##################################
##  VOLTA PROGRAMA ESPECIFICO   ##
##################################
_volta_progx () {	
    read -rp "${YELLOW}""       2- Informe o nome do programa em maiusculo: ""${NORM}" Vprog
    while [[ "$Vprog" =~ [^A-Z0-9] || -z "$Vprog" ]]; do

     printf "
     \033c\033[10;10H${RED}ERRO: Voce informou o nome do programa esta em minusculo ${NORM}
	 %s\n" 
_press
 _desatualizado
    done

M30="O(s) programa(s) da ${NORM}${RED} ""$VVERSAO"   
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M25}+COLUMNS)/2)) "$M25" ;printf "%*s""${NORM}"
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M30}+COLUMNS)/2)) "$M30" ;printf "%*s""${NORM}"
    _linha

    cd "$tools""$olds"/ || exit
    unzip -j "$INI"-"$VVERSAO".zip 
_volta_progy
}

_volta_progz () {
    printf "\n"
    printf "%*s\n""${YELLOW}""Deseja volta mais algum programa ? (N/s):""${NORM}"
    read -r -n1 CONT 
    printf "\n"
    printf "\n"
    if [ "$CONT" = N ] || [ "$CONT" = n ] || [ "$CONT" = "" ] ; then
_press
### limpando diretorio 
        local DIR1="$tools""$olds"/
        for pprog in {*.class,*.TEL,*.xml,*.int,*.png,*.jpg}
        do
		"$cmd_find" "$DIR1" -name "$pprog" -ctime +30 -exec rm -r {} \; 
        done

_desatualizado
    fi
	local Vprog=" "
    if [ "$CONT" = S ] || [ "$CONT" = s ] ; then
    read -rp "${YELLOW}""       2- Informe o nome do programa em maiusculo: ""${NORM}" Vprog
       if [[ "$Vprog" =~ [^A-Z0-9] || -z "$Vprog" ]]; then

     printf " \033c\033[10;10H${RED}ERRO: Voce informou o nome do programa esta em minusculo ${NORM}%s\n" 
#	 done
_press	 
_desatualizado
       else
     _volta_progy
        fi
_press
_desatualizado
    fi 
} 

_volta_progy () {

             if [ "$sistema" = "iscobol" ]; then
    "$cmd_find" "$tools""$olds" -name "$Vprog.xml" -exec mv {} "$xml" \; >> "$LOG_ATU" 

    "$cmd_find" "$tools""$olds" -name "$Vprog.TEL" -exec mv {} "$telas" \; >> "$LOG_ATU" 

    "$cmd_find" "$tools""$olds" -name "$Vprog*.class" -exec mv {} "$exec" \; >> "$LOG_ATU" 

    clear
             else
    "$cmd_find" "$tools""$olds" -name "$Vprog.TEL" -exec mv {} "$telas" \; >> "$LOG_ATU" 

	"$cmd_find" "$tools""$olds" -name "$Vprog*.int" -exec mv {} "$exec" \; >> "$LOG_ATU" 

			 fi

#                VOLTA DE PROGRAMAS CONCLUIDA
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M03}+COLUMNS)/2)) "$M03" ;printf "%*s""${NORM}"
    _linha

M30="O(s) programa(s) da ${NORM}${RED} ""$VVERSAO"
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M25}+COLUMNS)/2)) "$M25" ;printf "%*s""${NORM}"
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M30}+COLUMNS)/2)) "$M30" ;printf "%*s""${NORM}"
    _linha
_press
_volta_progz

}
# volta todos os programas da biblioteca

_volta_bibli () {
#          VOLTA DOS ARQUIVOS ANTERIORES...
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M03}+COLUMNS)/2)) "$M01" ;printf "%*s""${NORM}"
     _linha
     
    sleep 1
	if [ "$sistema" = "iscobol" ]; then

    cd "$tools""$olds" || exit

	"$cmd_find" "$tools""$olds" -type f \( -iname "*.class" -o -iname "*.jpg" -o -iname "*.png" -o -iname "*.brw" -o -iname "*." -o -iname "*.dll" \) -exec mv "{}" "$exec" \; >> "$LOG_ATU"

	"$cmd_find" "$tools""$olds" -type f \( -iname "*.TEL" \) -exec mv "{}" "$telas" \; >> "$LOG_ATU"

    cd "$xml"/ || exit
	"$cmd_find" "$tools""$olds" -type f \( -iname "*.xml" \) -exec mv "{}" "$xml" \; >> "$LOG_ATU"

    cd "$tools"/ || exit
    clear
    
    else
    cd "$tools""$olds"/ || exit
	"$cmd_find" "$tools""$olds" -type f \( -iname "*.int" \) -exec mv "{}" "$exec" \; >> "$LOG_ATU"

    cd "$tools""$olds"/ || exit
	"$cmd_find" "$tools""$olds" -type f \( -iname "*.TEL" \) -exec mv "{}" "$telas" \; >> "$LOG_ATU"

    cd "$tools"/ || exit     
    clear

M30="O(s) programa(s) da ${NORM}${RED} ""$VVERSAO"
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M25}+COLUMNS)/2)) "$M25" ;printf "%*s""${NORM}"
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M30}+COLUMNS)/2)) "$M30" ;printf "%*s""${NORM}"
    _linha
    fi
_press
_principal

}
 ### volta total dos programas ###
_volta_geral () { 
   
     printf "
      \033c\033[10;10H${RED}Voltando todos os programas. ${NORM}%s\n"

#               ---- Voltando versao anterior  ...
#M31="O programas da versao: ${NORM}${RED} ""$VVERSAO"
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M25}+COLUMNS)/2)) "$M25" ;printf "%*s""${NORM}"
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M31}+COLUMNS)/2)) "$M31" ;printf "%*s""${NORM}"
    _linha

    cd "$tools""$olds"/ || exit
    for FILES in "$tools""$olds"/ ;do
    "$cmd_unzip" -o "$INI"-"$VVERSAO".zip -d "$tools$olds">> "$LOG_ATU"
    done
    cd "$tools" || exit
    clear

#                  VOLTA DOS PROGRAMAS CONCLUIDA
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M03}+COLUMNS)/2)) "$M03" ;printf "%*s""${NORM}"
    _linha

_volta_bibli
_press
_principal  
}

########################################
## Rotina de Atualizacao Biblioteca   ##
########################################
_biblioteca () {
    clear
     printf "
      \033c\033[10;10H${RED}Informe versao a ser atualizar: ${NORM}
%s\n"
     _linha 
	  read -rp "         Informe somente o numeral da versao : " VERSAO
 
      if [ -z "$VERSAO" ]; then
     printf "
     \033c\033[10;10H${RED}Voce nao informou o a versao a ser atualizado :${NORM}
%s\n"
    _linha
	sleep 2
    _principal
    fi
    clear
    printf "${GREEN}     +--------------------------------------------+${NORM}%s\n"
    printf "${GREEN}     |${NORM}      ${RED}          Menu Biblioteca             ${GREEN}|${NORM}%s\n"
    printf "${GREEN}     +--------------------------------------------+${NORM}%s\n"
    printf "\n"
    printf "\n"
    printf "    ${PURPLE}Escolha o local da Biblioteca: ${NORM}%s\n"
    printf "\n"
    printf "    ${GREEN}1${NORM} - ${WHITE}Atualizacao do Transpc ${NORM}%s\n"
    printf "\n"
    printf "    ${GREEN}2${NORM} - ${WHITE}Atualizacao do Savatu ${NORM}%s\n"
    printf "\n"
    printf "    ${GREEN}3${NORM} - ${WHITE}Atualizacao OFF-Line${NORM}%s\n"
    printf "\n"
    printf "    ${GREEN}9${NORM} - ${RED}Menu Anterior${NORM}%s\n"
    printf "\n" 
    printf "    ${YELLOW}Digite o numero da OPCAO desejada -> ${NORM}%s"
    read -r OPCAO1
    printf "\n"
    printf "\n"
    case $OPCAO1 in
        1) _transpc ;;
        2) _savatu ;;
        3) _salva ;;
        9) clear ; _principal ;;
        *) Opcao Invalida ; printf ; _biblioteca ;;
    esac
}

### Processo do scp ###
_run_scp2 () {
     scp -r -P "$PORTA" "$USUARIO"@"$IPSERVER":"$DESTINO2""$atu""$VERSAO".zip . # programas da biblioteca
}


#### Processo de recepcao de biblioteca ##
_scp_biblioteca () {
	if [ "$sistema" = "iscobol" ]; then
    for atu in $SAVATU1 $SAVATU2 $SAVATU3 $SAVATU4 ;do
    _run_scp2
	done
_salva
	else
     for atu in $SAVATU1 $SAVATU2 $SAVATU3 ;do	
	 _run_scp2
	done 
	fi
_salva
}

##############################################################
#       Atualizacao da pasta transpc                         # 
##############################################################
_transpc () {

###
#   Informe a senha do usuario do scp
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M29}+COLUMNS)/2)) "$M29" ;printf "%*s""${NORM}"
     _linha
     DESTINO2="$DESTINO2TRANSPC"
     _scp_biblioteca

}

##############################################################
#       Atualizacao da pasta do savatu                       # 
##############################################################

_savatu () {
#  Informe a senha do usuario do scp 
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M29}+COLUMNS)/2)) "$M29" ;printf "%*s""${NORM}"
     _linha
	if [ "$sistema" = "iscobol" ]; then 
 	DESTINO2="$DESTINO2SAVATUISC"
    _scp_biblioteca
	else 
	DESTINO2="$DESTINO2SAVATUMF"
	_scp_biblioteca
	fi
}

##############################################################
#   Atualizacao offline a biblioteca deve esta no diretorio  # 
##############################################################
_salva () {

M21="A atualizacao tem que esta no diretorio ""$tools"
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M21}+COLUMNS)/2)) "$M21" ;printf "%*s""${NORM}"
     _linha
     if [ "$sistema" = "iscobol" ]; then
     for atu in $SAVATU1 $SAVATU2 $SAVATU3 $SAVATU4 ;do
        if  test ! -r "$atu""$VERSAO"".zip" ; then
            clear
#          Atualizacao nao encontrado no diretorio
    _linha
    printf "%*s""${RED}" ;printf "%*s\n" $(((${#M48}+COLUMNS)/2)) "$M48" ;printf "%*s""${NORM}"
    _linha
	_press
	clear
    _principal
        fi
     done 
_processo
#          Atualizacao nao encontrado no diretorio
    _linha
    printf "%*s""${RED}" ;printf "%*s\n" $(((${#M48}+COLUMNS)/2)) "$M48" ;printf "%*s""${NORM}"
    _linha
_press
_principal
    else
     for atu in $SAVATU1 $SAVATU2 $SAVATU3 ;do
           if  test ! -r "$atu""$VERSAO"".zip" ; then
            clear 
#          Atualizacao nao encontrado no diretorio
    _linha
    printf "%*s""${RED}" ;printf "%*s\n" $(((${#M48}+COLUMNS)/2)) "$M48" ;printf "%*s""${NORM}"
    _linha
_press
_principal
           fi
	done
	fi
_processo
}
 
##############################################################
#  procedimento salvar os programas antes de atualizar    # 
##############################################################

_processo () {

#          ZIPANDO OS ARQUIVOS ANTERIORES...
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M01}+COLUMNS)/2)) "$M01" ;printf "%*s""${NORM}"
     _linha
     
    sleep 1
	if [ "$sistema" = "iscobol" ]; then
    cd "$exec"/ || exit
	find "$exec"/ -type f \( -iname "*.class" -o -iname "*.jpg" -o -iname "*.png" -o -iname "*.brw" -o -iname "*." -o -iname "*.dll" \) -exec zip -r "$tools"/"$INI"-"$VERSAO" "{}" +;
#    zip -r "$tools"/"$INI"-"$VERSAO" -i "*.class" "*.jpg" "*.png" "*.brw" "*." "*.dll"
    cd "$telas"/ || exit
	find "$telas"/ -type f \( -iname "*.TEL" \) -exec zip -r "$tools"/"$INI"-"$VERSAO" "{}" +;
#    zip -r "$tools"/"$INI"-"$VERSAO" -i "*.TEL"
    cd "$xml"/ || exit
	find "$xml"/ -type f \( -iname "*.xml" \) -exec zip -r "$tools"/"$INI"-"$VERSAO" "{}" +;
#    zip -r "$tools"/"$INI"-"$VERSAO" -i "*.xml"
    cd "$tools"/ || exit
    clear
    
    else
    cd "$exec"/ || exit
	find "$exec"/ -type f \( -iname "*.int" \) -exec zip -r "$tools"/"$INI"-"$VERSAO" "{}" +;

    cd "$telas"/ || exit
	find "$telas"/ -type f \( -iname "*.TEL" \) -exec zip -r "$tools"/"$INI"-"$VERSAO" "{}" +;
    fi 

#               ..   BACKUP COMPLETO   ..
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M27}+COLUMNS)/2)) "$M27" ;printf "%*s""${NORM}"
     _linha

    sleep 1
    
    if test ! -r "$tools"/"$INI-$VERSAO"*.zip ; then
#               Backup nao encontrado no diretorio
    _linha
    printf "%*s""${RED}" ;printf "%*s\n" $(((${#M45}+COLUMNS)/2)) "$M45" ;printf "%*s""${NORM}"
    _linha

##############################################################
#  procedimento caso nao exista o diretorio a ser atualizado # 
##############################################################
    sleep 2    
     printf "
      \033c\033[10;10H${YELLOW}Deseja continuar a atualizacao? (n/S): ${NORM}
%s\n"
    read -r -n1 CONT 
    printf "\n"
    printf "\n"
        if [ "$CONT" = N ] || [ "$CONT" = n ]; then
_principal
        elif [ "$CONT" = S ] || [ "$CONT" = s ] || [ "$CONT" = "" ]; then
     printf "
      \033c\033[10;10H${YELLOW}Continuando a atualizacao...: ${NORM}
%s\n"
        else
#            Opcao Invalida 
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M08}+COLUMNS)/2)) "$M08" ;printf "%*s""${NORM}"
    _linha
 _principal
        fi 
    fi
    
##############################################################
#       Procedimento da Atualizacao de Programas             # 
##############################################################
#               ATUALIZANDO OS PROGRAMAS...
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M19}+COLUMNS)/2)) "$M19" ;printf "%*s""${NORM}"
    _linha
    for atu in $SAVATU1 $SAVATU2 $SAVATU3 $SAVATU4 ;do
	    printf "${GREEN}"" Atualizado ""$atu""$VERSAO"".zip""${NORM}%s\n" || printf "$M48"
        unzip -o "$atu""$VERSAO".zip -d "$destino" >> "$LOG_ATU"
      sleep 2
      clear
      done
#                 Atualizacao COMPLETA
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M17}+COLUMNS)/2)) "$M17" ;printf "%*s""${NORM}"
    _linha

        for f in *_"$VERSAO".zip; do
            mv -f -- "$f" "${f%.zip}.bkp"
        done
        mv -f -- *_"$VERSAO".bkp "$tools""$backup"
        mv -f -- "$INI"-"$VERSAO".zip "$tools""$olds"
#             ALTERANDO A EXTENSAO DA ATUALIZACAO.../De *.zip para *.bkp/
#Versao atualizada - $VERSAO$
M40="Versao atualizada - ""$VERSAO"
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M20}+COLUMNS)/2)) "$M20" ;printf "%*s""${NORM}"
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M13}+COLUMNS)/2)) "$M13" ;printf "%*s""${NORM}"
    printf "%*s""${RED}" ;printf "%*s\n" $(((${#M40}+COLUMNS)/2)) "$M40" ;printf "%*s""${NORM}"
    _linha
_press
_principal
}

##############################################################
#    Mostrar a versao do iscobol que esta sendo usada.       # 
##############################################################
_iscobol () {
    if [ "$sistema" = "iscobol" ]; then
    clear    
	_linha
          /u/sav/savisc/iscobol/bin/iscclient -v
     _linha

    else
#             Sistema nao e IsCOBOL
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M05}+COLUMNS)/2)) "$M05" ;printf "%*s""${NORM}"
     _linha
    fi
_press
_principal
}

##############################################################
#    Mostrar a versao do Linux que esta sendo usada.         # 
##############################################################
_linux () {

    printf "\n"
    printf "\n"
    printf "  Vamos descobrir qual SO / Distro voce esta executando.\n"
    _linha
	printf "\n"
    printf "\n"
    printf "  A partir de algumas informacoes basicas o seu sistema, parece estar executando:\n"
    _linha
# identificando OS
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    UPSTREAM_ID=${ID_LIKE,,}
    # Fallback to ID_LIKE if ID was not 'ubuntu' or 'debian'
    if [ "${UPSTREAM_ID}" != "debian" ] && [ "${UPSTREAM_ID}" != "ubuntu" ]; then
        UPSTREAM_ID="$(echo "${ID_LIKE,,}" | sed s/\"//g | cut -d' ' -f1)"
    fi

elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # Para algumas versões do Debian/Ubuntu sem o comando lsb_release
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Velhas distros Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Velhas distros SuSE/etc.
    OS=SuSE
    VER=$(cat /etc/SuSe-release)
elif [ -f /etc/redhat-release ]; then
    # Velhas distros Red Hat, CentOS, etc.
    OS=RedHat
    VER=$(cat /etc/redhat-release)
else
    # Para uname, e.x. "Linux <version>", também funciona para o BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi
    printf "${GREEN}          OS:${NORM}      ${CYAN} ""$OS""   ${NORM}%s\n"
	printf "\n"
    printf "${GREEN}          VER:${NORM}      ${CYAN} ""$VER"" ${NORM}%s\n"
	printf "\n"
    printf "${GREEN}          UPSTREAM_ID:${NORM} ${CYAN} ""$UPSTREAM_ID"" ${NORM}%s\n" 
    printf "\n"
	_linha
    printf "\n"
_press
_principal
    }

_ferramentas() {
    clear
    printf "\n"
    printf "\n"
    printf "${GREEN}     +--------------------------------------------+${NORM}%s\n"
    printf "${GREEN}     |${NORM}      ${RED}          Menu Ferramentas            ${GREEN}|${NORM}%s\n"
    printf "${GREEN}     +--------------------------------------------+${NORM}%s\n"
    printf "\n"
    printf "\n"
    printf "     ${PURPLE}Escolha opcao: ${NORM}%s\n"
    printf "\n"
    printf "\n"
    printf "     ${GREEN}1${NORM} - ${WHITE}Limpar Temporarios ${NORM}%s\n"
    printf "\n"
        if [ "$BANCO" = "s" ]; then
    printf " "
        else
    printf "     ${GREEN}2${NORM} - ${WHITE}Recuperar arquivos ${NORM}%s\n"
        fi
    printf "\n"
        if [ "$BANCO" = "s" ]; then
    printf " "
        else
    printf "     ${GREEN}3${NORM} - ${WHITE}Backup da base de dados ${NORM}%s\n"
        fi
    printf "\n"
        if [ "$BANCO" = "s" ]; then
    printf " "
        else
    printf "     ${GREEN}4${NORM} - ${WHITE}Restaurar Backup da base de dados ${NORM}%s\n"
        fi
    printf "\n"
    printf "     ${GREEN}5${NORM} - ${WHITE}Enviar Backup${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}6${NORM} - ${WHITE}Expurgar ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}9${NORM} - ${RED}Menu Anterior${NORM}%s\n"
    printf "\n" 
    printf "     ${YELLOW}Digite o numero da OPCAO desejada -> ${NORM}%s"
    read -r OPCAO1
    case $OPCAO1 in
        1) _temps      ;;
        2) _rebuild    ;;
        3) _backup     ;;
        4) _unbackup   ;;
        5) _backupavulso ;;
        6) _expurgador   ;;
        9) clear ; _principal ;;
        *) Opcao Invalida ; printf ; _ferramentas ;;
    esac
}

##############################################################
#   Le a lista "atualizat" que contem os arquivos a serem    # 
#   excluidas da base do sistema                             # 
##############################################################

#---------------------- TESTE Arquivos ----------------------------------#

[ ! -e "atualizat" ] && printf "ERRO. Arquivo nao existe."    && exit 1
[ ! -r "atualizat" ] && printf "ERRO. Sem acesso de leitura." && exit 1
#------------------------------------------------------------------------#
### Rotina para excluir arquivo temporarios###
_temps() {
#clear
    if [ "$sistema" = "iscobol" ]; then
    cd "$tools"/ || exit
    local arqs

    arqs=$(cat atualizat)
    DIRDEST="$tools""$backup"
    DIR="$destino""$base"/
    TEMPORARIOS="Temps"
    ETIQUETATEMPO="$(date +'%d-%m-%Y')"
    DAYS=$(find "$DIRDEST" -type f -name "Temps*" -mtime 10 -exec rm -rf {} \;)
         if [ "$DAYS" ] ; then
             printf "%*s""\033c\033[10;10H${RED}"Existe um backup no \
             Diretorio """$DIRDEST"" "antigo sera excluido."${NORM}"
         fi 
         for line in $arqs
         do
           zip -m "$DIRDEST"/"$TEMPORARIOS-$ETIQUETATEMPO" "$DIR""$line"  >> "$LOG_LIMPA"
         done
    
     #           Movendo arquivos Temporarios
         _linha
         printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M11}+COLUMNS)/2)) "$M11" ;printf "%*s""${NORM}"
         _linha
       
    cd "$tools"/ || exit
    else
    #              Sistema nao e IsCOBOL
         _linha
         printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M05}+COLUMNS)/2)) "$M05" ;printf "%*s""${NORM}"
         _linha
       
    fi

_press
_ferramentas


}
###################################################
##  Rotina de recuperar arquivos                 ##
###################################################

_rebuild    () {
    clear
    printf "${GREEN}     +--------------------------------------------+${NORM}%s\n"
    printf "${GREEN}     |${NORM}      ${RED}          Menu Rebuild                ${GREEN}|${NORM}%s\n"
    printf "${GREEN}     +--------------------------------------------+${NORM}%s\n"
    printf "\n"
    printf "\n"
    printf "     ${PURPLE}Escolha opcao: ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}1${NORM} - ${WHITE}Um arquivo ou Todos ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}2${NORM} - ${WHITE}Arquivos Principais ${NORM}%s\n"
    printf "\n"
    printf "     ${GREEN}9${NORM} - ${RED}Menu Anterior${NORM}%s\n"
    printf "\n"
    printf "     ${YELLOW}Digite o numero da OPCAO desejada -> ${NORM}%s"
    read -r OPCAO1
    case $OPCAO1 in
        1) _rebuild1 ;;
        2) _rebuildlista ;;
        9) clear ; _ferramentas ;;
        *) Opcao Invalida ; printf ; _ferramentas ;;
    esac
}

###################################################
##  Rotina de recuperar arquivos especifico ou   ##
##     todos se deixar em branco                 ##
###################################################

_rebuild1() {
 if [ "$sistema" = "iscobol" ]; then
         printf "
         \033c\033[10;10H${RED}Informe o nome do arquivo ser recuperado
        ou enter para todos os arquivos do diretorio: ${NORM} %s\n"
        read -rp "${YELLOW}""         Informe o nome maiusculo: ""${NORM}" PEDARQ

        if [ -z "$PEDARQ" ]; then
         printf "
         \033c\033[10;10H${RED}Voce nao informou o arquivo a ser recuperado:${NORM}%s\n"
 local jut="$destino""$JUTIL"
    cd "$dir"/ || exit

        for i in $dir/{*.ARQ.dat,*.DAT.dat,*.LOG.dat,*.PAN.dat}
        do
## grava tamanho do arquivo em variavel
    TAMANHO=$(du "$i" | awk '{print $1}')
## executa rebuild se tamanho for maior que zero
        if [ "$TAMANHO" -gt 0 ] ; then
        $jut -rebuild "$i" -a -f
        fi
        done 
        cd "$tools"/ || exit
        else
    while [[ "$PEDARQ" =~ [^A-Z0-9] ]]; do

     printf "
     \033c\033[10;10H${RED}Voce nao informou o nome do arquivo em minusculo ${NORM}%s\n" 
    cd "$tools"/ || exit
_press
_ferramentas
    done

        cd "$dir" || exit 
    local ARQUIVO="$PEDARQ.???.dat"
        for i in $ARQUIVO
        do 
        "$destino""$JUTIL" -rebuild "$i" -a -f 
        done
 
       cd "$tools"/ || exit
       fi

#             Arquivo(s) recuperado(s)...
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M18}+COLUMNS)/2)) "$M18" ;printf "%*s""${NORM}"
     _linha

cd "$tools"/ || exit
else
     printf "
         \033c\033[10;10H${RED}Recuperacao Isam :${NORM}%s\n"
    cd "$dir"/ || exit

for i in $dir/{*.ARQ,*.DAT,*.LOG,*.PAN}
do
# grava tamanho do arquivo em variavel
    TAMANHO=$(du "$i" | awk '{print $1}')
# executa rebuild se tamanho for maior que zero
    if [ "$TAMANHO" -gt 0 ]; then
     rebuild -e "$i"
    else
    rebuild -d -e "$i"
    fi
done
fi
_press
_rebuild 
}

###################################################
##  Rotina de recuperar arquivos de uma Lista    ## 
##  os arquivos estao cadatrados em "atualizaj"  ##
###################################################
#---------------------- TESTE Arquivos ----------------------------------#
[ ! -e "atualizaj" ] && printf "ERRO. Arquivo nao existe."    && exit 1
[ ! -r "atualizaj" ] && printf "ERRO. Sem acesso de leitura." && exit 1
#------------------------------------------------------------------------#

_rebuildlista() {
clear
if [ "$sistema" = "iscobol" ]; then
cd "$tools"/ || exit
local arqs
arqs=$(cat atualizaj)
local jut="$destino""$JUTIL"
cd "$dir"/ || exit
    for line in $arqs
    do
# grava tamanho do arquivo em variavel
    TAMANHO=$(du "$line" | awk '{print $1}')
# executa rebuild se tamanho for maior que zero
    if [ "$TAMANHO" -gt 0 ] ; then
    $jut -rebuild "$line" -a -f
    fi
    done 
#            Lista de Arquivo(s) recuperado(s)... 
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M12}+COLUMNS)/2)) "$M12" ;printf "%*s""${NORM}"
     _linha
   
_press
else
     printf "
         \033c\033[10;10H${RED}Recuperacao em desenvolvimento :${NORM}
%s\n"
fi
_press
_rebuild
}

###################################################
##  Rotina de backup com opcao de envio da a SAV ##
###################################################

_backup () {
clear
local DIRDEST="$tools""$backup"
    if [ ! -d "$DIRDEST" ]; then
M23=".. Criando o diretorio dos backups em $DIRDEST.."
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M23}+COLUMNS)/2)) "$M23" ;printf "%*s""${NORM}"
     _linha
   
    mkdir -p "$DIRDEST"
    fi
    
DAYS2=$(find "$DIRDEST" -ctime -2 -name "$EMPRESA"\*zip)
    cd "$dir" || exit
if [ "$DAYS2" ] ; then

M62="Ja existe um backup em ""$DIRDEST"" nos ultimos dias."
    printf "\n"
    printf "\n"
    _linha
    printf "%*s""${CYAN}" ;printf "%*s\n" $(((${#M62}+COLUMNS)/2)) "$M62" ;printf "%*s""${NORM}"
    _linha  
    printf "\n" 
    printf "${YELLOW}""          Deseja continuar ? (N/s): ""${NORM}%s"
    read -r -n1 CONT 
    printf "\n"
        if [ "$CONT" = N ] || [ "$CONT" = n ] || [ "$CONT" = "" ] ; then

#            Backup Abortado!
     _linha
     printf "%*s""${RED}" ;printf "%*s\n" $(((${#M47}+COLUMNS)/2)) "$M47" ;printf "%*s""${NORM}"
     _linha        
    sleep 3s
    _ferramentas 
        elif [ "$CONT" = S ] || [ "$CONT" = s ] ; then

#            Sera criado mais um backup para o mesmo dia
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M06}+COLUMNS)/2)) "$M06" ;printf "%*s""${NORM}"
     _linha

        else
#            Opcao Invalida 
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M08}+COLUMNS)/2)) "$M08" ;printf "%*s""${NORM}"
     _linha

     _ferramentas 
        fi
fi
#           Criando Backup..
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M14}+COLUMNS)/2)) "$M14" ;printf "%*s""${NORM}"
     _linha
    
ARQ="$EMPRESA"_$(date +%Y%m%d%H%M).zip

### Rotina do progresso de execução.

_progresso () { 
  echo -n "${YELLOW}"" Favor aguardar [""${NORM}"
  while true
  do
    echo -n "${YELLOW}"".""${NORM}"
    sleep 5
  done
}

_dobackup () {
    # put backup commands here
	zip "$DIRDEST"/"$ARQ" ./*.* -x ./*.zip ./*.tar ./*tar.gz >/dev/null 2>&1
}

# Inicia em background
_progresso &

# Save o progresso () PID
# Você precisa usar o PID para matar a função
MYSELF=$!

# Start backup
# Transfere o controle para o dobackup()
_dobackup

# Matar progresso
kill $MYSELF >/dev/null 2>&1

     echo "${CYAN}""]pronto""${NORM}"
     printf "\n"

####

#            O backup de nome \"""$ARQ""\" foi criado em $DIRDEST$}
M10="O backup de nome ""$ARQ"
M32="foi criado em ""$DIRDEST"
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M10}+COLUMNS)/2)) "$M10" ;printf "%*s""${NORM}"
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M32}+COLUMNS)/2)) "$M32" ;printf "%*s""${NORM}"
     _linha
     printf "\n"

#   Backup Concluido!
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M16}+COLUMNS)/2)) "$M16" ;printf "%*s""${NORM}"
     _linha
   
 
################################
# ENVIAR PARA A SAV OU NAO     #
################################

    printf "\n"
    clear
M10="O backup de nome \"""$ARQ""\"" 
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M10}+COLUMNS)/2)) "$M10" ;printf "%*s""${NORM}"
     _linha
   
     printf "${YELLOW}""         Deseja enviar para o servidor da SAV ? (N/s):""${NORM}%s"
     read -r -n1 CONT 
     printf "\n"
     printf "\n"
     if [ "$CONT" = N ] || [ "$CONT" = n ] || [ "$CONT" = "" ] ; then    
     _ferramentas
     elif [ "$CONT" = S ] || [ "$CONT" = s ] ; then
 
     printf "
      \033c\033[10;10H${RED}Enviar backup para a SAV. ${NORM}%s\n"
     read -rp "${YELLOW}""         Informe para qual diretorio no servidor: ""${NORM}" ENVBASE
     while [[ "$ENVBASE" =~ [0-9] || -z "$ENVBASE" ]] ;do
     printf "
     \033c\033[10;10H${RED}Voce nao informou o nome do diretorio a enviado, saindo... ${NORM}%s\n" 

_press    
     _ferramentas 
     done
#    Informe a senha do usuario do scp
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M29}+COLUMNS)/2)) "$M29" ;printf "%*s""${NORM}"
     _linha

     "$cmd_scp" -P "$PORTA" "$DIRDEST/$ARQ" "$USUARIO"@"$IPSERVER":/"$ENVBASE" 
M15="Backup enviado para a pasta, \"""$ENVBASE""\"."
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M15}+COLUMNS)/2)) "$M15" ;printf "%*s""${NORM}"
     _linha
     sleep 3 
     else
#   Opcao Invalida
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M08}+COLUMNS)/2)) "$M08" ;printf "%*s""${NORM}"
     _linha  
    _ferramentas 
   fi
} 

#####################################
#   Enviar backup avulso            #
#####################################
_backupavulso () {
local DIRDEST="$tools""$backup"
    ls "$DIRDEST"/"$EMPRESA"_*.zip

#            Informe de qual o Backup que deseja enviar.
     _linha
     printf "%*s""${RED}" ;printf "%*s\n" $(((${#M52}+COLUMNS)/2)) "$M52" ;printf "%*s""${NORM}"
     _linha     

     read -rp "${YELLOW}""         1- Informe nome BACKUP: ""${NORM}" VBACKAV
local VBACKUP="$EMPRESA"_"$VBACKAV"
     while [[ -f "$VBACKUP".zip ]] ;do 
     clear
     printf "
     \033c\033[10;10H${RED}* * * < < Nome do Backup nao foi informada > > * * *${NORM}%s\n" 
_press
_ferramentas
    done
    if test ! -r "$tools""$backup"/"$VBACKUP".zip ; then
        printf "
         ************************************************************
               ${RED}Backup nao encontrado no diretorio${NORM}
         ************************************************************
%s\n"
_press
_ferramentas
    fi
    printf "\n"
    clear
     printf "
          \033c\033[10;10H
          *****************************************************
             ${YELLOW}""O backup \"""$VBACKUP""\" ${NORM}
          *****************************************************
%s\n"
    printf "${YELLOW}""         Deseja enviar para o servidor da SAV ? (N/s):""${NORM}%s"
    read -r -n1 CONT 
    printf "\n"
    printf "\n"
    if [ "$CONT" = N ] || [ "$CONT" = n ] || [ "$CONT" = "" ] ; then    
    _ferramentas
    elif [ "$CONT" = S ] || [ "$CONT" = s ] ; then
 
     printf "
      \033c\033[10;10H${RED}Enviar backup para a SAV. ${NORM}%s\n"
    read -rp "${YELLOW}""         Informe para qual diretorio no servidor: ""${NORM}" ENVBASE
    while [[ "$ENVBASE" =~ [0-9] || -f "$ENVBASE" ]] ;do
     printf "
     \033c\033[10;10H${RED}Voce nao informou o nome do diretorio a enviado, saindo... ${NORM}%s\n" 

_press    
    _ferramentas 
    done

#    Informe a senha do usuario do scp
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M29}+COLUMNS)/2)) "$M29" ;printf "%*s""${NORM}"
     _linha
     "$cmd_scp" -P "$PORTA" "$DIRDEST/$VBACKUP".zip "$USUARIO"@"$IPSERVER":/"$ENVBASE" 
M15="Backup enviado para a pasta, \"""$ENVBASE""\"."
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M15}+COLUMNS)/2)) "$M15" ;printf "%*s""${NORM}"
     _linha
    sleep 3 
    else
#   Opcao Invalida
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M08}+COLUMNS)/2)) "$M08" ;printf "%*s""${NORM}"
     _linha 
    _ferramentas 
   fi
}   
  
###################################
## VOLTA BACKUP TOTAL OU PARCIAL ##
###################################

_unbackup () {
    clear
local DIRDEST="$tools""$backup"/
local DIRBACK="$tools""$backup"/dados

    if [ ! -d "$DIRBACK" ]; then

M22=".. Criando o diretorio temp do backup em $DIRBACK.." 
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M22}+COLUMNS)/2)) "$M22" ;printf "%*s""${NORM}"
     _linha
   
    mkdir -p "$DIRDEST"dados 
    fi
    ls -s "$DIRDEST""$EMPRESA"_*.zip
     _linha
     printf "%*s""${RED}" ;printf "%*s\n" $(((${#M53}+COLUMNS)/2)) "$M53" ;printf "%*s""${NORM}"
     _linha
     read -rp "${YELLOW}""         1- Informe nome BACKUP: ""${NORM}" VBACK
local VBACKUP="$EMPRESA"_"$VBACK"
    while [[ -f "$VBACKUP".zip ]] ;do 
    clear
    printf "
     \033c\033[10;10H${RED}* * * < < Nome do Backup nao foi informada > > * * *${NORM}%s\n" 
_press
_ferramentas
    done
    if test ! -r "$tools""$backup"/"$VBACKUP".zip ; then
#   Backup nao encontrado no diretorio
     _linha
     printf "%*s""${RED}" ;printf "%*s\n" $(((${#M45}+COLUMNS)/2)) "$M45" ;printf "%*s""${NORM}"
     _linha
   
_press
_ferramentas
    fi
    printf "\n" 
#   "Deseja volta todos os ARQUIVOS do Backup ? (N/s):"
    _linha
    printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M35}+COLUMNS)/2)) "$M35" ;printf "%*s""${NORM}"
    _linha
    read -r -n1 CONT 
    printf "\n"
    printf "\n"
    if [ "$CONT" = N ] || [ "$CONT" = n ] || [ "$CONT" = "" ] ; then

    read -rp "${YELLOW}""       2- Informe o somente nome do arquivo em maiusculo: ""${NORM}" VARQUIVO
    while [[ "$VARQUIVO" =~ [^A-Z0-9] ]]
    do
 
    printf "
     \033c\033[10;10H${RED}ERRO: Voce informou o nome do arquivo em minusculo ${NORM}%s\n" 
_press
_ferramentas
    done

#   ---- Voltando Backup anterior  ... ----

M34="O arquivo ""$VARQUIVO"

     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M33}+COLUMNS)/2)) "$M33" ;printf "%*s""${NORM}"
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M34}+COLUMNS)/2)) "$M34" ;printf "%*s""${NORM}"
     _linha

    cd "$DIRBACK" || exit
    unzip -o "$DIRDEST""$VBACKUP".zip "$VARQUIVO*.*" >> "$LOG_ATU"
    sleep 1

    if ls -s "$VARQUIVO"*.* >erro /dev/null 2>&1 ; then
#   Arquivo encontrado no diretorio$
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M28}+COLUMNS)/2)) "$M28" ;printf "%*s""${NORM}"
     _linha
   
    else
#   Arquivo nao encontrado no diretorio
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M49}+COLUMNS)/2)) "$M49" ;printf "%*s""${NORM}"
     _linha
   
_press 
_ferramentas   
    fi

    mv -f "$VARQUIVO"*.* "$dir" >> "$LOG_ATU" 
    cd "$tools"/ || exit
    clear
#   VOLTA DO ARQUIVO CONCLUIDA$
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M04}+COLUMNS)/2)) "$M04" ;printf "%*s""${NORM}"
     _linha
   
_press
_ferramentas
    elif [ "$CONT" = S ] || [ "$CONT" = s ] ; then
 
#    ---- Voltando Backup anterior  ... ----
M34="O arquivo ""$VARQUIVO"
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M33}+COLUMNS)/2)) "$M33" ;printf "%*s""${NORM}"
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M34}+COLUMNS)/2)) "$M34" ;printf "%*s""${NORM}"
     _linha
   
    cd "$DIRBACK" || exit
    unzip -o "$DIRDEST""$VBACKUP".zip  >> "$LOG_ATU"
    
    mv -f -- *.* "$dir" >> "$LOG_ATU"
 
    cd "$tools"/ || exit
    clear
#   VOLTA DOS ARQUIVOS CONCLUIDA
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M04}+COLUMNS)/2)) "$M04" ;printf "%*s""${NORM}"
     _linha
   
_press
    else
# Opcao Invalida
     _linha
     printf "%*s""${YELLOW}" ;printf "%*s\n" $(((${#M08}+COLUMNS)/2)) "$M08" ;printf "%*s""${NORM}"
     _linha
   
    fi
_ferramentas
}
########################################################
# Limpando arquivos de atualizacao com mais de 30 dias #
########################################################
_expurgador () {
    clear
### apagar Biblioteca### 
     local DIR1="$tools""$backup"/
     for seq1 in {*.bkp,*.zip,*.tgz}
     do
     "$cmd_find" "$DIR1" -name "$seq1" -ctime +30 -exec rm -r {} \; >> "$LOG_LIMPA"
     done
#### apagar olds###
     local DIR2="$tools""$olds"/
     "$cmd_find" "$DIR2" -name "*.zip" -ctime +30 -exec rm -r {} \; >> "$LOG_LIMPA"

#### apagar progs###
     local DIR3="$tools""$progs"/
     "$cmd_find" "$DIR3" -name "*.bkp" -ctime +30 -exec rm -r {} \; >> "$LOG_LIMPA"
     printf "\n"

# Verificando e/ou excluido arquivos com mais de 30 dias criado.
     _linha
     printf "%*s""${RED}" ;printf "%*s\n" $(((${#M51}+COLUMNS)/2)) "$M51" ;printf "%*s""${NORM}"
     _linha
     printf "\n"
     printf "\n" 
cd "$tools"/ || exit

_press
_ferramentas
}
_principal
tput sgr0

