.PHONY: clean clean-test clean-pyc clean-build docs help
.DEFAULT_GOAL := help


export REPOSITORY_NAME=content-database
export AWS_ACCOUNT_NUMBER ?= 294141084087
export REGION = eu-west-1
export GLOBAL_VERSION = 0.0.1


define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@poetry run python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

lint: checktypes checkstyle sast checklicenses ## run all checks

checktypes: ## check types with mypy
	poetry run mypy --ignore-missing-imports content_database

checkstyle: ## check style with flake8, isort and black
	poetry run isort --check-only --profile black content_database
	poetry run black --check --diff content_database

fixstyle: ## fix black and isort style violations
	poetry run isort --profile black content_database
	poetry run black content_database

sast: ## run static application security testing
	poetry run bandit -r content_database

test: ## run tests quickly with the default Python
	poetry run pytest --verbose --capture=no

coverage: ## check code coverage quickly with the default Python
	poetry run coverage run --source content_database -m pytest
	poetry run coverage report -m
	poetry run coverage html
	poetry run $(BROWSER) htmlcov/index.html

release: dist ## package and upload a release, manage version yourself
	# poetry version prerelease/patch/minor/major
	# https://python-poetry.org/docs/cli/#version
	sed -i 's/simple/upload/g' pyproject.toml
	poetry publish -r pypigetfeed
	sed -i 's/upload/simple/g' pyproject.toml

dist: clean ## builds source and wheel package
	poetry build

requirements.txt: poetry.lock ## create/update the requirements.txt file using poetry
	poetry export -f requirements.txt --output requirements.txt
	@touch -c requirements.txt # when there are no dependencies


.venv: poetry.lock
	poetry config virtualenvs.in-project true
	poetry install
	@touch -c .venv

poetry.lock:
	poetry update -vvv
	@touch -c poetry.lock

codeartifact_authenticate:
	poetry config http-basic.artifact aws `aws codeartifact get-authorization-token --domain degould  --query authorizationToken --output text`

infra__%:
	${MAKE} --directory ${CURDIR}/infra -f make.mk $*

build_deploy: infra__build infra__deploy

connect_db_local:
	python content_database/db_connect.py --connect local

connect_db_rds:
	python content_database/db_connect.py --connect rds
