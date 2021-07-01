FROM python:3.8.0

ARG MLFLOW_VERSION=1.18.0

ENV SERVER_PORT 5000

ENV SERVER_HOST 0.0.0.0

RUN apt-get update && apt-get install -y \
    curl \
    default-libmysqlclient-dev \
    htop \
    locales \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# install poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | POETRY_HOME=/opt/poetry python3 && \
    cd /usr/local/bin && \
    ln -s /opt/poetry/bin/poetry && \
    poetry config virtualenvs.create false

COPY pyproject.toml poetry.lock /app/ 

WORKDIR /app

RUN poetry install --no-interaction --no-ansi

RUN poetry add "mlflow=${MLFLOW_VERSION}"

EXPOSE ${SERVER_PORT}/tcp

ENTRYPOINT mlflow server \
    --backend-store-uri "mysql+mysqldb://${MYSQL_USR}:${MYSQL_PSW}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}?charset=utf8" \
    --default-artifact-root ${MLFLOW_AWS_BUCKET_URI} \
    --host ${SERVER_HOST}
