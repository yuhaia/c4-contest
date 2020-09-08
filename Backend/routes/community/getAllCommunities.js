const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const CommunityModel = require('../../models/community')
const checkNotLogin = require('../../middlewares/check').checkNotLogin

router.get('/', function (req, res, next) {
  console.log("request to community/getAllCommunities...")

  CommunityModel.getAllCommunities().then(function (result) {
    res.json({"success":"true", 'data': result})
  }).catch(next)
})

module.exports = router