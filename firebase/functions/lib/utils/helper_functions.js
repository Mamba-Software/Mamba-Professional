"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCustomerStripeData = void 0;
const constants_1 = require("./constants");
const v2_1 = require("firebase-functions/v2");
async function getCustomerStripeData(customerId, brandId, stripeAccountId) {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j;
    let customerDocInfo = await constants_1.userCollection.doc(customerId).get();
    let customerDoc = await constants_1.userCollection.doc(customerId).collection('Brands').doc(brandId).collection('StripeData').doc('StripeData').get();
    v2_1.logger.info( "Customer Document Info:");
    v2_1.logger.info(customerDoc.data());
    if (!customerDocInfo.exists) {
        return null;
    }
    if ((_a = customerDoc.data()) === null || _a === void 0 ? void 0 : _a.stripeCustomerId) {
        v2_1.logger.info( "EXISTS!");
        let customerExists = await checkCustomer((_b = customerDoc.data()) === null || _b === void 0 ? void 0 : _b.stripeCustomerId, stripeAccountId);
        if (customerExists) {
            let ephemeralKeysSecret = await getEphemeralKey((_c = customerDoc.data()) === null || _c === void 0 ? void 0 : _c.stripeCustomerId, stripeAccountId);
            let setupIntentKey = await getSetupIntent((_d = customerDoc.data()) === null || _d === void 0 ? void 0 : _d.stripeCustomerId, stripeAccountId);
            let customerData = {
                stripeCustomerId: (_e = customerDoc.data()) === null || _e === void 0 ? void 0 : _e.stripeCustomerId,
                ephemeralKeysSecret: ephemeralKeysSecret !== null && ephemeralKeysSecret !== void 0 ? ephemeralKeysSecret : '',
                clientSecret: setupIntentKey !== null && setupIntentKey !== void 0 ? setupIntentKey : ''
            };
            return customerData;
        }
    }
    const customer = await constants_1.stripe.customers.create({
        email: (_f = customerDocInfo.data()) === null || _f === void 0 ? void 0 : _f.email,
        name: `${(_g = customerDocInfo.data()) === null || _g === void 0 ? void 0 : _g.name}`,
    }, { stripeAccount: stripeAccountId});
    let result = await Promise.all([
        getEphemeralKey(customer.id, stripeAccountId),
        getSetupIntent(customer.id, stripeAccountId)
    ]);
    let customerData = {
        stripeCustomerId: customer.id,
        ephemeralKeysSecret: (_h = result[0]) !== null && _h !== void 0 ? _h : '',
        clientSecret: (_j = result[1]) !== null && _j !== void 0 ? _j : ''
    };
    await constants_1.userCollection.doc(customerId).collection('Brands').doc(brandId).collection('StripeData').doc('StripeData').set(customerData, { merge: true });
    return customerData;
}
exports.getCustomerStripeData = getCustomerStripeData;
async function checkCustomer(customerId, stripeAccountId) {
    try {
        v2_1.logger.info( "Customer Stripe");
        v2_1.logger.info(customerId);
        v2_1.logger.info(stripeAccountId);
        let customerStripeData = await constants_1.stripe.customers.retrieve(customerId,  { stripeAccount: stripeAccountId});
        v2_1.logger.info( "Customer Stripe");
    v2_1.logger.info(customerStripeData);
        if (customerStripeData.deleted) {
            return false;
        }
        return true;
    }
    catch (error) {
        return false;
    }
}
async function getEphemeralKey(customerId, stripeAccountId) {
    let result = await constants_1.stripe.ephemeralKeys.create({ customer: customerId }, { apiVersion: '2023-10-16', stripeAccount: stripeAccountId });
    return result.secret;
}
async function getSetupIntent(customerId, stripeAccountId) {
    let result = await constants_1.stripe.setupIntents.create({
        customer: customerId,
    },  { stripeAccount: stripeAccountId});
    return result.client_secret;
}
//# sourceMappingURL=helper_functions.js.map