const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const ResourceModel = require('../../models/resource')
const CommentModel = require('../../models/comment')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const Resource = require('../../lib/mongo').Resource

router.get('/', function (req, res, next) {
    console.log("request to removeCommentByMomentID...")
    const moment_id = req.query.moment_id
    
    CommentModel.remove(moment_id).then(function (result) {
        // console.log('remove comment结果', result)
        if (!result) {
            // console.log("comment not found")
            res.status = 404
            res.json({ 'error': 'comment not found' })
        } else {
            res.json({"success":"true"})
        }
    }).catch(next)
})

module.exports = router