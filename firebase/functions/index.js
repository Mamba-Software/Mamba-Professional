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
const nicknames = isProduction ? 'Nicknames' : '7777 Nicknames';
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
        // Count the number of Members
        const brandUsersSnapshot = await db.collection(brands).doc(brandId).collection("Users").get();
        let numberMembers = brandUsersSnapshot.size;
        functions.logger.log(
          "Number Members",
          numberMembers,
        );
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
      const brandOwnersSnapshot = await db.collection(brands)
          .doc(brandId)
          .collection("Users")
          .where("role", "=", 1)
          .get();
      // Count the number of Members
      const brandUsersSnapshot = await db.collection(brands).doc(brandId).collection("Users").get();
      let numberMembers = brandUsersSnapshot.size;
      functions.logger.log(
        "Number Members",
        numberMembers,
      );
      for (var i in brandOwnersSnapshot.docs) {
        const brandOwnersDoc = brandOwnersSnapshot.docs[i].data();
        functions.logger.log(
            "Brand Owners Data:",
            brandOwnersDoc
          );
        if (brandOwnersDoc.idioma == "es") {
            payload = {
              notification: {
                title: userDoc.firstName+" "+userDoc.lastName+" ha abandonado a "+brandDoc.name,
                body: "Ahora sois un total de "+numberMembers.toString()+" miembros",
              },
              data: {
                route: "SplashScreen2",
              },
            };
          } else {
            payload = {
              notification: {
                title: userDoc.firstName+" "+userDoc.lastName+" ha abandonat a "+brandDoc.name,
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
    .document("/"+users+"/{userId}/Requests/{requestId}")
    .onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const requestId = context.params.requestId;
      const userId = context.params.userId;
      // Get Data of the Request
      const requestSnapshot = await db.collection(users).doc(userId).collection("Requests").doc(requestId).get();
      const requestDoc = requestSnapshot.data();
      functions.logger.log(
            "Request Cover Data:",
            requestDoc.brandId,
            requestDoc.name,
          );
      // Get Data of the Brand
      const brandId = requestDoc.brandId;
      const brandSnapshot = await db.collection(brands).doc(brandId).get();
      const brandDoc = brandSnapshot.data();
      functions.logger.log(
          "Brand Data:",
          brandDoc,
      );
      // Add Request to Brands Request collection
      await db
        .collection(brands)
        .doc(brandId)
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
    .document("/"+users+"/{userId}/Requests/{requestId}")
    .onDelete( async (snap, context) => {
      // Get the value of the context triggers.
      const requestId = context.params.requestId;
      const userId = context.params.userId;
      // Get Data of Deleted Request
      const requestDoc = snap.data();
      functions.logger.log(
              "Deleting Request with ID:",
              requestId,
              "to Brand with ID",
              requestDoc.brandId
        );
      // Delete the Request on Users Request collection
      await db
        .collection(brands)
        .doc(requestDoc.brandId)
        .collection("Requests")
        .doc(requestId)
        .delete();
      return null;
    });

// User Adds Event
exports.userAddsEvent = functions
    .region("europe-west1")
    .firestore
    .document("/"+events+"/{eventId}")
    .onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const eventId = context.params.eventId;
      // Get Data of the Event
      const eventSnapshot = await db.collection(events).doc(eventId).get();
      const eventDoc = eventSnapshot.data();
      // Get Data of the Event Brand
      const eventBrandSnapshot = await db.collection(events).doc(eventId).collection("Brands").get();
      // Get Data of the Event Users
      const eventUsersSnapshot = await db.collection(events).doc(eventId).collection("Users").get();
      // Get Data of the Event Location
      const eventLocationsSnapshot = await db.collection(events).doc(eventId).collection("Locations").get();
      functions.logger.log(
          "Event Cover Data with ID:",
          eventId,
          "with Name:",
          eventDoc.title,
        );
      // Count the Number of Clients and Trainers
      let numClients = 0;
      let numTrainers = 0;
      for (var i in eventUsersSnapshot.docs) {
        const eventUsersDoc = eventUsersSnapshot.docs[i].data();
        if (eventUsersDoc.isTrainer) {
          numTrainers += 1;
        } else {
          numClients += 1;
        }
      }
      functions.logger.log(
        "numClients",
        numClients,
        "numTrainers",
        numTrainers,
      );
      // Add Event to Brands Event Subcollection
      for (var i in eventBrandSnapshot.docs) {
        const id = eventBrandSnapshot.docs[i].id;
        await db
        .collection(brands)
        .doc(id)
        .collection("Events")
        .doc(eventId).set({
          "title": eventDoc.title,
          "year": eventDoc.year,
          "month": eventDoc.month,
          "day": eventDoc.day,
          "hour": eventDoc.hour,
          "minute": eventDoc.minute,
          "duration": eventDoc.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
        });
      }
      // Add Event to Locations Event Subcollection
      for (var i in eventLocationsSnapshot.docs) {
        const id = eventLocationsSnapshot.docs[i].id;
        await db
        .collection(locations)
        .doc(id)
        .collection("Events")
        .doc(eventId).set({
          "title": eventDoc.title,
          "year": eventDoc.year,
          "month": eventDoc.month,
          "day": eventDoc.day,
          "hour": eventDoc.hour,
          "minute": eventDoc.minute,
          "duration": eventDoc.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
        });
      }
      return null;
    });

// User Deletes Event
exports.userDeletesEvent = functions
    .region("europe-west1")
    .firestore
    .document("/"+events+"/{eventId}")
    .onDelete( async (snap, context) => {
      // Get the value of the context triggers.
      const eventId = context.params.eventId;
      // Get Data of Deleted Event
      const eventDoc = snap.data();
      functions.logger.log(
        "Event Deleted with ID:",
        eventId,
        "and Name:",
        eventDoc.title,
      );
      // Get Data of the Event Locations
      const eventUsersSnapshot = await db.collection(events).doc(eventId).collection("Users").get();
      functions.logger.log(
        "eventUsersSnapshot size",
        eventUsersSnapshot.size,
      );
      // Get Data of the Event Brand
      const eventBrandSnapshot = await db.collection(events).doc(eventId).collection("Brands").get();
      functions.logger.log(
        "eventBrandSnapshot size",
        eventBrandSnapshot.size,
      );
      // Get Data of the Event Locations
      const eventLocationsSnapshot = await db.collection(events).doc(eventId).collection("Locations").get();
      functions.logger.log(
          "eventLocationsSnapshot size",
          eventLocationsSnapshot.size,
      );
      // Delete Users Subcollection in Event
      for (var i in eventUsersSnapshot.docs) {
          await db
          .collection(events)
          .doc(eventId)
          .collection("Users")
          .doc(eventUsersSnapshot.docs[i].id)
          .delete();
      }
      // Delete Event in Brands Subcollection
      for (var i in eventBrandSnapshot.docs) {
        await db
        .collection(brands)
        .doc(eventBrandSnapshot.docs[i].id)
        .collection("Events")
        .doc(eventId)
        .delete();
        // Delete Brands in Event
        await db
        .collection(events)
        .doc(eventId)
        .collection("Brands")
        .doc(eventBrandSnapshot.docs[i].id)
        .delete();
      }
      // Delete Event in Locations Subcollection
      for (var i in eventLocationsSnapshot.docs) {
        await db
        .collection(locations)
        .doc(eventLocationsSnapshot.docs[i].id)
        .collection("Events")
        .doc(eventId)
        .delete();
        // Delete Locations in Event
        await db
        .collection(events)
        .doc(eventId)
        .collection("Locations")
        .doc(eventLocationsSnapshot.docs[i].id)
        .delete();
      }
      return null;
    });

// User Joins Event
exports.userJoinsEvent = functions
    .region("europe-west1")
    .firestore
    .document("/"+events+"/{eventId}/Users/{userId}")
    .onCreate( async (change, context) => {
      // Get the value of the context triggers.
      const eventId = context.params.eventId;
      const userId = context.params.userId;
      // Get Event Data
      const eventSnapshot = await db.collection(events).doc(eventId).get();
      const eventDoc = eventSnapshot.data();
      // Count the Number of Clients and Trainers
      const eventUsersSnapshot = await db.collection(events).doc(eventId).collection("Users").get();
      let numClients = 0;
      let numTrainers = 0;
      for (var i in eventUsersSnapshot.docs) {
        const eventUsersDoc = eventUsersSnapshot.docs[i].data();
        if (eventUsersDoc.isTrainer) {
          numTrainers += 1;
        } else {
          numClients += 1;
        }
      }
      // Add Event To Users Event Subcollection
      await db
      .collection(users)
      .doc(userId)
      .collection("Events")
      .doc(eventId).set({
        "title": eventDoc.title,
        "year": eventDoc.year,
        "month": eventDoc.month,
        "day": eventDoc.day,
        "hour": eventDoc.hour,
        "minute": eventDoc.minute,
        "duration": eventDoc.duration,
        "numTrainers": numTrainers,
        "numClients": numClients,
      });
      return null;
    });

// User Joins Event
exports.userLeavesEvent = functions
    .region("europe-west1")
    .firestore
    .document("/"+events+"/{eventId}/Users/{userId}")
    .onDelete( async (change, context) => {
      // Get the value of the context triggers.
      const eventId = context.params.eventId;
      const userId = context.params.userId;
      // Add Event To Users Event Subcollection
      await db
      .collection(users)
      .doc(userId)
      .collection("Events")
      .doc(eventId)
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