const Community = require('../lib/mongo').Community

module.exports = {
    // 注册一个社圈
    create: function create(community) {
        return Community.create(community).exec()
    },

    removeCommunityByID: function remove(_id) {
        return Community.remove({ "_id": _id })
    },

    getAllCommunities: function getAllCommunities() {
        return Community.find({})
    },
    // 通过众多_id获取community
    getCommunityByIDArray: function getCommunityByIDArray(idArray) {
        return Community
            .find({ _id: { "$in": idArray } }).sort({ "_id": -1 })
    },

    getCommunityByID: function getCommunityByID(_id) {
        return Community.findOne({ _id: _id })
    },

    update: function update(_id, community) {
        return Community.findOneAndUpdate({ _id: _id }, { $set: community}, {
            new: true
        })
    },

    search: function search(reg) {
        return Community.find({$or: [{name: {$regex: reg}}, {description: {$regex: reg}}, {resource_name: {$regex: reg}}]})
    },

    changeUrl: function changeUrl(_id, picture_url) {
        return Community.findOneAndUpdate({ _id: _id }, { $set: { avatar: picture_url } }, {
            new: true
        })
    },

    getCommunitiesByResourceID: function getCommunitiesByResourceID(resource_id) {
        return Community.find({resource_id: resource_id})
    }

    // addToSet 不行哇
    // addUser: function addUser(_id, user_id) {
    //     return Community.findOneAndUpdate({ _id: _id }, { $addToSet: {users_id: users_id}}, {
    //         new: true
    //     })
    // }
}