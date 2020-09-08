const EvaluationTemplate = require('../lib/mongo').EvaluationTemplate

module.exports = {
  // 提供一个被试评测分析汇报
  create: function create (evaluation_template) {
    return EvaluationTemplate.create(evaluation_template).exec()
  },

  // 通过_id获取被试评测分析汇报
  getEvaluationTemplateByID: function getEvaluationTemplateByID (_id) {
    return EvaluationTemplate
      .findOne({ _id: _id })
  },

  // 通过theme获取被试评测分析汇报
  getEvaluationTemplateByTheme: function getEvaluationTemplateByTheme (theme) {
    return EvaluationTemplate
      .findOne({ theme: theme })
  }
}
