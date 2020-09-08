const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const LikeModel = require('../../models/like')
const ResourceModel = require('../../models/resource')
const checkNotLogin = require('../../middlewares/check').checkNotLogin


/**
 * @api {post} /v1.0/resources/get 获取资源
 * @apiName getResource
 * @apiGroup Resource
 *
 * @apiParam {Number} skip 跳过资源数目
 * @apiParam {Number} limit 一次请求资源数目
 * 
 *
 * @apiSuccess {Json} data 资源信息
 *
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 * {
 *   "success": "true",
 *    "data": [
 *       {
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
 *       },
 * {
 *           "_id": "5eb2784d94a8606a2b3c93d7",
 *           "category": "book",
 *           "name": "不妥协的谈判",
 *           "picture": "localhost/img/upload_c2df8e427859a04358ff397416b08c72.png",
 *           "time": "2020-01-01",
 *           "author": "丹尼尔·夏皮罗（DanielShapiro）",
 *           "link": "https://item.jd.com/45700318284.html",
 *           "description": "不妥协的谈判 哈佛大学经典谈判心理课",
 *           "likes": "1",
 *           "labels": "职业发展"
 *       }
 *      ]
 * }
 * 
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 404 Not Found
 *     {
 *       "error": "资源不存在"
 *     }
 * @apiSampleRequest http://localhost:80/v1.0/resources/get
 */
var verifyToken = require('../auth/verifyToken');
router.get('/', verifyToken, function (req, res, next) {
    console.log("request to ../resource/get")
    
    var user_id = req.user_id
    const skip = req.query.skip
    const limit = req.query.limit
    ResourceModel.getResource(skip, limit)
        .then(function (resources) {
            // // console.log(resources)
            if (!resources) {
                // console.log('obtain resources failed，resource not found')
                res.status(404)
                res.json({ 'error': 'resources不存在' })
            } else {
                // console.log("obtain resources successfully")
                // 添加isUserLike字段
                var resource_ids = []
                for (var i = 0; i < resources.length; ++i) {
                    resources[i].isUserLike = "0"
                    resource_ids.push(resources[i]._id)
                }

                LikeModel.getLikesByUserID(user_id, "all", skip, limit).then(function (user_like_resource_ids) {
                    if (user_like_resource_ids.length == 0) {
                        // console.log("user 未曾喜欢过资源")
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
                    res.json({ "success": "true", 'data': resources })
                })
            }
        })
        .catch(next)
  })
  
  module.exports = router