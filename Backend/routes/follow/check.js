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
    console.log("request to follow/check...")
    const followed_id = req.fields.followed_id
    const fans_id = req.user_id

    let follow = {
        followed_id: followed_id,
        fans_id: fans_id
    }
    FollowModel.check(followed_id, fans_id).then(
        function (check_res) {
            if (!check_res) {
                // console.log("该用户并没有关注另一位用户")
                res.json({ "success": "true", "data": "0" })
            } else {
                // console.log("该用户关注了另一位用户")
                res.json({ "success": "true", "data": "1" })
            }
        })
})

module.exports = router