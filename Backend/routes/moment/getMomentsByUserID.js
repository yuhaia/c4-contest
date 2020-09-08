const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const MomentModel = require('../../models/moment')
const UserModel = require('../../models/users')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path
var verifyToken = require('../auth/verifyToken');
const { User } = require('../../lib/mongo')

router.get('/', function (req, res, next) {
  console.log("request to moment/getMomentsByUserID...")

  const user_id = req.query.user_id
  var skip = 0
  var limit = 100
  if (req.query.skip) {
    skip = req.query.skip * 1
  }
  if (req.query.limit) {
    limit = req.query.limit * 1
  }
  UserModel.getUserByID(ObjectId(user_id)).then(function (user_info) {
    if (user_info) {
      MomentModel.getMomentsByUserID(user_id, skip, limit).then(function (result) {
        // console.log("该user skip=", skip, " limit=", limit, "的moments信息如下：")
        // console.log(result)
        res.json({"success":"true", 'data': result, "user_info": user_info})
      }).catch(next)
    } else {
      res.json({"error": "user not found"})
    }
  })
})

module.exports = router