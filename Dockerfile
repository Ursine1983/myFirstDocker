# Image the Dockerfile is based on
FROM debian

ENV DEBIAN_FRONTEND noninteractive

# ready package manger
RUN apt-get update && apt-get -y upgrade

# install packages
RUN apt-get install --no-install-recommends -y apt-utils nano git curl sass wget cron node.js sendmail apache2 php
RUN apt-get install --no-install-recommends -y npm

# quality of life/preference settings
RUN echo 'alias ll="ls -la"; alias ".."="cd .."' >> /root/.bashrc
RUN echo 'set default-terminal "screen-256color"' >> /root/.bashrc

RUN git config --global core.editor "nano"

# expose required port
EXPOSE 80/tcp

# create directory to map the local volume to
RUN mkdir /devVol

# edit apache config to set the apache root to the mapped volume
RUN sed -ri 's!/var/www/html!/devVol!g' /etc/apache2/sites-available/*.conf
RUN sed -ri 's!/var/www/!/devVol!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# import and run script that keeps the webserver running
ADD bootstrap.sh /bootstrap.sh
RUN chmod +x /bootstrap.sh

CMD ["/bootstrap.sh"]

ENV DEBIAN_FRONTEND teletype