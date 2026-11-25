import csv, sys, os, psycopg
from pathlib import Path

entrada = Path(sys.argv[1] if len(sys.argv) > 1 else "entrada.csv")

print(f"lendo {entrada}")
with entrada.open() as f:
    linhas = list(csv.DictReader(f))

with psycopg.connect(host="db", user="postgres",
                     password=os.environ["POSTGRES_PASSWORD"],
                     dbname="postgres") as conn:
    conn.execute("create table if not exists vendas (cliente text, valor numeric)")
    conn.execute("truncate vendas")
    for l in linhas:
        conn.execute("insert into vendas (cliente, valor) values (%s, %s)",
                     (l["cliente"], l["valor"]))
    total = conn.execute("select count(*) from vendas").fetchone()[0]
    
print(f"carga ok: tabela com {total} linhas")