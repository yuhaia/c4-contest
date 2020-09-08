const Like = require('../lib/mongo').Like

module.exports = {
  // 增加一个like信息
  create: function create (like) {
    return Like.create(like).exec()
  },

  remove: function remove(like) {
      return Like.remove(like)
  },

  isUserLike: function isUserLike(user_id, resource_id) {
    return Like.findOne({"user_id": user_id, "resource_id": resource_id})
  },

  getAllLikes: function getAllLikes() {
    return Like.find({})
  },
  // 通过user_id获取
  getLikesByUserID: function getLikesByUserID (user_id, category, skip, limit) {
    skip = skip * 1
    limit = limit * 1
    if (category == "all") {
      return Like
      .find({ user_id: user_id}, {skip: skip, limit: limit})
    } else {
      return Like
      .find({ user_id: user_id, category: category }, {skip: skip, limit: limit})
    }
    
  },

  // 通过resource_id获取
  getLikesByResourceID: function getLikesByResourceID (resource_id, skip, limit) {
    skip = skip * 1
    limit = limit * 1
    return Like
      .find({ resource_id: resource_id }, {skip: skip, limit: limit})
  },

  getLikesByResourceIDandUserID: function getLikesByResourceIDandUserID (resource_id, user_id) {
    return Like.findOne({resource_id: resource_id, user_id: user_id})
  }
}