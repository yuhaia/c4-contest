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

router.get('/', function (req, res, next) {
    console.log("request to ../reports/getAllReports:")
    ReportModel.getAllReports().then(function (reports) {
        res.json({"success": "true", "data": reports})
    })
})

module.exports = router