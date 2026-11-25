FROM python:3.12-slim
RUN pip install "psycopg[binary]==3.2.3"
WORKDIR /app
COPY etl.py entrada.csv ./ 
CMD ["python", "etl.py"]
