var kue     = require( 'kue' );         // https://github.com/Automattic/kue
var express = require( 'express' );     // https://github.com/expressjs/express
var redis = require('redis');           // https://github.com/NodeRedis/node_redis
var mcpeping = require('mcpe-ping');

var client = redis.createClient();
var startTime=(new Date()).getTime();
var DoCheck=true;


var jobs = kue.createQueue({
    prefix: 'q',
    redis: {
        port: 6379,
        host: '127.0.0.1',
        auth: '',
        db: 8,
        options: {
            // see https://github.com/mranney/node_redis#rediscreateclient
        }
    }
});


// 将队列复位，清空redis内存
function Reset()
{
    kue.Job.range(0, -1, 'asc', function( err, jobs ) {
        jobs.forEach( function( job ) {
            job.remove( function(){
                //console.log( 'removed ', job.id );
            });
        });
    });
}


//将服务器库存导入，待检测
function importServersQueue()
{
    // SET servers:queue
    client.smembers('servers:queue', function (err, values)
    {
        values.forEach(function(line)
        {
            //console.log( line );
            jobs.create( 'Ping Server',
                {
                title: 'Ping ' + line ,
                server: line
                } ).priority('normal').save();
        });
    });
}


//jobs.create 用来添加任务
//这个是kue的任务处理器process,会自动处理队列里的任务。


//自动测试队列里的任务
jobs.process( 'Ping Server', 18, function ( job, done )
{
    var host = job.data.server.split(':');
    var id = job.data.server;


    mcpeping(host[0], Number(host[1]), function(err, res)
    {
        if (err) //服务器下线
        {
            client.ZREM('servers:order_by_voted',id);
            done(new Error(err.description));
        }
        else //服务器在线，ping到了
        {
            //http://redis.io/commands/hmset 设置一个Hash Member，一个服务器的完整信息
            var title = res.cleanName.trim();
            title = title.replace(/\n/g,'');

            client.multi()
                .HMSET( // 先按ping到的服务器数据，更新server信息。
                    'server:'+id,
                    'id',id,
                    'host',host[0],
                    'port',Number(host[1]),
                    'title',title,
                    //'title',res.cleanName,
                    'version',res.version,
                    'currentPlayers',res.currentPlayers,
                    'maxPlayers',res.maxPlayers)
                .HGET('server:'+id,'voted')
                .exec(function (err, replies)
                {
                    if (Number(res.currentPlayers)>1)
                        client.ZADD('servers:order_by_voted',Number(replies[1]),id);
                    else
                        client.ZADD('servers:order_by_voted',0,id);
                        // client.ZREM('servers:order_by_voted',id);
                });

            //Bug：servers:queue 如果删除了一个服务器，servers:online始终没有删掉。因为机器人只知道添加和更新。
            done();
        }
    }, 3000);
});



// 定时检查任务是否完成
function CheckAllJobsCompleted()
{
    if (!DoCheck)
        return;
    jobs.inactiveCount(function( err, total )
    { // others are activeCount, completeCount, failedCount, delayedCount
        if( total == 0 )
        {
            var AllSecond =((new Date()).getTime()-startTime)/1000;
            console.log( '已无库存，计划下一个任务。用时(秒)：'+AllSecond );
            DoCheck = false;

            setTimeout(function()
            {
                console.log( '计划时间到，添加一批新任务' );
                Reset();
                importServersQueue();
                DoCheck = true;
            //}, 5*1000);
            }, 5*60*1000);
        }

        console.log(total);
    });
}


// start the UI


Reset();
importServersQueue();
setInterval(CheckAllJobsCompleted, 5*1000);

require('./make_search_file').make_searchfile_every30mins();

kue.app.listen( 8032 );
console.log( 'Kue任务面板 on port 8032' );



