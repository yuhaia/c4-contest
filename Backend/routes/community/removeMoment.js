const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
var verifyToken = require('../auth/verifyToken');
const CommunityModel = require('../../models/community')
const UserModel = require('../../models/users')
const MomentModel = require('../../models/moment')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path

router.get('/', verifyToken, function (req, res, next) {
    console.log("request to community/removeMoment...")

    const user_id = req.user_id
    const moment_id = req.query.moment_id
    
    UserModel.getUserByID(ObjectId(user_id)).then(function (user_res) {
        if (!user_res) {
            res.json({"error": "user not found"})
        } else {
            var moment_number = user_res.moment_number * 1
            MomentModel.getMomentByID(ObjectId(moment_id)).then(function (get_res) {
                if (!get_res) {
                    res.json({ "error": "user与moment不匹配" })
                } else {
                    MomentModel.removeMomentByID(ObjectId(moment_id))
                        .then(function (result) {
                            // 此 moment 是插入 mongodb 后的值，包含 _id
                            // console.log('moment删除结果如下：')
                            // console.log(result)
        
                            UserModel.updateMomentNumber(ObjectId(user_id), moment_number - 1).then(function (tt_res) {
                                // console.log("update moment_number bingo~")
                            })
        
                            const community_id = get_res.community_id
                            CommunityModel.getCommunityByID(ObjectId(community_id)).then(
                                function (got_community) {
                                    if (!got_community) {
                                        // console.log('no community found')
                                        res.status = 404
                                        res.json({ 'error': 'community not found' })
                                    } else {
                                        // // console.log(result)
                                        var new_community = got_community
                                        let index = new_community.moments_id.indexOf(moment_id)
                                        new_community.moments_id.splice(index, 1)
                                        CommunityModel.update(ObjectId(community_id), new_community).then(function (before_update_result) {
                                            CommunityModel.getCommunityByID(community_id).then(function (updated_result) {
                                                // console.log(result)
                                                if (!result) {
                                                    // console.log('no community found')
                                                    res.status = 404
                                                    res.json({ 'error': 'community not found' })
                                                } else {
                                                    // console.log('从社圈删除moment的结果如下：', updated_result)
                                                    res.json({ 'success': 'ok' })
                                                }
                                            }).catch(next)
                                        }).catch(next)
                                    }
                                }
                            ).catch(next)
                        })
                        .catch(next)
                }
            })
        }
    })
   
})

module.exports = router
