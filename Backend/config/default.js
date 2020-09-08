module.exports = {
  port: 80,
  session: {
    secret: 'c4-contest-app',
    key: 'c4-contest-app',
    maxAge: 2592000000
  },

  auth_secret: 'yuhaia',
  token_valid_time: 604800,  // token的有效期 60为一分钟 这里为2h
  appId: 'wxe550a57c54a57185',
  appSecret: '8ebd58009b48831dad70949f1e25e1de',
  mongodb: 'mongodb://localhost:27017/c4-contest-app',
  version: '/v1.0',
  img_path: 'https://xinqing.mysspku.com/img/'
}
