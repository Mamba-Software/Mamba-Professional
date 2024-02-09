


import { brandCollection, stripe } from '../utils/constants';

import { logger } from "firebase-functions/v2";


export async function createAccount( userId: string, userName: string, stripeAccountId?: string): Promise<any> {
    try {
        let account;
        if (!stripeAccountId) {
            account = await stripe.accounts.create({
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
            brandCollection.doc(userId).set({
                stripeAccountId: account.id,
                verified: false,
            }, { merge: true });
            console.log(account);

        }
        const accountLinks = await stripe.accountLinks.create({
            account: stripeAccountId ?? account?.id ?? '',
            refresh_url: 'https://www.mambafitness.es/reauth',
            return_url: 'https://www.mambafitness.es/return',
            type: stripeAccountId ? 'account_update' : 'account_onboarding',
        });
        console.log(accountLinks);
        return accountLinks;
    } catch (e) {
        logger.error(e);
        console.log(e);
        return e;
    }
}

// Email
// DOB ,Address,street address, city, province, postal code, 
// Phone number
// Industry , Website 
//Bank account
//
//