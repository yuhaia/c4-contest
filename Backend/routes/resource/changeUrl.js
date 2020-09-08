const sha1 = require('sha1')
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;
const LikeModel = require('../../models/like')
const MomentModel = require('../../models/moment')
const CommunityModel = require('../../models/community')

const UserModel = require('../../models/users')
const ResourceModel = require('../../models/resource')
const checkNotLogin = require('../../middlewares/check').checkNotLogin

var verifyToken = require('../auth/verifyToken');
const { User } = require('../../lib/mongo');
// resource
// router.get('/', function (req, res, next) {
//     console.log("request to ../resource/changeUrl")
//     // var resource_id = ObjectId(req.query.resource_id)
//     // var picture_url = req.query.picture_url
//     ResourceModel.getResource(0, 100).then(function (result) {
//         var resources = result
//         for (var i = 0; i < resources.length; ++i) {
//             var resource = resources[i]
//             var picture = resource.picture
//             var id = ObjectId(resource._id)
//             if (picture) {
//                 // picture = "https://xinqing.today" + picture.substring(12)
//                 picture = "https://xinqing.mysspku.com" + picture.substring(21)
//                 // console.log("picture:", picture)

//                 ResourceModel.changeUrl(id, picture).then(function (change_res) {
//                     console.log(change_res)
//                     res.json({"success": 'true'})
//                 })
//             }
//         }
//     })
//   })

// moments
// router.get('/', function (req, res, next) {
//     console.log("request to ../resource/changeUrl")
//     // var resource_id = ObjectId(req.query.resource_id)
//     // var picture_url = req.query.picture_url
//     MomentModel.getAllMoments().then(function (result) {
//         var moments = result
//         for (var i = 0; i < moments.length; ++i) {
//             var moment = moments[i]
//             var pictures = moment.pictures
//             var id = ObjectId(moment._id)

//             for (var j = 0; j < pictures.length; ++j) {
//                 pictures[j] = "https://xinqing.mysspku.com" + pictures[j].substring(21)
//             }

//             MomentModel.changeUrl(id, pictures).then(function (change_res) {
//                 console.log(change_res)
//             })
//         }

//         res.json({ "success": 'true' })

//     })
// })

// router.get('/', function (req, res, next) {
//     console.log("request to ../resource/changeUrl")
//     // var resource_id = ObjectId(req.query.resource_id)
//     // var picture_url = req.query.picture_url
//     UserModel.getAllUsers().then(function (result) {
//         var users = result
//         for (var i = 0; i < users.length; ++i) {
//             var user = users[i]
//             var picture = user.avatar
//             var id = ObjectId(user._id)

//             if (picture[16] == 't' && picture[17] == 'o') {
//                 picture = "https://xinqing.mysspku.com" + picture.substring(21)
//             }
//             UserModel.changeUrl(id, picture).then(function (change_res) {
//                 console.log(change_res)
//             })
//         }

//         res.json({ "success": 'true' })

//     })
// })

router.get('/', function (req, res, next) {
    console.log("request to ../resource/changeUrl")
    // var resource_id = ObjectId(req.query.resource_id)
    // var picture_url = req.query.picture_url


    CommunityModel.getAllCommunities.then(function (result) {
        var communities = result
        for (var i = 0; i < communities.length; ++i) {
            var community = communities[i]
            var picture = community.avatar
            var id = ObjectId(community._id)

            if (picture[16] == 't' && picture[17] == 'o') {
                picture = "https://xinqing.mysspku.com" + picture.substring(21)
            }
            CommunityModel.changeUrl(id, picture).then(function (change_res) {
                console.log(change_res)
            })
        }

        res.json({ "success": 'true' })

    })
})
module.exports = router