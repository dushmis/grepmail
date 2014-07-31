#!/bin/bash


usage() {
  cat << EOF
  Usage :  ${0##/*/} [options] <FILE> <PATTERN> <EMAIL>

  Options:
  -v|version    Display script version
EOF
  exit 1
}

if [[ $# -lt 3 ]]; then
  echo "Invalid Arguments...";
  usage;
  exit -1;
fi

file="$1";
pattern="$2";
email="$3";

md5er=$(exec 2>&-;which md5 || which md5sum);

if [[ ! -f "$file" ]]; then
  echo "Invalid File...";
  usage;
  exit -2;
fi
 
tail -f "$file" | while read line; do
  b=$(grep -A 10 -i "$pattern" <<< "$line")
  if [[ $? -eq 0 ]];
  then
    blength=${#b};
    mlimit=550;
    if [[ $blength -gt $mlimit ]];
    then
      b=${b:0:${mlimit}}
    fi
    msum=$("$md5er" <<< "$b")
    if [[ ! -f ~/.storesum ]]; then
      touch ~/.storesum
    fi
    grep "$msum" ~/.storesum
    if [[ $? -ne 0 ]];
    then
      echo >> ~/.storesum "$msum"
      echo "not found $msum $b";
      d_ate=$(date +"%D");
      echo "mailing to $email";
      mail -s "#monitoring-${d_ate}" "$email" <<< "$b";
    else
      echo "found $msum $b"
    fi
  fi
done

