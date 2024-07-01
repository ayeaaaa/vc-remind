const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const axios = require('axios');
const { Telegraf } = require('telegraf');
const schedule = require('node-schedule');
const app = express();
const port = 3000;

// 初始化数据库，使用持久化的数据库文件
const db = new sqlite3.Database('./machines.db');

// 创建机器表（如果不存在）
db.serialize(() => {
    db.run("CREATE TABLE IF NOT EXISTS machines (id INTEGER PRIMARY KEY, name TEXT, expiry_date DATE)");
});

// 中间件
app.use(express.json());

// 设置静态文件目录
app.use(express.static(path.join(__dirname, 'public')));

// 获取所有机器的续期状态
app.get('/api/machines', (req, res) => {
    db.all("SELECT * FROM machines", (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ machines: rows });
    });
});

// 添加或更新机器的续期状态
app.post('/api/machines', (req, res) => {
    const { id, name, expiry_date } = req.body;
    db.run("REPLACE INTO machines (id, name, expiry_date) VALUES (?, ?, ?)", [id, name, expiry_date], function(err) {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ message: 'Machine updated', id: this.lastID });
    });
});

// 删除机器
app.delete('/api/machines/:id', (req, res) => {
    const { id } = req.params;
    db.run("DELETE FROM machines WHERE id = ?", id, function(err) {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ message: 'Machine deleted', changes: this.changes });
    });
});

// 续期机器
app.post('/api/machines/:id/renew', (req, res) => {
    const { id } = req.params;
    const { expiry_date } = req.body;
    db.run("UPDATE machines SET expiry_date = ? WHERE id = ?", [expiry_date, id], function(err) {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ message: 'Machine renewed', changes: this.changes });
    });
});

// 捕获所有其他路由，返回 `index.html`
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Telegram Bot 设置
const token = '您的 Telegram Chat TOKEN';
const bot = new Telegraf(token);
const chatId = '您的 Telegram Chat ID'; // 您的 Telegram Chat ID

// 设置定时任务每分钟发送提醒
schedule.scheduleJob('*/30 * * * *', async () => {
    try {
        const machines = await fetchMachines();
        machines.forEach(machine => {
            const nextRenewalDate = addDays(new Date(machine.expiry_date), 7);
            const currentDate = new Date();
            const renewalReminderDate = addDays(new Date(machine.expiry_date), 7);
            
			
			// 将日期部分设置为相同以便比较
            currentDate.setHours(0, 0, 0, 0);
            renewalReminderDate.setHours(0, 0, 0, 0);

            console.log(`当前日期时间: ${currentDate}, 续期提醒日期: ${renewalReminderDate}`);
			
            if (currentDate.getTime() === renewalReminderDate.getTime()) {
                const message = `提醒：机器 ${machine.name} 的续期日期 ${machine.expiry_date} 即将到期，请及时处理。`;
                console.log(`发送提醒消息: ${message}`);
                bot.telegram.sendMessage(chatId, message);
                sendPushPlusMessage(message);
            }
        });
    } catch (error) {
        console.error('发送提醒时出错：', error);
    }
});

// 启动 Express 服务器
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});

// 辅助函数：获取所有机器
function fetchMachines() {
    return new Promise((resolve, reject) => {
        db.all("SELECT * FROM machines", (err, rows) => {
            if (err) {
                reject(err);
                return;
            }
            resolve(rows);
        });
    });
}

// 辅助函数：在日期上添加天数
function addDays(date, days) {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
}

// 辅助函数：推送消息到 PushPlus
function sendPushPlusMessage(message) {
    const pushplusToken = 'PushPlus Token'; // 替换为你的 PushPlus Token
    const url = `http://www.pushplus.plus/send?token=${pushplusToken}&title=续期提醒&content=${encodeURIComponent(message)}`;
    
    axios.post(url)
        .then(response => {
            console.log('PushPlus 消息发送成功:', response.data);
        })
        .catch(error => {
            console.error('PushPlus 消息发送失败:', error);
        });
}
