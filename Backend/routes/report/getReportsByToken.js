// 通过user_id来获取该用户praise的reports
const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var jwt = require('jsonwebtoken');
const config = require('config-lite')(__dirname)
var ObjectId = require('mongodb').ObjectID;
const ReportModel = require('../../models/report')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const report = require('../../lib/mongo').report
const UserModel = require('../../models/users')
var verifyToken = require('../auth/verifyToken');

router.get('/', verifyToken, function (req, res, next) {
    console.log("request to ../reports/getReportsByToken:")
    const user_id = req.user_id
    UserModel.getUserByID(user_id).then(function (user) {
        if (!user) {
            // console.log("登陆失败，不存在该token对应的user")
            res.status(404).send({ 'error': 'user not found' });
        } else {
            ReportModel.getReportsByUserID(String(user_id))
                .then(function (user_reports) {
                    var result = {}
                    for (var i = 0; i < user_reports.length; ++i) {
                        var theme = user_reports[i].questionnaire_info.theme
                        if (theme in result == false) {
                            result[theme] = []
                        }
                        result[theme].push(user_reports[i])
                    }
                    res.json({ "success": "true", "data": result })
                })
                .catch(next)
        }
    })
})

module.exports = router