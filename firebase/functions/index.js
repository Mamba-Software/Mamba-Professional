// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Required NPM Packages
const uuidv4 = require("uuid")

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
const rooms = isProduction ? "Rooms" : "7777 Rooms";
const conversations = isProduction ? "Conversations" : "7777 Conversations";
const messages = isProduction ? "Messages" : "7777 Messages";
const errors = isProduction ? "Errors" : "7777 Errors";
const requests = isProduction ? "Requests" : "7777 Requests";

// User Joins Brand
exports.userJoinsBrand = functions
    .region("europe-west1")
    .firestore
    .document("/"+brands+"/{brandId}/Users/{userId}")
    .onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const brandId = context.params.brandId;
      const userId = context.params.userId;
      functions.logger.log(
              "User with ID:",
              userId,
              "has joined Brand with ID:",
              brandId
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
      // Get Data of the Brand
      const brandSnapshot = await db.collection(brands).doc(brandId).get();
      const brandDoc = brandSnapshot.data();
      functions.logger.log(
          "Brand Cover Data:",
          brandDoc,
        );
      // Add the User Cover Data to Users in Brands Collection
      let date = new Date();
      let day = date.getDate();
      let month = date.getMonth() + 1;
      if (month < 10) {
        month = "0"+month;
      }
      let year = date.getFullYear().toString();
      let result = year.slice(2, 4);
      var formatted = day+"-"+month+"-"+result;
      await db.doc("/"+users+"/"+userId+"/Brands/"+brandId+"").set({
        "name": brandDoc.name,
        "logoUrl": brandDoc.logoUrl,
        "dateJoined": formatted,
        "myMonthlySessions": 0,
        "myTotalSessions": 0,
      });
      functions.logger.log(
                "userId",
                userId,
              );
      // Brand Was Just Created By Admin
      if (brandDoc.adminID == userId) {
        if (userDoc.idioma == "es") {
        payload = {
                notification: {
                  title: "Has creado tu marca "+brandDoc.name,
                  body: "Ahora podrás usar todas las funcionalidades de calendarización, control y gestión que ofrece MAMBA",
                },
                data: {
                  route: "SplashScreen1",
                },
              };
        } else {
          payload = {
                notification: {
                  title: "Has creat la teva marca "+brandDoc.name,
                  body: "Ahora podrás usar todas las funcionalidades de calendarización, control y gestión que ofrece MAMBA",
                },
                data: {
                  route: "SplashScreen1",
                },
          }
        }
        functions.logger.log(
                    "Payload",
                    payload
                  );
        response = await admin.messaging().sendToDevice(userDoc.notificationToken, payload);
        functions.logger.log(
                    "Response",
                    response
                  );
      } else {
      // Someone just joined the Brand
      // Send Notification To User Joining Brand
        var payload = 0;
        if (userDoc.idioma == "es") {
          payload = {
              notification: {
                title: "Te has unido a "+brandDoc.name,
                body: "Consulta el calendario para participar en tu primera sesión",
              },
              data: {
                route: "SplashScreen1",
              },
            };
        } else {
          payload = {
              notification: {
                title: "T'has unit a "+brandDoc.name,
                body: "Consulta el calendari per participar en la teva primera sessió",
              },
              data: {
                route: "SplashScreen1",
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
                  route: "SplashScreen2",
                },
              };
        } else {
          payload = {
                notification: {
                  title: userDoc.name+" s'ha unit a "+brandDoc.name,
                  body: "Ja sou un total de "+numberMembers.toString()+" membres",
                },
                data: {
                  route: "SplashScreen2",
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
      }
      return null;
    });

// User Leaves Brand
exports.userLeavesBrand = functions
    .region("europe-west1")
    .firestore
    .document("/"+brands+"/{brandId}/Users/{userId}")
    .onDelete( async (snap, context) => {
      // Get the value of the context triggers.
      const brandId = context.params.brandId;
      const userId = context.params.userId;
      functions.logger.log(
              "User with ID:",
              userId,
              "has left Brand with ID:",
              brandId
            );
      // Get Data of Deleted User
      const userDoc = snap.data();
      // Get Data of the Brand
      const brandSnapshot = await db.collection(brands).doc(brandId).get();
      const brandDoc = brandSnapshot.data();
      functions.logger.log(
          "Brand Cover Data:",
          brandDoc,
        );
      // Delete Brand in User´s Brand Subcollection
      await db.collection(users).doc(userId).collection("Brands").doc(brandId).delete();
      // Send Notification to Brand Owners
      let numberMembers = brandDoc.numberClients + brandDoc.numberClients;
      const brandOwnersSnapshot = await db.collection(brands)
        .doc(brandId)
        .collection("Users")
        .where("role", "=", 1)
        .get();
      for (var i in brandOwnersSnapshot.docs) {
        const brandOwnersDoc = brandOwnersSnapshot.docs[i].data();
        functions.logger.log(
            "Brand Owners Data:",
            brandOwnersDoc
          );
        if (brandOwnersDoc.idioma == "es") {
            payload = {
              notification: {
                title: userDoc.name+" ha abandonado a "+brandDoc.name,
                body: "Ahora sois un total de "+numberMembers.toString()+" miembros",
              },
              data: {
                route: "SplashScreen2",
              },
            };
          } else {
            payload = {
              notification: {
                title: userDoc.name+" ha abandonat a "+brandDoc.name,
                body: "Ara sou un total de "+numberMembers.toString()+" membres",
              },
              data: {
                route: "SplashScreen2",
              },
            }
          }
          functions.logger.log(
              "Payload",
              payload
            );
          const notificationToken = brandOwnersDoc.notificationToken;
          functions.logger.log(
              "Notification Token",
              notificationToken
            );
          const response = await admin.messaging().sendToDevice(notificationToken, payload);
          functions.logger.log(
            "Response",
            response
          );
      }
      return null;
    });


// User Adds Location
exports.userAddsLocation = functions
    .region("europe-west1")
    .firestore
    .document("/"+locations+"/{locationId}")
    .onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const locationId = context.params.locationId;
      // Get Data of the Location
      const locationSnapshot = await db.collection(locations).doc(locationId).get();
      const locationDoc = locationSnapshot.data();
      functions.logger.log(
            "Location Data:",
            locationDoc
          );
      // Add Location to Brands Collection
      await db.doc("/"+brands+"/"+locationDoc.brandID+"/Locations/"+locationId+"").set({
         "isBaseLocation": locationDoc.isBaseLocation,
         "description": locationDoc.description,
         "latitude": locationDoc.latitude,
         "longitude": locationDoc.longitude,
      });
      return null;
    });

// User Deletes Location
exports.userDeletesLocation = functions
    .region("europe-west1")
    .firestore
    .document("/"+locations+"/{locationId}")
    .onDelete( async (snap, context) => {
        // Get the value of the context triggers.
        const locationId = context.params.locationId;
        // Get Data of Deleted Location
        const locationDoc = snap.data();
        functions.logger.log(
                "Deleting Location with ID:",
                locationId,
                "to Brand with ID",
                locationDoc.brandID
          );
        // Delete Location to Brands Collection
        await db
        .collection(brands)
        .doc(locationDoc.brandID)
        .collection("Locations")
        .doc(locationId)
        .delete();
        return null;
    });



// User Sends Request
exports.userSendsRequest = functions
    .region("europe-west1")
    .firestore
    .document("/"+brands+"/{brandId}/Requests/{requestId}")
    .onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const requestId = context.params.requestId;
      const brandId = context.params.brandId;
      // Get Data of the Request
      const requestSnapshot = await db.collection(brands).doc(brandId).collection("Requests").doc(requestId).get();
      const requestDoc = requestSnapshot.data();
      functions.logger.log(
            "Request Cover Data:",
            requestDoc.brandId,
            requestDoc.name,
          );
      // Get Data of the Brand
      const brandSnapshot = await db.collection(brands).doc(brandId).get();
      const brandDoc = brandSnapshot.data();
      functions.logger.log(
          "Brand Data:",
          brandDoc,
      );
      // Add Request to Users Request collection
      await db
        .collection(users)
        .doc(requestDoc.userId)
        .collection("Requests")
        .doc(requestId).set({
            "brandId": requestDoc.brandId,
            "userId": requestDoc.userId,
            "name": requestDoc.name,
            "isTrainer": requestDoc.isTrainer,
            "dateSent": requestDoc.dateSent,
            "year": requestDoc.year,
            "month": requestDoc.month,
            "day": requestDoc.day,
        });
      // Send Notification to Brand Owners
      const brandOwnersSnapshot = await db.collection(brands)
          .doc(brandId)
          .collection("Users")
          .where("role", "=", 1)
          .get();
      for (var i in brandOwnersSnapshot.docs) {
          const brandOwnersDoc = brandOwnersSnapshot.docs[i].data();
          functions.logger.log(
              "Brand Owners Data:",
              brandOwnersDoc
            );
          if (brandOwnersDoc.idioma == "es") {
              payload = {
                notification: {
                  title: requestDoc.name+" ha enviado una solicitud de afiliación",
                  body: "Enviada el "+requestDoc.dateSent,
                },
                data: {
                  route: "SplashScreen2",
                },
              };
          } else {
              payload = {
                notification: {
                  title: requestDoc.name+" ha enviat una sol·licitud d'afiliació",
                  body: "Enviada el "+requestDoc.dateSent,
                },
                data: {
                  route: "SplashScreen2",
                },
              }
          }
          functions.logger.log(
                "Payload",
                payload
          );
          const notificationToken = brandOwnersDoc.notificationToken;
          functions.logger.log(
                "Notification Token",
                notificationToken
          );
          const response = await admin.messaging().sendToDevice(notificationToken, payload);
          functions.logger.log(
              "Response",
              response
          );
      }
      return null;
    });

// User Deletes Request
exports.userDeletesRequest = functions
    .region("europe-west1")
    .firestore
    .document("/"+brands+"/{brandId}/Requests/{requestId}")
    .onDelete( async (snap, context) => {
      // Get the value of the context triggers.
      const requestId = context.params.requestId;
      const brandId = context.params.brandId;
      functions.logger.log(
              "Deleting Request with ID:",
              requestId,
              "to Brand with ID",
              brandId
        );
      // Get Data of Deleted Request
      const requestDoc = snap.data();
      // Delete the Request on Users Request collection
      await db
        .collection(users)
        .doc(requestDoc.userId)
        .collection("Requests")
        .doc(requestId)
        .delete();
      return null;
    });


// Change Message Status
exports.changeMessageStatus = functions
  .region("europe-west1")
  .firestore
  .document("/"+rooms+"/{roomId}/messages/{messageId}")
  .onWrite((change) => {
    const message = change.after.data()
    if (message) {
      if (['delivered', 'seen', 'sent'].includes(message.status)) {
        return null
      } else {
        return change.after.ref.update({
          status: 'delivered',
        })
      }
    } else {
      return null
    }
  })

// Change Last Message
exports.changeLastMessage = functions
  .region("europe-west1")
  .firestore
  .document("/"+rooms+"/{roomId}/messages/{messageId}")
  .onUpdate((change, context) => {
    const message = change.after.data()
    if (message) {
      const updatedAt = message.updatedAt;
      functions.logger.log(
                    "Message",
                    message.updatedAt,
                  );
      return db.doc(rooms + "/" + context.params.roomId).update({
        lastMessages: [message],
        updatedAt: updatedAt,
      })
    } else {
      return null
    }
  })