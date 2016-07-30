/*
    2016-6-29 添加VOTE 排名功能
 */
var express = require('express');    // https://github.com/expressjs/express
var redis = require('redis');        // https://github.com/NodeRedis/node_redis
var morgan = require('morgan');      //https://github.com/expressjs/morgan 后台log显示http request
var bodyParser = require('body-parser'); //https://github.com/expressjs/body-parser 上传文件
var md5 = require('md5'); //https://github.com/pvorb/node-md5
//var multer = require('multer');      //https://github.com/expressjs/multer
var request=require('request');

var app = express();
app.use(morgan('dev'));
app.use(bodyParser.json()); // for parsing application/json
app.use(bodyParser.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded

var client = redis.createClient();



// 提交新坐标给机器人
app.post('/v1/addscanjob', function(req, res)
{
    var options = {
        url: 'http://127.0.0.1:8088/job',
        method: 'POST',
        json:true,
        body: {
            "type": "HuntPoint",
            "data":
            {
                "title": "Hunt Scan",
                "longitude":req.body.longitude,
                "latitude":req.body.latitude,
            },
            "options" : {
                "attempts": 3,
                "priority": "high"
            }
        }
    };


    request(options, function callback(error, response, data)
    {
        if (!error && response.statusCode == 200)
        {
            console.log(data);
            res.json(data);
        }
    });
});


app.get('/v1/pokehub',function (req, res)
{
    var coord = req.query.coord;
    client.HVALS('PokeHub:'+coord,function(err,info)
    {
        // console.log(err);
        var json=[];

        for (var line of info)
        {
            json.push(JSON.parse(line));
        }

        res.json(json);
    });
});


// 测试url:
//      http://127.0.0.1:8080/v1/pokes?longitude=-118.23&latitude=34.048&m=1000
//      redis> GEORADIUS PokesGEO -118.24 34.04 1000 m  WITHCOORD
app.get('/v1/pokes',function (req, res)
{
    var coord = req.query.coord;
    //redis> GEORADIUS PokesGEO -118.24 34.04 3000 m  WITHCOORD
    client.GEORADIUS(
        'PokesGEO',
        req.query.longitude,//-118.24,
        req.query.latitude,//34.04,
        req.query.m,//1000,
        'm',
    'WITHCOORD',
    function(err,info)
    {
        console.log(err);
        res.json(info);
    });
});





// app启动时，提交用户id给服务器。服务器保存用户id和md5，有效期10分钟。
app.post('/v1/checkin', function(req, res)
{
    console.log(req.body.userid);

    var userid = req.body.userid;

    //client.SET('online:user:'+userid,function (err, obj)
    client.SET('md5:'+md5(userid),'online:userid:'+userid,'EX',10000,function (err, obj)
    {
        res.json({"message":obj});
    });
});


client.on("error", function (err) {
    console.log("REDIS Error " + err);
});


setInterval(function() {
    var myDate = new Date(new Date().getTime()+(1*24*60*60*1000));
    myDate.setHours(0,0,0,0);
    console.log(myDate);

    var expire = myDate.getTime()/1000; //设置第二天的0点过期
    client.EXPIREAT('voted:today',expire);
}, 1000*60*60*24);

app.listen(8080);
console.log('Express started on port 8080');

