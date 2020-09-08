const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const QuestionnaireModel = require('../../models/questionnaire')
const checkNotLogin = require('../../middlewares/check').checkNotLogin

router.get('/', function (req, res, next) {
    // const questionnaireId = ObjectId(req.params.questionnaireId)
    console.log("request to ../questionnaire/getByTheme:")
    const theme = req.query.theme
    // console.log(theme)
    QuestionnaireModel.getQuestionnaireByTheme(theme)
        .then(function (questionnaire) {
            // console.log(questionnaire)
            if (!questionnaire) {
                // console.log('obtain questionnaire failed，questionnaire not found')
                res.status(404)
                res.json({ 'error': '问卷不存在' })
            } else {
                // console.log("obtain questionnaire successfully")
                res.json({"success":"true", 'data': questionnaire })
            }
        })
        .catch(next)
  })
  
  module.exports = router