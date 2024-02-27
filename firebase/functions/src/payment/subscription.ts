import { stripe } from "../utils/constants";
import { getCustomerStripeData } from "../utils/helper_functions";
import { CustomerMethodsData } from "../utils/types";

export async function getPaymentMethods(userId: string): Promise<CustomerMethodsData> {
    try {
        let customerData = await getCustomerStripeData(userId);
        if (!customerData) {
            return {
                message: 'No customer found',
                customerId: '',
                paymentMethods: [],
                responseStatus: 'Error',
                ephemeralKeysSecret: null,
            }
        }
        let paymentMethods = await stripe.paymentMethods.list({
            customer: customerData.stripeCustomerId,
        });
        if (paymentMethods.data.length === 0) {
            //create customer and get ephemeral key
            let data: CustomerMethodsData = {
                customerId: customerData.stripeCustomerId,
                message: 'No payment methods found',
                paymentMethods: [],
                responseStatus: 'add_method',
                ephemeralKeysSecret: customerData.ephemeralKeysSecret,
            }
            return data;
        }
        else {
            let cards = [];
            for (let i = 0; i < paymentMethods.data.length; i++) {
                let methodData = {
                    id: paymentMethods.data[i].id,
                    type: paymentMethods.data[i].type,
                    card: {
                        brand: paymentMethods.data[i].card?.brand,
                        last4: paymentMethods.data[i].card?.last4,
                        exp_month: paymentMethods.data[i].card?.exp_month,
                        exp_year: paymentMethods.data[i].card?.exp_year,
                    }
                }
                cards.push(methodData);
            }
            let data: CustomerMethodsData = {
                message: 'Payment methods found',
                customerId: customerData.stripeCustomerId,
                paymentMethods: cards,
                responseStatus: 'select_method',
                ephemeralKeysSecret: customerData.ephemeralKeysSecret,
            }
            return data;
        }
    } catch (e) {
        console.log(e);
        return {
            message: `${e}`,
            customerId: '',
            paymentMethods: [],
            responseStatus: 'Error',
            ephemeralKeysSecret: null,
        }
    }
}

export async function createSubscription(customerId: string, priceId: string, brandId: string, productId: string, paymentMethodId: string): Promise<any> {
    try {
        let subscription = await stripe.subscriptions.create({
            customer: customerId,
            items: [
                { price: priceId },
            ],
            default_payment_method: paymentMethodId,
            metadata: {
                'brandId': brandId,
                'customerId': customerId,
                'productId': productId,
                'priceId': priceId,
            }
        });
        return { data: subscription, error: null }
    } catch (e) {
        console.log(e);
        return { data: null, error: e }

    }
}

