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
    console.log("request to ../reports/getReportsByTheme:")
    const user_id = req.user_id
    const theme = req.query.theme
    UserModel.getUserByID(user_id).then(function (user) {
        if (!user) {
            // console.log("登陆失败，不存在该token对应的user")
            res.status(404).send({ 'error': 'user not found' });
        } else {
            // console.log("user_id:", user_id)
            // console.log("typeof user_id:")
            // console.log(typeof(user_id))
            const questionnaire_id = ObjectId(req.query.questionnaire_id)
            ReportModel.getReportsByTheme(theme)
                .then(function (user_reports) {
                    // console.log(user_reports)
                    res.json({ "success": "true", "data": user_reports })
                })
                .catch(next)
        }
    })
})

module.exports = router