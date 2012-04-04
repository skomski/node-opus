var opus   = require('..');

var consumer = opus.createConsumer({
  queue: 'add50',
  host: '127.0.0.1',
  port: 6379
});

var add50 = function(payload, done) {
  var first = parseInt(payload, 10);
  done(first + 50);
}

consumer.setJobHandler(add50);
consumer.start();
