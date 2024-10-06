# HOST=localhost
# PORT=8000
PRODUCTION=false

.PHONY: start list build push update

start:
	HOST=0.0.0.0 PORT=8000 poetry run ./entrypoint.sh --nosetup
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
build:
	docker-compose build udemy
push: build
	docker-compose push udemy
update:
	poetry export -o requirements.txt
	SECRET_KEY=secret poetry run ./manage.py collectstatic --noinput
	SECRET_KEY=secret poetry run ./manage.py makemigrations
.env:
	echo HOST=localhost > .env
	echo PORT=8000 >> .env
	echo PRODUCTION=false >> .env
	echo NOSETUP=true >> .env
	echo SECRET=$$(date +%s | sha256sum | base64 | head -c 32 && echo) >> .env
