// 用户提交评论
/*
    moment_id: 
    floor: 第几层评论
    from_user_id: 
    to_user_id:
    "texts":
    "time"
*/

const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const ResourceModel = require('../../models/resource')
const CommentModel = require('../../models/comment')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const Resource = require('../../lib/mongo').Resource

/**
 * @api {post} /v1.0/comments/submit 用户提交评论
 * @apiName submitComment
 * @apiGroup Comment
 *
 * @apiParam {String} name 用户昵称
 * @apiParam {String} bio 用户简介
 * @apiParam {String} password 用户密码
 * @apiParam {String} repassword 密码的二次确认
 * @apiParam {File} avatar 用户头像
 * @apiParam {String="m", "f", "x"} gender 用户性别
 * @apiParam {String="1", "0"} professor 是否专业人士
 * 
 *
 * @apiSuccess {Json} data 用户的个人信息
 *
 * @apiSuccessExample Success-Response:
 *     HTTP/1.1 200 OK
 *     {
 *       "success" : "true",
 *       "data": {
 *          "name": "小海",
 *          "gender": "m",
 *          "bio": "一个爱运动的小海",
 *          "avatar": "upload_83f1f7282bff3d7485c02019295a120d.jpeg",
 *          "professor": "0",
 *          "_id": "5eae91482918310189257839"
 *       }
 *     }
 * @apiErrorExample Error-Response:
 *     HTTP/1.1 401 Unauthorized
 *     {
 *       "error": "用户名已被占用"
 *     }
 * @apiSampleRequest http://localhost:80/v1.0/comments/submit
 */
router.post('/', function (req, res, next) {
    console.log("request to ../comment/submit...")
    const moment_id = req.fields.moment_id
    const floor = req.fields.floor * 1
    const from_user_id = req.fields.from_user_id
    const to_user_id = req.fields.to_user_id
    const texts = req.fields.texts
    const time = req.fields.time

    let subComment = {
        floor: floor + "",
        from_user_id: from_user_id,
        to_user_id: to_user_id,
        texts: texts,
        time: time
    }
    if (floor == 1) {
        // 说明这个moment是第一次被评论
        var sub_comments = [subComment]

        let comment = {
            moment_id: moment_id,
            floors_number: floor + "",
            sub_comments: sub_comments
        }
        // console.log('要提交的评论:', comment)
        CommentModel.create(comment).then(function (result) {
            // console.log('提交评论的结果:', result)
            if (!result) {
                // console.log('submit comment moment not found')
                res.status(404)
                res.json({ 'error': 'moment不存在' })
            } else {
                var comment = result.ops[0]
                // console.log('submit comment: ', comment)
                res.json({ "success": "true", "data": comment })
            }
        })
            .catch(next)
    } else if (floor > 1) {
        // 说明这个moment已经存在 > 1 个评论了
        // 需要盖楼式的加评论 参数里的floor便是更新后的楼层数目(前提是ok的)
        // TODO: 如何解决高并发的问题
        CommentModel.getCommentsByMomentID(moment_id).then(function (result) {
            // console.log('查询comment结果', result)
            if (!result) {
                // console.log("comment not found")
                res.status = 404
                res.json({ 'error': 'comment not found' })
            } else {
                var old_comment = result
                old_comment.floors_number = floor + ""
                old_comment.sub_comments.push(subComment)
                var new_comment = old_comment
                CommentModel.addSubCommentByMomentID(moment_id, new_comment)
                    .then(function (result) {
                        CommentModel.getCommentsByMomentID(moment_id).then(
                            function (final_res) {
                                // console.log('add subComment result:', result)
                                res.json({ "success": "true", 'data': final_res })
                            }
                        )

                    })
                    .catch(next)
            }
        }).catch(next)
    }
})

module.exports = router