const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const UserModel = require('../../models/users')
const CommunityModel = require('../../models/community')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path
var verifyToken = require('../auth/verifyToken');

// 获取该用户创建或加入的小组
router.get('/', verifyToken, function (req, res, next) {
    console.log("request to community/getCommunitiesByToken...")

    const user_id = req.user_id
    UserModel.getUserByID(ObjectId(user_id)).then(function (user_res) {
        const user = user_res
        // console.log("user info:")
        // console.log(user)
        if (!user.communities_id || user.communities_id.length == 0) {
            // console.log("该用户尚未创建或加入过兴趣小组")
            res.json({ "success": "true", "data": [] })
        } else {
            var communities_id = []
            for (var i = 0; i < user.communities_id.length; ++i) {
                communities_id.push(ObjectId(user.communities_id[i]))
            }
            CommunityModel.getCommunityByIDArray(communities_id).then(function (comm_res) {
                console.log("community_res:")
                console.log(comm_res)
                var communities = comm_res
                var sponsor_ids = []
                for (var i = 0; i < communities.length; ++i) {
                    sponsor_ids.push(ObjectId(communities[i].sponsor_id))
                }
                UserModel.getUsersByIDArray(sponsor_ids).then(function (sponsors_res) {
                    for (var i = 0; i < communities.length; ++i) {
                        for (var j = 0; j < sponsors_res.length; ++j) {
                            // console.log("communities[i].sponsor_id:")
                            // if (!communities[i]["sponsor_id"]) {
                            //     console.log(communities[i])
                            // }
                            // console.log(communities[i]["sponsor_id"])
                            // console.log(communities[i])
                            if (communities[i].sponsor_id == undefined) {
                                console.log(communities[i])
                            }
                            if (communities[i].sponsor_id != undefined) {
                                if (String(sponsors_res[j]._id) == communities[i].sponsor_id) {
                                    communities[i].sponsor_info = sponsors_res[j]
                                }
                            }
                            
                        }
                    }
                    res.json({ "success": "true", "data": communities })
                }).catch(next)
            })
        }
    })
})

module.exports = router