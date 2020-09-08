const community = require('./community')

const User = require('../lib/mongo').User

module.exports = {
  // 注册一个用户
  create: function create(user) {
    return User.create(user).exec()
  },

  getUserByOpenID: function getUserByOpenID(openid) {
    return User.findOne({openid: openid})
  },
  getUserByID: function getUserByID(user_id) {
    return User.findOne({_id: user_id})
  },
  getAllUsers: function getAllUsers() {
    return User.find({}).sort({ "_id": -1 })
  },
  // 通过用户名获取用户信息
  getUserByName: function getUserByName(name) {
    return User
      .findOne({ name: name })
  },
  // 可以获取所有的c 然后add一个 再set一下；
  // 也可以直接addToSet操作直接更新数组
  // createCommunity: function createCommunity(user_id, communities_id) {
  //   return User.findOneAndUpdate({_id: user_id}, {$set: {communities_id: communities_id}})
  // },

  addCommunity: function addCommunity(user_id, community_id) {
    return User.update({_id: user_id}, {$addToSet: {"communities_id": community_id}})
  },

  removeCommunity: function removeCommunity(user_id, community_id) {
    return User.update({_id: user_id}, {$pull: {"communities_id": community_id}})
  },

  // 通过用户ID获取用户信息
  getUserByID: function getUserByID(user_id) {
    return User
      .findOne({ _id: user_id })
  },

  // 通过众多_id获取users
  getUsersByIDArray: function getUsersByIDArray(idArray) {
    return User
      .find({ _id: { "$in": idArray } })
  },

  update: function update(_id, user) {
    return User.findOneAndUpdate({ _id: _id }, { $set: user }, {
      new: true
    })
  },

  // 更新user_id这位用户的粉丝数目
  updateFansNumberByID: function updateFansNumberByID(user_id, fans_number) {
    return User.findOneAndUpdate({ _id: user_id }, { $set: { fans_number: fans_number } }, { new: true })
  },
  // 更新user_id这位用户关注的用户数目
  updateFollowNumberByID: function updateFollowNumberByID(user_id, follow_number) {
    return User.findOneAndUpdate({ _id: user_id }, { $set: { follow_number: follow_number } }, { new: true })
  },

  updateCoins: function updateCoins(user_id, coins) {
    return User.findOneAndUpdate({_id: user_id}, {$set: {coins: coins}})
  },

  updateMomentNumber: function updateMomentNumber(user_id, moment_number) {
    return User.findOneAndUpdate({_id: user_id}, {$set: {moment_number: moment_number}})
  },

  search: function search(reg) {
    return User.find({$or: [{name: {$regex: reg}}, {bio: {$regex: reg}}]})
  },

  changeUrl: function changeUrl(_id, avatar) {
    return User.findOneAndUpdate({_id: _id}, {$set: {avatar: avatar}})
  },
  
}
