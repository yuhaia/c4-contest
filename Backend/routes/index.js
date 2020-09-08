const config = require('config-lite')(__dirname)

module.exports = function (app) {
  var version = config.version
  app.get('/', function (req, res) {
    res.end('hello world')
  })
  app.use(version + '/search', require('./search'))
  // users
  app.use(version + '/users/verifyToken', require('./users/verifyToken'))
  app.use(version + '/users/signup', require('./users/signup'))
  app.use(version + '/users/signin', require('./users/signin'))
  app.use(version + '/users/signout', require('./users/signout'))
  app.use(version + '/users/getAllUsers', require('./users/getAllUsers'))
  app.use(version + '/users/getUserByID', require('./users/getUserByID'))
  app.use(version + '/users/getUser', require('./users/getUser'))
  app.use(version + '/auth/getUserAuthorization', require('./auth/getUserAuthorization'))
  app.use(version + '/users/getRecommendedUsers', require('./users/getRecommendedUsers'))
  // questionnaires
  app.use(version + '/questionnaires/submit', require('./questionnaire/submit'))
  app.use(version + '/questionnaires/getByTheme', require('./questionnaire/getByTheme'))
  app.use(version + '/questionnaires/getByID', require('./questionnaire/getByID'))
  app.use(version + '/questionnaires/getAll', require('./questionnaire/getAll'))
  app.use(version + 'questionnaires/getAllTheme', require('./questionnaire/getAllTheme'))
  app.use(version + '/questionnaire/getRecommendQues', require('./questionnaire/getRecommendQues'))
  // reports
  app.use(version + '/reports/submit', require('./report/submit'))
  app.use(version + '/reports/submit_template', require('./report/submit_template'))
  app.use(version + '/reports/getReportsByUserID', require('./report/getReportsByUserID'))
  app.use(version + '/reports/getReportByUserIDandQuesID', require('./report/getReportByUserIDandQuesID'))
  app.use(version + '/reports/getReportsByToken', require('./report/getReportsByToken'))
  app.use(version + '/reports/getReportsByQuesID', require('./report/getReportsByQuesID'))
  app.use(version + '/reports/getAllReports', require('./report/getAllReports'))

  // resources
  app.use(version + '/resources/submit', require('./resource/submit'))
  app.use(version + '/resources/get', require('./resource/get'))
  app.use(version + '/resources/getByID', require('./resource/getByID'))
  app.use(version + '/resources/getCategories', require('./resource/getCategories'))
  app.use(version + '/resources/getByCategory', require('./resource/getByCategory'))
  app.use(version + '/resources/getMyLikes', require('./resource/getMyLikes'))
  app.use(version + '/resources/recommends', require('./resource/recommends'))
  app.use(version + '/resources/updateLikes', require('./resource/updateLikes'))
  app.use(version + '/resources/changeUrl', require('./resource/changeUrl'))

  // like
  app.use(version + '/likes/likeResource', require('./likes/likeResource'))
  app.use(version + '/likes/dislikeResource', require('./likes/dislikeResource'))
  app.use(version + '/likes/getByUserID', require('./likes/getByUserID'))
  app.use(version + '/likes/getByToken', require('./likes/getByToken'))
  app.use(version + '/likes/getAll', require('./likes/getAll'))
  app.use(version + '/likes/isUserLike', require('./likes/isUserLike'))
  // app.use(version + '/likes/getByResourceID', require('./likes/getByResourceID'))

  // follow
  app.use(version + '/follow/followHim', require('./follow/followHim'))
  app.use(version + '/follow/disfollowHim', require('./follow/disfollowHim'))
  app.use(version + '/follow/getFansByFollowedID', require('./follow/getFansByFollowedID'))
  app.use(version + '/follow/getFollowedByFansID', require('./follow/getFollowedByFansID'))
  app.use(version + '/follow/getAll', require('./follow/getAll'))
  app.use(version + '/follow/check', require('./follow/check'))

  // moment
  app.use(version + '/moment/submit', require('./moment/submit'))
  app.use(version + '/moment/removeMomentByID', require('./moment/removeMomentByID'))
  app.use(version + '/moment/getAllMoments', require('./moment/getAllMoments'))
  app.use(version + '/moment/getFollowedMomentsByToken', require('./moment/getFollowedMomentsByToken'))
  app.use(version + '/moment/getRecommendMoments', require('./moment/getRecommendMoments'))
  app.use(version + '/moment/getMyMomentsByToken', require('./moment/getMyMomentsByToken'))
  app.use(version + '/moment/getMomentsByUserID', require('./moment/getMomentsByUserID'))
  app.use(version + '/moment/getMomentsByResourceID', require('./moment/getMomentsByResourceID'))
  app.use(version + '/moment/getMomentsByCommunityID', require('./moment/getMomentsByCommunityID'))
  // praise
  app.use(version + '/praises/praiseMoment', require('./praise/praiseMoment'))
  app.use(version + '/praises/unpraiseMoment', require('./praise/unpraiseMoment'))
  app.use(version + '/praises/getByUserID', require('./praise/getByUserID'))

  // comment
  app.use(version + '/comments/submit', require('./comment/submit'))
  app.use(version + '/comments/removeSubComment', require('./comment/removeSubComment')) 
  app.use(version + '/comments/getCommentByMomentID', require('./comment/getCommentByMomentID'))
  app.use(version + '/comments/getAllComments', require('./comment/getAllComments'))
  app.use(version + '/comments/removeCommentByMomentID', require('./comment/removeCommentByMomentID'))

  // community
  app.use(version + '/community/create', require('./community/create'))
  app.use(version + '/community/remove', require('./community/remove'))
  app.use(version + '/community/getCommunityByID', require('./community/getCommunityByID'))
  app.use(version + '/community/addUser', require('./community/addUser'))
  app.use(version + '/community/removeUser', require('./community/removeUser'))
  app.use(version + '/community/addMoment', require('./community/addMoment'))
  app.use(version + '/community/removeMoment', require('./community/removeMoment'))
  app.use(version + '/community/getAllCommunities', require('./community/getAllCommunities'))
  app.use(version + '/community/getCommunitiesByToken', require('./community/getCommunitiesByToken'))
  app.use(version + '/community/getRecommendCommunities', require('./community/getRecommendCommunities'))
  app.use(version + '/community/getUsersByCommunityID', require('./community/getUsersByCommunityID'))
  app.use(version + '/community/getMomentsByCommunityID', require('./community/getMomentsByCommunityID'))
  app.use(version + '/community/getCommunitiesByResourceID', require('./community/getCommunitiesByResourceID'))
}
