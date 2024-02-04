import { stripe, userCollection } from "./constants";
import { CustomerStripeData } from "./types";

export async function getCustomerStripeData(customerId: string): Promise<CustomerStripeData | null> {
    let customerDoc = await userCollection.doc(customerId).get();
    if (!customerDoc.exists) {
        return null;
    }
    if (customerDoc.data()?.stripeCustomerId) {
        let customerExists = await checkCustomer(customerDoc.data()?.stripeCustomerId);
        if (customerExists) {
            let ephemeralKeysSecret = await getEphemeralKey(customerDoc.data()?.stripeCustomerId);
            let setupIntentKey = await getSetupIntent(customerDoc.data()?.stripeCustomerId);
            let customerData: CustomerStripeData = {
                stripeCustomerId: customerDoc.data()?.stripeCustomerId,
                ephemeralKeysSecret: ephemeralKeysSecret ?? '',
                clientSecret: setupIntentKey ?? ''
            }
            return customerData;
        }

    }

    const customer = await stripe.customers.create({
        email: customerDoc.data()?.email,
        name: `${customerDoc.data()?.name}`,
    });
    let result = await Promise.all([
        getEphemeralKey(customer.id),
        getSetupIntent(customer.id)
    ])
    let customerData: CustomerStripeData = {
        stripeCustomerId: customer.id,
        ephemeralKeysSecret: result[0] ?? '',
        clientSecret: result[1] ?? ''
    }
    await userCollection.doc(customerId).update(customerData);
    return customerData;

}

async function checkCustomer(customerId: string): Promise<boolean> {
    try {
        let customerStripeData = await stripe.customers.retrieve(customerId);
        if (customerStripeData.deleted) { return false; }
        return true;
    } catch (error) { return false; }

}
async function getEphemeralKey(customerId: string) {
    let result = await stripe.ephemeralKeys.create(
        { customer: customerId },
        { apiVersion: '2023-10-16' }
    );
    return result.secret;
}
async function getSetupIntent(customerId: string) {
    let result = await stripe.setupIntents.create({
        customer: customerId,
    })
    return result.client_secret;
}