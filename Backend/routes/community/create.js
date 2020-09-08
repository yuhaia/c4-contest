const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const CommunityModel = require('../../models/community')
const UserModel = require('../../models/users')
const ResourceModel = require('../../models/resource')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path
var verifyToken = require('../auth/verifyToken');
const { User } = require('../../lib/mongo')

router.post('/', verifyToken, function (req, res, next) {
  console.log("request to community/create...")

  console.log("req:")
  console.log(req)

  console.log("req.fields:")
  console.log(req.fields)

  var name = req.fields.name
  var description = req.fields.description
  var resource_name = req.fields.resource_name
  var resource_id = req.fields.resource_id
  var time_start = req.fields.time_start * 1
  var time_end = req.fields.time_end * 1
  var frequency = req.fields.frequency * 1
  var way = req.fields.way
  var ps = req.fields.ps
  var coins_needed = req.fields.coins_needed * 1

  console.log("req.fields.time_start: ")
  console.log(req.fields.time_start)
  
  if (req.fields["time_start"] == 'NaN') {
    time_start = Date.now()
    time_end = 1632295563000
  }

  // const avatar = req.files.avatar.path.split(path.sep).pop()
  const sponsor_id = req.user_id
  const users_id = [sponsor_id]
  const moments_id = []
  const time_create = Date.now()

  UserModel.getUserByID(ObjectId(sponsor_id)).then(function (user_res) {
    if (!user_res) {
      res.json({ "error": "user not found" })
    } else {
      ResourceModel.getResourceByName(resource_name).then(function (resource_res) {
      // })
      // ResourceModel.getResourceByID(ObjectId(resource_id)).then(function (resource_res) {
        var avatar = user_res.avatar
        if (resource_res) {
          avatar = resource_res.picture
          resource_id = String(resource_res._id)
        }
        var community = {
          name: name,
          description: description,
          avatar: avatar,
          resource_name: resource_name,
          resource_id: resource_id,
          time_start: time_start,
          time_end: time_end,
          frequency: frequency,
          way: way,
          ps: ps,
          coins_needed: coins_needed,
          sponsor_id: sponsor_id,
          time_create: time_create,
          users_id: users_id,
          moments_id: moments_id,
          praises: 0
        }
  
        console.log("community to create:")
        console.log(community)
        CommunityModel.create(community).then(function (result) {
          community = result.ops[0]
          //// console.log('社圈创建成功,创建信息如下：')
          //// console.log(community)
  
          UserModel.getUserByID(ObjectId(sponsor_id)).then(function (find_user_res) {
            if (!find_user_res) {
              res.json({ "error": "user not found" })
            } else {
              var coins = find_user_res.coins
              coins = coins - coins_needed
              UserModel.updateCoins(ObjectId(sponsor_id), coins).then(function (update_coins_res) {
                // 更新用户的communities_id字段信息
              UserModel.addCommunity(ObjectId(sponsor_id), String(community._id)).then(function (add_commu_res) {
                UserModel.getUserByID(ObjectId(sponsor_id)).then(function (update_user_result) {
                  community.sponsor_info = update_user_result
                  res.json({ "success": "true", 'data': community })
                }).catch(next)
              }).catch(next)
  
                // 更新resource的communities_id字段
                ResourceModel.addCommunity(ObjectId(resource_id), String(community._id)).then(function (update_resource_res) {
                  //// console.log("update resource's communities_id result: ")
                  //// console.log(update_resource_res)
                }).catch(next)
              })
            }
  
          }).catch(next)
        }).catch(next)
      })
    }

  })
})

module.exports = router