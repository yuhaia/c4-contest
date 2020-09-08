// 通过user_id来获取该用户follow的resources
const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const UserModel = require('../../models/users')
const FollowModel = require('../../models/follow')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const Resource = require('../../lib/mongo').Resource

router.get('/', function (req, res, next) {
    console.log("request to follow/getFansByFollowedID...")
    const followed_id = req.query.followed_id
    const skip = req.query.skip
    const limit = req.query.limit
    // console.log(followed_id)
    FollowModel.getFansByFollowedID(followed_id, skip, limit)
        .then(function (followed_infors) {
            // console.log("followed_infors:",followed_infors)
            var fans_ids = []
            for (var i = 0; i < followed_infors.length; ++i) {
                fans_ids.push(followed_infors[i].fans_id)
            }
            UserModel.getUsersByIDArray(fans_ids)
                .then(function (result) {
                    // console.log("关注该用户的fans: ", result)
                    if (!result) {
                        res.json({"success":"true", "data": [] })
                    } else {
                        res.json({"success":"true", "data": result })
                    }
                })
                .catch(next)
        })
        .catch(next)
})

module.exports = router