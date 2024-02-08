"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.stripe = exports.webhookSecretForConnect = exports.webhookSecretForAccount = exports.stripeAccounts = exports.bonos = exports.commonLogs = exports.invoicePaid = exports.chargeAmount = exports.brandCollection = exports.userCollection = void 0;
const stripe_1 = require("stripe");
const admin = require("firebase-admin");
const secretKey = 'sk_test_51OWbhYIhy0dvY0FfOinR0wbP0UoVeu2WEr1ovTTw1crqSqNy51tza6koJuVUwkg8JdLYLStZIwCXKwwKQ9nmarSp00ykqCvB62';
exports.userCollection = admin.firestore().collection('Users');
exports.brandCollection = admin.firestore().collection('Brands');
exports.locationCollection = admin.firestore().collection('Locations');
exports.chargeAmount = admin.firestore().collection('ChargeAmount');
exports.invoicePaid = admin.firestore().collection('InvoicePaid');
exports.commonLogs = admin.firestore().collection('CommonLogs');
exports.bonos = 'Bonos';
exports.stripeAccounts = admin.firestore().collection('stripe_accounts');
exports.webhookSecretForAccount = 'whsec_mrWp9CrwYoA3VO2nGSaNdYcQWUyA5mbN';
exports.webhookSecretForConnect = 'whsec_P66Yw68jtrUnZxYdKCVmeGwXkpOZ44EX';
exports.stripe = new stripe_1.default(secretKey, {
    apiVersion: "2023-10-16",
    typescript: false,
});
//# sourceMappingURL=constants.js.map