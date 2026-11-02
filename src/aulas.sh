#!/bin/bash
curl -sf https://missing.csail.mit.edu/naoexiste > /tmp/pagina.html || { echo "erro na URL"; exit 1; }
ano=$(grep -oE 'href="/[0-9]{4}/' /tmp/pagina.html | grep -oE '[0-9]{4}' | sort -nr | head -1)
if [ -z "$ano" ]; then
    echo "erro na extração do ano das aulas"
    exit 1
fi
grep -c "href=\"/$ano/[a-z]" /tmp/pagina.html