// Lambda function to send CloudWatch Logs to Lark
// npm install https

const https = require('https');
const url = require('url');
const zlib = require('zlib');
const { Buffer } = require('buffer');

exports.handler = async (event) => {
    const payload = Buffer.from(event.awslogs.data, 'base64');
    const parsed = JSON.parse(zlib.gunzipSync(payload).toString('utf8'));
    const logEvents = parsed.logEvents;

    const webhookUrl = process.env.LARK_WEBHOOK_URL;

    for (let logEvent of logEvents) {
        // Extract timestamp from the message
        const timestampMatch = logEvent.message.match(/(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z)/);
        const timestamp = timestampMatch ? timestampMatch[1] : 'Unknown';
    
        // Extract Request ID from the message
        const requestIdMatch = logEvent.message.match(/Request ID: (\w+-\w+)/);
        const requestId = requestIdMatch ? requestIdMatch[1] : 'Unknown';
    
        const postData = JSON.stringify({
            'msg_type': 'text',
            'content': {
                'Timestamp': timestamp, // Use the extracted timestamp
                'RequestID': requestId, // Use the extracted Request ID
                'ErrorMessage': logEvent.message
            }
        });
    
        const options = url.parse(webhookUrl);
        options.method = 'POST';
        options.headers = {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(postData)
        };
    
        await new Promise((resolve, reject) => {
            const req = https.request(options, (res) => {
                res.setEncoding('utf8');
                res.on('data', (chunk) => {
                    console.log('Response from Lark:', chunk); // Log the response
                    resolve(chunk);
                });
            });
    
            req.on('error', (e) => {
                reject(e.message);
            });
    
            // send the request
            req.write(postData);
            req.end();
        });
    }
};