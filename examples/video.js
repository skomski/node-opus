var Queue = require('..');

var videoQueue = new Queue('video', {
  host: '127.0.0.1',
  port: 6379
});

videoQueue.enqueue({
  'ddd': 'dd'
}, function(err, job) {
  if (err) throw err;

  job.on('result', function (result) {
    console.log(result);
  });
});

videoQueue.process(function(err, job, done) {
  if (err) throw err;

  done(null, {
    status: 200
  });
});
