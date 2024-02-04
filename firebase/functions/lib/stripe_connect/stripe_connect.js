"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createAccount = void 0;
const constants_1 = require("../utils/constants");
const v2_1 = require("firebase-functions/v2");
async function createAccount(userId, userName, stripeAccountId) {
    var _a;
    try {
        let account;
        if (!stripeAccountId) {
            account = await constants_1.stripe.accounts.create({
                country: 'ES',
                type: 'custom',
                individual: {
                    first_name: userName,
                    last_name: userName,
                    dob: {
                        day: 1,
                        month: 1,
                        year: 1990,
                    },
                    // email: email,
                    phone: '+34666777888',
                    id_number: '000000000',
                    address: {
                        country: 'ES',
                        state: 'Barcelona',
                        city: 'Barcelona',
                        line1: 'Carrer de la Diputació, 238',
                        postal_code: '08007',
                    },
                },
                tos_acceptance: {
                    date: Math.floor(Date.now() / 1000),
                    ip: '192.168.20.20',
                },
                // external_account: {
                //     object: 'bank_account',
                //     country: 'ES',
                //     currency: 'eur',
                //     account_holder_name: userName,
                //     account_holder_type: 'individual',
                //     routing_number: '110000000',
                //     account_number: '000222222227',
                // },
                business_type: 'individual',
                business_profile: {
                    mcc: '8999',
                    url: 'https://techanion.com',
                },
                // email: email,
                metadata: {
                    'user_id': userId,
                    'user_name': userName,
                    // 'email': email
                },
                capabilities: {
                    card_payments: {
                        requested: true,
                    },
                    transfers: {
                        requested: true,
                    },
                },
            });
            constants_1.brandCollection.doc(userId).set({
                stripeAccountId: account.id,
                verified: false,
            }, { merge: true });
            console.log(account);
        }
        const accountLinks = await constants_1.stripe.accountLinks.create({
            account: (_a = stripeAccountId !== null && stripeAccountId !== void 0 ? stripeAccountId : account === null || account === void 0 ? void 0 : account.id) !== null && _a !== void 0 ? _a : '',
            refresh_url: 'https://www.mambafitness.es/reauth',
            return_url: 'https://www.mambafitness.es/return',
            type: stripeAccountId ? 'account_update' : 'account_onboarding',
        });
        console.log(accountLinks);
        return accountLinks;
    }
    catch (e) {
        v2_1.logger.error(e);
        console.log(e);
        return e;
    }
}
exports.createAccount = createAccount;
// Email
// DOB ,Address,street address, city, province, postal code, 
// Phone number
// Industry , Website 
//Bank account
//
//
//# sourceMappingURL=stripe_connect.js.map