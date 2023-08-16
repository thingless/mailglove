From ubuntu:focal
MAINTAINER Richard Klafter

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

# Install package here for cache
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils supervisor postfix curl rsyslog ca-certificates openssl \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get -y install nodejs \
    && apt-get clean && rm -rf /var/cache/apt/lists

# Add files & install node requirements
ADD assets/install.sh /opt/install.sh
ADD assets/package.json /opt/package.json
ADD assets/webhook.js /opt/webhook.js
RUN cd /opt; npm install; chmod +x /opt/webhook.js

# Run
CMD /opt/install.sh;/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
