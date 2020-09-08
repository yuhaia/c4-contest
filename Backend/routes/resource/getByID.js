const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const ResourceModel = require('../../models/resource')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const LikeModel = require('../../models/like')

/**
 * @api {post} /v1.0/resources/getByID 根据ID获取资源
 * @apiName getByID
 * @apiGroup Resource
 *
 * @apiParam {String} resource_id 类别ID
 * 
 *
 * @apiSuccess {Json} data 资源信息
 *
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 * {
 *   "success": "true",
 *    "data": {
 *           "_id": "5eb2784294a8606a2b3c93d6",
 *           "category": "book",
 *           "name": "认知天性",
 *           "picture": "localhost/img/upload_53874f74751a543e49de322ae944a927.png",
 *           "time": "2020-01-01",
 *           "author": "彼得布朗著",
 *           "link": "https://item.jd.com/41582960046.html",
 *           "description": "认知天性 提高学生记忆力",
 *           "likes": "1",
 *           "labels": "职业发展"
 *       }
 * }
 * 
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "error": "资源不存在"
 *     }
 * @apiSampleRequest http://localhost:80/v1.0/resources/getByID
 */
var verifyToken = require('../auth/verifyToken')

router.get('/', verifyToken, function (req, res, next) {
    console.log("request to resource/getByID...")
    const user_id = req.user_id
    const resource_id = ObjectId(req.query.resource_id)
    // console.log(resource_id)
    ResourceModel.getResourceByID(resource_id)
        .then(function (resource) {
            // // console.log(resource)
            if (!resource) {
                // console.log('obtain resource failed，resource not found')
                res.status(404)
                res.json({ 'error': '资源不存在' })
            } else {
                resource.isUserLike = "0"
                // console.log("obtain resource successfully")
                LikeModel.getLikesByUserID(user_id).then(function (user_like_resource_ids) {
                    if (user_like_resource_ids.length == 0) {
                        // console.log("user暂未喜欢该类别的资源")
                    } else {

                        for (var j = 0; j < user_like_resource_ids.length; ++j) {
                            if (resource_id == user_like_resource_ids[j].resource_id) {
                                resource.isUserLike = "1"
                                break
                            }
                        }

                    }
                    res.json({ "success": "true", 'data': resource })
                })
            }
        })
        .catch(next)
})

module.exports = router