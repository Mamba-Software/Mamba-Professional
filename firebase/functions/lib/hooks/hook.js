"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.webhookHandler = void 0;
const v2_1 = require("firebase-functions/v2");
const constants_1 = require("../utils/constants");
const admin = require("firebase-admin");
/* default webhook handler */
async function webhookHandler(event) {
    try {
        console.log(`**${event.type}`);
        console.log(event.data.object);
        console.log(event.data.object.id);
        constants_1.commonLogs.add({
            event: event.type,
            data: event.data.object,
            timestamp: admin.firestore.Timestamp.now(),
        });
        switch (event.type) {
            case 'account.updated':
                return await accountUpdateHandler(event);
            case 'product.created':
                return await productCreatedUpdatedHandler(event);
            case 'product.updated':
                return await productCreatedUpdatedHandler(event);
            case 'charge.succeeded':
                return await chargeSuccessHandler(event);
            case 'invoice.paid':
                return await invoicePaidHandler(event);
            default:
                return `Not supported event type: ${event.type}`;
        }
    }
    catch (e) {
        console.log(e);
        v2_1.logger.error(e);
        return `Error: ${e}`;
    }
}
exports.webhookHandler = webhookHandler;
/* Trigger whenever stripe connect account update like user update address payment method etc  */
async function accountUpdateHandler(event) {
    try {
        let objectData = event.data.object;
        let metadata = objectData.metadata;
        if (metadata) {
            let userId = metadata.user_id;
            await constants_1.brandCollection.doc(userId).set({
                stripeAccountId: objectData.id,
                isVerified: objectData.payouts_enabled,
            }, { merge: true });
            await constants_1.stripeAccounts.doc(userId).set(objectData, { merge: true });
        }
        return 'Success';
    }
    catch (e) {
        console.log(e);
        v2_1.logger.error(e);
        return `Error: ${e}`;
    }
}
/* This will trigger when a customer is charged  */
async function chargeSuccessHandler(event) {
    constants_1.chargeAmount.add({
        amount: event.data.object.amount,
        data: event.data.object,
        timestamp: admin.firestore.Timestamp.now(),
    });
    try {
        let objectData = event.data.object;
        let metadata = objectData.metadata;
        if (metadata) {
            let amount = objectData.amount / 100;
            let brandId = metadata.brandId;
            if (!brandId) {
                return 'No brandId found';
            }
            await constants_1.brandCollection.doc(brandId).update({
                balance: admin.firestore.FieldValue.increment(amount),
                totalEarning: admin.firestore.FieldValue.increment(amount),
            });
        }
        return 'Success';
    }
    catch (e) {
        console.log(e);
        v2_1.logger.error(e);
        return `Error: ${e}`;
    }
}
/* this function work as same as [chargeSuccessHandler] but for sub */
async function invoicePaidHandler(event) {
    var _a;
    constants_1.invoicePaid.add({
        amount: event.data.object.amount_paid,
        data: event.data.object,
        timestamp: admin.firestore.Timestamp.now(),
        subscription: event.data.object.subscription,
    });
    try {
        let objectData = event.data.object;
        let metadata = (_a = objectData.subscription_details) === null || _a === void 0 ? void 0 : _a.metadata;
        if (metadata) {
            let amount = objectData.amount_paid / 100;
            let brandId = metadata.brandId;
            let purchaseId = metadata.purchaseId;
            await constants_1.brandCollection.doc(brandId).update({
                balance: admin.firestore.FieldValue.increment(amount),
                totalEarning: admin.firestore.FieldValue.increment(amount),
            });
            //TODO POSAR EL SUSCRIPTION ID
            await admin.firestore().collection('Purchases').doc(purchaseId).update({
                subscriptionStripe: event.data.object.subscription,
            });
        }
        return 'Success';
    }
    catch (e) {
        console.log(e);
        v2_1.logger.error(e);
        return `Error: ${e}`;
    }
}
async function productCreatedUpdatedHandler(event) {
    try {
        let objectData = event.data.object;
        let metadata = objectData.metadata;
        v2_1.logger.info(`product created or updated ${objectData.default_price} `);
        if (metadata) {
            let productId = metadata.productId;
            let brandId = metadata.brandId;
            await constants_1.brandCollection.doc(brandId).collection(constants_1.bonos).doc(productId).update({
                priceId: objectData.default_price,
                defaultPriceId: objectData.default_price,
            });
        }
        return 'Success';
    }
    catch (e) {
        console.log(e);
        v2_1.logger.error(e);
        return `Error: ${e}`;
    }
}
//# sourceMappingURL=hook.js.map