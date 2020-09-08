const config = require('config-lite')(__dirname)
const Mongolass = require('mongolass')
const mongolass = new Mongolass()
mongolass.connect(config.mongodb)

exports.User = mongolass.model('User', {
    name: { type: 'string', required: true },
    password: { type: 'string', required: true },
    avatar: { type: 'string', required: true },
    thumb_avatar: {type: 'string'},
    gender: { type: 'string', enum: ['m', 'f', 'x'], default: 'x' },
    bio: { type: 'string', required: true },
    professor: { type: 'string', enum: ['1', '0'], default: '0'},
    fans_number: {type: 'string', default: '0'},
    follow_number: {type: 'string', default: '0'},
    communities_id: {type: Array},
    // 用于标识是否是微信用户
    openid: {type: 'string', default: '0'},
    // 注册便送100积分
    coins: {type: 'number', default: 100},
    moment_number: {type: 'number', default: 0}
  })
exports.User.index({ name: 1 }, { unique: true }).exec()// 根据用户名找到用户，用户名全局唯一

exports.Questionnaire = mongolass.model('Questionnaire', {
  theme: { type: 'string', required: true },
  description: {type: 'string', required: true},
  questions: {type: Array, required: true},
  minest_value: {type: 'number', required: true},
  maxest_value: {type: 'number', required: true},
  stride_value: {type: 'number', required: true},
  level_des: {type: Array, required: true},
  groups: {type: 'object', required: true},
  anti_questions: {type: Array, required: true},
})


exports.Report = mongolass.model('Report', {
  user_id: {type: 'string', required: true},
  // questionnaire_id: {type: 'string', required: true},
  // questionnaire_theme: {type: 'string'},
  // 供前端每次打开用户报表页面时通过提交，貌似不需要
  // result_id: {type: 'string', required: true},
  // Result里的scores拷贝过来，直接传回给前端

  time: {type: 'number'},
  // scores: {type: Array},
  // 对应socres的文字分析和建议
  result: {type: 'object', required: true},
  questionnaire_info: {type: 'object'}
})

exports.Resource = mongolass.model('Resource', {
  category: {type: 'string', enum: ['书籍', '电影', '课程', '正念'], required: true},
  name: {type: 'string', required: true},
  picture: { type: 'string', required: true },
  time: {type: 'string'},
  author: {type: 'string', required: true},
  link: {type: 'string', required: true},
  description: {type: 'string', required: true},
  likes: {type: 'string', default: 0},
  labels: {type: 'string'},

  communities_id: {type: Array},
})

exports.Like = mongolass.model('Like', {
  category: {type: 'string', required: true},
  resource_id: {type: 'string', required: true},
  user_id: {type: 'string', required: true}
})

exports.Follow = mongolass.model('Follow', {
  followed_id: {type: 'string', required: true},
  fans_id: {type: 'string', required: true}
})

exports.Moment = mongolass.model('Moment', {
  user_id: {type: 'string', required: true},
  // 考虑到用户可能会改头像和昵称，所以moment这里只加user_id标识
  // 否则当用户改了头像和昵称后，后台还要每次都去修改moment的数据
  // 待这样的话前端为了获得moment的完整数据需要请求两次 一次是这个
  // 一次是user信息
  // user_name: {type: 'string', required: true},
  // user_avatar: {type: 'string', required: true},
  texts: {type: 'string'},
  time: {type: 'number'},
  pictures_number: {type: 'number'},
  pictures: {type: Array},
  praises: {type: 'number', default: 0},
  user_info: {type: 'object'},
  // 用户可以直接发动态 也可以在社圈里打卡发动态
  // 打卡发的动态不仅在该社群里可以展现 在一级页面里也可以展现同时可以展现该community的链接
  // 别的用户点进去之后可以申请添加社圈
  community_id: {type: 'string'}
})

exports.Praise = mongolass.model('Praise', {
  moment_id: {type: 'string', required: true},
  user_id: {type: 'string', required: true}
})
  
exports.Comment = mongolass.model('Comment', {
  moment_id: {type: 'string', required: true},
  floors_number: {type: 'string', required: true},
  sub_comments: {type: Array, required: true}
  /*
  moment_id: 000000,
  floors_number: 2,
  sub_comments: {
    "data": [
      {
        "floor": 1,
        "from_user_id": 111,
        "to_user_id": 222,
        "texts": "加油哇",
        "time": "2020-05-08 9:12"
      },
      {
        "floor": 2,
        "from_user_id": 222,
        "to_user_id": 111,
        "texts": "嗯嗯嗯，你也要加油哇",
        "time": "2020-05-08 12:12"
      }
    ]
  }
  */
})

exports.Community = mongolass.model('Community', {
  name: {type: 'string', required: true},
  description: {type: 'string'},
  avatar: {type: 'string'},
  resource_name: {type: 'string', default: ''},
  resource_id: {type: 'string', default: ''},
  time_start: {type: 'number'},
  time_end: {type: 'number', default: 0}, // 如果是0则表示永远？
  frequency: {type: 'number'},  // **次/周
  way: {type: 'string', default: '发布目标打卡动态，图片+文字，含心得体会'},
  ps: {type: 'string'},
  coins_needed: {type: 'number'},

  sponsor_id: {type: 'string', required: true},
  sponsor_info: {type: 'object'},

  time_create: {type: 'number'},
  // avatar: {type: 'string'},  // 后续弄成用户头像组合的
  
  users_id: {type: Array},
  moments_id: {type: Array},
  praises: {type: 'number', default: 0},
})


exports.Rules = mongolass.model('Rules', {
  questionnaire_id: {type: 'string', required: true},
  scores: {type: 'object', required: true},
  groups_scores: {type: 'object', required: true}
})

exports.EvaluationTemplate = mongolass.model('Rules', {
  theme: {type: 'string', required: true},
  advisory: {type: 'object', required: true}
})


const moment = require('moment')
const objectIdToTimestamp = require('objectid-to-timestamp')

// 根据 id 生成创建时间 created_at
mongolass.plugin('addCreatedAt', {
  afterFind: function (results) {
    results.forEach(function (item) {
      item.created_at = moment(objectIdToTimestamp(item._id)).format('YYYY-MM-DD HH:mm')
    })
    return results
  },
  afterFindOne: function (result) {
    if (result) {
      result.created_at = moment(objectIdToTimestamp(result._id)).format('YYYY-MM-DD HH:mm')
    }
    return result
  }
})
