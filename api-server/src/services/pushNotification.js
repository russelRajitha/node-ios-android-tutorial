'use strict';
const admin = require('firebase-admin');
const { DeviceToken } = require('../models');

let fcmClient = null;

const initFirebase = () => {
    if (fcmClient) return fcmClient;
    try {
        const serviceAccount = require('../../firebase-service-account.json');
        if (!admin.apps.length) {
            admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
        }
        fcmClient = admin.messaging();
        console.log('[push] Firebase Admin initialised');
        return fcmClient;
    } catch (err) {
        console.error('[push] Failed to initialise Firebase Admin:', err.message);
        return null;
    }
};

const FCM_STALE_ERRORS = new Set([
    'messaging/registration-token-not-registered',
    'messaging/invalid-registration-token',
    'messaging/invalid-argument',
]);

const sendViaFCM = async (tokens, title, body, data) => {
    const messaging = initFirebase();
    if (!messaging || !tokens.length) return;

    const stringData = Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
    );

    const message = {
        tokens,
        notification: { title, body },
        data: stringData,
        android: {
            priority: 'high',
            notification: { sound: 'default', clickAction: 'OPEN_DEEP_LINK' },
        },
        apns: {
            payload: { aps: { sound: 'default' } },
        },
    };

    try {
        const response = await messaging.sendEachForMulticast(message);
        console.log(`[push/fcm] sent=${response.successCount} failed=${response.failureCount}`);

        const stale = [];
        response.responses.forEach((r, i) => {
            if (r.error && FCM_STALE_ERRORS.has(r.error.code)) stale.push(tokens[i]);
        });
        if (stale.length) {
            await DeviceToken.destroy({ where: { token: stale } });
            console.log(`[push/fcm] Removed ${stale.length} stale token(s)`);
        }
    } catch (err) {
        console.error('[push/fcm] sendEachForMulticast error:', err.message);
    }
};

const buildDeepLink = ({ orderId } = {}) =>
    orderId ? `app://notifications/${orderId}` : 'app://notifications';

const sendPushToUser = async (userId, title, body, data = {}) => {
    const deviceTokens = await DeviceToken.findAll({ where: { userId } });
    if (!deviceTokens.length) return;

    const payload = { ...data, deepLink: buildDeepLink(data) };
    const allTokens = deviceTokens.map((d) => d.token);

    await sendViaFCM(allTokens, title, body, payload);
};

module.exports = { sendPushToUser };