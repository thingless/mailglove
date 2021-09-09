FROM node:16
LABEL "authors"="Richard Klafter,raaowx"
LABEL "version"="1.1.0"

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

# Update
RUN apt-get update

# Start editing
# Install package here for cache
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y  supervisor postfix curl rsyslog

# Add files & install node requirements
ADD assets/install.sh /opt/install.sh
ADD assets/package.json /opt/package.json
ADD assets/webhook.js /opt/webhook.js
RUN cd /opt; npm install; chmod +x /opt/webhook.js

# Run
CMD /opt/install.sh;/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
