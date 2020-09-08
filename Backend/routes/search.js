const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const MomentModel = require('../models/moment')
const UserModel = require('../models/users')
const CommunityModel = require('../models/community')
const ResourceModel = require('../models/resource')
const checkNotLogin = require('../middlewares/check').checkNotLogin
let img_path = config.img_path
var verifyToken = require('./auth/verifyToken');
const community = require('../models/community')

router.get('/', verifyToken, function (req, res, next) {
  console.log("request to search...")
  var user_id = req.user_id
  var content = req.query.content
  var reg = new RegExp(content, 'i')
  var data = {}
  UserModel.search(reg).then(function (user_res) {
    // // console.log("search user res:")
    // // console.log(user_res)
      data.users = user_res
      MomentModel.search(reg).then(function (moment_res) {
        data.moments = moment_res
        CommunityModel.search(reg).then(function (community_res) {
          data.communities = community_res
          ResourceModel.search(reg).then(function (resource_res) {
            data.resources = resource_res
            res.json({ "success": "true", 'data': data })
          })
        })
      })
  })
})

module.exports = router