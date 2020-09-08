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

router.get('/', function (req, res, next) {
    console.log("request to ../resource/getByCategory")
    var token = req.headers['token'];
    var category = req.query.category
    var skip = req.query.skip * 1
    var limit = req.query.limit * 1
    console.log('token:', token)
    if (!token) {
        ResourceModel.getResourcesByCategory(category, skip, limit)
            .then(function (resources) {
                // // console.log(resources)
                if (!resources) {
                    // console.log('obtain resources failed，resource not found')
                    res.status(404)
                    res.json({ 'error': '资源不存在' })
                } else {
                    // console.log("obtain resources successfully")
                    res.json({ "success": "true", "data": resources })
                }
            })
    } else {
        jwt.verify(token, config.auth_secret, function (err, decoded) {
            if (err)
                return res.status(401).send({ 'error': 'Failed to authenticate token.' });

            // if everything good, save to request for use in other routes
            var user_id = decoded.id;
            ResourceModel.getResourcesByCategory(category, skip, limit)
                .then(function (resources) {
                    // // console.log(resources)
                    if (!resources) {
                        // console.log('obtain resources failed，resource not found')
                        res.status(404)
                        res.json({ 'error': '资源不存在' })
                    } else {
                        console.log("obtain resources successfully")
                        var resource_ids = []
                        for (var i = 0; i < resources.length; ++i) {
                            resources[i].isUserLike = "0"
                            resource_ids.push(resources[i]._id)
                        }
                        LikeModel.getLikesByUserID(user_id, category, skip, limit).then(function (user_like_resource_ids) {
                            console.log("user_id: ", user_id)
                            console.log("like find res: ", user_like_resource_ids)
                            if (user_like_resource_ids.length == 0) {
                                console.log("user暂未喜欢该类别的资源")
                            } else {
                                for (var i = 0; i < resource_ids.length; ++i) {
                                    var resource_id = resource_ids[i]
                                    for (var j = 0; j < user_like_resource_ids.length; ++j) {
                                        if (resource_id == user_like_resource_ids[j].resource_id) {
                                            resources[i].isUserLike = "1"
                                            break
                                        }
                                    }
                                }
                            }
                            console.log("resources:")
                            console.log(resources)
                            res.json({ "success": "true", 'data': resources })
                        })
                    }
                })
                .catch(next)
        });
    }
})



module.exports = router