简易的VC续期通知网站，后端采用NODE.JS 

使用方法：下载到你的目录，直接bash i.sh按照提示即可

实现TG和PUSHPLUS每隔半个小时通知

TG和pushplus提醒配置分别在server.js第85、87行以及第144行

访问地址http://ip:3000

使用方法：进入网站之后，点击添加机器，填上机器最近的续期时间，并添加。网页会自动计算下一次续期时间，当续期时间超过七天的时候，机器列表中的renew按钮变成绿色，点击renew之后按钮变灰色，系统自动将当前续期时间更新到数据库并计算下次续期时间。

在配置好TG和PUSHplus参数的情况下，当下次续期时间到时，每半个小时自动推送提醒，直至续期之后再次点击renew进入下次周期。

本程序仅能提醒续期，无法实现自动续期，续期还得自己手动登录官网续期。


本程序因自己使用，没有做任何的安全过滤。
