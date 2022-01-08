// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Firebase DataBase
const db = admin.firestore();

// Firebase collections
const isProduction = false;
const users = isProduction ? "Users" : "7777 Users";
const brands = isProduction ? "Brands" : "7777 Brands";
const events = isProduction ? "Events" : "7777 Events";
const locations = isProduction ? "Locations" : "7777 Locations";
const groupOfQuestions = isProduction ? "GroupOfQuestions" : "7777 GroupOfQuestions";
const questions = isProduction ? "Questions" : "7777 Questions";
const answers = isProduction ? "Answers" : "7777 Answers";
const conversations = isProduction ? "Conversations" : "7777 Conversations";
const messages = isProduction ? "Messages" : "7777 Messages";
const errors = isProduction ? "Errors" : "7777 Errors";
const requests = isProduction ? "Requests" : "7777 Requests";
const notifications = isProduction ? "Notifications" : "7777 Notifications";

// User Joins Brand
exports.userJoinsBrand = functions
    .region("europe-west1")
    .firestore
    .document("/"+users+"/{userId}/Brands/{brandId}")
    .onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const userId = context.params.userId;
      const brandId = context.params.brandId;
      functions.logger.log(
              "User with ID:",
              userId,
              "has joined Brand with ID:",
              userId
            );
      // Get Data of the User
      const userSnapshot = await db.collection(users).doc(userId).get();
      const userDoc = userSnapshot.data();
      functions.logger.log(
              "User Cover Data:",
              userDoc.name,
              userDoc.nick,
              userDoc.imageUrl,
              userDoc.isTrainer,
              userDoc.notificationToken,
            );
      // Add the User Cover Data to Users in Brands Collection
      await db.doc("/"+brands+"/"+brandId+"/Users/"+userId+"").set({
          "name": userDoc.name,
          "nick": userDoc.nick,
          "imageUrl": userDoc.imageUrl,
          "isTrainer": userDoc.isTrainer,
          "notificationToken": userDoc.notificationToken,
        });
      // Get Data of the Brand
      const brandSnapshot = await db.collection(brands).doc(brandId).get();
      const brandDoc = brandSnapshot.data();
      functions.logger.log(
              "Brand Cover Data:",
              brandDoc.name,
              brandDoc.logoUrl,
            );
      // Send Notification To User Joining Brand
      var payload = 0;
      if (userDoc.idioma == "es") {
        payload = {
            notification: {
              title: "Te has unido a "+brandDoc.name,
              body: "Consulta el calendario para participar en tu primera sesión",
            },
            data: {
              route: "SplashScreen",
            },
          };
      } else {
        payload = {
            notification: {
              title: "T'has unit a "+brandDoc.name,
              body: "Consulta el calendari per participar en la teva primera sessió",
            },
            data: {
              route: "SplashScreen",
            },
          };
      }
      functions.logger.log(
                "Payload",
                payload
              );
      var response = await admin.messaging().sendToDevice(userDoc.notificationToken, payload);
      functions.logger.log(
                "Response",
                response
              );
      // Send Notification To Brand Owner
      const adminSnapshot = await db.collection(users).doc(brandDoc.adminID).get();
      const adminDoc = adminSnapshot.data();
      functions.logger.log(
            "Owner Cover Data:",
            adminDoc.name,
            adminDoc.nick,
            adminDoc.imageUrl,
            adminDoc.isTrainer,
            adminDoc.notificationToken,
          );
      // TO DO: Aixo hauria de ser el length dels usuaris, aixi ya estaria contabilitzat l'ultim.
      let numberMembers = brandDoc.numberClients + brandDoc.numberClients;
      if (adminDoc.idioma == "es") {
        payload = {
              notification: {
                title: userDoc.name+" se ha unido a "+brandDoc.name,
                body: "Ya sois un total de "+numberMembers.toString()+" miembros",
              },
              data: {
                route: "SplashScreen",
              },
            };
      } else {
        payload = {
              notification: {
                title: userDoc.name+" s'ha unit a "+brandDoc.name,
                body: "Ja sou un total de "+numberMembers.toString()+" membres",
              },
              data: {
                route: "SplashScreen",
              },
        }
      }
      functions.logger.log(
                  "Payload",
                  payload
                );
      response = await admin.messaging().sendToDevice(adminDoc.notificationToken, payload);
      functions.logger.log(
                  "Response",
                  response
                );
      return null;
    });