const gm = require('gm')
gm('../public/upload_1bca99078f514f8a37f0c47d54ee58d6.jpg')
  .draw('image Over 460, 460, 140, 140 "../public/upload_0a59e190c294a1768479b55f5b00793d.jpg"')
  .write('../output/${Date.now()}.jpg', function(err) {
    if (!err) {
      // console.log('done')
    }else {
      // console.log(err.message || "出错了！");
    }
  })