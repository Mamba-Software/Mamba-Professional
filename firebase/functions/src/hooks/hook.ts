
import Stripe from "stripe";
import { logger } from "firebase-functions/v2";
import { bonos, brandCollection, chargeAmount, commonLogs, invoicePaid, stripeAccounts } from "../utils/constants";
import * as admin from 'firebase-admin';

/* default webhook handler */
export async function webhookHandler(event: any) {
    try {
        console.log(`**${event.type}`);
        console.log(event.data.object);
        console.log((event.data.object as { id: string }).id);
        commonLogs.add(
            {
                event: event.type,
                data: event.data.object,
                timestamp: admin.firestore.Timestamp.now(),
            }
        )
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

    } catch (e) {
        console.log(e);
        logger.error(e);
        return `Error: ${e}`;
    }
}
/* Trigger whenever stripe connect account update like user update address payment method etc  */

async function accountUpdateHandler(event: any) {
    try {
        let objectData: Stripe.Account = event.data.object;
        let metadata: Stripe.Metadata | undefined = objectData.metadata;
        if (metadata) {
            let userId = metadata.user_id;
            await brandCollection.doc(userId).set({
                stripeAccountId: objectData.id,
                isVerified: objectData.payouts_enabled,
            }, { merge: true });
            await stripeAccounts.doc(userId).set(objectData, { merge: true });
        }
        return 'Success';
    } catch (e) {
        console.log(e);
        logger.error(e);
        return `Error: ${e}`;
    }

}

/* This will trigger when a customer is charged  */

async function chargeSuccessHandler(event: any) {
    chargeAmount.add({
        amount: event.data.object.amount,
        data: event.data.object,
        timestamp: admin.firestore.Timestamp.now(),
    });
    try {
        let objectData: Stripe.Charge = event.data.object;
        let metadata: Stripe.Metadata | undefined = objectData.metadata;
        if (metadata) {
            let amount = objectData.amount / 100;
            let brandId = metadata.brandId;
            if (!brandId) {
                return 'No brandId found';
            }
            await brandCollection.doc(brandId).update({
                balance: admin.firestore.FieldValue.increment(amount),
                totalEarning: admin.firestore.FieldValue.increment(amount),
            });
        }
        return 'Success';
    } catch (e) {
        console.log(e);
        logger.error(e);
        return `Error: ${e}`;
    }

}

/* this function work as same as [chargeSuccessHandler] but for sub */

async function invoicePaidHandler(event: any) {
    invoicePaid.add({
        amount: event.data.object.amount_paid,
        data: event.data.object,
        timestamp: admin.firestore.Timestamp.now(),
    });
    try {
        let objectData: Stripe.Invoice = event.data.object;
        let metadata: Stripe.Metadata | null | undefined = objectData.subscription_details?.metadata;
        if (metadata) {
            let amount = objectData.amount_paid / 100;
            let brandId = metadata.brandId;
            await brandCollection.doc(brandId).update({
                balance: admin.firestore.FieldValue.increment(amount),
                totalEarning: admin.firestore.FieldValue.increment(amount),
            });

        }
        return 'Success';
    } catch (e) {
        console.log(e);
        logger.error(e);
        return `Error: ${e}`;
    }

}

async function productCreatedUpdatedHandler(event: any) {
    try {
        let objectData: Stripe.Product = event.data.object;
        let metadata: Stripe.Metadata | undefined = objectData.metadata;
        logger.info(`product created or updated ${objectData.default_price} `);
        if (metadata) {
            let productId = metadata.productId;
            let brandId = metadata.brandId;

            await brandCollection.doc(brandId).collection(bonos).doc(productId).update({
                priceId: objectData.default_price,
                defaultPriceId: objectData.default_price,
            });
        }
        return 'Success';
    } catch (e) {
        console.log(e);
        logger.error(e);
        return `Error: ${e}`;
    }
}