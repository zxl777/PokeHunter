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
                "title": "Hunt in : "+req.body.placename,
                "placename":req.body.placename,
                "coord":req.body.coord
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

//获得服务器列表 http://play.itoytoy.com:3000/servers?page=3
app.get('/servers', getServersByPage);

function getServersByPage(req, res)
{
    // 限定按一页20个结果浏览

    var page = req.query.page ? parseInt(req.query.page):0;
    var pageLimit = (req.query.limits)?parseInt(req.query.limits):20;

    //ZSET servers:online 按score排序的

    client.ZREVRANGE('servers:online', page*pageLimit, page*pageLimit+pageLimit-1, function(err,ids)
    {
        var multi = client.multi();

        ids.forEach(function( id )
        {
            multi.hgetall('server:'+id,redis.print); //redis.print 是调试时用来显示redis命令执行结果的
        });

        multi.exec(function (err, replies)
        {
            res.json(replies);
        });
    });
}

app.get('/v1/servers',function (req, res)
{
    // 限定按一页20个结果浏览

    var page = req.query.page ? parseInt(req.query.page):0;
    var pageLimit = (req.query.limits)?parseInt(req.query.limits):20;



    //ZSET servers:online 按score排序的

    client.ZREVRANGE('servers:order_by_voted', page*pageLimit, page*pageLimit+pageLimit-1, function(err,ids)
    {
        var multi = client.multi();

        ids.forEach(function( id )
        {
            multi.hgetall('server:'+id);
        });

        multi.exec(function (err, replies)
        {
            console.log(err);
            res.json(replies);
        });
    });
});


app.get('/v1/server',function (req, res)
{
    var serverid = req.query.serverid;
    client.HGETALL('server:'+serverid,function(err,info)
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


// 投票时，提交的是用户md5，先检查今天是不是已经投票过了。然后检查是不是合法用户。都通过了，才真正vote
app.post('/v1/vote', function(req, res)
{
    var md5 = req.body.qq;
    var serverid= req.body.serverid;

    client.get("md5:"+md5, function(err, reply) {

        if (reply != null)
        {
            client.SISMEMBER('voted:today',md5, function(err, reply) {
                console.log(md5);
                if (reply == 0 || md5 == 'a61ee9b4f3570dc4e81e9ff7823fbc7d')
                {
                    console.log("验证通过，开始投票");

                    var day = new Date(); //获取今天日期
                    var today = (day.getMonth()+1)+"-"+day.getDate();

                    client.multi()
                    .SADD('voted:'+serverid,md5)
                    //.ZINCRBY("servers:order_by_voted",1,serverid)
                    .HINCRBY('server:'+serverid,"voted",1)
                    .HINCRBY('votecount:'+serverid,today,1)
                    .SADD('voted:today',md5)
                    .exec(function (err, replies)
                    {
                        console.log(err);
                        console.log(replies);
                        res.json({"message":"Thanks for your vote!"});
                    });


                }
                else
                    res.json({"message":"You have voted today, please come back tomorrow to vote."});
            });
        }
        else
            res.json({"message":"Thanks for your vote!!"});
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

