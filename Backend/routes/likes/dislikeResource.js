const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const ResourceModel = require('../../models/resource')
const LikeModel = require('../../models/like')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const Resource = require('../../lib/mongo').Resource

var verifyToken = require('../auth/verifyToken');

router.post('/', verifyToken,function (req, res, next) {
    console.log("request to likes/dislikeResource...")
    const resource_id = req.fields.resource_id
    const user_id = req.user_id

    let like = {
        resource_id: resource_id,
        user_id: user_id
    }
    LikeModel.isUserLike(user_id, resource_id).then(function (user_like_res) {
        if (!user_like_res) {
            // console.log("该用户并未曾喜欢该资源")
            res.json({"error": "无法取消喜欢，因为就没有喜欢过..."})
        } else {
            LikeModel.remove(like)
        .then(function (remove_result) {
            // console.log("remove_like_result:", remove_result)
            ResourceModel.getResourceByID(resource_id)
                .then(function (resource) {
                    if (!resource) {
                        // console.log('find resource failed，resource not found')
                        res.status(404)
                        res.json({ 'error': 'resource不存在' })
                    } else {
                        var likes = (resource.likes * 1 - 1) + ""
                        ResourceModel.updateLikesByID(resource_id, likes)
                            .then(function (result) {
                                // console.log("这是update前的result！！！")
                                // console.log(result)
                                if (!result.value) {
                                    // console.log('update resource failed，resource not found')
                                    res.status(404)
                                    res.json({ 'error': 'resource不存在' })
                                } else {
                                    // console.log("update resource successfully")
                                    res.json({ 'success': "ok" })
                                }
                            })
                            .catch(next)
                    }
                })
                .catch(next)
        })
        .catch(next)
        }
    })
    
    })

    module.exports = router