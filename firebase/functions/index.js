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
const notifications = isProduction ? "Notifications" : "7777 Notifications";

// User Registers To Mamba
exports.userRegistersMamba = functions
    .region("europe-west1")
    .firestore
    .document("/"+users+"/{userId}")
    .onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const userId = context.params.userId;
      functions.logger.log(
              "User has registered with ID:",
              userId,
            );
      // Send Wellcome Notificaction
      var uid = uuidv4.v4();
      functions.logger.log(
          "Uid",
          uid,
        );
      let date = new Date();
      let day = date.getDate();
      let month = date.getMonth() + 1;
      if (month < 10) {
        month = "0"+month;
      }
      let year = date.getFullYear().toString();
      let result = year.slice(2, 4);
      var formatted = day+"-"+month+"-"+result;
      await db
      .collection(users)
      .doc(userId)
      .collection("Notifications")
      .doc(uid).set({
        "type": "Wellcome_User",
        "isRead": false,
        "dateSent": formatted,
        "year": date.getFullYear(),
        "month": date.getMonth() + 1,
        "day": date.getDate(),
        "hour": date.getHours(),
        "minutes": date.getMinutes(),
        "seconds": date.getSeconds(),
        "parameters": [],
      });
      return null;
    });

// User Creates Brand
exports.userCreatesBrand = functions
    .region("europe-west1")
    .firestore
    .document("/"+brands+"/{brandId}")
    .onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const brandId = context.params.brandId;
      functions.logger.log(
              "Brand created with ID",
              brandId,
            );
      // Get Data of the Brand
      const brandSnapshot = await db.collection(brands).doc(brandId).get();
      const brandDoc = brandSnapshot.data();
      functions.logger.log(
        "Brand Cover Data:",
        brandDoc.name,
        brandDoc.logoUrl,
      );
      // Add Brand to the User´s Brand Collection
      const userSnapshot = await db.collection(users).doc(userId).get();
      const userDoc = userSnapshot.data();
      // Add Brand to Admins Sub Brands Collection
      // Add Location to Brands SubLocation
      // Send Alert of Brand Created



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
      return null;
    });


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
      return null;
    });

// User Sends Request
exports.userSendsRequest = functions
    .region("europe-west1")
    .firestore
    .document("/"+requests+"/{requestId}")
    .onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const requestId = context.params.requestId;
      // Get Data of the Request
      const requestSnapshot = await db.collection(requests).doc(requestId).get();
      const requestDoc = requestSnapshot.data();
      functions.logger.log(
            "Request Cover Data:",
            requestDoc.brandId,
            requestDoc.name,
          );
      // Get Notification Token for All Brand Trainers
      // TO DO: Modificar aquesta funcion quan tinguem la base de dades acutualitzada.
      const brandTrainersSnapshot = await db.collection(users)
        .where("brandID", "=", requestDoc.brandId)
        .where("isTrainer", "=", true)
        .get();
      for (var i in brandTrainersSnapshot.docs) {
          const brandTrainersDoc = brandTrainersSnapshot.docs[i].data();
          functions.logger.log(
              "Brand Trainer Data:",
              brandTrainersDoc
            );
          if (brandTrainersDoc.idioma == "es") {
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
            const notificationToken = brandTrainersDoc.notificationToken;
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