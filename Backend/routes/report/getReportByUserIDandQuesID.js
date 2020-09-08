const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const ReportModel = require('../../models/report')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const report = require('../../lib/mongo').report

router.get('/', function (req, res, next) {
    console.log("request to report/getReportByUserIDandQuesID...")

    ////// console.log(req)
    const user_id = req.query.user_id
    const questionnaire_id = ObjectId(req.query.questionnaire_id)
    // const skip = req.query.skip
    // const limit = req.query.limit
    //// console.log(user_id)
    ReportModel.getReportByUserIDandQuesID(user_id, questionnaire_id)
        .then(function (user_report) {
            if (user_report.length == 0) {
                // console.log("根据user_id and questionnaire_id未能找到相应的report")
                res.status = 404
                res.json({"error": "report not found"})
            } else {
                res.json({"success":"true","data": user_report[0]})
            }
        })
        .catch(next)
})

module.exports = router
