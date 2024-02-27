import { stripe } from "../utils/constants";
import { getCustomerStripeData } from "../utils/helper_functions";
import { CustomerStripeData, paymentIntentData } from "../utils/types";

export async function createPaymentIntent(amount: number, customerId: string | null, brandId: string | null): Promise<paymentIntentData> {
    let customerData: CustomerStripeData | null = null;
    if (customerId) { customerData = await getCustomerStripeData(customerId); }
    const paymentIntent = await stripe.paymentIntents.create({
        amount: amount,
        customer: customerData?.stripeCustomerId,
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
    let setupIntent = await stripe.setupIntents.create({
        customer: customerData?.stripeCustomerId ?? '',
    });
    let ephemeralKeys = await stripe.ephemeralKeys.create({
        customer: customerData?.stripeCustomerId ?? '',
    }, { apiVersion: '2023-10-16' });
    return {
        stripeCustomerId: customerData?.stripeCustomerId ?? '',
        ephemeralKeysSecret: ephemeralKeys?.secret ?? '',
        setupClientSecret: setupIntent?.client_secret ?? '',
        paymentClientSecret: paymentIntent.client_secret ?? ''
    }
}