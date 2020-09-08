const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const UserModel = require('../../models/users')
const FollowModel = require('../../models/follow')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const user = require('../../lib/mongo').user

var verifyToken = require('../auth/verifyToken');
router.post('/', verifyToken, function (req, res, next) {
    console.log("request to follow/followHim...")
    const followed_id = req.fields.followed_id
    const fans_id = req.user_id

    let follow = {
        followed_id: followed_id,
        fans_id: fans_id
    }
    FollowModel.check(followed_id, fans_id).then(
        function (check_res) {
            if (check_res) {
                // console.log("该用户已经关注了另一位用户")
                res.json({ "error": "不可重复关注" })
            } else {
                FollowModel.create(follow).then(function (create_follow_result) {
                    UserModel.getUserByID(ObjectId(fans_id)).then(function (fans_user) {
                        if (!fans_user) {
                            // console.log('find fan failed，user not found')
                            res.status(404)
                            res.json({ 'error': 'fan不存在' })
                        } else {
                            var follow_number = (fans_user.follow_number * 1 + 1) + ""
                            UserModel.updateFollowNumberByID(ObjectId(fans_id), follow_number).then(function (update_follows_result) {
                                if (!update_follows_result.value) {
                                    // console.log('update user,s follows failed，user not found')
                                    res.status(404)
                                    res.json({ 'error': 'user不存在' })
                                } else {
                                    UserModel.getUserByID(ObjectId(followed_id)).then(function (followed_user) {
                                        if (!followed_user) {
                                            // console.log('find followed_user failed，user not found')
                                            res.status(404)
                                            res.json({ 'error': 'followed_user不存在' })
                                        } else {
                                            var fans_number = (followed_user.fans_number * 1 + 1) + ""
                                            UserModel.updateFansNumberByID(ObjectId(followed_id), fans_number).then(function (update_fans_result) {
                                                if (!update_fans_result.value) {
                                                    // console.log('update user,s fans failed，user not found')
                                                    res.status(404)
                                                    res.json({ 'error': 'user不存在' })
                                                } else {
                                                    res.json({ "success": "ok" })
                                                }
                                            })
                                                .catch(next)
                                        }
                                    })
                                        .catch(next)
                                }
                            })
                                .catch(next)
                        }
                    })
                        .catch(next)
                })
                    .catch(next)
            }
        }
    )

})

module.exports = router