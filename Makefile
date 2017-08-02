# free-speech/Makefile -- A collection of rules for testing and deploying the project

DJANGO_PROJECT_ROOT=free-speech-django
DOCS_BUILD_PATH=docs-build
DOCS_PATH=docs

LINT_TARGETS=\
	cafe/settings.py\
	cafe/urls.py\
	cafe/wsgi.py\
	app/management/commands/__init__.py\
	app/management/commands/cleantext.py\
	app/management/commands/makedbtrans.py\
	app/management/commands/makemessages.py\
	app/templatetags/localize_url.py\
	app/admin.py\
	app/apps.py\
	app/signals.py\
	app/urls.py\
	app/views.py

EXCLUDED_MODULES=\
	$(DJANGO_PROJECT_ROOT)/app/migrations\
	$(DJANGO_PROJECT_ROOT)/app/test*\
	$(DJANGO_PROJECT_ROOT)/app/urls.py

CLEANTEXT_TARGETS=\
	Comment.message\
	Comment.tag\
	Respondent.location

STATIC_ROOT_CMD=./manage.py shell -c 'from django.conf import settings; print(settings.STATIC_ROOT)'

CREATE_PROD_DB_QUERY=\
	CREATE DATABASE IF NOT EXISTS app CHARACTER SET utf8;\
	GRANT ALL PRIVILEGES ON free-speech.* TO root@localhost;\
	FLUSH PRIVILEGES;

install:
	pip2 install -r requirements.txt
	npm install --only=production

all: deploy lint test

lint: $(LINT_TARGETS:%.py=$(DJANGO_PROJECT_ROOT)/%.py)
	pylint --output-format=colorized --rcfile=.pylintrc $^

test:
	cd $(DJANGO_PROJECT_ROOT) && ./manage.py test

createproddb:
	mysql -e '$(CREATE_PROD_DB_QUERY)' -u root --password="$(shell printenv mysql_pass)"
	cd $(DJANGO_PROJECT_ROOT) && ./manage.py migrate --run-syncdb

deleteproddb:
	mysql -e 'DROP DATABASE free-speech;' -u root --password="$(shell printenv mysql_pass)"

cleandb:
	cd $(DJANGO_PROJECT_ROOT) && ./manage.py clearsessions
	cd $(DJANGO_PROJECT_ROOT) && ./manage.py cleantext $(CLEANTEXT_TARGETS)

compilestatic: install
	cd $(DJANGO_PROJECT_ROOT)/app/static/css && export PATH=$$PATH:$(shell npm bin) && lessc -x main.less main.min.css

disabledebug:
	sed -i -e 's/DEBUG\s*=\s*True/DEBUG = False/g' $(DJANGO_PROJECT_ROOT)/cafe/settings.py

collectstatic: compilestatic
	cd $(DJANGO_PROJECT_ROOT) && ./manage.py collectstatic --no-input

deploy: disabledebug collectstatic compiletrans
	$(eval STATIC_ROOT=$(shell cd $(DJANGO_PROJECT_ROOT) && $(STATIC_ROOT_CMD)))
	cd $(STATIC_ROOT)/css && rm *.less
