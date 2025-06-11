#!/usr/bin/env node
var simpleParser = require('mailparser').simpleParser;
var request = require('request');

var WEBHOOK_URL = '__URL__'; //NOTE: can include basic auth in url!
var MAX_SIZE = parseInt(__MAX_EMAIL_SIZE__);

function makeRequest(options){
    return new Promise((resolve, reject)=>{
        request(options, function(error, response, body){
            if(error) reject(error)
            else resolve(response)
        })
    })
}

function mapToObject(map) {
    var out = Object.create(null)
    map.forEach((value, key) => {
        if (value instanceof Map) {
            out[key] = map_to_object(value)
        }
        else {
            out[key] = value
        }
    })
    return out
}

var envelopeSize = parseInt(process.argv[4]);
if (envelopeSize <= MAX_SIZE) {
    simpleParser(process.stdin)
        .then(mail=>{
            var body = mail;
            body.envelopeRecipient = process.argv[2];
            body.envelopeSender = process.argv[3];
            body.envelopeSize = envelopeSize;
            body.headers = mapToObject(mail.headers);
            return makeRequest({
                uri: WEBHOOK_URL,
                method: "POST",
                json: true,
                headers: {"content-type": "application/json"},
                body: body,
            })
            .then((response)=>{
                if(response.statusCode !== 200)
                    throw "received non 200 http status code from "+WEBHOOK_URL;
                return response;
            })
        })
        .catch(err=>{
            console.error(err);
        })
}
else {
    console.log("Email is too large: size=" + envelopeSize);
}
