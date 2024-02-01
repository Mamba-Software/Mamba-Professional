import Stripe from "stripe";
import * as admin from 'firebase-admin';
const secretKey: string = 'sk_test_51OWbhYIhy0dvY0FfOinR0wbP0UoVeu2WEr1ovTTw1crqSqNy51tza6koJuVUwkg8JdLYLStZIwCXKwwKQ9nmarSp00ykqCvB62';
export const userCollection = admin.firestore().collection('TestUsers');
export const brandCollection = admin.firestore().collection('TestBrands');
export const chargeAmount = admin.firestore().collection('TestChargeAmount');
export const invoicePaid = admin.firestore().collection('TestInvoicePaid');
export const commonLogs = admin.firestore().collection('TestCommonLogs');
export const bonos = 'TestBonos';
export const stripeAccounts = admin.firestore().collection('temp_stripe_accounts')
export const webhookSecretForAccount: string = 'whsec_yorPKf2zF1aEBzE0mmzY7uTUS0ZrUjHD';
export const webhookSecretForConnect: string = 'whsec_vcmpRO4pN61pwEEKcQNEKWwNfgyHU4k0';
export const stripe = new Stripe(
    secretKey,
    {
        apiVersion: "2023-10-16",
        typescript: true,
    }
);
