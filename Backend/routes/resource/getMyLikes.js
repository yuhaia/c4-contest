const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const LikeModel = require('../../models/like')
const ResourceModel = require('../../models/resource')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
var verifyToken = require('../auth/verifyToken')
var jwt = require('jsonwebtoken')
const config = require('config-lite')(__dirname)

router.get('/', verifyToken, function (req, res, next) {
    console.log("request to ../resource/getMyLikes")

    var category = req.query.category
    var skip = req.query.skip
    var limit = req.query.limit
    // if everything good, save to request for use in other routes
    var user_id = req.user_id

    LikeModel.getLikesByUserID(user_id, category, skip, limit).then(function (like_info) {
        var resources_id = []
        // console.log("like_info")
        // console.log(like_info)
        for (var i = 0; i < like_info.length; ++i) {
            resources_id.push(ObjectId(like_info[i].resource_id))
        }
        // console.log("resources_id")
        // console.log(resources_id)
        ResourceModel.getResourceByIDArray(resources_id).then(function (resource_res) {
            // console.log("resource_res")
            // console.log(resource_res)
            for (var i = 0; i < resource_res.length; ++i) {
                resource_res.isUserLike = "1"
            }
            res.json({ "success": "true", 'data': resource_res })
        })
    })
})



module.exports = router