FROM python:3.10-alpine
# FROM alpine
ENV SECRET_KEY=whatever
# ARG timestamp
# ARG commit
# LABEL build.timestamp=timestamp
# LABEL build.commit=commit

# Labels
LABEL maintainer="marc.partensky@gmail.com"
LABEL image="https://hub.docker.com/r/marcpartensky/django-udemy-clone"
LABEL source="https://github.com/marcpartensky/django-udemy-clone"
LABEL website="https://marcpartensky.com"

# Install curl and stuff for pillow
RUN apk update
RUN apk add --update --virtual .tmp libffi-dev build-base linux-headers
RUN apk add python3 curl jpeg-dev zlib-dev py3-pip nodejs
RUN apk add shadow

# Setup home user website
RUN useradd -m website
USER website

# Copy useful files
WORKDIR /home/website
# COPY --chown=website --from=builder /opt/website/requirements.txt ./
COPY --chown=website requirements.txt ./
COPY --chown=website manage.py ./
# COPY LICENSE ./

# No .pyo and easier debugging
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install dependencies
# RUN pip install -U pip
RUN pip install -r requirements.txt

COPY --chown=website . .
RUN echo "DEBUG=True" > .env
RUN ./manage.py makemigrations
RUN ./manage.py collectstatic --noinput

USER root
RUN apk del .tmp
USER website

# Setup env vars for entrypoint.sh
ENV PORT 80
ENV HOST 0.0.0.0
ENV PATH="${PATH}:/home/website/.local/bin"
ENV PRODUCTION false
ENV NOSETUP true
EXPOSE 80

# Check health
HEALTHCHECK --interval=30s \
            --timeout=10s \
            --start-period=1m \
            --retries=3 \
             CMD curl -sSf http://localhost:$PORT/admin || exit 1

WORKDIR /home/website
ENTRYPOINT ["./entrypoint.sh"]
# ENTRYPOINT ["daphne", "-e", "ssl:443:privateKey=$KEY:certKey=$CERT", "django_project.asgi:application"]
