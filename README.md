mailglove
==============
Accept inbound email to a domain and hit a webhook with every new email.

(thanks to https://github.com/catatnight/docker-postfix for initial docker container)

Usage
=====
```
docker run -p 2525:25 -e DOMAIN=glove.example.com -e URL=https://requestb.in/1bcv6631 thingless/mailglove
```
