const community = require('./community')
// const { changeUrl } = require('./resource')

const Moment = require('../lib/mongo').Moment

module.exports = {
    // 注册一个用户
    create: function create(moment) {
        return Moment.create(moment).exec()
    },

    removeMomentByID: function remove(_id) {
        return Moment.remove({ "_id": _id })
    },
    
    getAllMoments: function getAllMoments() {
        return Moment.find({}).sort({ "_id": -1 })
    },
    // 通过众多_id获取resource
    getMomentByIDArray: function getMomentByIDArray(idArray) {
        return Moment
            .find({ _id: { "$in": idArray } }).sort({ "_id": -1 })
    },
    getMomentsByFollowedUserIDArray: function getMomentsByFollowedUserIDArray(user_id_array, skip, limit) {
        return Moment
            .find({ user_id: { "$in": user_id_array } }, { skip: skip, limit: limit }).sort({ "_id": -1 })
    },
    getMomentByID: function getMomentByID(_id) {
        return Moment.findOne({ _id: _id })
    },
    // 通过user_id获取该用户发布过的moments
    getMomentsByUserID: function getMomentsByUserID(user_id, skip, limit) {
        // string to number
        skip = skip * 1
        limit = limit * 1
        return Moment
            .find({ user_id: user_id }, { skip: skip, limit: limit }).sort({ "_id": -1 })
    },

    // 按照时间由近到远的顺序获得moments
    getMomentsFromNow: function getMoments(skip, limit) {
        // string to number
        skip = skip * 1
        limit = limit * 1
        return Moment
            .find({}, { skip: skip, limit: limit }).sort({ "_id": -1 })
    },

    updatePraisesByID: function updatePraisesByID(_id, praises) {
        return Moment.findOneAndUpdate({ _id: _id }, { $set: { praises: praises } }, {
            new: true
        })
    },

    getMomentsByCommunityID: function getMomentsByCommunityID(community_id) {
        return Moment.find({community_id: community_id})
    },

    removeMomentsByCommunityID: function removeMomentsByCommunityID(community_id) {
        return Moment.remove({community_id: community_id})
    },

    search: function search(reg) {
        return Moment.find({$or: [{texts: {$regex: reg}}]})
      },

    changeUrl: function changeUrl(_id, pictures) {
        return Moment.findOneAndUpdate({ _id: _id }, { $set: { pictures: pictures } }, {
            new: true
        })
    },
}