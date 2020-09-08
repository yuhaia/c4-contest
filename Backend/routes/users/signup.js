const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const express = require('express')
const router = express.Router()
const request = require('request')
const https = require('https')
const UserModel = require('../../models/users')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const gm = require('gm')
let img_path = config.img_path

router.post('/', function (req, res, next) {

  console.log("request to ../users/signup:")
  console.log("req.fields:")
  // console.log(req.fields)

  var js_code = req.fields.js_code
  // console.log("js_code:" + js_code)
  // 分为微信用户注册和非微信用户注册
  if (js_code) {
    // 微信用户注册
    // appid和secret可以静态存储在后端
    var appid = config.appId
    var secret = config.appSecret
    var grant_type = "authorization_code"

    var name = req.fields.name
    var gender = req.fields.gender
    var avatar = req.fields.avatar
    if (gender == "1") {
      gender = 'm'
    } else if (gender == "0") {
      gender = "f"
    } else {
      gender = 'x'
    }
    var weixin_user = {
      name: name,
      password: "",
      gender: gender,
      bio: "这个人很神秘，什么都没说~",
      avatar: req.fields.avatar,
      openid: ''
    }

    var url = "https://api.weixin.qq.com/sns/jscode2session?appid=" + appid + "&secret=" + secret + "&js_code=" + js_code + "&grant_type=" + grant_type

    request(url, (err, weixin_res, data) => {
      // console.log(typeof (data))
      // console.log("data from weixin:")
      // console.log(data)

      let json_data = JSON.parse(data)
      let openid = json_data.openid
      // console.log("openid by json_data.openid: ")
      // console.log(openid)

      if (!openid) {
        res.json({ 'error': '请求微信auth.code2Session出错' })
      } else {
        weixin_user.openid = openid
        // console.log("openid:" + weixin_user.openid) // 这个openid可以唯一标识一个微信用户

        // console.log("weixin_user:")
        // console.log(weixin_user)
        // 微信用户可能会多次注册（小程序端的需求）
        UserModel.getUserByOpenID(openid).then(function (user_res) {
          // console.log('result of getUserByOpenID:')
          // console.log(user_res)
          if (!user_res) {
            // 数据库里没有微信用户的信息 
            // 这时便需要往数据库里插入微信用户的信息

            UserModel.create(weixin_user)
              .then(function (signup_weixin_user_result) {
                // 此 user 是插入 mongodb 后的值，包含 _id
                weixin_user = signup_weixin_user_result.ops[0]
                user_id = weixin_user._id

                // console.log('新用户注册成功，注册结果如下：')
                // console.log(signup_weixin_user_result)

                // create a token
                // 86400 expires in 24 hours
                // 3600 is 1 hour
                // 60 is 1 minute
                var token = jwt.sign({ id: user_id }, config.auth_secret, {
                  expiresIn: config.token_valid_time
                });

                let return_data = {
                  token: token,
                  user_info: signup_weixin_user_result
                }
                res.json({ 'success': 'true', 'data': return_data })
              })
          } else {
            var user_id = user_res._id
            var token = jwt.sign({ id: user_id }, config.auth_secret, {
              expiresIn: config.token_valid_time
            });

            let return_data = {
              token: token,
              user_info: user_res
            }
            res.json({ 'success': 'true', 'data': return_data })
          }
        })
      }

      if (err) {
        // console.log('data from weixin: err:')
        // console.log(err)
      }
    })

  } else {
    // 非微信用户请求注册
    var name = req.fields.name
    var gender = req.fields.gender
    var bio = req.fields.bio ? req.fields.bio : '这个人很神秘，什么都没说~'
    var professor = req.fields.professor
    var avatar = req.files.avatar.path.split(path.sep).pop()
    var password = req.fields.password
    var repassword = req.fields.repassword

    // 检查用户名是否重复
    UserModel.getUserByName(name)
      .then(function (user) {
        if (user) {
          // console.log('新用户注册失败，信息如下：用户名被占用')
          res.status(401)
          res.json({ 'error': '用户名已被占用' })
        } else {
          // 明文密码加密
          password = sha1(password)

          let thumb_name = "thumb_" + avatar
          gm("/home/yuhai_ven226/projects/c4-contest-app/c4-contest-app/app_backend/public/img/" + avatar)
            .resize(100,120)     //设置压缩后的w/h
            .quality(70)       //设置压缩质量: 0-100
            .strip()
            .autoOrient()
            .write("/home/yuhai_ven226/projects/c4-contest-app/c4-contest-app/app_backend/public/img/" + thumb_name,
              function (err) { console.log("err: " + err); })
          // 待写入数据库的用户信息
          let user = {
            name: name,
            password: password,
            gender: gender,
            bio: bio,
            avatar: img_path + avatar,
            thumb_avatar: img_path + thumb_name,
            professor: professor
          }
          // 用户信息写入数据库
          UserModel.create(user)
            .then(function (result) {
              // 此 user 是插入 mongodb 后的值，包含 _id
              user = result.ops[0]
              // 删除密码这种敏感信息，将用户信息存入 session
              delete user.password
              req.session.user = user

              // console.log("user._id:")
              // console.log(user._id)
              var user_id = user._id
              var token = jwt.sign({ id: user_id }, config.auth_secret, {
                expiresIn: config.token_valid_time
              });

              let return_data = {
                token: token,
                user_info: user
              }
              res.json({ 'success': 'true', 'data': return_data })
              // console.log('新用户注册成功，注册结果如下：')
              // console.log(result)
            })
            .catch(next)
        }
      })
  }


})

module.exports = router
