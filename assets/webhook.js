#!/usr/bin/env node
var simpleParser = require('mailparser').simpleParser;
var request = require('request');

var WEBHOOK_URL = '__URL__'; //NOTE: can include basic auth in url!

function makeRequest(options){
    return new Promise((resolve, reject)=>{
        request(options, function(error, response, body){
            if(error) reject(error)
            else resolve(response)
        })
    })
}

simpleParser(process.stdin)
    .then(mail=>{
        var body = mail;
        body.envelopeRecipient = process.argv[2];
        body.envelopeSender = process.argv[3];
        body.envelopeSize = parseInt(process.argv[4]);
        return makeRequest({
            uri: WEBHOOK_URL,
            method: "POST",
            json: true,
            headers: {"content-type": "application/json"},
            body: JSON.stringify(body),
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
