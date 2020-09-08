const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const MomentModel = require('../../models/moment')
const ResourceModel = require('../../models/resource')
const UserModel = require('../../models/users')
const CommunityModel = require('../../models/community')

const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path
var verifyToken = require('../auth/verifyToken');

router.get('/', function (req, res, next) {
  console.log("request to moment/getMomentsByCommunityID...")

  const community_id = req.query.community_id
  // console.log("resource_id:", resource_id)
  var skip = 0
  var limit = 100
  if (req.query.skip) {
    skip = req.query.skip * 1
  }
  if (req.query.limit) {
    limit = req.query.limit * 1
  }

  CommunityModel.getCommunityByID(ObjectId(community_id)).then(function (commu_res) {
    var moments_id = commu_res.moments_id
    if (moments_id.length == 0) {
      res.json({ "success": "true", "data": [] })
    }
    MomentModel.getMomentByIDArray(moments_id).then(function (moments_result) {

      var moments = moments_result
      // console.log('所有moments的信息如下：')
      // console.log(moments)
      var user_ids = []
      for (var i = 0; i < moments.length; ++i) {
        user_ids.push(moments[i]["user_id"])
      }
      console.log("user_ids:")
      console.log(user_ids)
      UserModel.getUsersByIDArray(user_ids).then(function (user_res) {
        console.log("user_info:")
        console.log(user_res) // 每个用户只出现一次。。
        for (var i = 0; i < moments.length; ++i) {
          for (var j = 0; j < user_res.length; ++j) {
            if (moments[i]["user_id"] == String(user_res[j]["_id"])) {
              moments[i].user_info = user_res[j]
            }
          }
        }
        res.json({ "success": "true", 'data': moments })
      })
    })
  })
})

module.exports = router