import { stripe } from "../utils/constants";
import { ProductData } from "../utils/types";

export async function createProduct(productData: ProductData): Promise<{ product: any } | any> {
    try {
        let result: boolean = await productAvailable(productData.productId);
        if (result) {

            productData.active = true;
            return updateProduct(productData)

        } else {
            let product = await stripe.products.create({
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
                    unit_amount: productData.price ?? 0,
                    recurring: {
                        interval: 'month',
                    },
                }
            });
            return { product };
        }
    } catch (e) {
        console.log(e);
        return e;
    }
}
async function productAvailable(productId: string): Promise<boolean> {
    try {
        await stripe.products.retrieve(productId);
        return true;
    } catch (e) {
        return false;
    }
}

export async function updateProduct(productData: ProductData,): Promise<{ product: any, } | any> {
    try {

        let product = await stripe.products.update(productData.productId, {
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
    } catch (e) {
        console.log(e);
        return e;
    }
}
export async function deleteProduct(productId: string,): Promise<{ product: any, } | any> {
    try {
        let product = await stripe.products.update(
            productId,
            { active: false }
        );
        return { product };
    } catch (e) {
        console.log(e);
        return e;
    }
}

export async function updatePrice(priceId: string, amount: number, productId: string): Promise<{ price: any, } | any> {
    try {
        let product = await stripe.products.retrieve(productId);

        let price = await stripe.prices.create({
            unit_amount: amount,
            currency: 'eur',
            product: productId,
            recurring: {
                interval: 'month',
            },

            metadata: product.metadata,

        });
        await stripe.products.update(productId, {
            default_price: price.id,
        });
        await stripe.prices.update(priceId, {
            active: false,
        });
        return { price };
    } catch (e) {
        console.log(e);
        return e;
    }


}