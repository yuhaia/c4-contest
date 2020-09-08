const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const UserModel = require('../../models/users')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
var jwt = require('jsonwebtoken');
const config = require('config-lite')(__dirname)
var verifyToken = require('../auth/verifyToken');

// 通过header中的token获取用户信息
router.get('/', verifyToken, function (req, res, next) {
  console.log("request to ../users/getUser:")
  // //// console.log(req)
  const user_id = req.user_id
  // console.log("user_id:" + user_id)
  UserModel.getUserByID(user_id).then(function (user) {
    if (!user) {
      // console.log("登陆失败，不存在该token对应的user")
      res.status(404).send({ 'error': 'user not found' });
    } else {
      if (user.password) {
        delete user.password
      }
      res.json({ 'success': 'true', 'data': user })
    }
  })

})

module.exports = router