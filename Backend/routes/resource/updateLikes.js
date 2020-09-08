const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const ResourceModel = require('../../models/resource')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const Resource = require('../../lib/mongo').Resource

/**
 * @api {post} /v1.0/resources/updateLikes 更新资源的被喜欢数
 * @apiName updateLikes
 * @apiGroup Resource
 *
 * @apiParam {String} resource_id 资源ID
 * @apiParam {Number} likes 资源被喜欢数
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
 * @apiSampleRequest http://localhost:80/v1.0/resources/updateLikes
 */
router.post('/', function (req, res, next) {
    console.log("request to report/updateLikes...")
    const resource_id = ObjectId(req.fields.resource_id)
    const likes = req.fields.likes
    // console.log(resource_id)
    // console.log(likes)
    
    ResourceModel.updateLikesByID(resource_id, likes)
        .then(function (result) {
            console.log("这是update前的result！！！")
            console.log(result)
            if (!result.value) {
                // console.log('update resource failed，resource not found')
                res.status(404)
                res.json({ 'error': '资源不存在' })
            } else {
                // console.log("update resource successfully")
                ResourceModel.getResourceByID(resource_id)
                .then(function(resource) {
                    if (!resource) {
                        // console.log('find resource failed，resource not found')
                        res.status(404)
                        res.json({ 'error': '资源不存在' })
                    } else {
                        res.json({"success": 'true', 'data': resource })
                    }
                })
            }
        })
        .catch(next)
  })
  
  module.exports = router