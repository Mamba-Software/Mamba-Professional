"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createPaymentIntent = void 0;
const constants_1 = require("../utils/constants");
const helper_functions_1 = require("../utils/helper_functions");
async function createPaymentIntent(amount, customerId, brandId) {
    var _a, _b, _c, _d, _e, _f;
    let customerData = null;
    if (customerId) {
        customerData = await (0, helper_functions_1.getCustomerStripeData)(customerId);
    }
    const paymentIntent = await constants_1.stripe.paymentIntents.create({
        amount: amount,
        customer: customerData === null || customerData === void 0 ? void 0 : customerData.stripeCustomerId,
        currency: 'eur',
        automatic_payment_methods: {
            enabled: true,
        },
        metadata: {
            customerId: customerId,
            brandId: brandId,
            amount: amount
        },
    });
    let setupIntent = await constants_1.stripe.setupIntents.create({
        customer: (_a = customerData === null || customerData === void 0 ? void 0 : customerData.stripeCustomerId) !== null && _a !== void 0 ? _a : '',
    });
    let ephemeralKeys = await constants_1.stripe.ephemeralKeys.create({
        customer: (_b = customerData === null || customerData === void 0 ? void 0 : customerData.stripeCustomerId) !== null && _b !== void 0 ? _b : '',
    }, { apiVersion: '2023-10-16' });
    return {
        stripeCustomerId: (_c = customerData === null || customerData === void 0 ? void 0 : customerData.stripeCustomerId) !== null && _c !== void 0 ? _c : '',
        ephemeralKeysSecret: (_d = ephemeralKeys === null || ephemeralKeys === void 0 ? void 0 : ephemeralKeys.secret) !== null && _d !== void 0 ? _d : '',
        setupClientSecret: (_e = setupIntent === null || setupIntent === void 0 ? void 0 : setupIntent.client_secret) !== null && _e !== void 0 ? _e : '',
        paymentClientSecret: (_f = paymentIntent.client_secret) !== null && _f !== void 0 ? _f : ''
    };
}
exports.createPaymentIntent = createPaymentIntent;
//# sourceMappingURL=one_time_payment.js.map