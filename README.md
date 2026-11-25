# DE-shell

Neste repositório guardo as entregas do meu estudo das bases de computação usadas em
engenharia de dados: terminal, Git e Docker. O estudo segue as aulas do Missing Semester
(MIT), o livro Pro Git e a documentação oficial do Docker. Cada semana tem uma pasta, com um
entregável que roda e um registro do que aprendi.

Para rodar, você precisa de um Linux ou do WSL com bash, Python 3 e Docker (só na semana 4).


## s1 - shell e scripts

O que estudei: navegação e arquivos pelo terminal, redirecionamento (`>`, `>>`, `2>&1`),
códigos de saída e scripts bash.

O entregável é o `s1/rodar_etl.sh`, um script que roda um ETL em Python, grava
um log com data e hora e sai com erro se o Python falhar.

Decisões:
- O script começa com `cd "$(dirname "$0")"`, então funciona chamado de qualquer pasta.
- O `if !` testa o código de saída do Python, e não o texto que ele imprime. Se o ETL falha,
  o script registra o erro no log e sai com `exit 1`.
- O `s1/ruim.csv` é um arquivo de teste com um valor inválido (`dez`), feito para provocar a
  falha: `python3 s1/etl.py s1/ruim.csv`.

Os arquivos em `src/` são os exercícios curtos das aulas (argumentos, testes de arquivo,
nomes com espaço).


## s2 - dados direto no terminal

O que estudei: grep, awk, sort, uniq e wc, e o ambiente da linha de comando.

O entregável é o `s2/perguntas.sh`. Ele responde a três perguntas sobre os aeroportos do Brasil
usando só ferramentas de terminal. A base é pública (datasets/airport-codes) e o
script a baixa para `files/` se ainda não estiver lá.

As perguntas e o que encontrei:
1. Quantos aeroportos de cada tipo existem? O tipo mais comum é small_airport, com 5.605.
2. Quais são os 5 municípios com mais aeroportos? O primeiro é São Paulo, com 281.
3. Qual é a altitude média por estado, ignorando os vazios? A maior é a do DF, com 3.545 pés.


## s3 - Git

O que estudei: o modelo de dados do Git (commits como fotos do projeto, branches como nomes
que apontam para um commit), merge, conflito, stash, blame e reescrita de histórico.

O entregável está no histórico deste repositório, e não numa pasta. Criei duas branches a
partir da main, cada uma com uma melhoria no ETL da semana 1:
- `media`: acrescenta a coluna da média por linha;
- `duas-casas`: formata os valores com duas casas decimais.

As duas alteram a mesma linha, de propósito. O primeiro merge foi um fast-forward. O segundo
deu conflito, e o resolvi combinando os dois lados, ou seja, mantendo a média e as duas casas
decimais. O resultado é o commit de merge `0e61af8`.

    git log --all --graph --decorate --oneline

O que aprendi:
- O `.gitignore` não tira do Git um arquivo que já é versionado. Para isso existe o
  `git rm --cached`.
- Apagar um arquivo num commit novo não o remove do histórico. Uma senha comitada continua
  legível nos commits antigos.
- Reescrever um commit muda o hash dele e o de todos os commits seguintes.


## s4 - Docker

O que estudei: imagem, container, volume, rede, Dockerfile e Docker Compose.

O entregável é o `s4/docker-compose.yml`, que sobe dois serviços:
- `db`: um Postgres 16, com os dados num volume;
- `etl`: uma imagem própria (`s4/Dockerfile`) com Python e psycopg, que lê o `entrada.csv` e
  carrega na tabela `vendas`.

Para rodar, crie primeiro o arquivo `s4/.env` com a senha do banco. Ele não está no repositório
de propósito:

    cd s4
    echo "POSTGRES_PASSWORD=escolha-uma-senha" > .env
    docker compose up --build -d
    docker compose ps -a
    docker compose logs etl

Saída esperada: `db` como `Up (healthy)` e `etl` como `Exited (0)`, com a mensagem
`carga ok: tabela com 2 linhas`. Para consultar a tabela:

    docker compose exec db psql -U postgres -c "select * from vendas"

Para derrubar tudo, incluindo os dados: `docker compose down -v`.

Decisões:
- A carga é idempotente: o ETL esvazia a tabela (`truncate`) e insere tudo de novo, na mesma
  transação. Rodar uma ou dez vezes dá o mesmo resultado. Se um insert falha, o rollback
  devolve os dados que já estavam lá, e a tabela nunca fica vazia nem pela metade.
- O `etl` espera o banco ficar saudável (`healthcheck` com `pg_isready`). Só o `depends_on`
  não bastava: ele garante a ordem de início, mas não espera o Postgres aceitar conexões, e na
  primeira subida o ETL falhava com "connection refused".
- A senha vem do `.env`, que fica fora do Git (`.gitignore`) e fora da imagem
  (`.dockerignore`).
- No Dockerfile, o `pip install` vem antes do `COPY` do código. Assim, editar o `etl.py` não
  reinstala as bibliotecas, porque o Docker reaproveita essa etapa do cache.
- A imagem recebe os arquivos pelo nome, e não com `COPY . .`, para não levar nada além do que
  o ETL usa.
