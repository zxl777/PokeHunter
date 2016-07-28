var kue     = require( 'kue' );         // https://github.com/Automattic/kue
var express = require( 'express' );     // https://github.com/expressjs/express
var redis = require('redis');           // https://github.com/NodeRedis/node_redis

var client = redis.createClient();

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


//自动测试队列里的任务
jobs.process( 'HuntPoint', 1, function ( job, done ) {
    // var host = job.data.server.split(':');
    // var id = job.data.server;


    var python = require('child_process').spawn(
        'python',
        // second argument is array of parameters, e.g.:
        // ["./pyscan/spiral_poi_search.py"
            ["./pyscan/huntpoke-quicktest.py"
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
        // 任务完成,把pokemon数据写到redis

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


function writePokeJson(coordkey,json1)
{
    var fs = require('fs');
    var json = JSON.parse(fs.readFileSync('./pyscan/test.json', 'utf8'));

    // console.log(json["pokemons"]['80c2c645d7d-41']);
    var multi = client.multi();

    var i=0;



    for (var key in json.pokemons)
    {
        // console.log('poke=',json.pokemons[key]);
        var poke = json.pokemons[key];

        multi.HSET(
            coordkey,
            i++,
            JSON.stringify({'livetime':poke.last_modified_timestamp_ms + poke.time_till_hidden_ms,
            'pokeid':poke.pokemon_data.pokemon_id,
            'longitude':poke.longitude,
            'latitude':poke.latitude})
        );

        multi.GEOADD(
            'PokesGEO',
            poke.longitude,
            poke.latitude,
            poke.pokemon_data.pokemon_id+':'+(poke.last_modified_timestamp_ms + poke.time_till_hidden_ms)+':'+(i++)
        );
    }

    multi.exec(function (err, replies)
    {

    });

    //写入hash
}

// start the UI

writePokeJson("PokeHub:34.0522342,-118.2436849",'');
kue.app.listen( 8088 );
console.log( 'Kue任务面板 on port 8088' );



