const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
const https = require('https')
const request = require('request')
const UserModel = require('../../models/users')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
var verifyToken = require('../auth/verifyToken');

router.get('/', verifyToken,function (req, res, next) {
  console.log("request to ../users/getRecommendedUsers:")
  // verifyToken
  let user_id = req.user_id
  // // console.log("经过verifyToken后的user_id:", user_id)
  UserModel.getAllUsers()
    .then(function (users) {
      if (!users) {                                    // 检查用户名是否存在
        res.status(404)
        res.json({ 'error': '暂时没有用户' })
      } else {
        var recommendedUsers = []
        for (var i =0; i < users.length; ++i) {
            if (String(users[i]._id) != user_id) {
                recommendedUsers.push(users[i])
            }
        }
        res.json({ "success": "true", 'data': recommendedUsers })
      }
    })
    .catch(next)
})

module.exports = router