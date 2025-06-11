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
postconf -F '*/*/chroot = n'

# Add the myhook hook to the end of master.cf
tee -a /etc/postfix/master.cf <<'EOF'
myhook unix - n n - - pipe
    flags=F user=nobody argv=/opt/webhook.js ${recipient} ${sender} ${size}
EOF

# Enable logging output to stdout with postlog daemon
tee -a /etc/postfix/master.cf <<'EOF'
postlog   unix-dgram n  -       n       -       1       postlogd
EOF

# Make SMTP use myhook
postconf -F 'smtp/inet/command = smtpd -o content_filter=myhook:dummy'

# Disable bounces
postconf -F 'bounce/unix/command = discard'

# Disable local recipient maps so nothing is dropped b/c of non-existent email
postconf 'local_recipient_maps ='

# Enable logging to foreground in postlog
postconf -e 'maillog_file = /dev/stdout'

# Make the webhook.js use the correct URI
sed -i "s/__URL__/${URL//\//\\/}/" /opt/webhook.js

# Make MAX_EMAIL_SIZE. 1MB emails by default
sed -i "s/__MAX_EMAIL_SIZE__/${MAX_EMAIL_SIZE:-1000000}/" /opt/webhook.js

#############
## Enable TLS
#############
#if [[ -n "$(find /etc/postfix/certs -iname *.crt)" && -n "$(find /etc/postfix/certs -iname *.key)" ]]; then
#  # /etc/postfix/main.cf
#  postconf -e smtpd_tls_cert_file=$(find /etc/postfix/certs -iname *.crt)
#  postconf -e smtpd_tls_key_file=$(find /etc/postfix/certs -iname *.key)
#  chmod 400 /etc/postfix/certs/*.*
#  # /etc/postfix/master.cf
#  postconf -M submission/inet="submission   inet   n   -   n   -   -   smtpd"
#  postconf -P "submission/inet/syslog_name=postfix/submission"
#  postconf -P "submission/inet/smtpd_tls_security_level=encrypt"
#  postconf -P "submission/inet/smtpd_sasl_auth_enable=yes"
#  postconf -P "submission/inet/milter_macro_daemon_name=ORIGINATING"
#  postconf -P "submission/inet/smtpd_recipient_restrictions=permit_sasl_authenticated,reject_unauth_destination"
#fi
