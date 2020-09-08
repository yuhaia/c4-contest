const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const FollowModel = require('../../models/follow')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path

router.get('/', function (req, res, next) {
  console.log("request to follow/getAll...")

  FollowModel.getAllFollows().then(function (result) {
    // console.log('所有Follows的信息如下：')
    // console.log(result)
    res.json({"success":"true", 'data': result})
  }).catch(next)
})

module.exports = router