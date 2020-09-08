const community = require('./community')

const Resource = require('../lib/mongo').Resource

module.exports = {
    // 添加一个资源
    create: function create(resource) {
        return Resource.create(resource).exec()
    },

    addCommunity: function addCommunity(resource_id, community_id) {
        return Resource.findOneAndUpdate({_id: resource_id}, {$addToSet: {"communities_id": community_id}})
    },

    removeCommunity: function removeCommunity(resource_id, community_id) {
        return Resource.update({_id: resource_id}, {$pull: {"communities_id": community_id}})
    },

    // 通过_id获取resource
    getResourceByID: function getResourceByID(_id) {
        return Resource
            .findOne({ _id: _id })
    },

    getResourceByName: function getResourceByName(name) {
        return Resource.findOne({name: name})
    },


    // 通过众多_id获取resource
    getResourceByIDArray: function getResourceByIDArray(idArray) {
        return Resource
            .find({ _id: {"$in": idArray}})
    },

    // 通过category获取resource
    getResourcesByCategory: function getResourcesByCategory(category, skip, limit) {
        // string to number
        skip = skip * 1
        limit = limit * 1
        return Resource
            .find({ category: category }, { skip: skip, limit: limit }).sort({ "_id": -1 })
    },

    // 不区分任何field获取到resource
    getResource: function getResource(skip, limit) {
        // string to number
        skip = skip * 1
        limit = limit * 1
        return Resource.find({}, { skip: skip, limit: limit })
    },

    // 通过_id更新resource 的 likes
    // https://mongoosejs.com/docs/tutorials/findoneandupdate.html
    // 这个new true没啥卵用啊
    updateLikesByID: function updateLikesByID(_id, likes) {
        return Resource.findOneAndUpdate({ _id: _id }, { $set: { likes: likes } }, {
            new: true
        })
    },

    changeUrl: function changeUrl(_id, picture_url) {
        return Resource.findOneAndUpdate({ _id: _id }, { $set: { picture: picture_url } }, {
            new: true
        })
    },

    search: function search(reg) {
        return Resource.find({$or: [{name: {$regex: reg}}, {description: {$regex: reg}}, {author: {$regex: reg}}]})
    }
}