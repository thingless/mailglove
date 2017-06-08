#!/bin/bash

#supervisor.conf already exists? do not reinstall!
if [[ -a /etc/supervisor/conf.d/supervisord.conf ]]; then
  exit 0
fi

#supervisor
cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[supervisord]
nodaemon=true

[program:postfix]
command=/opt/postfix.sh

[program:rsyslog]
command=/usr/sbin/rsyslogd -n -c3
EOF

############
#  postfix
############
cat >> /opt/postfix.sh <<EOF
#!/bin/bash
service postfix start
tail -f /var/log/mail.log
EOF
chmod +x /opt/postfix.sh
postconf -e myhostname=$maildomain
postconf -F '*/*/chroot = n'

# Add the myhook hook to the end of master.cf
tee -a /etc/postfix/master.cf <<'EOF'
myhook unix - n n - - pipe
    flags=F user=nobody argv=/usr/local/bin/mailhook.py ${recipient} ${sender} ${size}
EOF

# Make SMTP use myhook
postconf -F 'smtp/inet/command = smtpd -o content_filter=myhook:dummy'

# Disable bounces
postconf -F 'bounce/unix/command = discard'

# Disable local recipient maps so nothing is dropped b/c of non-existent email
postconf 'local_recipient_maps ='

# Create myhook script
tee /usr/local/bin/mailhook.py <<'EOF'
#!/usr/bin/python2
# /usr/local/bin/handle_email.py ${recipient} ${sender} ${size}
try:
    import json
    import requests
    import sys
    import time

    from mailparser import MailParser

    txt = sys.stdin.read()

    parser = MailParser()
    parser.parse_from_string(txt)

    # auth = (__BASIC_USERNAME__, __BASIC_PASSWORD__)
    auth = None

    # Parse the email
    out = {
        'recipient': sys.argv[1],
        'sender': sys.argv[2],
        'size': sys.argv[3],
        'timestamp': int(time.time()),

        'body': parser.body,
        'headers': None
    }

#headers
#subject
#from_email
#from_name
#body
#attachments
#attachments[].data
#attachments[].cid

    requests.post(__URL__, auth=auth, json=out, timeout=91)
except Exception as e:
    print("Error :(   %r" % e)
EOF

# Replace the URL in the myhook script
sed -i "s/__URL__/$webhookurl/" /usr/local/bin/handle_email.py
chmod +x /usr/local/bin/handle_email.py

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
