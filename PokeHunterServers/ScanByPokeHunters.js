var kue     = require( 'kue' );         // https://github.com/Automattic/kue
var express = require( 'express' );     // https://github.com/expressjs/express
var redis = require('redis');           // https://github.com/NodeRedis/node_redis

var client = redis.createClient();
var startTime=(new Date()).getTime();
var DoCheck=true;


var jobs = kue.createQueue({
    prefix: 'q',
    redis: {
        port: 6379,
        host: '127.0.0.1',
        auth: '',
        db: 5,
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
            jobs.create( 'HuntPoint',
                {
                title: 'To Hunt ' + 'Los Angeles' , //任务栏的标题
                placename:'Los Angeles',            //传送给任务处理程序的地名
                point: line                         //传送给任务处理程序的坐标
                } ).priority('normal').save();
        });
    });
}


//jobs.create 用来添加任务
//这个是kue的任务处理器process,会自动处理队列里的任务。


//自动测试队列里的任务
jobs.process( 'HuntPoint', 1, function ( job, done ) {
    // var host = job.data.server.split(':');
    // var id = job.data.server;

    var python = require('child_process').spawn(
        'python',
        // second argument is array of parameters, e.g.:
        // ["./pyscan/spiral_poi_search.py"
            ["./pyscan/huntpoke.py"
            , '-a', 'google', '-u', 'zhangxiaolong@itoytoy.com', '-p', '18879bbb', '-l', '"Los Angeles"']
    );
    var output = "";
    python.stdout.on('data', function (data) {
        output += data
    });

    python.stderr.on('data', (data) =>
    {
        console.log(`stderr: ${data}`);
});


    python.on('close', (code) =>
    {
        console.log(`exit code=${code}`);

    if (code == 0) {
        console.log(`res=${output}`);
        var obj = JSON.parse(output);
        console.log("json=", obj);
        job.log("json=", obj);
        done();
    }
    else
    {
        job.log("error=", output);
        done(new Error('error'));
    }


    });
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



