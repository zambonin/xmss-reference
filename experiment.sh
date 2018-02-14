#!/bin/bash
# usage: ./$0 <n. tests>

tests="${1:-10240}"
while : ; do
  for R in 25 200 3500 ; do
    make "THRESHOLD=$R" "SIGNATURES=$tests" -Bsj
    for i in test/xmss{,mt}_*f* ; do
      printf "running %d signatures on %s with R=%d\n" $tests $i $R
      ./$i | awk -v n=$tests '
        /s.* t/ { s += $3 } /v.* t/ { v += $3 } END { print s / n, v / n }'
    done
  done
  if grep -q "params->wots_w = 256;" params.c ; then
    git checkout params.c
    break
  fi
  sed -i '/wots_w/{s/16/256/}; /wots_log_w /{s/4/8/}' params.c
done
