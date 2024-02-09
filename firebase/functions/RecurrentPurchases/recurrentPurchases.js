


// Daily Notification For Bonos
//exports.scheduledCheckBonoFunction= functions
//.region("europe-west1")
//.pubsub
//.schedule('every day 5:00')
//.timeZone('Europe/Madrid')
//.onRun( async (context) => {
    exports.scheduledCheckBonoFunctionOnCall = functions
      .region("europe-west1")
      .https
      .onCall(async (data, context) => {

        const today = new Date();
    
        // Ejecutar subfunciones
        await processRegularPurchases();
        //await processDirectAndRecurrentPurchases();
    
        functions.logger.log("Función ejecutada correctamente", today);
        return { result: "Success", executionDate: today.toISOString() };

      });


// Subfunción para procesar las Purchases normales
    async function processRegularPurchases() {
    const purchasesRef = db.collection('Purchases');
    const snapshot = await purchasesRef
        .where('isActive', '==', true)
        .where('directPurchase', 'in', [false, null])
        .where('brandId', '==', '1d16285c-54e8-4a6a-bd1f-ba7071c72774')
        .get();

    for (const doc of snapshot.docs) {
        const purchase = doc.data();
        let { gracePeriod, isRecurrent } = purchase;

        // Restar un día del período de gracia
        gracePeriod = (gracePeriod || 0) - 1;

        // Preparar el objeto de actualización
        const updateData = {
        gracePeriod: gracePeriod <= 0 ? 0 : gracePeriod,
        isActive: gracePeriod > 0,
        };

        // Si es recurrente y el período de gracia es <= 0, desactivar también la recurrencia
        if (isRecurrent && gracePeriod <= 0) {
        updateData.isActiveRecurrency = false;
        }

        functions.logger.log("Compra", purchase);
        functions.logger.log("Actualización", updateData);

        // Actualizar la Purchase
        //await doc.ref.update(updateData);
    }
    }
  
    // Subfunción para procesar las Purchases directas y recurrentes
    async function processDirectAndRecurrentPurchases() {
    const purchasesRef = db.collection('Purchases');
    const snapshot = await purchasesRef
        .where('directPurchase', '==', true)
        .where('isActiveRecurrency', '==', true)
        .get();

    for (const doc of snapshot.docs) {
        const purchase = doc.data();
        const { expirationDate, purchasedAt, purchasesGroupId } = purchase;
        let shouldCreateNewPurchase = false;

        if (expirationDate > 0) {
        // Lógica para cuando expirationDate es mayor que 0
        const expirationDateTime = new Date(purchasedAt.toDate().getTime() + expirationDate * 24 * 60 * 60 * 1000);
        shouldCreateNewPurchase = today >= expirationDateTime;
        } else {
        // Lógica para cuando expirationDate es 0 y estamos en día 1 del mes
        shouldCreateNewPurchase = today.getDate() === 1;
        }

        if (shouldCreateNewPurchase) {
        // Crear nuevo registro en la colección Purchases
        // ... Aquí iría tu lógica para obtener las características de la colección Brand/brandId o Bonos/bonoId si es necesario
        const newPurchaseData = {
            // ... Propiedades copiadas o actualizadas de la Purchase original
            directPurchase: false,
            purchasedAt: admin.firestore.Timestamp.fromDate(new Date()), // La fecha actual
            // ... Otros campos como gracePeriod, etc.
        };

        // Añadir la nueva Purchase a la base de datos
        const newDocRef = await purchasesRef.add(newPurchaseData);

        // Añadir el ID del nuevo documento al array groupPurchases en Purchases/purchasesGroupId
        const groupRef = db.collection('Purchases').doc(purchasesGroupId);
        const groupDoc = await groupRef.get();
        if (groupDoc.exists) {
            const groupData = groupDoc.data();
            const groupPurchases = groupData.groupPurchases || [];
            groupPurchases.push(newDocRef.id);
            await groupRef.update({ groupPurchases });
        }

        // Desactivar la recurrencia en la Purchase original
        await doc.ref.update({ isActiveRecurrency: false });
        }
    }
    }
    