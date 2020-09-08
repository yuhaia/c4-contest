const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
var jwt = require('jsonwebtoken');
var bcrypt = require('bcryptjs');
const express = require('express')
const request = require('request')
const router = express.Router()

const https = require('https')
const UserModel = require('../../models/users')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path

router.get('/', function (req, res, next) {
    console.log("request to getUserAuthorizaiton...")
    const js_code = req.query.js_code
    if (js_code) {
        // 微信用户前来获取token
        // appid和secret可以静态存储在后端
        const appid = config.appId
        const secret = config.appSecret

        const js_code = req.query.js_code
        const grant_type = "authorization_code"

        const url = "https://api.weixin.qq.com/sns/jscode2session?appid=" + appid + "&secret=" + secret + "&js_code=" + js_code + "&grant_type=" + grant_type

        request(url, (err, weixin_res, data) => {
            // console.log(typeof (data))
            // console.log("data from weixin:")
            // console.log(data)

            let json_data = JSON.parse(data)
            let openid = json_data.openid
            // console.log("openid by json_data.openid: ")
            // console.log(openid)
            UserModel.getUserByOpenID(openid).then(function (user_res) {
                if (!user_res) {
                    res.status(404).send({ 'error': 'user not found' });
                } else {
                    // console.log("user_res:" + user_res)
                    user_id = user_res._id
                    // 只是进来索要token的
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
        })
    } else {
        // 如果是非微信用户 也需要这个接口
        const name = req.query.name
        const password = req.query.password

        UserModel.getUserByName(name)
            .then(function (user_res) {
                if (!user_res) {                               
                    // console.log('登陆失败，用户名不存在')
                    res.status(404)
                    res.json({ 'error': '用户名不存在' })
                } else if (sha1(password) !== user_res.password) {  
                    // 检查密码是否匹配
                    // console.log('登陆失败，密码错误')
                    res.status(401)
                    res.json({ 'error': '用户名或密码错误' })
                } else {
                    user_id = user_res._id
                    // 只是进来索要token的
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
})

module.exports = router