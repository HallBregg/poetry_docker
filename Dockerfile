# TODO Share ENV's between stages.
ARG PYTHONUNBUFFERED=1
ARG PYTHONDONTWRITEBYTECODE=1
ARG PIP_NO_CACHE_DIR=off
ARG PIP_DISABLE_PIP_VERSION_CHECK=on
ARG PIP_DEFAULT_TIMEOUT=100
ARG POETRY_HOME="/opt/poetry"
ARG POETRY_VIRTUALENVS_IN_PROJECT=true
ARG POETRY_NO_INTERACTION=1
ARG PYSETUP_PATH="/opt/pysetup"
ARG VENV_PATH="/opt/pysetup/.venv"


FROM python:3.10 AS python-base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"


FROM python-base AS build-base

ENV POETRY_VERSION=1.1.12
RUN apt-get update \
    && apt-get install --no-install-recommends -y curl build-essential \
    && curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $PYSETUP_PATH
COPY ./poetry.lock ./pyproject.toml ./
RUN poetry install --no-dev


FROM python-base AS dev

COPY --from=build-base $POETRY_HOME $POETRY_HOME
COPY --from=build-base $PYSETUP_PATH $PYSETUP_PATH
WORKDIR $PYSETUP_PATH
RUN poetry install

WORKDIR /opt/app
COPY . .
RUN pip install -e.
