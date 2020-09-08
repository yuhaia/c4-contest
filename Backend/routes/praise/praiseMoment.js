const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const MomentModel = require('../../models/moment')
const PraiseModel = require('../../models/praise')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const moment = require('../../lib/mongo').moment
var verifyToken = require('../auth/verifyToken');

router.post('/', verifyToken, function (req, res, next) {
    console.log("request to praise/praiseMoment...")
    const moment_id = req.fields.moment_id
    const user_id = req.user_id

    let praise = {
        moment_id: moment_id,
        user_id: user_id
    }
    PraiseModel.create(praise)
        .then(function (create_praise_result) {
            MomentModel.getMomentByID(ObjectId(moment_id))
                .then(function (moment) {
                    if (!moment) {
                        // console.log('find moment failed，moment not found')
                        res.status(404)
                        res.json({ 'error': 'moment不存在' })
                    } else {
                        // 把原有的praises（string）变成number， +1 后再变回string存入数据库
                        var praises = (moment.praises * 1 + 1) + ""
                        MomentModel.updatePraisesByID(ObjectId(moment_id), praises)
                            .then(function (result) {
                                // // console.log("这是update前的result！！！")
                                // console.log(result)
                                if (!result.value) {
                                    // console.log('update moment failed，moment not found')
                                    res.status(404)
                                    res.json({ 'error': 'moment不存在' })
                                } else {
                                    // console.log("update moment successfully")
                                    res.json({ 'success': "ok" })
                                }
                            })
                            .catch(next)
                    }
                })
                .catch(next)
        })
        .catch(next)
    })

    module.exports = router