const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
var verifyToken = require('../auth/verifyToken');
const ReportModel = require('../../models/report')

const QuestionnaireModel = require('../../models/questionnaire')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path

router.get('/', verifyToken, function (req, res, next) {
    const user_id = req.user_id
    console.log("request to ../questionnaire/getAll:")
    QuestionnaireModel.getAllQuestionnaires().then(function (ques_res) {
        ReportModel.getReportsByUserID(String(user_id))
            .then(function (user_reports) {
                var result = []
                for (var j = 0; j < ques_res.length; ++j) {
                    var exist = false;
                    for (var i = 0; i < user_reports.length; ++i) {
                        var theme = user_reports[i].questionnaire_info.theme
                        if (theme == ques_res[j].theme) {
                            exist = true
                            break
                        }
                    }
                    if (!exist) {
                        result.push(ques_res[j])
                    }
                }
                res.json({ "success": "true", "data": result })
            })
            .catch(next)
    }).catch(next)
})

module.exports = router