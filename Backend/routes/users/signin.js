const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
const config = require('config-lite')(__dirname)
var jwt = require('jsonwebtoken');
const UserModel = require('../../models/users')
const checkNotLogin = require('../../middlewares/check').checkNotLogin

// 本来加上了中间件 checkNotLogin
router.post('/', function (req, res, next) {

  console.log("request to ../users/signin:")
  // 微信用户登陆（小程序端不需要了 小程序去getUserAuth...接口）
  const js_code = req.fields.js_code
  if (js_code) {
    var token = req.headers['token'];
    if (!token) return res.status(401).send({ 'error': 'No token provided' });

    jwt.verify(token, config.auth_secret, function (err, decoded) {
      if (err) return res.status(401).send({ 'error': 'Failed to authenticate token.' });

      // res.status(200).send(decoded);
      let user_id = decoded.id
      UserModel.getUserByID(user_id).then(function (user) {
        if (!user) {
          // console.log("登陆失败，不存在该openid的user")
          res.status(404).send({ 'error': 'user not found' });
        } else {
          res.json({ 'success': 'true' })
        }
      })
    });
  }
  // 非微信用户登陆
  const name = req.fields.name
  const password = req.fields.password

  UserModel.getUserByName(name)
    .then(function (user) {
      if (!user) {                                    // 检查用户名是否存在
        // console.log('登陆失败，用户名不存在')
        res.status(404)
        res.json({ 'error': '用户名不存在' })
      } else if (sha1(password) !== user.password) {  // 检查密码是否匹配
        // console.log('登陆失败，密码错误')
        res.status(401)
        res.json({ 'error': '用户名或密码错误' })
      } else {

        // // 测试一下 user_id为string时 能否访问数据库取出user
        // // console.log("user_id: ", user._id)
        // // console.log(typeof (user._id)) // $: object
        // // console.log(typeof (user.name))// $: string
        // UserModel.getUserByID(user._id).then(function (user_res) {
        //   // console.log("user_res by user._id")
        //   // console.log(user_res)
        // })

        // // by string 也是可以的
        // // console.log(typeof (String(user._id)))
        // UserModel.getUserByID(String(user._id)).then(function (user_res) {
        //   // console.log("user_res by string(user._id)")
        //   // console.log(user_res)
        // })

        // 用户信息写入 session
        delete user.password
        req.session.user = user
        // console.log("登陆成功")

        user_id = user._id
        // 只是进来索要token的
        var token = jwt.sign({ id: user_id }, config.auth_secret, {
          expiresIn: config.token_valid_time
        });
        let return_data = {
          token: token,
          user_info: user
        }
        res.json({ "success": "true", 'data': return_data })
        // console.log("user sign in successfully")
        // console.log("heiheihei")
      }
    })
    .catch(next)
})

module.exports = router
