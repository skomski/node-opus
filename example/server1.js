var opus   = require('..');
var fs     = require('fs');

var snappyProducer = opus.createProducer({
  queue: 'add50',
  host: '127.0.0.1',
  port: 6379
});

var counter = 0;

snappyProducer.on('result', function(id, result) {
  console.log(+result)
  if (parseInt(result, 10) !== 200) throw new Error(result);
});

snappyProducer.start();

setInterval(function() {
  snappyProducer.add({ payload: 150 }, function(id) {
  });
}, 100);
