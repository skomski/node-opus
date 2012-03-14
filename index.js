var Queue     = require('./lib/Queue')
var RedisPool = require('./lib/redis/Pool')

module.exports = function(name, options) {

  options.redisPool = options.redisPool || new RedisPool({
    host       : options.redisHost,
    port       : options.redisPort,
    maxClients : options.redisMaxClients
  });

  var queue = new Queue(name, options);
  return queue;
}
