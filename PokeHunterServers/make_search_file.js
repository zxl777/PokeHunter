/**
 * Created by sky on 16/7/5.
 * /usr/share/nginx/html/realtime_search.html
 */
var redis = require('redis');        // https://github.com/NodeRedis/node_redis
var client = redis.createClient();
fs = require('fs');



function make_search_file()
{

    fs.readFile('./search_template.html', 'utf8', function (err,data) {
        if (err) {
            return console.log(err);
        }
        //console.log(data);

        client.ZREVRANGE('servers:order_by_voted', 0, -1, function(err,ids)
        {
            var multi = client.multi();

            ids.forEach(function( id )
            {
                multi.hgetall('server:'+id);
            });

            multi.exec(function (err, replies)
            {
                console.log('error='+err);
                //console.log(replies);

                replies.forEach(function(server)
                {
                    data = data.replace('<!--%repeat%-->','<li><a href="mineserver:%serverid%">%server_title%</a></li>\n<!--%repeat%-->');
                    data = data.replace('%serverid%',server.id);
                    data = data.replace('%server_title%',server.title.replace(/\n/g,''));
                });

                //console.log(data);

                fs.writeFile('./realtime_search.html', data, function (err) {
                    if (err) return console.log(err);
                    console.log('已写入./realtime_search.html');
                });


                fs.stat('/usr/share/nginx/html/', function(err, stat)
                {
                    if(err == null && stat.isDirectory())
                    {
                        fs.writeFile('/usr/share/nginx/html/realtime_search.html', data, function (err) {
                            if (err) return console.log(err);
                            console.log('已写入nginx文件/usr/share/nginx/html/realtime_search.html');
                        });
                    }
                });


            });
        });


    });
}


exports.make_searchfile_every30mins = function make_searchfile_every30mins()
{
    setInterval(function ()
    {
        make_search_file();
    }, 1000 * 60 * 30);
    //}, 1000 * 10);
}

//make_search_file();
