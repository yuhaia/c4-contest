const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const express = require('express')
const router = express.Router()

const QuestionnaireModel = require('../../models/questionnaire')
const checkNotLogin = require('../../middlewares/check').checkNotLogin

router.post('/', function (req, res, next) {
  console.log("request to ../questionnaire/submit:")

  // console.log("req infor: ")
  // //// console.log(req)

  const theme = req.fields.theme
  const description = req.fields.description
  const questions = req.fields.questions
  const minest_value = req.fields.minest_value
  const maxest_value = req.fields.maxest_value
  const stride_value = req.fields.stride_value
  const level_des = req.fields.level_des
  const groups = req.fields.groups
  const anti_questions = req.fields.anti_questions

  // 待写入数据库的问卷信息
  let questionnaire = {
    theme: theme,
    description: description,
    questions: questions,
    minest_value: minest_value,
    maxest_value: maxest_value,
    stride_value: stride_value,
    level_des: level_des,
    groups: groups,
    anti_questions: anti_questions
  }
  // console.log("questionnaire: ")
  // console.log(questionnaire)
  // 将问卷信息写入数据库
  QuestionnaireModel.create(questionnaire)
    .then(function (result) {
      // 此 questionnaire 是插入 mongodb 后的值，包含 _id
      questionnaire = result.ops[0]
      // console.log('问卷添加成功，添加信息如下：')
      // console.log(questionnaire)
      res.json({"success":"true", 'data': questionnaire})
    })
    .catch(next)
})

module.exports = router