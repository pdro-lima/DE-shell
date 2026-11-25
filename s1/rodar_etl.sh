#!/bin/bash
cd "$(dirname "$0")" || { echo "erro no diretório"; exit 1; }
fmt='+%Y-%m-%d %H:%M:%S'
path_log=../files/log_etl.log
echo "[$(date "$fmt")] início" >> "$path_log"
if ! python3 etl.py >> "$path_log" 2>&1; then
    echo "[$(date "$fmt")] erro" >> "$path_log"
    exit 1
else
    echo "[$(date "$fmt")] fim" >> "$path_log"
    exit 0
fi
