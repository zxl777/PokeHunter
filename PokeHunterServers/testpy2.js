/**
 * Created by sky on 16/7/25.
 */

// var obj1 = require('./pyscan/test.json');
// console.log("json1=",obj1);

var python = require('child_process').spawn(
    'python',
    // second argument is array of parameters, e.g.:
    ["./pyscan/spiral_poi_search.py"
        ,'-a','google','-u','zhangxiaolong@itoytoy.com','-p','18879bbb','-l','"Los Angeles"']
);
var output = "";
python.stdout.on('data', function(data)
{
    output += data
});
python.on('close', function(code)
{
    console.log("code=",code);

    var obj = JSON.parse(output);

    console.log("json=",obj);

});