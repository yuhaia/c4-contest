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
  console.log("request to ../questionnaire/getAllTheme:")
  QuestionnaireModel.getAllQuestionnaires().then(function (result) {
    // // console.log('所有问卷的信息如下：')
    // // console.log(result)
    var themes = []
    for (var i = 0; i < result.length; ++i) {
        themes.push(result[i].theme)
    }
    res.json({"success":"true", 'data': themes})
  }).catch(next)
})

module.exports = router