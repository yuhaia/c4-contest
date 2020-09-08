// 通过user_id来获取该用户like的resources
const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const ResourceModel = require('../../models/resource')
const LikeModel = require('../../models/like')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const Resource = require('../../lib/mongo').Resource

// 该接口负责查看user所like的所有课程
router.get('/', function (req, res, next) {
    console.log("request to likes/isUserLike...")
    const user_id = req.query.user_id
    const resource_id = req.query.resource_id
    LikeModel.isUserLike(user_id, resource_id).then(function (result) {
        if (!result) {
            res.json({"success": "true", "data": "0"})
        } else {
            res.json({"success": "true", "data": "1"})
        }
    }).catch(next)
})

module.exports = router