const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const express = require('express')
const config = require('config-lite')(__dirname)
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const Moment = require('../../models/moment')
const UserModel = require('../../models/users')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const img_path = config.img_path
var verifyToken = require('../auth/verifyToken');


router.post('/', verifyToken, function (req, res, next) {
  console.log("request to moment/submit...")


  const user_id = req.user_id
  const texts = req.fields.texts
  const time = Date.now()
  const pictures_number = req.fields.pictures_number * 1
  // console.log('picture number:', pictures_number)
  var pictures_array = []
  for (var i = 0; i < pictures_number; ++i) {
    let picture_name = "picture" + i
    pictures_array.push(img_path + req.files[picture_name].path.split(path.sep).pop())
  }
  // var pictures = {}
  // pictures["data"] = pictures_array
  var pictures = pictures_array
  // console.log("pictures: ", pictures)
  // 待写入数据库的moment信息
  let moment = {
    user_id: user_id,
    texts: texts,
    time: time,
    pictures_number: pictures_number,
    pictures: pictures
  }


  // 添加上user_info
  UserModel.getUserByID(ObjectId(user_id)).then(function (user_res) {
    if (!user_res) {
      // console.log("user not found")
      res.json({ "error": "user not found" })
    } else {
      moment.user_info = user_res
      // console.log("moment after adding user_info: ")
      // console.log(moment)

      // 将moment信息写入数据库
      Moment.create(moment)
        .then(function (result) {
          // 此 moment 是插入 mongodb 后的值，包含 _id
          moment = result.ops[0]
          // console.log('moment添加成功，添加信息如下：')
          // console.log(moment)

          var moments_number = (user_res.moments_number * 1 + 1)
          UserModel.updateMomentsNumber(ObjectId(user_id), moments_number).then(function (update_moments_number_res) {
            moment.user_info.moments_number = moments_number
            res.json({ "success": "true", 'data': moment })
          })
        })
        .catch(next)
    }
  })

})

module.exports = router
