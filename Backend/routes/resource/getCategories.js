const express = require('express')
const router = express.Router()

router.get('/', function (req, res, next) {
    console.log("request to ../resources/getCategories")
    let category_array = ["书籍", "电影", "课程", "正念"]
    let categories = {
        categories: category_array
    }
    res.json({'success': 'true', 'data': categories})
})
module.exports = router