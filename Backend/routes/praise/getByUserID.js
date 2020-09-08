// 通过user_id来获取该用户praise的moments
const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const MomentModel = require('../../models/moment')
const PraiseModel = require('../../models/praise')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const moment = require('../../lib/mongo').moment

// 该接口负责查看user所praise的所有课程
router.get('/', function (req, res, next) {
    console.log("request to praise/getByUserID...")
    const user_id = req.query.user_id
    const skip = req.query.skip
    const limit = req.query.limit
    // console.log(user_id)
    PraiseModel.getPraisesByUserID(user_id, skip, limit)
        .then(function (user_praises) {
            // console.log(user_praises)
            var moment_ids = []
            for (var i = 0; i < user_praises.length; ++i) {
                moment_ids.push(user_praises[i].moment_id)
            }
            MomentModel.getMomentByIDArray(moment_ids)
                .then(function (result) {
                    // console.log(result)
                    res.json({"success":"true", "data": result })
                })
                .catch(next)
        })
        .catch(next)
})

module.exports = router