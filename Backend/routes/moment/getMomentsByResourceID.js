const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const MomentModel = require('../../models/moment')
const ResourceModel = require('../../models/resource')
const CommunityModel = require('../../models/community')

const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path
var verifyToken = require('../auth/verifyToken');

router.get('/', function (req, res, next) {
  console.log("request to moment/getMomentsByResourceID...")

  const resource_id = req.query.resource_id
  // console.log("resource_id:", resource_id)
  var skip = 0
  var limit = 100
  if (req.query.skip) {
    skip = req.query.skip * 1
  }
  if (req.query.limit) {
    limit = req.query.limit * 1
  }
  
  ResourceModel.getResourceByID(ObjectId(resource_id)).then(function (resource) {
    var communities_id = resource.communities_id
    if (!communities_id || communities_id.length == 0) {
      res.json({"success": "true", "data": []})
    } else {
      CommunityModel.getCommunityByIDArray(communities_id).then(function (commu_res) {
        var moments_id = []
        for (var i = 0; i < commu_res.length; ++i) {
          moments_id = moments_id.concat(commu_res[i].moments_id)
        }
        if (moments_id.length == 0) {
          res.json({"success": "true", "data": []})
        } else {
          MomentModel.getMomentByIDArray(moments_id).then(function (final_res) {
            res.json({"success": "true", "data": final_res})
          })
        }
      })
    }
  })
})

module.exports = router