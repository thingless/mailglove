mailglove
==============
Accept inbound email to a domain and post to a webhook with every new email.

Usage
=====
```
docker run -p 25:25 -e DOMAIN=glove.example.com -e URL=https://requestb.in/1bcv6631 thingless/mailglove
```
* `DOMAIN` the domain you would like to receive email for. Your should add an A or MX record to your DNS
pointing to the server your running the docker container on.

* `URL` is the url to post the parsed email to. The url can contain basic auth credentials. Example:  `https://user:password@requestb.in/1bcv6631`

* The email is parsed to json and posted to the webhook. You can find an [example json body here](https://github.com/thingless/mailglove/blob/master/example_post_body.json).

Acknowledgments
===============
* thanks to https://github.com/catatnight/docker-postfix for initial docker container
* thanks to https://github.com/nodemailer/mailparser for a good email parser 
