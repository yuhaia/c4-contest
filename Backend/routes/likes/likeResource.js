const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const ResourceModel = require('../../models/resource')
const LikeModel = require('../../models/like')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const Resource = require('../../lib/mongo').Resource

var verifyToken = require('../auth/verifyToken');

router.post('/', verifyToken, function (req, res, next) {
    console.log("request to likes/likeResource...")
    var resource_id = req.fields.resource_id
    const user_id = req.user_id
    console.log("resource_id of req: ", resource_id, ". type is ", typeof (resource_id))
    console.log("user_id: ", user_id)
    if (!resource_id) {
        resource_id = req.query.resource_id
        // console.log("resource_id of req: ", resource_id, ". type is ", typeof(resource_id))
    }

    ResourceModel.getResourceByID(ObjectId(resource_id))
        .then(function (resource) {
            if (!resource) {
                console.log('find resource failed，resource not found')
                res.status(404)
                res.json({ 'error': 'resource不存在' })
            } else {
                let like = {
                    resource_id: resource_id,
                    user_id: user_id,
                    category: resource.category,
                }
                LikeModel.isUserLike(user_id, resource_id).then(function (user_like_res) {
                    if (user_like_res) {
                        console.log("该用户已喜欢过该资源")
                        res.json({ "error": "该用户已喜欢过该资源" })
                    } else {
                        console.log("该用户还未喜欢该资源")
                        LikeModel.create(like)
                            .then(function (create_like_result) {
    
                                // 把原有的likes（string）变成number， +1 后再变回string存入数据库
                                var likes = (resource.likes * 1 + 1) + ""
                                ResourceModel.updateLikesByID(ObjectId(resource_id), likes)
                                    .then(function (result) {
                                        console.log("这是update前的result！！！")
                                        console.log(result)
                                        if (!result.value) {
                                            // console.log('update resource failed，resource not found')
                                            res.status(404)
                                            res.json({ 'error': 'resource不存在' })
                                        } else {
                                            console.log("update resource successfully")
                                            res.json({ 'success': "ok" })
                                        }
                                    })
                                    .catch(next)
                            })
                            
                        }
                    })
                }
        })
})

module.exports = router