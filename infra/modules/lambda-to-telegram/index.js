// This Lambda function sends a message to a Telegram chat when an alarm is triggered in CloudWatch.
// npm install https

const https = require('https');

exports.handler = async (event) => {
    const botToken = process.env.TELEGRAM_BOT_TOKEN;
    const chatId = process.env.TELEGRAM_CHAT_ID;

    // Parse the incoming event
    const message = JSON.parse(event.Records[0].Sns.Message);

    // Extract the relevant fields
    const alarmName = message.AlarmName;
    const newState = message.NewStateValue;
    const oldState = message.OldStateValue;
    const reason = message.NewStateReason;
    const region = message.Region;
    const timestamp = event.Records[0].Sns.Timestamp;

    // Format the message
    const formattedMessage = `[${newState}] ${alarmName}\nNew State: ${newState}\nOld State: ${oldState}\nReason: ${reason}\nRegion: ${region}\nTimestamp: ${timestamp}`;

    const options = {
        hostname: 'api.telegram.org',
        port: 443,
        path: `/bot${botToken}/sendMessage`,
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    };

    const data = JSON.stringify({
        chat_id: chatId,
        text: formattedMessage
    });

    return new Promise((resolve, reject) => {
        const req = https.request(options, (res) => {
            res.setEncoding('utf8');
            res.on('data', () => {});
            res.on('end', () => {
                resolve('Message sent');
            });
        });

        req.on('error', (e) => {
            reject(e.message);
        });

        // send the request
        req.write(data);
        req.end();
    });
};