const Result = require('../lib/mongo').Result

module.exports = {
  // 提供一个被试评测结果
  create: function create (result) {
    return Result.create(result).exec()
  },

  // 通过_id获取被试评测结果
  getResultByID: function getResultByID (_id) {
    return Result
      .findOne({ _id: _id })
  },

  // 通过theme获取被试评测结果
  getResultByTheme: function getResultByTheme (theme) {
    return Result
      .findOne({ theme: theme })
  }
}