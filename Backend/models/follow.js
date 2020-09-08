const Follow = require('../lib/mongo').Follow

module.exports = {
  // 增加一个Follow信息
  create: function create (follow) {
    return Follow.create(follow).exec()
  },

  remove: function remove(followed_id, fans_id) {
      return Follow.remove({followed_id: followed_id,
        fans_id: fans_id})
  },

  check: function check(followed_id, fans_id) {
    return Follow.findOne({followed_id: followed_id,
      fans_id: fans_id})
  },

  getAllFollows: function getAllFollows() {
    return Follow.find({})
  },
  // 通过fans_id获取
  getFollowedByFansID: function getFollowedByFansID (fans_id, skip, limit) {
    skip = skip * 1
    limit = limit * 1
    return Follow
      .find({ fans_id: fans_id }, {skip: skip, limit: limit})
  },

  // 通过followed_id获取
  getFansByFollowedID: function getFansByFollowedUserID (followed_id, skip, limit) {
    skip = skip * 1
    limit = limit * 1
    return Follow
      .find({ followed_id: followed_id }, {skip: skip, limit: limit})
  },

  checkRelation: function checkRelation(followed_id, fans_id) {
    return Follow.findOne({fans_id: fans_id, followed_id: followed_id})
  }
}