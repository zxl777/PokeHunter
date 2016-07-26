var request=require('request');

var options = {
    url: 'http://127.0.0.1:8088/job',
    method: 'POST',
    json:true,
    body: {
        "type": "HuntPoint",
        "data":
        {
            "title": "To Hunt : Los Angeles",
            "placename":"Los Angeles",
            "point": "34.0522342 -118.2436849 0.0"
        },
        "options" : {
            "attempts": 5,
            "priority": "high"
        }
    }
};

function callback(error, response, data) {
    if (!error && response.statusCode == 200) {
        console.log('----info------',data);
    }
}

request(options, callback);