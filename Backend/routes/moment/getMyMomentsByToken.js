const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const MomentModel = require('../../models/moment')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path
var verifyToken = require('../auth/verifyToken');

router.get('/', verifyToken, function (req, res, next) {
  console.log("request to moment/getMyMomentsByToken...")

  const user_id = req.user_id
  var skip = 0
  var limit = 100
  if (req.query.skip) {
    skip = req.query.skip * 1
  }
  if (req.query.limit) {
    limit = req.query.limit * 1
  }
  MomentModel.getMomentsByUserID(user_id, skip, limit).then(function (result) {
    // console.log("该user skip=", skip, " limit=", limit, "的moments信息如下：")
    // console.log(result)
    res.json({"success":"true", 'data': result})
  }).catch(next)
})

module.exports = router