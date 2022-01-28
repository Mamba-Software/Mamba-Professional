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
const rooms = isProduction ? "Rooms" : "7777 Rooms";
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
       //Get Data of the Room
       const roomSnapshot = await db.collection(rooms).doc(brandDoc.roomId).get();
       const roomDoc = roomSnapshot.data();

       var metadataMessage = {};
       var metadataRoom = {};

        functions.logger.log(
                     "UserIds",
                     roomDoc.userIds,
                   );
       roomDoc.userIds.push(userId);

      if(roomDoc.lastMessages.length != 0) {
      metadataMessage = roomDoc.lastMessages[0].metadata;
      metadataMessage[userId] = "delivered";
      await db.doc(rooms + "/" + brandDoc.roomId + "/messages/" + roomDoc.lastMessages[0].remoteId).update({
        metadata: metadataMessage,
        status: "delivered",
      })
      }

      metadataRoom = roomDoc.metadata;
      metadataRoom["trainer" + userId] = userDoc.isTrainer;
      metadataRoom["active" + userId] = false;
      await db.doc(rooms + "/" + brandDoc.roomId).update({
            metadata: metadataRoom,
            userIds: roomDoc.userIds,
      })
/*
       await db.collection(rooms).doc(brandDoc.roomId).update({
                 metadata: {
                 roomDoc.metadata,
                 "trainer" + userId: userDoc.isTrainer,
                 "active" + userId: false,
                 },
                 userIds: roomDoc.userIds,

       });*/
      // const roomSnapshot = await db.collection(rooms).doc(brandDoc.roomId).update();
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
  .onWrite(async (change, context) => {
    const message = change.after.data();
    const previousValue = change.before.data();
    const roomId = context.params.roomId;
    const messageId = context.params.messageId;
    var payload = 0;
    const roomSnapshot =  await db.collection(rooms).doc(roomId).get();
         const roomDoc = roomSnapshot.data();
         functions.logger.log(
                             "PreviousValue",


                           );
    if (message && previousValue === undefined) {
    //Get Data of the Room

     var messageStatus = "seen";
     var metadata = {};
     var userSnapshot;
     var userDoc;
     functions.logger.log(
                         "MessageTest",
                         roomDoc.metadata,

                       );
     for(let i = 0; i < roomDoc.userIds.length; ++i) {
     functions.logger.log(
                              "Incremental",
                              roomDoc.userIds[i],

                            );
           if(roomDoc.metadata["active" + roomDoc.userIds[i]] == false) {
           functions.logger.log(
                                         "Es activo",
                                         roomDoc.userIds[i],

                                       );
             messageStatus = "delivered";
             metadata[roomDoc.userIds[i]] = "delivered";
               userSnapshot = await db.collection(users).doc(roomDoc.userIds[i]).get();
                        userDoc = userSnapshot.data();
             // Send Notification To Users who received the message and not active
             if(roomDoc.type == "group") {
             payload = {
                                   notification: {
                                   title: roomDoc.name,
                                                       body: userDoc.firstName + '' + userDoc.lastName + ': ' + message.text,
                                                     },
                                                     data: {
                                                       route: "SplashScreen3",
                                                     },
                                                   };
             }
             else {
             payload = {
                                   notification: {
                                   title: userDoc.firstName + '' + userDoc.lastName + ':',
                                                       body: message.text,
                                                     },
                                                     data: {
                                                       route: "SplashScreen3",
                                                     },
                                                   };
             }

                                  var response = await admin.messaging().sendToDevice(userDoc.notificationToken, payload);
                                  functions.logger.log(
                                            "Response",
                                            response
                                          );
           }
           else {
           metadata[roomDoc.userIds[i]] = "seen";
           }
         }
      if (['delivered', 'seen', 'sent'].includes(message.status)) {
        return null
      } else {
        change.after.ref.update({
          status: messageStatus,
          metadata: metadata,
          remoteId: messageId,
        });
        message.status = messageStatus;
        message.metadata = metadata;
        message.remoteId = messageId;
              return db.doc(rooms + "/" + roomId).update({
                lastMessages: [message],
                updatedAt: message.updatedAt,
                })
      }
    }
    else if (roomDoc.lastMessages[0].remoteId == message.remoteId)
    {
         return db.doc(rooms + "/" + roomId).update({
                        lastMessages: [message],
                        })
    }

    else {
      return null
    }
  })

/*
// Change Last Message
exports.changeLastMessage = functions
  .region("europe-west1")
  .firestore
  .document("/"+rooms+"/{roomId}/messages/{messageId}")
  .onUpdate(async (change, context) => {
    var metadata = {};
    const roomId = context.params.roomId;
    const roomSnapshot =  await db.collection(rooms).doc(roomId).get();
         const roomDoc = roomSnapshot.data();
    const message = change.after.data()
    if (message) {
      const updatedAt = message.updatedAt;
      metadata = roomDoc.metadata;
      metadata["alreadyChanged"] = true;
      functions.logger.log(
                    "Message",
                    message.updatedAt,
                  );
      return db.doc(rooms + "/" + context.params.roomId).update({
        lastMessages: [message],
        updatedAt: updatedAt,
        metadata: metadata,
      })
    } else {
      return null
    }
  })
*/

/*
  // Updated Room message Status changes
  exports.updateMessageStatus= functions
    .region("europe-west1")
    .firestore
    .document("/"+rooms+"/{roomId}")
    .onUpdate(async (change, context) => {

  const newValue = change.after.data();
  const newFieldValue = newValue.lastMessages[0];

  // ...or the previous value before this update
  const previousValue = change.before.data();
  const previousFieldValue = previousValue.lastMessages[0];
functions.logger.log(
                      "Activo o no activo",
                      previousFieldValue,
                    );
                    functions.logger.log(
                                          "Activo o no activo",
                                          newFieldValue,
                                        );

  if (previousFieldValue.remoteId == newFieldValue.remoteId && newValue.metadata["alreadyChanged"] == false && newFieldValue.status != "seen") {
  functions.logger.log(
                      "Activo o no activo DENTRO",
                      previousFieldValue,
                    );
    const roomId = context.params.roomId;
    const roomSnapshot =  await db.collection(rooms).doc(roomId).get();
             const roomDoc = roomSnapshot.data();

    const messageSnapshot =  await db.collection(rooms + "/" + roomId + "/messages/").doc(roomDoc.lastMessages[0].remoteId).get();
    const message = messageSnapshot.data();
         var messageStatus = "seen";
         var metadata = {};

         functions.logger.log(
                             "MessageTest",
                             message.metadata,

                           );
         for(let i = 0; i < roomDoc.userIds.length; ++i) {
               if(roomDoc.metadata["active" + roomDoc.userIds[i]] == false) {
                 messageStatus = "delivered";
                 metadata[roomDoc.userIds[i]] = "delivered";
               }
               else {
               metadata[roomDoc.userIds[i]] = "seen";
               }
             }
             if(messageStatus == "seen") {
             const messageSnapshotFinal =  await db.collection(rooms + "/" + roomId + "/messages").get();
                          const messageDoc = messageSnapshotFinal.data();
                          for(let j = 0; j < messageDoc.length; ++j) {
                                      await db.doc(rooms + "/" + roomId + "/messages/" + messageDoc[j].remoteId).update({
                                                        metadata: metadata,
                                                        status: messageStatus,
                                                      })
                          }

             }


          return await db.doc(rooms + "/" + roomId + "/messages/" + roomDoc.lastMessages[0].remoteId).update({
                  metadata: metadata,
                  status: messageStatus,
                })
        }

        else return null;

      });*/