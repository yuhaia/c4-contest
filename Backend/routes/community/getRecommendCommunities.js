const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
var jwt = require('jsonwebtoken')

const UserModel = require('../../models/users')
const CommunityModel = require('../../models/community')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path
var verifyToken = require('../auth/verifyToken');
const { all } = require('../moment/getRecommendMoments')

// 获取该用户可能感兴趣的小组
// 暂时先返回除该用户创建或加入的小组外 其他所有小组
router.get('/', function (req, res, next) {
    console.log("request to community/getRecommendCommunities...")
    var token = req.headers['token'];
    if (!token) {
        CommunityModel.getAllCommunities().then(function (all_comm_res) {
            res.json({ "success": "true", "data": all_comm_res })
        })
    } else {
        jwt.verify(token, config.auth_secret, function (err, decoded) {
            if (err) {
                return res.status(401).send({ 'error': 'Failed to authenticate token.' });
            }
            var user_id = decoded.id;
            UserModel.getUserByID(ObjectId(user_id)).then(function (user_res) {
                const user = user_res
                // console.log("user info:")
                // console.log(user)

                CommunityModel.getAllCommunities().then(function (all_comm_res) {
                    if (all_comm_res.length == 0) {
                        res.json({ "success": "true", "data": [] })
                    } else {
                        var communities_id = []
                        for (var i = 0; i < all_comm_res.length; ++i) {
                            var comm_id = all_comm_res[i]._id
                            var isIn = false
                            var user_comm_ids = user.communities_id
                            if (user_comm_ids) {
                                for (var j = 0; j < user_comm_ids.length; ++j) {
                                    if (comm_id == user.communities_id[j]) {
                                        isIn = true
                                        break
                                    }
                                }
                            }
                            if (isIn == false) {
                                communities_id.push(ObjectId(comm_id))
                            }
                        }

                        CommunityModel.getCommunityByIDArray(communities_id).then(function (comm_res) {
                            var communities = comm_res
                            var sponsor_ids = []
                            for (var i = 0; i < communities.length; ++i) {
                                sponsor_ids.push(ObjectId(communities[i].sponsor_id))
                            }
                            UserModel.getUsersByIDArray(sponsor_ids).then(function (sponsors_res) {
                                for (var i = 0; i < communities_id.length; ++i) {
                                    for (var j = 0; j < sponsors_res.length; ++j) {
                                        if (String(sponsors_res[j]._id) == communities[i].sponsor_id) {
                                            communities[i].sponsor_info = sponsors_res[j]
                                        }
                                    }
                                }
                                res.json({ "success": "true", "data": communities })
                            })
                        })
                    }
                })
            })
        })
    }
})

module.exports = router