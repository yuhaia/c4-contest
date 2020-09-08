// 通过user_id来获取该用户praise的reports
const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const ReportModel = require('../../models/report');
const e = require('express');
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const report = require('../../lib/mongo').report
var verifyToken = require('../auth/verifyToken');

router.get('/', function (req, res, next) {
    console.log("request to ../reports/getReportsByUserID:")
    const user_id = req.query.user_id
    // const skip = req.query.skip
    // const limit = req.query.limit
    // console.log(user_id)
    ReportModel.getReportsByUserID(user_id)
        .then(function (user_reports) {
            // console.log(user_reports)
            var result = {}
            for (var i = 0; i < user_reports.length; ++i) {
                var theme = user_reports[i].questionnaire_info.theme
                if (theme in result == false) {
                    result[theme] = []
                }
                result[theme].push(user_reports[i])
            }
            res.json({"success":"true","data": result})
        })
        .catch(next)
})

module.exports = router