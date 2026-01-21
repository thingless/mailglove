#!/bin/bash

#supervisor.conf already exists? do not reinstall!
if [[ -a /etc/supervisor/conf.d/supervisord.conf ]]; then
  exit 0
fi

#supervisor
cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[supervisord]
nodaemon=true
logfile=/dev/null
logfile_maxbytes=0

[program:postfix]
command=postfix start-fg
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true
EOF

############
#  postfix
############
postconf -e myhostname=${DOMAIN}

# Add the myhook hook to the end of master.cf
tee -a /etc/postfix/master.cf <<'EOF'
myhook unix - n n - - pipe
    flags=F user=nobody argv=/opt/webhook.js ${recipient} ${sender} ${size}
EOF

# Enable logging output to stdout with postlog daemon
tee -a /etc/postfix/master.cf <<'EOF'
postlog   unix-dgram n  -       n       -       1       postlogd
EOF

# Enable logging to foreground in postlog
postconf -e 'maillog_file = /dev/stdout'

# Disable bounces
postconf -F 'bounce/unix/command = discard'

# Disable local recipient maps so nothing is dropped b/c of non-existent email
postconf 'local_recipient_maps ='

# Disable the chroot so we can call our script and resolv.conf works
postconf -F '*/*/chroot = n'

# Call the webhook
if ! [ -z "$URL" ]; then
  # Make SMTP use myhook
  postconf -F 'smtp/inet/command = smtpd -o content_filter=myhook:dummy'

  # Make the webhook.js use the correct URI
  sed -i "s/__URL__/${URL//\//\\/}/" /opt/webhook.js

# Forward to the forward domain
elif ! [ -z "$FORWARD_DOMAIN" ]; then
  # Create virtual alias mapping to forward from DOMAIN to FORWARD_DOMAIN
  cat > /etc/postfix/virtual <<EOF
@${DOMAIN} @${FORWARD_DOMAIN}
EOF

  # Generate the virtual alias database
  postmap /etc/postfix/virtual

  # Configure virtual alias domains and maps
  postconf -e "virtual_alias_domains = ${DOMAIN}"
  postconf -e "virtual_alias_maps = hash:/etc/postfix/virtual"
else
  echo "Must set URL or FORWARD_DOMAIN for this tool to do anything useful"
  exit 1
fi
