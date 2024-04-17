"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updatePrice = exports.deleteProduct = exports.updateProduct = exports.createProduct = void 0;
const constants_1 = require("../utils/constants");
const v2_1 = require("firebase-functions/v2");
async function createProduct(productData, stripeAccountId) {
    var _a;
    try {
        let result = await productAvailable(productData.productId, stripeAccountId);
        if (result) {
            productData.active = true;
            return updateProduct(productData, stripeAccountId);
        }
        else {
            v2_1.logger.info('NEW CREATION');
            v2_1.logger.info(productData);
            let product = await constants_1.stripe.products.create({
                name: productData.title,
                // type: 'service',
                description: productData.description,
                active: productData.active,
                id: productData.productId,
                metadata: {
                    'productId': productData.productId,
                    'brandId': productData.brandId,
                    'brandName': productData.brandName,
                },
                default_price_data: {
                    currency: 'eur',
                    unit_amount: (_a = productData.price) !== null && _a !== void 0 ? _a : 0,
                    recurring: {
                        interval: 'month',
                        interval_count: productData.expirationTime === 30 ? 1 : productData.expirationTime === 60 ? 2 : productData.expirationTime === 90 ? 3 : 1,
                    },
                },
            }, {
                stripeAccount: stripeAccountId,
            });
            v2_1.logger.info(product);
            return { product };
        }
    }
    catch (e) {
        console.log(e);
        return e;
    }
}
exports.createProduct = createProduct;
async function productAvailable(productId, stripeAccountId) {
    try {
        await constants_1.stripe.products.retrieve(productId, { stripeAccount: stripeAccountId});
        return true;
    }
    catch (e) {
        return false;
    }
}
async function updateProduct(productData, stripeAccountId) {
    try {
        let product = await constants_1.stripe.products.update(productData.productId, {
            name: productData.title,
            description: productData.description,
            active: productData.active,
            metadata: {
                'productId': productData.productId,
                'brandId': productData.brandId,
                'brandName': productData.brandName,
            },  
        },  {stripeAccount: stripeAccountId});

            v2_1.logger.info(product);
        return { product };
    }
    catch (e) {
        console.log(e);
        return e;
    }
}
exports.updateProduct = updateProduct;
async function deleteProduct(productId,stripeAccountId) {
    try {
        let product = await constants_1.stripe.products.update(productId, { active: false}, {stripeAccount: stripeAccountId });
        return { product };
    }
    catch (e) {
        console.log(e);
        return e;
    }
}
exports.deleteProduct = deleteProduct;
async function updatePrice(priceId, amount, productId, expirationTime, stripeAccountId) {
    try {
        v2_1.logger.info(' EXPIRATION' + expirationTime);
        let product = await constants_1.stripe.products.retrieve(productId, { stripeAccount: stripeAccountId});
        let price = await constants_1.stripe.prices.create({
            unit_amount: amount,
            currency: 'eur',
            product: productId,
            recurring: {
                interval: 'month',
                interval_count: expirationTime === 30 ? 1 : expirationTime === 60 ? 2 : expirationTime === 90 ? 3 : 1,
            },
            metadata: product.metadata,
        }, {stripeAccount: stripeAccountId});
        await constants_1.stripe.products.update(productId, {
            default_price: price.id,
        },  {stripeAccount: stripeAccountId});
        await constants_1.stripe.prices.update(priceId, {
            active: false,
        },  {stripeAccount: stripeAccountId});
        return { price };
    }
    catch (e) {
        console.log(e);
        return e;
    }
}
exports.updatePrice = updatePrice;
//# sourceMappingURL=products.js.map