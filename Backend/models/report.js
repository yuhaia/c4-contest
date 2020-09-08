const Report = require('../lib/mongo').Report

module.exports = {
  // 提供一个被试评测分析汇报
  create: function create(report) {
    return Report.create(report).exec()
  },

  getAllReports: function getAllReports() {
    return Report.find({}).sort({ "_id": -1 })
  },

  getReportsByQuesID: function getReportsByQuesID(questionnaire_id) {
    return Report.find({ "questionnaire_info._id": questionnaire_id }, { sort: { _id: -1 } })
  },

  getReportsByTheme: function getReportsByTheme(theme) {
    return Report.find({ "questionnaire_info.theme": theme }, { sort: { _id: -1 } })
  },

  getReportByUserIDandQuesID: function getReportByUserIDandQuesID(user_id, questionnaire_id) {
    return Report.find({ user_id: user_id, "questionnaire_info._id": questionnaire_id }, { sort: { _id: -1 } })

  },
  // 通过_id获取被试评测分析汇报
  getReportByID: function getReportByID(_id) {
    return Report
      .findOne({ _id: _id })
  },

  // 通过user_id获取被试评测分析汇报
  getReportsByUserID: function getReportsByUserID(user_id) {
    return Report
      .find({ user_id: user_id })
  },

  // 通过user_id and theme获取被试评测分析汇报
  getReportByUserIDandTheme: function getReportByUserIDandTheme(user_id, theme) {
    return Report
      .find({ user_id: user_id, "questionnaire_info.theme": theme }).sort({ "_id": -1 })
  }
}
