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
            console.log('BRAND ' + userId);
            const brandDocRef = constants_1.brandCollection.doc(userId);
            const brandDoc = await brandDocRef.get();
            const brandDocData = brandDoc.data();
            console.log(brandDocData);
            console.log('USER' + brandDocData.adminID);
            const userDocRef = constants_1.userCollection.doc(brandDocData.adminID);
            const userDoc = await userDocRef.get();
            const userDocData = userDoc.data();
            console.log('LOCATION');
            const locationDocRef = constants_1.locationCollection.doc(brandDocData.baseLocation);
            const locationDoc = await locationDocRef.get();
            const locationDocData = locationDoc.data();
            const [day, month, year] = userDocData.dateOfBirth.split("-");
            account = await constants_1.stripe.accounts.create({
                country: 'ES',
                type: 'custom',
                individual: {
                    first_name: userDocData.firstName,
                    last_name: userDocData.lastName,
                    email: userDocData.email,
                    dob: {
                        day: day,
                        month: month,
                        year: year,
                    }, //PROPIETARIO DE LA MARCA
                    // email: email,
                    phone: '+34677909194',
                    //id_number: '000000000',
                    address: {
                        country: 'ES',
                        state: locationDocData.city,
                        city: locationDocData.city,
                        line1: locationDocData.street + locationDocData.streetNumber != 'N/A'? ',' + locationDocData.streetNumber : '',
                        postal_code: locationDocData.zipCode,
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
                    mcc: '7997', //TODO
                    url: 'https://mambafitness.es/',
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
                isVerified: false,
                stripeActivated: true,
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