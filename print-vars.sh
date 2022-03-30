#!/bin/sh
echo "== Vars =="
echo "pwd = $(pwd)"
echo "HOME = $HOME"
echo "[~/cache]"
ls ~/cache
cat ~/cache/dates.txt
echo "[./cache]"
ls ./cache
cat ./cache/dates.txt
exit 0
