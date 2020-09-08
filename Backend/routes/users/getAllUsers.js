const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
const https = require('https')
const request = require('request')
const UserModel = require('../../models/users')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
var verifyToken = require('../auth/verifyToken');

router.get('/',function (req, res, next) {
  console.log("request to ../users/getAllUser:")
  // verifyToken
  // let user_id = req.user_id
  // // console.log("经过verifyToken后的user_id:", user_id)
  UserModel.getAllUsers()
    .then(function (users) {
      if (!users) {                                    // 检查用户名是否存在
        res.status(404)
        res.json({ 'error': '暂时没有用户' })
      } else {

        // let url = "https://xinqing.today/v1.0/users/getAllUsers"
        // https.get(url, function (xinqing_res) {
        //   // console.log('statusCode:', xinqing_res.statusCode);
        //   // console.log('headers:', xinqing_res.headers);

        //   xinqing_res.on('data', (d) => {
        //     process.stdout.write(d);
        //   });
        // }).on('error', (e) => {
        //   console.error(e);
        // });
        // 测试nodejs后台请求别的服务器数据 用request即可
        // request(url, (err, weixin_res, data)=>{
        //   // console.log("weixin_data:")
        //   // console.log(data)
        // })


        res.json({ "success": "true", 'data': users })
        // console.log("users:")
        // console.log(users)
      }
    })
    .catch(next)
})

module.exports = router