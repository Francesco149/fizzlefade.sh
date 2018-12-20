#!/bin/sh
o=$(printf '\033[31;41mx')
_=$(printf '\033[30;40mx')
trap 'exit' INT
trap 'tput rmcup; tput cnorm' EXIT
w=$( (tput cols && echo 652) | sort -n | sed 1q)
h=$( (tput lines && echo 201) | sort -n | sed 1q)
w=$(( w / 2 ))
seed=$(( ${1:-1} + 0 ))
rnd=$seed
scr=$(yes "$(yes "$_" | sed "${w}q" | xargs echo)" | sed "${h}q")
tput civis
while :; do
  rnd=$(( (rnd >> 1) ^ 0x00012000 * (rnd & 1) ))
  x=$(( (rnd >> 8) & 0x1ff )) && y=$(( rnd & 0xff ))
  if [ "$x" -lt "$w" ] && [ "$y" -lt "$h" ]; then
    scr=$(
      [ $y -gt 0 ] && echo "$scr" | sed $(( y ))q
      echo "$scr" | sed -n $(( y + 1 ))p |
        awk "$(printf "{ \$%d=\"%s\"; print \$0 }" $(( x + 1 )) "$o")"
      echo "$scr" | sed 1,$(( y + 1 ))d
    )
    printf '\033[H%s' "$(echo "$scr" |
      cut -d' ' -f1-$(( $(tput cols) / 2 )) | awk '{ print $0 "x" }')"
  fi
  if [ $rnd -eq $seed ]; then
    printf '\033[H%s ' "$o"; sleep 1; exec "$0" "$@"
  fi
done
