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
var verifyToken = require('../auth/verifyToken');
const { User } = require('../../lib/mongo')

router.post('/', verifyToken,function (req, res, next) {
    console.log("request to community/addUser...")

    const community_id = ObjectId(req.fields.community_id)
    const user_id = req.user_id
    // console.log(community_id)
    CommunityModel.getCommunityByID(community_id).then(function (commu_res) {
        if (!commu_res) {
            res.json({"error": "该小组不存在"})
        } else {
            var coins_needed = commu_res.coins_needed * 1
            UserModel.getUserByID(ObjectId(user_id)).then(function (result) {
                if (!result) {
                    res.json({"error": "该用户不存在"})
                } else {
                    var new_user = result
                var inFlag = 0
                if (!new_user.communities_id) {
                    new_user.communities_id = []
                } else {
                    for (var i = 0; i < new_user.communities_id.length; ++i) {
                        if (new_user.communities_id[i] == req.fields.community_id) {
                            inFlag = 1
                            break
                        }
                    }
                }
                if (inFlag == 1) {
                    res.json({"error": "该用户已在该小组中"})
                } else if (new_user.coins < coins_needed) {
                    res.json({"error": "硬币余额不足，无法加入该小组"})
                } else {
                    new_user.communities_id.push(req.fields.community_id)
                    UserModel.update(user_id, new_user).then(function (result2) {
                        // console.log("更新后的user：")
                        // console.log(result2)
            
                        CommunityModel.getCommunityByID(community_id).then(function (result) {
                            // console.log(result)
                            if (!result) {
                                // console.log('no community found')
                                res.status = 404
                                res.json({ 'error': 'community not found' })
                            } else {
                                // // console.log(result)
                                var new_community = result
                                new_community.users_id.push(user_id)
                                CommunityModel.update(community_id, new_community).then(function (before_update_result) {
                                    CommunityModel.getCommunityByID(community_id).then(function (updated_result) {
                                        // console.log(result)
                                        if (!result) {
                                            // console.log('no community found')
                                            res.status = 404
                                            res.json({ 'error': 'community not found' })
                                        } else {
                                            // console.log('添加用户至社圈结果如下：', updated_result)
                                            res.json({"success":"true", 'data': updated_result })
                                        }
                                    }).catch(next)
                                }).catch(next)
                            }
                        }).catch(next)
            
                    })
                }
                }
            }).catch(next)
        }
    })
    
})

module.exports = router