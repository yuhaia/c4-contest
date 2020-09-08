const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
const https = require('https')
const request = require('request')
const UserModel = require('../../models/users')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
var verifyToken = require('../auth/verifyToken');
var jwt = require('jsonwebtoken')
const config = require('config-lite')(__dirname)

router.get('/', function (req, res, next) {
  console.log("request to ../users/verifyToken:")
  var token = req.headers['token'];
  if (!token) {
    return res.status(403).send({ 'error': 'No token provided.' });
  } else {
    jwt.verify(token, config.auth_secret, function (err, decoded) {
      if (err) {
        return res.status(401).send({ 'error': 'Failed to authenticate token.' });
      } else {
        return res.status(200).send({'success': 'true'})
      }
    })
  }
})

module.exports = router