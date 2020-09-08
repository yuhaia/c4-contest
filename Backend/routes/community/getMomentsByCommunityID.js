const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const CommunityModel = require('../../models/community')
const MomentModel = require('../../models/moment')
const UserModel = require('../../models/users')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path

router.get('/', function (req, res, next) {
  console.log("request to community/getMomentsByCommunityID...")

  const community_id = ObjectId(req.query.community_id)
  CommunityModel.getCommunityByID(community_id).then(function (community) {
    //// console.log('社圈信息如下：')
    // console.log(community)
    var moments_id = []
    for (var i = 0; i < community.moments_id.length; ++i) {
      moments_id.push(ObjectId(community.moments_id[i]))
    }
    MomentModel.getMomentByIDArray(moments_id).then(function (moments_result) {
      // console.log('moments result:', result)
      if (!moments_result) {
        // console.log('moments not found')
        res.status = 404
        res.json({ 'error': 'moments not found' })
      } else {
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
      }
    })
  }).catch (next)
})

module.exports = router