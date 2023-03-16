FROM python:3.8-slim-bullseye

RUN apt-get update && \
   apt-get install -y --no-install-recommends \
       liblapack-dev libatlas-base-dev && \
   rm -rf /var/lib/apt/lists/*

COPY requirements.txt  /srv/app/
RUN pip install --upgrade pip && \
    pip install -r /srv/app/requirements.txt

ENV TERM=xterm

COPY src /srv/app/src

ENTRYPOINT [ "/srv/app/src/entrypoint.sh", "-v" ]
