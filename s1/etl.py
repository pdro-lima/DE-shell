import csv, sys
from pathlib import Path

entrada = Path(sys.argv[1] if len(sys.argv) > 1 else "entrada.csv")
saida = Path("saida.csv")

print(f"lendo {entrada}")
with entrada.open() as f:
    linhas = list(csv.DictReader(f))

total = sum(float(l["valor"]) for l in linhas)
with saida.open("w") as f:
    f.write(f"linhas,total\n{len(linhas)},{total:.2f}\n")
print(f"ok: {len(linhas)} linhas, total {total:.2f}")
