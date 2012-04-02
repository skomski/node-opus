var opus   = require('..');
var snappy = require('snappy');

var snappyConsumer = opus.createConsumer({
  queue: 'snappyCompress',
  host: '127.0.0.1',
  port: 6379
});

var compressPath = function(payload, done) {
  snappy.compress(new Buffer(payload), function(err, compressed) {
    if (err) return done(err);
    done(compressed);
  });
}

snappyConsumer.setJobHandler(compressPath);
snappyConsumer.start();
