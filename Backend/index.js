const path = require('path')
const express = require('express')
const session = require('express-session')
const MongoStore = require('connect-mongo')(session)
// const flash = require('connect-flash')
const config = require('config-lite')(__dirname)
const routes = require('./routes')
const pkg = require('./package')
const https = require('https')
const app = express()
const fs = require('fs')
// 设置模板目录
// app.set('views', path.join(__dirname, 'views'))
// 设置模板引擎为 ejs
// app.set('view engine', 'ejs')

// 设置静态文件目录
app.use(express.static(path.join(__dirname, 'public')))
// session 中间件
app.use(session({
  name: config.session.key, // 设置 cookie 中保存 session id 的字段名称
  secret: config.session.secret, // 通过设置 secret 来计算 hash 值并放在 cookie 中，使产生的 signedCookie 防篡改
  resave: true, // 强制更新 session
  saveUninitialized: false, // 设置为 false，强制创建一个 session，即使用户未登录
  cookie: {
    maxAge: config.session.maxAge// 过期时间，过期后 cookie 中的 session id 自动删除
  },
  store: new MongoStore({// 将 session 存储到 mongodb
    url: config.mongodb// mongodb 地址
  })
}))
// flash 中间件，用来显示通知
// app.use(flash())

// 处理表单及文件上传的中间件
app.use(require('express-formidable')({
  uploadDir: path.join(__dirname, 'public/img'), // 上传文件目录
  keepExtensions: true// 保留后缀
}))
// 路由
routes(app)

// 监听端口，启动程序
//app.listen(config.port, function () {
//  // console.log(`${pkg.name} listening on port ${config.port}`)
//})

https.createServer({
  //key: fs.readFileSync('../../../backend-key/4119796_xinqing.today.key'),
  //cert: fs.readFileSync('../../../backend-key/4119796_xinqing.today.pem')

  key: fs.readFileSync('../../backend-key/4109152_xinqing.mysspku.com.key'),
  cert: fs.readFileSync('../../backend-key/4109152_xinqing.mysspku.com.pem')
}, app).listen(443, () => {
  console.log('https server listenning at 443 port...')
})

const http = require('http')
http.createServer(app).listen(80, () => {
  console.log('http server listening at 80 port...')
})

var aasa = fs.readFileSync('./.well-known/apple-app-site-association');
app.get('/apple-app-site-association', function(req, res, next) {
    console.log("Request to apple-app-site-association");
     res.set('content-type', 'application/pkcs7-mime');
     res.status(200).send(aasa);
});
