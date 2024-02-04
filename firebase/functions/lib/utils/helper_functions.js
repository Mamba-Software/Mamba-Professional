"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCustomerStripeData = void 0;
const constants_1 = require("./constants");
async function getCustomerStripeData(customerId) {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j;
    let customerDoc = await constants_1.userCollection.doc(customerId).get();
    if (!customerDoc.exists) {
        return null;
    }
    if ((_a = customerDoc.data()) === null || _a === void 0 ? void 0 : _a.stripeCustomerId) {
        let customerExists = await checkCustomer((_b = customerDoc.data()) === null || _b === void 0 ? void 0 : _b.stripeCustomerId);
        if (customerExists) {
            let ephemeralKeysSecret = await getEphemeralKey((_c = customerDoc.data()) === null || _c === void 0 ? void 0 : _c.stripeCustomerId);
            let setupIntentKey = await getSetupIntent((_d = customerDoc.data()) === null || _d === void 0 ? void 0 : _d.stripeCustomerId);
            let customerData = {
                stripeCustomerId: (_e = customerDoc.data()) === null || _e === void 0 ? void 0 : _e.stripeCustomerId,
                ephemeralKeysSecret: ephemeralKeysSecret !== null && ephemeralKeysSecret !== void 0 ? ephemeralKeysSecret : '',
                clientSecret: setupIntentKey !== null && setupIntentKey !== void 0 ? setupIntentKey : ''
            };
            return customerData;
        }
    }
    const customer = await constants_1.stripe.customers.create({
        email: (_f = customerDoc.data()) === null || _f === void 0 ? void 0 : _f.email,
        name: `${(_g = customerDoc.data()) === null || _g === void 0 ? void 0 : _g.name}`,
    });
    let result = await Promise.all([
        getEphemeralKey(customer.id),
        getSetupIntent(customer.id)
    ]);
    let customerData = {
        stripeCustomerId: customer.id,
        ephemeralKeysSecret: (_h = result[0]) !== null && _h !== void 0 ? _h : '',
        clientSecret: (_j = result[1]) !== null && _j !== void 0 ? _j : ''
    };
    await constants_1.userCollection.doc(customerId).update(customerData);
    return customerData;
}
exports.getCustomerStripeData = getCustomerStripeData;
async function checkCustomer(customerId) {
    try {
        let customerStripeData = await constants_1.stripe.customers.retrieve(customerId);
        if (customerStripeData.deleted) {
            return false;
        }
        return true;
    }
    catch (error) {
        return false;
    }
}
async function getEphemeralKey(customerId) {
    let result = await constants_1.stripe.ephemeralKeys.create({ customer: customerId }, { apiVersion: '2023-10-16' });
    return result.secret;
}
async function getSetupIntent(customerId) {
    let result = await constants_1.stripe.setupIntents.create({
        customer: customerId,
    });
    return result.client_secret;
}
//# sourceMappingURL=helper_functions.js.map