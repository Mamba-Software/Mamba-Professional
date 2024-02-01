"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.transferFunds = void 0;
const constants_1 = require("../utils/constants");
async function transferFunds() {
    var test = await constants_1.stripe.balance.retrieve({});
    console.log(test);
    // get all brands with balance is not null and balance > 0
    let snapshot = await constants_1.brandCollection.where('balance', '>', 0).get();
    let todayDate = new Date();
    let random = Math.floor(Math.random() * 1000);
    let transferGroup = `ORDER_${todayDate.getTime()}_${random}`;
    for (let i = 0; i < snapshot.docs.length; i++) {
        let brand = snapshot.docs[i].data();
        if (brand.stripeAccountId === undefined)
            continue;
        try {
            let transfer = await sendFunds(brand.balance, brand.stripeAccountId, transferGroup);
            if (transfer === true) {
                await constants_1.brandCollection.doc(snapshot.docs[i].id).update({
                    balance: 0,
                });
            }
            console.log(transfer);
        }
        catch (e) {
            console.log(e);
        }
    }
}
exports.transferFunds = transferFunds;
async function sendFunds(balance, destination, transferGroup) {
    try {
        let transfer = await constants_1.stripe.transfers.create({
            amount: balance * 100,
            currency: 'eur',
            destination: destination,
            transfer_group: transferGroup,
        });
        console.log(transfer);
        return true;
    }
    catch (e) {
        console.log(e);
        return false;
    }
}
//# sourceMappingURL=transfer_funds.js.map