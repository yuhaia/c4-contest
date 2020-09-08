// 通过user_id来获取该用户like的resources
const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const ResourceModel = require('../../models/resource')
const LikeModel = require('../../models/like')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const Resource = require('../../lib/mongo').Resource
var verifyToken = require('../auth/verifyToken');

// 该接口负责查看user所like的所有课程
router.get('/', verifyToken,function (req, res, next) {
    console.log("request to likes/getByToken...")
    const user_id = req.user_id
    const skip = req.query.skip
    const limit = req.query.limit
    // console.log(user_id)
    LikeModel.getLikesByUserID(user_id, skip, limit)
        .then(function (user_likes) {
            // console.log(user_likes)
            var resource_ids = []
            for (var i = 0; i < user_likes.length; ++i) {
                resource_ids.push(user_likes[i].resource_id)
            }
            ResourceModel.getResourceByIDArray(resource_ids)
                .then(function (result) {
                    // console.log(result)
                    res.json({"success":"true", "data": result })
                })
                .catch(next)
        })
        .catch(next)
})

module.exports = router