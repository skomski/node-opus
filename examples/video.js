var queue = require('..');

var videoQueue = queue('video', {
  redisHost: '127.0.0.1',
  redisPort: '6379',
  redisMaxClients: 10
});

videoQueue.enqueue({
  data: {
    'ddd': 'dd'
  },
  priority: 1
}, function(err, job) {
  if (err) throw err;

  job.on('result', function (result) {
    console.log(result);
  });
});

videoQueue.process({ priority: 1 }, function(err, job, done) {
  if (err) throw err;
  done(null, {
    status: 200
  });
});
