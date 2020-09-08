const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const UserModel = require('../../models/users');
const FollowModel = require('../../models/follow')
const { verbose } = require('winston');
const verifyToken = require('../auth/verifyToken');
const { request } = require('express');
const checkNotLogin = require('../../middlewares/check').checkNotLogin

router.get('/', function (req, res, next) {
    console.log("request to ../users/getUserByID:")
    const user_id = req.query.user_id
    const request_user_id = req.query.request_user_id
    // console.log(user_id)
    UserModel.getUserByID(user_id)
        .then(function (user) {
            // console.log(user)
            if (!user) {
                // console.log('obtain user failed，user not found')
                res.status(404)
                res.json({ 'error': '用户不存在' })
            } else {
                if (request_user_id) {
                    // ios用户 需要follow信息
                    console.log("obtain user successfully")
                    FollowModel.checkRelation(user_id, request_user_id).then(function (find_relation_res) {
                        var followed = 1
                        if (!find_relation_res) {
                            followed = 0
                        }
                        res.json({ "success": "true", 'data': user, "followed": followed })
                    })
                } else {
                    res.json({ "success": "true", 'data': user })
                }
            }
        })
        .catch(next)
})

module.exports = router