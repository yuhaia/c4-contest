const fs = require('fs')
const path = require('path')
const sha1 = require('sha1')
const config = require('config-lite')(__dirname)
const express = require('express')
const router = express.Router()
var ObjectId = require('mongodb').ObjectID;

const CommunityModel = require('../../models/community')
const MomentModel = require('../../models/moment')
const UserModel = require('../../models/users')
const checkNotLogin = require('../../middlewares/check').checkNotLogin
let img_path = config.img_path
var verifyToken = require('../auth/verifyToken');
const { User } = require('../../lib/mongo')

router.post('/', verifyToken, function (req, res, next) {
    console.log("request to community/addMoment...")
    const user_id = req.user_id
    const texts = req.fields.texts
    const time = Date.now()
    const community_id = req.fields.community_id

    var pictures_number = 0
    var pictures_url = []

    var ios_user = req.fields.ios_user
    if (ios_user == "true") {
        pictures_number = req.fields.pictures_number * 1
        // console.log('picture number:', pictures_number)
        for (var i = 0; i < pictures_number; ++i) {
            let picture_name = "picture" + i
            pictures_url.push(img_path + req.files[picture_name].path.split(path.sep).pop())
        }
    } else {
        var pictures = req.fields.pictures
        // console.log("req pictures:")
        // console.log(typeof (pictures))
        if (typeof (pictures) == 'string') {
            var tmp = JSON.parse(pictures)
            pictures = tmp
            // console.log("反序列化pictures得到：")
            // // console.log(pictures)
            // // console.log(typeof(pictures))
        }
        var pictures_name = []
        var max_len = 9
        if (pictures.length < max_len) {
            max_len = pictures.length
        }
        pictures_number = max_len
        for (var i = 0; i < max_len; ++i) {
            var name = "img_" + String(i) + "_" + String(user_id) + "_" + String(Date.now()) + ".jpg"
            pictures_name.push(name)
            pictures_url.push(img_path + name)
        }

        for (var i = 0; i < max_len; ++i) {
            var name = pictures_name[i]
            let base64Image = pictures[i].split(';base64,').pop();
            fs.writeFile('./public/img/' + name, base64Image, { encoding: 'base64' }, function (err) {
                // // console.log('File created');
                // fs.rename('./public/')
            });
        }
    }

    // 待写入数据库的moment信息
    let moment = {
        user_id: user_id,
        texts: texts,
        time: time,
        pictures_number: pictures_number * 1,
        pictures: pictures_url,
        community_id: community_id
    }
    // console.log("moment: ")
    // console.log(moment)
    UserModel.getUserByID(ObjectId(user_id)).then(function (user_res) {
        var moment_number = user_res.moment_number * 1
        if (!user_res.communities_id || user_res.communities_id.length == 0) {
            res.json({ "error": "该用户还未曾加入任何小组" })
        } else {
            UserModel.updateMomentNumber(ObjectId(user_id), moment_number + 1).then(function (tt_res) {
                // console.log("update moment number bingo~")
            })
            const communities_id = user_res.communities_id
            var inFlag = 0
            for (var i = 0; i < user_res.communities_id.length; ++i) {
                if (user_res.communities_id[i] == community_id) {
                    inFlag = 1
                    break
                }
            }
            if (inFlag == 0) {
                res.json({ "error": "该用户并未在该小组中，无法进行打卡" })
            } else {
                // 将moment信息写入数据库
                MomentModel.create(moment)
                    .then(function (result) {
                        // 此 moment 是插入 mongodb 后的值，包含 _id
                        moment = result.ops[0]
                        // console.log('moment添加成功，添加信息如下：')
                        // console.log(moment)
                        UserModel
                        CommunityModel.getCommunityByID(ObjectId(community_id)).then(
                            function (got_community) {
                                if (!got_community) {
                                    // console.log('no community found')
                                    res.status = 404
                                    res.json({ 'error': 'community not found' })
                                } else {
                                    // // console.log(result)
                                    var new_community = got_community
                                    new_community.moments_id.push(String(moment._id))
                                    CommunityModel.update(ObjectId(community_id), new_community).then(function (before_update_result) {
                                        // console.log('已经添加moment至社圈')
                                        res.json({ 'success': 'true', 'data': moment })
                                    }).catch(next)
                                }
                            }
                        ).catch(next)
                    })
                    .catch(next)
            }
        }
    })



    // old version
    // const user_id = req.user_id
    // const texts = req.fields.texts
    // const time = Date.now()
    // const community_id = req.fields.community_id
    // const pictures_number = req.fields.pictures_number * 1
    // // console.log('picture number:', pictures_number)
    // var pictures_array = []
    // for (var i = 0; i < pictures_number; ++i) {
    //     let picture_name = "picture" + i
    //     pictures_array.push(img_path + req.files[picture_name].path.split(path.sep).pop())
    // }
    // var pictures = {}
    // pictures["data"] = pictures_array
    // // console.log("pictures: ", pictures)
    // // 待写入数据库的moment信息
    // let moment = {
    //     user_id: user_id,
    //     texts: texts,
    //     time: time,
    //     pictures_number: pictures_number + "",
    //     pictures: pictures,
    //     community_id: community_id
    // }
    // // console.log("moment: ")
    // // console.log(moment)
    // UserModel.getUserByID(ObjectId(user_id)).then(function (user_res) {
    //     const communities_id = user_res.communities_id
    //     var inFlag = 0
    //     for (var i = 0; i < user_res.communities_id.length; ++i) {
    //         if (user_res.communities_id[i] == community_id) {
    //             inFlag = 1
    //             break
    //         }
    //     }
    //     if (inFlag == 0) {
    //         res.json({"error": "该用户并未在该小组中，无法进行打卡"})
    //     } else {
    //         // 将moment信息写入数据库
    // MomentModel.create(moment)
    // .then(function (result) {
    //     // 此 moment 是插入 mongodb 后的值，包含 _id
    //     moment = result.ops[0]
    //     // console.log('moment添加成功，添加信息如下：')
    //     // console.log(moment)
    //     CommunityModel.getCommunityByID(ObjectId(community_id)).then(
    //         function (got_community) {
    //             if (!got_community) {
    //                 // console.log('no community found')
    //                 res.status = 404
    //                 res.json({ 'error': 'community not found' })
    //             } else {
    //                 // // console.log(result)
    //                 var new_community = got_community
    //                 new_community.moments_id.push(String(moment._id))
    //                 CommunityModel.update(ObjectId(community_id), new_community).then(function (before_update_result) {
    //                     // console.log('已经添加moment至社圈')
    //                     res.json({'success': 'true', 'data': moment })
    //                 }).catch(next)
    //             }
    //         }
    //     ).catch(next)
    // })
    // .catch(next)
    //     } 
    // })
})

module.exports = router