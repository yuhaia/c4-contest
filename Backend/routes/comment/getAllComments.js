const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const ResourceModel = require('../../models/resource')
const CommentModel = require('../../models/comment')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const Resource = require('../../lib/mongo').Resource

router.get('/', function (req, res, next) {
    console.log("request to getAllComments...")
    const moment_id = req.query.moment_id

    CommentModel.getAllComments().then(function (result) {
        // console.log('查询 all comments结果', result)
        if (!result) {
            // console.log("comments not found")
            res.status = 404
            res.json({ 'error': 'comments not found' })
        } else {
            res.json({"success":"true","data": result})
        }
    }).catch(next)
})

module.exports = router