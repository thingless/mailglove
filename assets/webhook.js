var simpleParser = require('mailparser').simpleParser;
var WEBHOOK_URL = process.env.WEBHOOK_URL; //NOTE: can include basic auth in url!
var request = require('request');

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
        return makeRequest({
            url:WEBHOOK_URL,
            method: "POST",
            json: true,
            headers: {"content-type": "application/json"},
            body: JSON.stringify(mail),
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