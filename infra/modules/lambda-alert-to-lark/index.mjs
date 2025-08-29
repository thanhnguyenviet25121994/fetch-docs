// Lambda function to send CloudWatch alarms to Lark
// npm install https
// npm install aws-sdk
// zip -r lambda-alert-to-lark.zip ./*

import https from 'https';
import { parse } from 'url';
import AWS from 'aws-sdk';

const ecs = new AWS.ECS();

export const handler = async (event) => {
    const webhookUrl = process.env.LARK_WEBHOOK_URL;

    // Parse the incoming event
    const message = JSON.parse(event.Records[0].Sns.Message);

    // Extract the relevant fields
    const alarmName = message.AlarmName;
    const newState = message.NewStateValue;
    const oldState = message.OldStateValue;
    const reason = message.NewStateReason;
    const region = message.Region;
    const timestamp = event.Records[0].Sns.Timestamp;

    // Check if the transition is from INSUFFICIENT_DATA to OK or OK to INSUFFICIENT_DATA
    if ((oldState === 'INSUFFICIENT_DATA' && newState === 'OK') || (oldState === 'OK' && newState === 'INSUFFICIENT_DATA')) {
        console.log('Transition from INSUFFICIENT_DATA to OK or OK to INSUFFICIENT_DATA, no notification sent.');
        return;
    }

    // Define icons for each state
    const icons = {
        OK: '✅',
        ALARM: '❌',
    };

    // Get the icon based on the newState
    const icon = icons[newState] || '';

    // Format the message
    const formattedMessage = `New State: ${newState}\nOld State: ${oldState}\nReason: ${reason}\nRegion: ${region}\nTimestamp: ${timestamp}`;

    const postData = JSON.stringify({
        'msg_type': 'text',
        'content': {
            'title': `${icon} [${newState}] ${alarmName}`,
            'text': formattedMessage
        }
    });

    const options = parse(webhookUrl);
    options.method = 'POST';
    options.headers = {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
    };

    // Send notification to Lark
    await new Promise((resolve, reject) => {
        const req = https.request(options, (res) => {
            res.setEncoding('utf8');
            res.on('data', () => {});
            res.on('end', () => {
                resolve('Message sent to Lark');
            });
        });

        req.on('error', (e) => {
            reject(e.message);
        });

        req.write(postData);
        req.end();
    });

    // Restart ECS service if the alarm is in ALARM state and the alarm name matches the specified condition
    if (newState === 'ALARM' && alarmName === '[HIGH]dev-ERROR-Count-greater-than-5-in-5-minutes (TEST ONLY)') {
        const response = await ecs.updateService({
            cluster: 'dev-service-game-client',
            service: 'service-game-client',
            forceNewDeployment: true
        }).promise();

        console.log('ECS service restarted:', response);
    }
};