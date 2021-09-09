# mailglove

[![circleci status](https://circleci.com/gh/thingless/mailglove.svg?style=shield)](https://hub.docker.com/r/thingless/mailglove/)

Accept inbound email on your domain and post it to an HTTP webhook.

## Usage

```shell
docker run -p 25:25 -e DOMAIN=glove.example.com -e URL=https://requestb.in/1bcv6631 thingless/mailglove
```

* `DOMAIN` is the domain you would like to receive email for. Your should add an A or MX record to your DNS
pointing to the server you're running the docker container on.

* `URL` is the url to post the parsed email to. The url can contain basic auth credentials. Example:  `https://user:password@requestb.in/1bcv6631`

* The email is parsed to JSON and posted to the webhook. You can find an [example JSON body here](./example_post_body.json).

### Advanced examples

```shell
docker run -p 25:25 -e DOMAIN=glove.example.com -e smtp_user=user:password -e URL=https://requestb.in/1bcv6631 thingless/mailglove
```

* `smtp_user` is an environment variable that set an specific user/password combination in the mail server. Useful to being able to send mail with an internal user instead of using a third party mail service.

## Acknowledgments

* thanks to [docker-postfix](https://github.com/catatnight/docker-postfix) for initial docker container
* thanks to [mailparser](https://github.com/nodemailer/mailparser) for a good email parser

## License

This project is licensed under [MIT license](./LICENSE).
