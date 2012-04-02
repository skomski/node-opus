var opus   = require('..');
var snappy = require('snappy');
var fs     = require('fs');

var snappyProducer = opus.createProducer({
  queue: 'snappyCompress',
  host: '127.0.0.1',
  port: 6379
});

var counter = 0;

snappyProducer.on('result', function(job) {
  snappy.decompress(job.result, function(err, decompressed) {
    if (err) throw err;
    console.log(++counter);
  });
});

snappyProducer.start();

var payload = fs.readFileSync('/home/skomski/Code/node-snappy/test/test.js')

setInterval(function() {
  snappyProducer.add({ payload: payload }, function(id) {
  });
}, 100);
