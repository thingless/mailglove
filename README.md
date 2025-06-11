[![circleci status](https://circleci.com/gh/thingless/mailglove.svg?style=shield)](https://hub.docker.com/r/thingless/mailglove/)

mailglove
==============
Accept inbound email on your domain and post it to an HTTP webhook.

Usage
=====
```
docker run -p 25:25 -e DOMAIN=glove.example.com -e URL=https://requestb.in/1bcv6631 thingless/mailglove
```
* `DOMAIN` is the domain you would like to receive email for. Your should add an A or MX record to your DNS
pointing to the server you're running the docker container on.

* `URL` is the url to post the parsed email to. The url can contain basic auth credentials. Example:  `https://user:password@requestb.in/1bcv6631`

* `__MAX_EMAIL_SIZE__` Allows you to modify the maximum size of an email. The default value is 1000000 for a 1MB email.

* The email is parsed to JSON and posted to the webhook. You can find an [example JSON body here](https://github.com/thingless/mailglove/blob/master/example_post_body.json).

Acknowledgments
===============
* thanks to https://github.com/catatnight/docker-postfix for initial docker container
* thanks to https://github.com/nodemailer/mailparser for a good email parser
