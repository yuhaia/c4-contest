
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

router.post('/', verifyToken, function (req, res, next) {
    console.log("request to community/removeUser...")

    const community_id = ObjectId(req.fields.community_id)
    const user_id = req.user_id
    // console.log(community_id)
    UserModel.getUserByID(user_id).then(function (result) {
        var new_user = result

        var inFlag = 0
        for (var i = 0; i < new_user.communities_id.length; ++i) {
            if (new_user.communities_id[i] == req.fields.community_id) {
                inFlag = 1
                break
            }
        }
        if (inFlag == 0) {
            res.json({"error": "该用户并不在该小组中"})
        } else {
            let user_index = new_user.communities_id.indexOf(user_id)
        new_user.communities_id.splice(user_index, 1)
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
                    let index = new_community.users_id.indexOf(user_id)
                    new_community.users_id.splice(index, 1)
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
    }).catch(next)
})

module.exports = router