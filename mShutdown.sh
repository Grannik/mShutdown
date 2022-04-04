#!/bin/bash
 E='echo -e';    # -e включить поддержку вывода Escape последовательностей
 e='echo -en';   # -n не выводить перевод строки
 trap "R;exit" 2
    ESC=$( $e "\e")
   TPUT(){ $e "\e[${1};${2}H" ;}
  CLEAR(){ $e "\ec";}
# 25 возможно это
  CIVIS(){ $e "\e[?25l";}
# это цвет текста списка перед курсором при значении 0 в переменной  UNMARK(){ $e "\e[0m";}
MARK(){ $e "\e[2;31;42m";}
# 0 это цвет списка
 UNMARK(){ $e "\e[0m";}
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Эти строки задают цвет фона ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  R(){ CLEAR ;stty sane;CLEAR;};                 # в этом варианте фон прозрачный
# R(){ CLEAR ;stty sane;$e "\ec\e[37;44m\e[J";}; # в этом варианте закрашивается весь фон терминала
# R(){ CLEAR ;stty sane;$e "\ec\e[0;45m\e[";};   # в этом варианте закрашивается только фон меню
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 HEAD(){ for (( a=2; a<=23; a++ ))
  do
 TPUT $a 1
   $E "\033[31m\xE2\x94\x82                                                       \xE2\x94\x82\033[0m";
  done
 TPUT 3 3
   $E "\033[1;36m*** shutdown ***\033[0m";
 TPUT 4 3
   $E "\033[2mОстановить, выключить или перезагрузить машину\033[0m";
 TPUT 5 1
   $E "\033[31m+-------------------------------------------------------+\033[0m";
 TPUT 10 1
   $E "\033[31m+--------------------------------------- Options -------+\033[0m";
 TPUT 11 3
   $E "\033[2mПоддерживаются следующие опции:\033[0m";
 TPUT 21 3
   $E "\033[2mUp \xE2\x86\x91 \xE2\x86\x93 Down Select Enter ----------------------------\033[0m";
 MARK;TPUT 1 1
   $E "+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+";UNMARK;}
   i=0; CLEAR; CIVIS;NULL=/dev/null
# 32 это расстояние сверху и 48 это расстояние слева
   FOOT(){ MARK;TPUT 24 1
   $E "+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+";UNMARK;}
# это управляет кнопками ввер/хвниз
 i=0; CLEAR; CIVIS;NULL=/dev/null
#
 ARROW(){ IFS= read -s -n1 key 2>/dev/null >&2
           if [[ $key = $ESC ]];then
              read -s -n1 key 2>/dev/null >&2;
              if [[ $key = \[ ]]; then
                 read -s -n1 key 2>/dev/null >&2;
                 if [[ $key = A ]]; then echo up;fi
                 if [[ $key = B ]];then echo dn;fi
              fi
           fi
           if [[ "$key" == "$($e \\x0A)" ]];then echo enter;fi;}
  M0(){ TPUT  6 3; $e " Краткий обзор                         \033[32mSynopsis     \033[0m";}
  M1(){ TPUT  7 3; $e " Описание                              \033[32mDescription  \033[0m";}
  M2(){ TPUT  8 3; $e " Статус выхода                         \033[32mExit Status  \033[0m";}
  M3(){ TPUT  9 3; $e " Смотрите также                        \033[32mSee Also     \033[0m";}
#
  M4(){ TPUT 12 3; $e " Показать справку и выйти              \033[32m   --help    \033[0m";}
  M5(){ TPUT 13 3; $e " Остановить машину                     \033[32m-H --halt    \033[0m";}
  M6(){ TPUT 14 3; $e " Выключение машины (по умолчанию)      \033[32m-P --poweroff\033[0m";}
  M7(){ TPUT 15 3; $e " Перезагрузите машину                  \033[32m-r --reboot  \033[0m";}
  M8(){ TPUT 16 3; $e " Эквивалент к -poweroff                \033[32m-h           \033[0m";}
  M9(){ TPUT 17 3; $e " Bыключайте питание, перезагружайтесь  \033[32m-k           \033[0m";}
 M10(){ TPUT 18 3; $e " Не отправлять сообщение на стену      \033[32m   --no-wall \033[0m";}
 M11(){ TPUT 19 3; $e " Отменить отложенное завершение работы \033[32m-c           \033[0m";}
 M12(){ TPUT 20 3; $e " Grannik Git                                        ";}
#
 M13(){ TPUT 22 3; $e " EXIT                                               ";}
LM=13
   MENU(){ for each in $(seq 0 $LM);do M${each};done;}
    POS(){ if [[ $cur == up ]];then ((i--));fi
           if [[ $cur == dn ]];then ((i++));fi
           if [[ $i -lt 0   ]];then i=$LM;fi
           if [[ $i -gt $LM ]];then i=0;fi;}
REFRESH(){ after=$((i+1)); before=$((i-1))
           if [[ $before -lt 0  ]];then before=$LM;fi
           if [[ $after -gt $LM ]];then after=0;fi
           if [[ $j -lt $i      ]];then UNMARK;M$before;else UNMARK;M$after;fi
           if [[ $after -eq 0 ]] || [ $before -eq $LM ];then
           UNMARK; M$before; M$after;fi;j=$i;UNMARK;M$before;M$after;}
   INIT(){ R;HEAD;FOOT;MENU;}
     SC(){ REFRESH;MARK;$S;$b;cur=`ARROW`;}
# Функция возвращения в меню
     ES(){ MARK;$e " ENTER = main menu ";$b;read;INIT;};INIT
  while [[ "$O" != " " ]]; do case $i in
  0) S=M0 ;SC;if [[ $cur == enter ]];then R;echo " shutdown [OPTIONS...] [TIME] [WALL...]";ES;fi;;
  1) S=M1 ;SC;if [[ $cur == enter ]];then R;echo "     Oтключение может быть использовано для отключения, отключения или перезагрузки машины.
 Первый аргумент может быть строкой времени (который обычно сейчас). По желанию, это может быть соблюдено настенным сообщением, которое будет отправлено всем
 зарегистрированным пользователям прежде чем идти вниз.
     Строка времени может быть либо в формате hh:mm в течение часа/минут, указав время, чтобы выполнить отключение, указанный в 24-часовом формате.
     В качестве альтернативы он может быть в синтаксисе +m, ссылаясь на указанное количество минут м отныне теперь является псевдонимом для +0, т.е. для запуска
 немедленное отключение. Если не указано время, +1 подразумевается.
 Обратите внимание, что для определения стенового сообщения необходимо указать временный аргумент тоже.
     Если аргумент времени используется, 5 минут до того, как система сводится к запуску / извинению файла создается для обеспечения того, чтобы дальнейшие входы не
 были разрешены.";ES;fi;;
  2) S=M2 ;SC;if [[ $cur == enter ]];then R;echo " В случае успеха возвращается 0, в противном случае — ненулевой код ошибки.";ES;fi;;
  3) S=M3 ;SC;if [[ $cur == enter ]];then R;echo " systemd, systemctl, halt, wall";ES;fi;;
  4) S=M4 ;SC;if [[ $cur == enter ]];then R;echo -e "\033[32m shutdown --help\033[0m";ES;fi;;
  5) S=M5 ;SC;if [[ $cur == enter ]];then R;echo -e "Остановить машину:\033[32m shutdown -H\033[0m";ES;fi;;
  6) S=M6 ;SC;if [[ $cur == enter ]];then R;echo -e "Выключение машины (по умолчанию):\033[32m\033[0m";ES;fi;;
  7) S=M7 ;SC;if [[ $cur == enter ]];then R;echo -e "Перезагрузите машину:\033[32m\033[0m";ES;fi;;
  8) S=M8 ;SC;if [[ $cur == enter ]];then R;echo -e "Эквивалент к -poweroff, если -halt не указан:\033[32m\033[0m";ES;fi;;
  9) S=M9 ;SC;if [[ $cur == enter ]];then R;echo -e "Не останавливайтесь, выключайте питание, перезагружайтесь, просто напишите сообщение на стене:\033[32m\033[0m";ES;fi;;
 10) S=M10;SC;if [[ $cur == enter ]];then R;echo -e "Не отправлять сообщение на стену перед остановкой, выключением питания, перезагрузкой:\033[32m\033[0m";ES;fi;;
 11) S=M11;SC;if [[ $cur == enter ]];then R;echo -e "
 Отменить отложенное завершение работы. Это можно использовать для отмены эффекта вызова shutdown с аргументом времени, отличным от «+0» или «сейчас»:
 \033[32m\033[0m";ES;fi;;
 12) S=M12;SC;if [[ $cur == enter ]];then R;echo "
 mShutdown. Программа описание утилиты shutdown. Остановить, выключить или перезагрузить машину.
 https://framagit.org/GrannikOleg/mshutdown
 https://bitbucket.org/grannikoleg/mshutdown/src/master/
 https://codeberg.org/Grannik/mShutdown
 https://notabug.org/Grannikoleg/mShutdown
 https://sourceforge.net/projects/mshutdown/files/
 https://github.com/GrannikOleg/mShutdown
 https://gitlab.com/grannik/mshutdown
 https://asciinema.org/a/484187
 Grannik | 2022.04.04
";ES;fi;;
#
 13) S=M13;SC;if [[ $cur == enter ]];then R;ls -l;exit 0;fi;;
 esac;POS;done
