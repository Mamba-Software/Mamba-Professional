const serviceAccount = require('../service_key.json');
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

import { logger } from "firebase-functions/v2";
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
    databaseURL: "https://insights-books-app.firebaseio.com",
});

import * as express from 'express';
import { brandCollection, stripe, webhookSecretForAccount, webhookSecretForConnect } from './utils/constants';
import { Request, Response } from 'express';
import { setGlobalOptions } from "firebase-functions/v2";
import { createAccount } from './stripe_connect/stripe_connect';
// import bodyParser = require('body-parser');
import { webhookHandler } from './hooks/hook';
import { createPaymentIntent } from './payment/one_time_payment';
import { createProduct, deleteProduct, updatePrice, updateProduct } from './products/products';
import { ProductData } from './utils/types';
import { createSubscription, getPaymentMethods } from './payment/subscription';
import { transferFunds } from './funds/transfer_funds';
setGlobalOptions({ maxInstances: 10 });
const app = express();
// app.use(express.json());

admin.firestore().settings({ ignoreUndefinedProperties: true });
// Only for Testing purposes
app.get('/', (req: Request, res: Response) => {
    res.send('Hello World!');
});


/* --------------------------- Firebase Functions --------------------------- */
export const stripeApi = functions.https.onRequest(app);
export const webhookListenerAccount = functions.https.onRequest(async (request, res) => {
    try {
        let signingSecret = webhookSecretForAccount;
        let sig = request.headers['stripe-signature'] as string | string[] | Buffer;
        let event = stripe.webhooks.constructEvent(request.rawBody, sig, signingSecret);
        let result = await webhookHandler(event);
        res.status(200).send(result);
    } catch (e) {
        logger.error(e);
        res.status(400).send(e);
    }
});
export const webhookListenerConnect = functions.https.onRequest(async (request, res) => {
    try {
        let signingSecret = webhookSecretForConnect;
        let sig = request.headers['stripe-signature'] as string | string[] | Buffer;
        let event = stripe.webhooks.constructEvent(request.rawBody, sig, signingSecret);
        let result = await webhookHandler(event);
        res.status(200).send(result);
    } catch (e) {
        logger.error(e);
        res.status(400).send(e);
    }
});

//CHECKED BY JMF
export const onBonosCreateForStripe = functions.firestore.document('Brands/{brandId}/Bonos/{bonoId}').onCreate(async (snap, context) => {
    logger.info('created a new bono');
    try {
        let brandData = await brandCollection.doc(context.params.brandId).get();
        let productData: ProductData = {
            productId: snap.id,
            brandId: context.params.brandId,
            brandName: brandData.data()?.brandName,
            title: snap.data()?.title,
            description: snap.data()?.description,
            active: snap.data()?.isActive,
            priceId: snap.data()?.priceId ?? null,
            price: (snap.data()?.price ?? 0) * 100,

        };
        createProduct(
            productData
        );
    } catch (e) {
        logger.error(e);
    }
});
export const onBonosUpdatedForStripeProd = functions.firestore.document('Brands/{brandId}/Bonos/{bonoId}').onUpdate(async (snap, context) => {
    try {

        logger.info('updated a bono');
        let brandData = await brandCollection.doc(context.params.brandId).get();
        let productData: ProductData = {
            productId: snap.after.id,
            brandId: context.params.brandId,
            brandName: brandData.data()?.brandName,
            title: snap.after.data()?.title,
            description: snap.after.data()?.description,
            active: snap.after.data()?.isActive,
            priceId: snap.after.data()?.priceId ?? null,
            price: (snap.after.data()?.price ?? 0) * 100,
        };
        updateProduct(
            productData
        );
        if (snap.before.data()?.price !== snap.after.data()?.price) {
            updatePrice(
                snap.after.data()?.priceId, (snap.after.data()?.price ?? 0) * 100, snap.after.id
            );
        }
    } catch (e) {
        logger.error(e);
    }
});
export const onBonosDeleteForStripeProd = functions.firestore.document('Brands/{brandId}/Bonos/{bonoId}').onDelete(async (snap, context) => {
    try {
        logger.info('deleted a bono');
        deleteProduct(
            snap.id
        );
    } catch (e) {
        logger.error(e);
    }
});

/* ------------------------------------------------------------ */
/*      For LocalTesting and Api Endpoints                       */
/* ------------------------------------------------------------ */

/* --------------------------- for webhook Testing -------------------------- */
app.post('/webhook/account', express.raw({ type: "application/json" }), async (req: Request, res: Response) => {
    let signingSecret = 'whsec_c889b3764c34648092334faed84db6b151f0fcc5b9d3fb7e5d1e3954cef84ed0';
    const sig = req.headers['stripe-signature'] as string | string[] | Buffer;
    let event = stripe.webhooks.constructEvent(req.body, sig, signingSecret);
    let result = await webhookHandler(event);
    res.send(result).status(200);
});

/* ---------------------- Create stripe connect account --------------------- */
app.get('/createAccount', async (req: Request, res: Response) => {
    if (req.query.userId === undefined || req.query.userName === undefined) {
        res.send('Missing parameters');
        return;
    }
    let result = await createAccount(
        req.query.userId as string,
        req.query.userName as string,
        req.query.stripeAccountId as string
    );
    if (result) {

        res.send(result).status(200);
    } else {
        res.send('Error').status(400);
    }
});

/* ----------------------- create,delete or update a product ----------------------- */
// This is for local testing otherwise this function triggered when a bono is created,deleted or updated
app.post('/createUpdateProduct', async (req: Request, res: Response) => {
    //convert to json

    console.log(req.body);
    if (req.body.productId === undefined || req.body.brandId === undefined || req.body.brandName === undefined || req.body.title === undefined || req.body.description === undefined || req.body.active === undefined) {
        res.send({
            message: 'Missing parameters', required: ['productId', 'brandId', 'brandName', 'title', 'description', 'price', 'active'], optional: ['updateProduct:true/false(by default false)']
        });
        return;
    }
    let productData: ProductData = {
        productId: req.body.productId,
        brandId: req.body.brandId,
        brandName: req.body.brandName,
        title: req.body.title,
        description: req.body.description,
        active: req.body.active,
        priceId: req.body.priceId ?? null,
        price: req.body.price ?? null,
    }
    let result;
    if (req.body.updateProduct) {
        result = await updateProduct(
            productData,
        );
    } else {
        result = await createProduct(
            productData
        );
    }
    if (result) {
        res.send(result).status(200);
    } else {
        res.send('Error').status(400);
    }
});
app.delete('/deleteProduct', async (req: Request, res: Response) => {
    if (req.query.productId === undefined) {
        res.send('Missing parameters');
        return;
    }
    let result = await deleteProduct(
        req.query.productId as string,
    );
    if (result) {
        res.send(result).status(200);
    } else {
        res.send('Error').status(400);
    }
});

app.post('/updatePrice', async (req: Request, res: Response) => {

    if (req.body.priceId === undefined || req.body.amount === undefined || req.body.productId === undefined) {
        res.send({ message: 'Missing parameters', required: ['priceId', 'amount', 'productId'] });
        return;
    }
    let result = await updatePrice(
        req.body.priceId, req.body.amount, req.body.productId
    );
    if (result) {
        res.send(result).status(200);
    } else {
        res.send('Error').status(400);
    }
});


/* --------------------------- create payment intent -------------------------- */
app.get('/createPaymentIntent', async (req: Request, res: Response) => {
    if (req.query.amount === undefined || req.query.customerId === undefined) {
        res.send('Missing parameters');
        return;
    }
    let result = await createPaymentIntent(
        req.query.amount as unknown as number,
        req.query.customerId as string,
        req.query.brandId as string
    );
    if (result) {
        res.send(result).status(200);
    } else {
        res.send('Error').status(400);
    }
});

/* ------------------- get payment methods for a user ------------------- */
app.get('/paymentMethod', async (req: Request, res: Response) => {
    if (req.query.userId === undefined) {
        res.send({
            message: 'Missing parameters', required: ['userId']
        });
        return;
    }
    let result = await getPaymentMethods(
        req.query.userId as string,
    );
    res.send(result).status(200);
});

/* --------------------------- create subscription -------------------------- */
app.post('/createSubscription', async (req: Request, res: Response) => {
    console.log(req.body);
    if (req.body.productId === undefined || req.body.brandId === undefined || req.body.customerId === undefined || req.body.priceId === undefined || req.body.paymentMethodId === undefined) {
        res.status(400).send({
            message: 'Missing parameters', required: ['productId', 'brandId', 'customerId', 'priceId', 'paymentMethodId']
        });
        return;
    }
    let result = await createSubscription(
        req.body.customerId,
        req.body.priceId,
        req.body.brandId,
        req.body.productId,
        req.body.paymentMethodId
    );
    if (result.error == null) {
        res.send(result.data).status(200);
    } else {
        res.send(result.error).status(400);
    }
});
/* ---------------------------- transfer funds ---------------------------- */
app.get('/transferFunds', async (req: Request, res: Response) => {
  await  transferFunds();
    res.send('Function executed Successfully').status(200);
    
});

/* -------------------------------------------------------------------------- */
/*                                   Listener                                   */
/* -------------------------------------------------------------------------- */
// app.listen(3000, () => console.log('Listening on port 3000'));

