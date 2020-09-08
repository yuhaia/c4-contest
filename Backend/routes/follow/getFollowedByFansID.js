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
    console.log("request to follow/getFollowedByFansID...")
    const fans_id = req.query.fans_id
    const skip = req.query.skip
    const limit = req.query.limit
    // console.log(fans_id)
    FollowModel.getFollowedByFansID(fans_id, skip, limit)
        .then(function (followed_infors) {
            // console.log("followed_infors:",followed_infors)
            var followed_users_ids = []
            for (var i = 0; i < followed_infors.length; ++i) {
                followed_users_ids.push(followed_infors[i].followed_id)
            }
            UserModel.getUsersByIDArray(followed_users_ids)
                .then(function (result) {
                    // console.log("fans followed: ", result)
                    res.json({"success":"true", "data": result })
                })
                .catch(next)
        })
        .catch(next)
})

module.exports = router