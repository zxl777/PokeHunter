// python spiral_poi_search.py -a google -u zhangxiaolong@itoytoy.com -p 18879bbb -l "Los Angeles"

var PythonShell = require('python-shell');

var options = {
    mode: 'text',
    pythonPath: '/usr/local/bin/python',
    pythonOptions: ['-u'],
    scriptPath: './pyscan',
    args: ['-a','google','-u','zhangxiaolong@itoytoy.com','-p','18879bbb','-l','"Los Angeles"']
};


PythonShell.run('spiral_poi_search.py', options, function (err, results)
{
    if (err) throw err;
    console.log(results);
});
