FROM python:3.11-slim-bookworm

WORKDIR /usr/src/app

# Если нужен psycopg2 без компиляции — ставим бинарный
RUN pip install --no-cache-dir flask flask_sqlalchemy psycopg2-binary

COPY . .

ARG COLOR_SCHEME=light
ENV COLOR_SCHEME=$COLOR_SCHEME

CMD ["python", "./app.py"]