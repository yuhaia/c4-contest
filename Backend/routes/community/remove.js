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
const MomentModel = require('../../models/moment')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path
var verifyToken = require('../auth/verifyToken');

router.get('/', verifyToken, function (req, res, next) {
  console.log("request to community/remove...")

  const user_id = req.user_id
  const community_id = req.query.community_id
  CommunityModel.getCommunityByID((community_id)).then(function (find_res) {
    if (!find_res) {
      res.json({"error": "community not found"})
    } else {
      if (find_res.sponsor_id != user_id) {
        res.json({"error": "该用户不是小组的发起者，不能删除该小组"})
      } else {
        CommunityModel.removeCommunityByID(community_id).then(function (result) {
          //// console.log('社圈删除成功,删除信息如下：')
          //// console.log(result)
          res.json({"success":"true"})

          // 更新user里和resource里的communities_id 还有moment的
          UserModel.removeCommunity(ObjectId(user_id), community_id).then(function (remove_user_commu_res) {
            //// console.log("删除user里的该community id")
            //// console.log(remove_user_commu_res)
          })
          
          const resource_id = find_res.resource_id
          ResourceModel.removeCommunity(ObjectId(resource_id), community_id).then(function (remove_reso_commu_res) {
            //// console.log("删除resourcei的该communities")
            //// console.log(remove_reso_commu_res)
          })

          MomentModel.removeMomentsByCommunityID(community_id).then(function (remove_moment_by_commu) {
            //// console.log("删除该community的所有moment")
            //// console.log(remove_moment_by_commu)
          })
        }).catch(next)
      }
    }
  })
  
})

module.exports = router