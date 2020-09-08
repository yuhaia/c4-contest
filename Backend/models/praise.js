const Praise = require('../lib/mongo').Praise

module.exports = {
  // 增加一个Praise信息
  create: function create (praise) {
    return Praise.create(praise).exec()
  },

  remove: function remove(praise) {
      return Praise.remove(praise)
  },

  // 通过user_id获取
  getPraisesByUserID: function getPraisesByUserID (user_id, skip, limit) {
    skip = skip * 1
    limit = limit * 1
    return Praise
      .find({ user_id: user_id }, {skip: skip, limit: limit})
  },

  // 通过moment_id获取
  getPraisesByMomentID: function getPraisesByMomentID (moment_id, skip, limit) {
    skip = skip * 1
    limit = limit * 1
    return Praise
      .find({ moment_id: moment_id }, {skip: skip, limit: limit})
  }
}