export type CustomerStripeData = {
    stripeCustomerId: string;
    ephemeralKeysSecret: string;
    clientSecret: string;
}

export type paymentIntentData = {
    stripeCustomerId: string,
    ephemeralKeysSecret: string,
    paymentClientSecret: string,
    setupClientSecret: string,
}


export type ProductData = {
    productId: string;
    priceId: string | null;
    price: number|null;
    title: string;
    description: string;
    active: boolean;
    brandId: string;
    brandName: string;
}

export type CustomerMethodsData={
    customerId:string;
    message:string,
    paymentMethods:any[];
    responseStatus:string;
    ephemeralKeysSecret:string|null;
}