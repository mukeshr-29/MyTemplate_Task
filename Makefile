#.PHONY: docs test agent-setup agent-resetdb agent-smoke agent-test
.PHONY: docs test lint security coverage ui agent-setup agent-resetdb agent-smoke agent-test
VENV_PYTHON=env/bin/python
AGENT_TEST_FILES=$(shell git ls-files 'tests/*.py')

# help:
# 	@echo "  env         create a development environment using virtualenv"
# 	@echo "  deps        install dependencies using pip"
# 	@echo "  clean       remove unwanted files like .pyc's"
# 	@echo "  lint        check style with flake8"
# 	@echo "  test        run all your tests using py.test"
# 	@echo "  agent-setup install dependencies in ./env for AI/code agents"
# 	@echo "  agent-resetdb reset and seed local development database"
# 	@echo "  agent-smoke run fast smoke tests"
# 	@echo "  agent-test  run full test suite with coverage"
help:
	@echo "  env         create a development environment using virtualenv"
	@echo "  deps        install dependencies using pip"
	@echo "  clean       remove unwanted files like .pyc's"
	@echo "  lint        check code with Ruff"
	@echo "  security    run Bandit security scan"
	@echo "  test        run backend tests using pytest"
	@echo "  coverage    run tests with coverage and generate reports"
	@echo "  ui          run Playwright UI tests"
	@echo "  agent-setup install dependencies in ./env for AI/code agents"
	@echo "  agent-resetdb reset and seed local development database"
	@echo "  agent-smoke run fast smoke tests"
	@echo "  agent-test  run full test suite with coverage"
env:
	python3 -m venv env && \
	. env/bin/activate && \
	make deps

deps:
	pip install -r requirements.txt

clean:
	find . | grep -E "(__pycache__|\.pyc|\.DS_Store|\.db|\.pyo$\)" | xargs rm -rf

lint:
	# flake8 --exclude=env .
	ruff check appname tests --output-format=json > reports/ruff-report.json
security:
	mkdir -p reports
	bandit -r appname -f json -o reports/bandit-report.json
test:
	# py.test tests
	APPNAME_ENV=test $(VENV_PYTHON) -m pytest tests --ignore=tests/ui -v
coverage:
	mkdir -p reports/coverage
	APPNAME_ENV=test $(VENV_PYTHON) -m pytest tests --ignore=tests/ui -v \
		--junitxml=reports/junit.xml \
		--cov=appname \
		--cov-report=term-missing \
		--cov-report=xml:reports/coverage/coverage.xml \
		--cov-report=html:reports/coverage/html

ui:
	$(VENV_PYTHON) -m pytest tests/ui -v --base-url=http://127.0.0.1:5000

agent-setup:
	python3 -m venv env
	$(VENV_PYTHON) -m pip install --upgrade pip
	$(VENV_PYTHON) -m pip install -r requirements.txt

agent-resetdb:
	@if [ ! -x "$(VENV_PYTHON)" ]; then echo "Run 'make agent-setup' first."; exit 1; fi
	APPNAME_ENV=dev $(VENV_PYTHON) manage.py resetdb

agent-smoke:
	@if [ ! -x "$(VENV_PYTHON)" ]; then echo "Run 'make agent-setup' first."; exit 1; fi
	APPNAME_ENV=test $(VENV_PYTHON) -m pytest -q tests/test_urls.py tests/test_login.py

agent-test:
	@if [ ! -x "$(VENV_PYTHON)" ]; then echo "Run 'make agent-setup' first."; exit 1; fi
	APPNAME_ENV=test $(VENV_PYTHON) -m pytest --cov-report=term-missing --cov=appname $(AGENT_TEST_FILES)
