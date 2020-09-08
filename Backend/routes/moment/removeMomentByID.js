const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const express = require('express')
const config = require('config-lite')(__dirname)
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const Moment = require('../../models/moment')
const Comment = require('../../models/comment')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
const img_path = config.img_path

router.get('/', function (req, res, next) {
  console.log("request to moment/removeMomentByID...")


  const moment_id = ObjectId(req.query.moment_id)
  const user_id = req.query.user_id
  UserModel.getUserByID(ObjectId(user_id)).then(function (user_res) {
    if (!user_res) {
      // console.log("user not found")
      res.json({ "error": "user not found" })
    } else {

      Moment.removeMomentByID(moment_id)
    .then(function (result) {
      Comment.remove(moment_id).then(function (result) {

        var moments_number = (user_res.moments_number * 1 - 1) + ""
          UserModel.updateMomentsNumber(ObjectID(user_id), moments_number).then(function (update_moments_number_res) {
            // console.log('删除 moment and its comment成功', result)
        res.json({'success': "ok"})
          })
      }).catch(next)
    })
    .catch(next)

    }
  })
  
})

module.exports = router