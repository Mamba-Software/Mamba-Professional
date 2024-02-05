"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onBonosDeleteForStripeProd = exports.onBonosUpdatedForStripeProd = exports.onBonosCreateForStripeProd = exports.webhookListenerConnect = exports.webhookListenerAccount = exports.stripeApi = void 0;
const serviceAccount = require('../service_key.json');
const admin = require("firebase-admin");
const functions = require("firebase-functions");
const v2_1 = require("firebase-functions/v2");
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://insights-books-app.firebaseio.com",
});
const express = require("express");
const constants_1 = require("./utils/constants");
const v2_2 = require("firebase-functions/v2");
const stripe_connect_1 = require("./stripe_connect/stripe_connect");
// import bodyParser = require('body-parser');
const hook_1 = require("./hooks/hook");
const one_time_payment_1 = require("./payment/one_time_payment");
const products_1 = require("./products/products");
const subscription_1 = require("./payment/subscription");
const transfer_funds_1 = require("./funds/transfer_funds");
(0, v2_2.setGlobalOptions)({ maxInstances: 10 });
const app = express();
// app.use(express.json());
admin.firestore().settings({ ignoreUndefinedProperties: true });
// Only for Testing purposes
app.get('/', (req, res) => {
    res.send('Hello World!');
});
/* --------------------------- Firebase Functions --------------------------- */
exports.stripeApi = functions.https.onRequest(app);
exports.webhookListenerAccount = functions.https.onRequest(async (request, res) => {
    try {
        let signingSecret = constants_1.webhookSecretForAccount;
        let sig = request.headers['stripe-signature'];
        let event = constants_1.stripe.webhooks.constructEvent(request.rawBody, sig, signingSecret);
        let result = await (0, hook_1.webhookHandler)(event);
        res.status(200).send(result);
    }
    catch (e) {
        v2_1.logger.error(e);
        res.status(400).send(e);
    }
});
exports.webhookListenerConnect = functions.https.onRequest(async (request, res) => {
    try {
        let signingSecret = constants_1.webhookSecretForConnect;
        let sig = request.headers['stripe-signature'];
        let event = constants_1.stripe.webhooks.constructEvent(request.rawBody, sig, signingSecret);
        let result = await (0, hook_1.webhookHandler)(event);
        res.status(200).send(result);
    }
    catch (e) {
        v2_1.logger.error(e);
        res.status(400).send(e);
    }
});
exports.onBonosCreateForStripeProd = functions.firestore.document('TestBrands/{brandId}/TestBonos/{bonoId}').onCreate(async (snap, context) => {
    var _a, _b, _c, _d, _e, _f, _g, _h;
    v2_1.logger.info('created a new bono');
    try {
        let brandData = await constants_1.brandCollection.doc(context.params.brandId).get();
        let productData = {
            productId: snap.id,
            brandId: context.params.brandId,
            brandName: (_a = brandData.data()) === null || _a === void 0 ? void 0 : _a.brandName,
            title: (_b = snap.data()) === null || _b === void 0 ? void 0 : _b.title,
            description: (_c = snap.data()) === null || _c === void 0 ? void 0 : _c.description,
            active: (_d = snap.data()) === null || _d === void 0 ? void 0 : _d.isActive,
            priceId: (_f = (_e = snap.data()) === null || _e === void 0 ? void 0 : _e.priceId) !== null && _f !== void 0 ? _f : null,
            price: ((_h = (_g = snap.data()) === null || _g === void 0 ? void 0 : _g.price) !== null && _h !== void 0 ? _h : 0) * 100,
        };
        (0, products_1.createProduct)(productData);
    }
    catch (e) {
        v2_1.logger.error(e);
    }
});
exports.onBonosUpdatedForStripe = functions.firestore.document('TestBrands/{brandId}/TestBonos/{bonoId}').onUpdate(async (snap, context) => {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m, _o;
    try {
        v2_1.logger.info('updated a bono');
        let brandData = await constants_1.brandCollection.doc(context.params.brandId).get();
        let productData = {
            productId: snap.after.id,
            brandId: context.params.brandId,
            brandName: (_a = brandData.data()) === null || _a === void 0 ? void 0 : _a.brandName,
            title: (_b = snap.after.data()) === null || _b === void 0 ? void 0 : _b.title,
            description: (_c = snap.after.data()) === null || _c === void 0 ? void 0 : _c.description,
            active: (_d = snap.after.data()) === null || _d === void 0 ? void 0 : _d.isActive,
            priceId: (_f = (_e = snap.after.data()) === null || _e === void 0 ? void 0 : _e.priceId) !== null && _f !== void 0 ? _f : null,
            price: ((_h = (_g = snap.after.data()) === null || _g === void 0 ? void 0 : _g.price) !== null && _h !== void 0 ? _h : 0) * 100,
        };
        (0, products_1.updateProduct)(productData);
        if (((_j = snap.before.data()) === null || _j === void 0 ? void 0 : _j.price) !== ((_k = snap.after.data()) === null || _k === void 0 ? void 0 : _k.price)) {
            (0, products_1.updatePrice)((_l = snap.after.data()) === null || _l === void 0 ? void 0 : _l.priceId, ((_o = (_m = snap.after.data()) === null || _m === void 0 ? void 0 : _m.price) !== null && _o !== void 0 ? _o : 0) * 100, snap.after.id);
        }
    }
    catch (e) {
        v2_1.logger.error(e);
    }
});
exports.onBonosDeleteForStripe = functions.firestore.document('TestBrands/{brandId}/TestBonos/{bonoId}').onDelete(async (snap, context) => {
    try {
        v2_1.logger.info('deleted a bono');
        (0, products_1.deleteProduct)(snap.id);
    }
    catch (e) {
        v2_1.logger.error(e);
    }
});
/* ------------------------------------------------------------ */
/*      For LocalTesting and Api Endpoints                       */
/* ------------------------------------------------------------ */
/* --------------------------- for webhook Testing -------------------------- */
app.post('/webhook/account', express.raw({ type: "application/json" }), async (req, res) => {
    let signingSecret = 'whsec_c889b3764c34648092334faed84db6b151f0fcc5b9d3fb7e5d1e3954cef84ed0';
    const sig = req.headers['stripe-signature'];
    let event = constants_1.stripe.webhooks.constructEvent(req.body, sig, signingSecret);
    let result = await (0, hook_1.webhookHandler)(event);
    res.send(result).status(200);
});
/* ---------------------- Create stripe connect account --------------------- */
app.get('/createAccount', async (req, res) => {
    if (req.query.userId === undefined || req.query.userName === undefined) {
        res.send('Missing parameters');
        return;
    }
    let result = await (0, stripe_connect_1.createAccount)(req.query.userId, req.query.userName, req.query.stripeAccountId);
    if (result) {
        res.send(result).status(200);
    }
    else {
        res.send('Error').status(400);
    }
});
/* ----------------------- create,delete or update a product ----------------------- */
// This is for local testing otherwise this function triggered when a bono is created,deleted or updated
app.post('/createUpdateProduct', async (req, res) => {
    //convert to json
    var _a, _b;
    console.log(req.body);
    if (req.body.productId === undefined || req.body.brandId === undefined || req.body.brandName === undefined || req.body.title === undefined || req.body.description === undefined || req.body.active === undefined) {
        res.send({
            message: 'Missing parameters', required: ['productId', 'brandId', 'brandName', 'title', 'description', 'price', 'active'], optional: ['updateProduct:true/false(by default false)']
        });
        return;
    }
    let productData = {
        productId: req.body.productId,
        brandId: req.body.brandId,
        brandName: req.body.brandName,
        title: req.body.title,
        description: req.body.description,
        active: req.body.active,
        priceId: (_a = req.body.priceId) !== null && _a !== void 0 ? _a : null,
        price: (_b = req.body.price) !== null && _b !== void 0 ? _b : null,
    };
    let result;
    if (req.body.updateProduct) {
        result = await (0, products_1.updateProduct)(productData);
    }
    else {
        result = await (0, products_1.createProduct)(productData);
    }
    if (result) {
        res.send(result).status(200);
    }
    else {
        res.send('Error').status(400);
    }
});
app.delete('/deleteProduct', async (req, res) => {
    if (req.query.productId === undefined) {
        res.send('Missing parameters');
        return;
    }
    let result = await (0, products_1.deleteProduct)(req.query.productId);
    if (result) {
        res.send(result).status(200);
    }
    else {
        res.send('Error').status(400);
    }
});
app.post('/updatePrice', async (req, res) => {
    if (req.body.priceId === undefined || req.body.amount === undefined || req.body.productId === undefined) {
        res.send({ message: 'Missing parameters', required: ['priceId', 'amount', 'productId'] });
        return;
    }
    let result = await (0, products_1.updatePrice)(req.body.priceId, req.body.amount, req.body.productId);
    if (result) {
        res.send(result).status(200);
    }
    else {
        res.send('Error').status(400);
    }
});
/* --------------------------- create payment intent -------------------------- */
app.get('/createPaymentIntent', async (req, res) => {
    if (req.query.amount === undefined || req.query.customerId === undefined) {
        res.send('Missing parameters');
        return;
    }
    let result = await (0, one_time_payment_1.createPaymentIntent)(req.query.amount, req.query.customerId, req.query.brandId);
    if (result) {
        res.send(result).status(200);
    }
    else {
        res.send('Error').status(400);
    }
});
/* ------------------- get payment methods for a user ------------------- */
app.get('/paymentMethod', async (req, res) => {
    if (req.query.userId === undefined) {
        res.send({
            message: 'Missing parameters', required: ['userId']
        });
        return;
    }
    let result = await (0, subscription_1.getPaymentMethods)(req.query.userId);
    res.send(result).status(200);
});
/* --------------------------- create subscription -------------------------- */
app.post('/createSubscription', async (req, res) => {
    console.log(req.body);
    if (req.body.productId === undefined || req.body.brandId === undefined || req.body.customerId === undefined || req.body.priceId === undefined || req.body.paymentMethodId === undefined) {
        res.status(400).send({
            message: 'Missing parameters', required: ['productId', 'brandId', 'customerId', 'priceId', 'paymentMethodId']
        });
        return;
    }
    let result = await (0, subscription_1.createSubscription)(req.body.customerId, req.body.priceId, req.body.brandId, req.body.productId, req.body.paymentMethodId);
    if (result.error == null) {
        res.send(result.data).status(200);
    }
    else {
        res.send(result.error).status(400);
    }
});
/* ---------------------------- transfer funds ---------------------------- */
app.get('/transferFunds', async (req, res) => {
    await (0, transfer_funds_1.transferFunds)();
    res.send('Function executed Successfully').status(200);
});
/* -------------------------------------------------------------------------- */
/*                                   Listener                                   */
/* -------------------------------------------------------------------------- */
// app.listen(3000, () => console.log('Listening on port 3000'));
//# sourceMappingURL=index.js.map