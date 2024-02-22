"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createSubscription = exports.getPaymentMethods = exports.cancelSubscription = void 0;
const constants_1 = require("../utils/constants");
const helper_functions_1 = require("../utils/helper_functions");
async function getPaymentMethods(userId) {
    var _a, _b, _c, _d;
    try {
        let customerData = await (0, helper_functions_1.getCustomerStripeData)(userId);
        if (!customerData) {
            return {
                message: 'No customer found',
                customerId: '',
                paymentMethods: [],
                responseStatus: 'Error',
                ephemeralKeysSecret: null,
            };
        }
        let paymentMethods = await constants_1.stripe.paymentMethods.list({
            customer: customerData.stripeCustomerId,
        });
        if (paymentMethods.data.length === 0) {
            //create customer and get ephemeral key
            let data = {
                customerId: customerData.stripeCustomerId,
                message: 'No payment methods found',
                paymentMethods: [],
                responseStatus: 'add_method',
                ephemeralKeysSecret: customerData.ephemeralKeysSecret,
            };
            return data;
        }
        else {
            let cards = [];
            for (let i = 0; i < paymentMethods.data.length; i++) {
                let methodData = {
                    id: paymentMethods.data[i].id,
                    type: paymentMethods.data[i].type,
                    card: {
                        brand: (_a = paymentMethods.data[i].card) === null || _a === void 0 ? void 0 : _a.brand,
                        last4: (_b = paymentMethods.data[i].card) === null || _b === void 0 ? void 0 : _b.last4,
                        exp_month: (_c = paymentMethods.data[i].card) === null || _c === void 0 ? void 0 : _c.exp_month,
                        exp_year: (_d = paymentMethods.data[i].card) === null || _d === void 0 ? void 0 : _d.exp_year,
                    }
                };
                cards.push(methodData);
            }
            let data = {
                message: 'Payment methods found',
                customerId: customerData.stripeCustomerId,
                paymentMethods: cards,
                responseStatus: 'select_method',
                ephemeralKeysSecret: customerData.ephemeralKeysSecret,
            };
            return data;
        }
    }
    catch (e) {
        console.log(e);
        return {
            message: `${e}`,
            customerId: '',
            paymentMethods: [],
            responseStatus: 'Error',
            ephemeralKeysSecret: null,
        };
    }
}
exports.getPaymentMethods = getPaymentMethods;
async function createSubscription(customerId, priceId, brandId, productId, paymentMethodId, purchaseId, expirationTime) {
    const v2_1 = require("firebase-functions/v2");
    try {
        let brandData = await constants_1.brandCollection.doc(brandId).get();
        let brandPaymentTerms = brandData.data().paymentTerms;
        let subscription = null;
        const now = new Date();
        let addMonth = 1;

        v2_1.logger.info(now.getDate());
        v2_1.logger.info(brandPaymentTerms);
        
        if (now.getDate() !== 1 && brandPaymentTerms !== null && brandPaymentTerms !== 2) {
        
        const startOfToday = Math.floor(new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime() / 1000);
        const fifthDayMonth = new Date(now.getFullYear(), now.getMonth(), 15);
        const firstOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const firstOfMonthMath = Math.floor(firstOfMonth.getTime() / 1000);
        if(expirationTime === '30') {
            addMonth = 1;
        }
        else if(expirationTime === '60')
        {
            addMonth = 2;
        }
        else if(expirationTime === '90') 
        {
            addMonth = 3;
        }
        const nextMonth = new Date(now.getFullYear(), now.getMonth() + addMonth, 1);
        const fifthDatMath = Math.floor(fifthDayMonth.getTime() / 1000);
        const billingCycleAnchor = Math.floor(nextMonth.getTime() / 1000);
        
        let dayTouse = 0;
        if(brandPaymentTerms === 0) {
            dayTouse = startOfToday;
        }
        else {
            if (now >= fifthDayMonth) {
                dayTouse = fifthDatMath;
            } else {
                dayTouse = firstOfMonthMath;
            }
        }

          subscription = await constants_1.stripe.subscriptions.create({
            customer: customerId,
            items: [
                { price: priceId },
            ],
            default_payment_method: paymentMethodId,
            backdate_start_date: dayTouse,
            billing_cycle_anchor: billingCycleAnchor,
            proration_behavior: 'create_prorations',
            metadata: {
                'brandId': brandId,
                'customerId': customerId,
                'productId': productId,
                'priceId': priceId,
                'purchaseId': purchaseId,
            }
        });
        }
        else {

          subscription = await constants_1.stripe.subscriptions.create({
            customer: customerId,
            items: [
                { price: priceId },
            ],
            default_payment_method: paymentMethodId,
            proration_behavior: 'none',
            metadata: {
                'brandId': brandId,
                'customerId': customerId,
                'productId': productId,
                'priceId': priceId,
                'purchaseId': purchaseId,
            }
        });
    }
        return { data: subscription, error: null };
    }
    catch (e) {
        console.log(e);
        return { data: null, error: e };
    }
}
exports.createSubscription = createSubscription;

async function cancelSubscription(subscriptionId) {
    try {
        let subscription = await constants_1.stripe.subscriptions.cancel(subscriptionId);
        return { data: subscription, error: null };
    }
    catch (e) {
        console.log(e);
        return { data: null, error: e };
    }
}
exports.cancelSubscription = cancelSubscription;
//# sourceMappingURL=subscription.js.map