const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const express = require('express')
const config = require('config-lite')(__dirname)
const router = express.Router()

const Resource = require('../../models/resource')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const img_path = config.img_path

router.post('/', function (req, res, next) {
  console.log("request to report/submit...")


  const category = req.fields.category
  const name = req.fields.name
  const picture = req.files.picture.path.split(path.sep).pop()
  const time = req.fields.time
  const author = req.fields.author
  const link = req.fields.link
  const description = req.fields.description
  const likes = req.fields.likes
  const labels = req.fields.labels

  // 待写入数据库的resource信息
  let resource = {
    category: category,
    name: name,
    picture: img_path + picture,
    time: time,
    author: author,
    link: link,
    description: description,
    likes: likes,
    labels: labels
  }
  // console.log("resource: ")
  // console.log(resource)
  // 将resource信息写入数据库
  Resource.create(resource)
    .then(function (result) {
      // 此 resource 是插入 mongodb 后的值，包含 _id
      resource = result.ops[0]
      // console.log('resource添加成功，添加信息如下：')
      // console.log(resource)
      res.json({"success":"true", 'data': resource})
    })
    .catch(next)
})

module.exports = router