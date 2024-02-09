import { brandCollection, stripe } from "../utils/constants";



export async function transferFunds() {

    var test=await stripe.balance.retrieve({});
    console.log(test);
  


    // get all brands with balance is not null and balance > 0
    let snapshot = await brandCollection.where('balance', '>', 0).get();
    let todayDate = new Date();
    let random = Math.floor(Math.random() * 1000);
    let transferGroup = `ORDER_${todayDate.getTime()}_${random}`;




    for (let i = 0; i < snapshot.docs.length; i++) {
        let brand = snapshot.docs[i].data();
        if (brand.stripeAccountId === undefined) continue;

        try {
            let transfer = await sendFunds(brand.balance, brand.stripeAccountId, transferGroup);
            if (transfer === true) {
                await brandCollection.doc(snapshot.docs[i].id).update({
                    balance: 0,
                });
            }
            console.log(transfer);
        } catch (e) {
            console.log(e);
        }
    }
}


async function sendFunds(balance: number, destination: string, transferGroup: string): Promise<boolean> {
    try {
        let transfer = await stripe.transfers.create({
            amount: balance * 100,
            currency: 'eur',
            destination: destination,
            transfer_group: transferGroup,
        });
        console.log(transfer);
        return true;
    } catch (e) {
        console.log(e);
        return false;
    }
}
