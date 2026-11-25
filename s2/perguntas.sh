#!/bin/bash
cd "$(dirname "$0")"
FILE_PATH="../files/airport-codes.csv"

if [ ! -f "$FILE_PATH" ]; then
    curl -sSL -o "$FILE_PATH" https://raw.githubusercontent.com/datasets/airport-codes/main/data/airport-codes.csv
fi

# pergunta 1.Quantos aeroportos o Brasil tem de cada tipo?:
printf "Quantos aeroportos de cada tipo no Brasil?\n"
awk -F, '$6=="BR" {print $2}' "$FILE_PATH" | sort | uniq -c | sort -rn | head -5

# pergunta 2. Quais são os 5 municípios brasileiros com mais aeroportos?:
printf "Quais os 5 municípios com mais aeroportos?\n"
awk -F, '$6=="BR" {print $8}' "$FILE_PATH" | sort | uniq -c | sort -rn | head -5

# pergunta 3. Qual estado tem a maior altitude média entre os aeroportos que não estão fechados?:
printf "Estado com maior altitude entre os que não estão fechados:\n"
awk -F, '$6=="BR" && $2!="closed" && $4!="" { n[$7]++ ; s[$7]+=$4 } END {for (k in n) print s[k]/n[k], k}' "$FILE_PATH" | sort -rn | head -3