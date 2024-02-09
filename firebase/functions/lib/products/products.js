"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updatePrice = exports.deleteProduct = exports.updateProduct = exports.createProduct = void 0;
const constants_1 = require("../utils/constants");
async function createProduct(productData) {
    var _a;
    try {
        let result = await productAvailable(productData.productId);
        if (result) {
            productData.active = true;
            return updateProduct(productData);
        }
        else {
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
                    },
                }
            });
            return { product };
        }
    }
    catch (e) {
        console.log(e);
        return e;
    }
}
exports.createProduct = createProduct;
async function productAvailable(productId) {
    try {
        await constants_1.stripe.products.retrieve(productId);
        return true;
    }
    catch (e) {
        return false;
    }
}
async function updateProduct(productData) {
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
        });
        return { product };
    }
    catch (e) {
        console.log(e);
        return e;
    }
}
exports.updateProduct = updateProduct;
async function deleteProduct(productId) {
    try {
        let product = await constants_1.stripe.products.update(productId, { active: false });
        return { product };
    }
    catch (e) {
        console.log(e);
        return e;
    }
}
exports.deleteProduct = deleteProduct;
async function updatePrice(priceId, amount, productId) {
    try {
        let product = await constants_1.stripe.products.retrieve(productId);
        let price = await constants_1.stripe.prices.create({
            unit_amount: amount,
            currency: 'eur',
            product: productId,
            recurring: {
                interval: 'month',
            },
            metadata: product.metadata,
        });
        await constants_1.stripe.products.update(productId, {
            default_price: price.id,
        });
        await constants_1.stripe.prices.update(priceId, {
            active: false,
        });
        return { price };
    }
    catch (e) {
        console.log(e);
        return e;
    }
}
exports.updatePrice = updatePrice;
//# sourceMappingURL=products.js.map