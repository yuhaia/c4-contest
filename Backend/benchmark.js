var siege = require('siege')
siege('sudo node index.js')// node server.js为服务启动脚本
.wait(3000)//延迟时间 
.on(1250)//被压测的服务端口
.concurrent(100)//并发数
.for(100).times //或者.seconds 
.get('https://xinqing.today/v1.0/users/getAllUsers')//需要压测的页面
.attack()//执行压测
