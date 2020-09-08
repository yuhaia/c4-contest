const Questionnaire = require('../lib/mongo').Questionnaire

module.exports = {
  // 提供一个问卷
  create: function create (questionnaire) {
    return Questionnaire.create(questionnaire).exec()
  },

  getAllQuestionnaires: function getAllQuestionnaires() {
    return Questionnaire.find({})
  },
  
  // 通过_id获取问卷信息
  getQuestionnaireByID: function getQuestionnaireByID (_id) {
    return Questionnaire
      .findOne({ _id: _id })
  },

  // 通过theme获取问卷信息
  getQuestionnaireByTheme: function getQuestionnaireByTheme (theme) {
    return Questionnaire
      .findOne({ theme: theme })
  }
}
