const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const QuestionnaireModel = require('../../models/questionnaire')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path

router.get('/', function (req, res, next) {
  console.log("request to ../questionnaire/getAll:")
  QuestionnaireModel.getAllQuestionnaires().then(function (result) {
    // // console.log('所有问卷的信息如下：')
    // // console.log(result)
    res.json({"success":"true", 'data': result})
  }).catch(next)
})

module.exports = router