const Comment = require('../lib/mongo').Comment

// 一个comment对应一个comment的_id，同时也对应一个moment的_id
module.exports = {
  // 增加一个Comment信息
  create: function create (comment) {
    return Comment.create(comment).exec()
  },

  remove: function remove(moment_id) {
      return Comment.remove({moment_id: moment_id})
  },

  getAllComments: function getAllComments() {
    return Comment.find({}).sort({ "_id": -1 })
  },
  
  // 通过moment_id获取 这里就不要skip和limit了
  getCommentsByMomentID: function getCommentsByMomentID (moment_id) {
    return Comment
      .findOne({ moment_id: moment_id })
  },

  addSubCommentByMomentID: function addSubCommentByMomentID(moment_id, comment) {
    // 更新数组有点麻烦 直接简单粗暴替换得了。。
    // 但这里的new：true没啥卵用啊
    // return Comment.findOneAndUpdate({moment_id: moment_id}, {floors_number: floors_number,$addToSet: {"sub_comments.$[data]": subComment}}, {new: true})

    return Comment.findOneAndUpdate({moment_id: moment_id}, {$set: comment}, {new: true})
  },

  removeSubCommentByMomentID: function addSubCommentByMomentID(moment_id, comment) {
    // 并不从数组中删除 而是将texts替换为“该评论已删除”

    // 太复杂了 直接简单粗暴，在route中获得这个comment，然后更新之后再更新数据库
    // return Comment.findOneAndUpdate({moment_id: moment_id}, {$set: {  "data.$[].condition.$[inner].valueConnection":"after"  }}, {new: true})

    return Comment.findOneAndUpdate({moment_id: moment_id}, {$set: comment}, {new: true})
  },

}