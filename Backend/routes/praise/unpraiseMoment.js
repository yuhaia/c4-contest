const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const MomentModel = require('../../models/moment')
const PraiseModel = require('../../models/praise')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const moment = require('../../lib/mongo').moment

router.post('/', function (req, res, next) {
    console.log("request to praise/unpraiseMoment...")
    const moment_id = req.fields.moment_id
    const user_id = req.fields.user_id

    let praise = {
        moment_id: moment_id,
        user_id: user_id
    }
    PraiseModel.remove(praise)
        .then(function (remove_result) {
            // console.log("remove_praise_result:", remove_result)
            MomentModel.getMomentByID(moment_id)
                .then(function (moment) {
                    if (!moment) {
                        // console.log('find moment failed，moment not found')
                        res.status(404)
                        res.json({ 'error': 'moment不存在' })
                    } else {
                        var praises = (moment.praises * 1 - 1) + ""
                        MomentModel.updatePraisesByID(moment_id, praises)
                            .then(function (result) {
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