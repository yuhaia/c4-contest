const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const CommunityModel = require('../../models/community')
const UserModel = require('../../models/users')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path

router.get('/', function (req, res, next) {
  console.log("request to community/getUsersByCommunityID...")

  const community_id = ObjectId(req.query.community_id)
  CommunityModel.getCommunityByID(community_id).then(function (community) {
    //// console.log('社圈信息如下：')
    // console.log(community)
    var users_id = []
    for (var i = 0; i < community.users_id.length; ++i ) {
      users_id.push(ObjectId(community.users_id[i]))
    }
    UserModel.getUsersByIDArray(users_id).then(function (result) {
      // console.log('users result:', result)
      if (!result) {
        // console.log('users not found')
        res.status = 404
        res.json({'error': 'users not found'})
      } else {
        res.json({"success":"true", 'data': result})
      }
    })
  }).catch(next)
})

module.exports = router