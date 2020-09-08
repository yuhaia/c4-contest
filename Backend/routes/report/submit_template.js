const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const express = require('express')
const router = express.Router()

const EvaluationTemplateModel = require('../../models/evaluation_template')
const checkNotLogin = require('../../middlewares/check').checkNotLogin

router.post('/', function (req, res, next) {
  console.log("request to report/submit_template...")


  const theme = req.fields.theme
  const advisory = req.fields.advisory

  // 待写入数据库的报告模板信息
  let evaluation_template = {
    theme: theme,
    advisory: advisory
  }
  // console.log("evaluation_template: ")
  // console.log(evaluation_template)
  // 将问卷信息写入数据库
  EvaluationTemplateModel.create(evaluation_template)
    .then(function (result) {
      // 此 questionnaire 是插入 mongodb 后的值，包含 _id
      evaluation_template = result.ops[0]
      // console.log('报告模板添加成功，添加信息如下：')
      // console.log(evaluation_template)
      res.json({"success":"true", 'data': evaluation_template})
    })
    .catch(next)
})

module.exports = router