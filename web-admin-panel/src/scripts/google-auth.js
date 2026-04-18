/**
 * One-time Google OAuth2 setup script.
 * Run: node src/scripts/google-auth.js
 *
 * This will:
 * 1. Open a Google authorization URL in your browser
 * 2. Ask you to paste the authorization code
 * 3. Print the refresh token to add to your .env
 */

'use strict';

require('dotenv').config();
const { google } = require('googleapis');
const readline = require('readline');

const CLIENT_ID     = process.env.GOOGLE_OAUTH_CLIENT_ID;
const CLIENT_SECRET = process.env.GOOGLE_OAUTH_CLIENT_SECRET;

if (!CLIENT_ID || !CLIENT_SECRET) {
  console.error('\n❌ Missing GOOGLE_OAUTH_CLIENT_ID or GOOGLE_OAUTH_CLIENT_SECRET in .env\n');
  console.log('Steps:');
  console.log('1. Go to https://console.cloud.google.com');
  console.log('2. APIs & Services → Credentials → Create OAuth 2.0 Client ID');
  console.log('3. Application type: Desktop App');
  console.log('4. Copy Client ID and Client Secret to .env');
  process.exit(1);
}

const oauth2Client = new google.auth.OAuth2(
  CLIENT_ID,
  CLIENT_SECRET,
  'urn:ietf:wg:oauth:2.0:oob'
);

const authUrl = oauth2Client.generateAuthUrl({
  access_type: 'offline',
  scope: ['https://www.googleapis.com/auth/drive.file'],
  prompt: 'consent',
});

console.log('\n=== Google Drive OAuth2 Setup ===\n');
console.log('1. Open this URL in your browser:\n');
console.log(authUrl);
console.log('\n2. Sign in with your Google account and click Allow');
console.log('3. Copy the authorization code shown\n');

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

rl.question('Paste the authorization code here: ', async (code) => {
  rl.close();
  try {
    const { tokens } = await oauth2Client.getToken(code.trim());
    console.log('\n✅ Success! Add these to your .env file:\n');
    console.log(`GOOGLE_OAUTH_REFRESH_TOKEN=${tokens.refresh_token}`);
    console.log('\nThen set GOOGLE_DRIVE_ENABLED=true and run a backup to test.');
  } catch (err) {
    console.error('\n❌ Failed to get token:', err.message);
  }
});
