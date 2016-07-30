var Pokespotter = require('pokespotter')('zhangxiaolong@itoytoy.com', '18879bbb', 'google');

// Pokespotter.get('New York').then(function (pokemon) {
    Pokespotter.get('Central Park, New York').then(function (pokemon) {
        console.log(pokemon);
    });