// 用户删除评论
/*
    moment_id: 
    floor: 第几层评论
    // from_user_id: 
    // to_user_id:
    // "texts":
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

router.post('/', function (req, res, next) {
    console.log("request to removeSubComment...")
    const moment_id = req.fields.moment_id
    const floor = req.fields.floor
    const from_user_id = req.fields.from_user_id
    // const to_user_id = req.fields.to_user_id
    // const texts = req.fields.texts
    const time = req.fields.time

    CommentModel.getCommentsByMomentID(moment_id).then(function (result) {
        // console.log('查询comment结果', result)
        if (!result) {
            // console.log("comment not found")
            res.status = 404
            res.json({ 'error': 'comment not found' })
        } else if (result.sub_comments[floor * 1 - 1].from_user_id != from_user_id) {
            // console.log('forbidden! the user can not remove the sumComment')
            res.status = 401
            res.json({ 'error': 'the subComment does not belong to the user' })
        } else {
            var old_comment = result
            old_comment.sub_comments[floor * 1 - 1].texts = "该评论已删除"
            old_comment.sub_comments[floor * 1 - 1].time = time
            var new_comment = old_comment
            CommentModel.removeSubCommentByMomentID(moment_id, new_comment)
                .then(function (result) {
                    CommentModel.getCommentsByMomentID(moment_id).then(
                        function (final_res) {
                            // console.log('remove subComment result:', result)
                            res.json({ "success": "true", 'data': final_res })
                        }
                    )
                })
                .catch(next)
        }
    }).catch(next)
})

module.exports = router