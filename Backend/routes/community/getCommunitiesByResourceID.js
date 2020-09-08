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

router.get('/', function (req, res, next) {
  console.log("request to community/getCommunitiesByResourceID...")
  const resource_id = req.query.resource_id

  CommunityModel.getCommunitiesByResourceID(resource_id).then(function (comm_res) {
    var communities = comm_res
    var sponsor_ids = []
    for (var i = 0; i < communities.length; ++i) {
      sponsor_ids.push(ObjectId(communities[i].sponsor_id))

    }
    UserModel.getUsersByIDArray(sponsor_ids).then(function (sponsors_res) {
      for (var i = 0; i < communities.length; ++i) {
        for (var j = 0; j < sponsors_res.length; ++j) {
          if (String(sponsors_res[j]._id) == communities[i].sponsor_id) {
            communities[i].sponsor_info = sponsors_res[j]
          }
        }
      }
      res.json({ "success": "true", "data": communities })
    })
  }).catch(next)
})

module.exports = router