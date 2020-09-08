const express = require('express')
const router = express.Router()

const checkLogin = require('../../middlewares/check').checkLogin

router.get('/', checkLogin, function (req, res, next) {
  console.log("request to ../users/signout:")
  // 清空 session 中用户信息
  req.session.user = null
  // req.flash('success', '登出成功')
  // 登出成功后跳转到主页
  // res.redirect('/posts')
  res.json({'success': '成功登出'})
})

module.exports = router