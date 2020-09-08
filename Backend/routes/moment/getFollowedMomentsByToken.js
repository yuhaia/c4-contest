const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const MomentModel = require('../../models/moment')
const UserModel = require('../../models/users')
const FollowModel = require('../../models/follow')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path
var verifyToken = require('../auth/verifyToken');

router.get('/', verifyToken, function (req, res, next) {
  console.log("request to moment/getAllMoments...")
  var user_id = req.user_id
  var skip = req.query.skip * 1
  var limit = req.query.limit * 1

  FollowModel.getFollowedByFansID(user_id, 0, Number.MAX_SAFE_INTEGER).then(function (followed_info) {
    // console.log("followed users: ")
    // console.log(followed_info)
    if (followed_info.length == 0) {
      // console.log("还未曾关注任何用户")
      res.json({ "error": "还未曾关注任何用户" })
    } else {
      var followed_id_array = []
      for (var i = 0; i < followed_info.length; ++i) {
        followed_id_array.push(followed_info[i].followed_id)
      }
      MomentModel.getMomentsByFollowedUserIDArray(followed_id_array, skip, limit).then(function (moments_res) {
        // // console.log('用户关注的大咖们发布的动态信息如下：')
        // // console.log(moments_res)


        var moments = moments_res
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
          console.log("moments:")
          console.log(moments)
          res.json({ "success": "true", 'data': moments })
        })
      })
    }
  })
})

module.exports = router