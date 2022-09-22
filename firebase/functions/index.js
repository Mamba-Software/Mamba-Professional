// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Required NPM Packages
const uuidv4 = require("uuid")

// Firebase DataBase
const db = admin.firestore();

// Daily Notification For Events
exports.scheduledDailyFunction = functions
.region("europe-west1")  
.pubsub
.schedule('every day 7:00')
.timeZone('Europe/Madrid')
.onRun( async (context) => {
      // For each User get Events of Today
      let today = new Date();
      const usersSnapshot = await db.collection("Users").get();
      for (var i in usersSnapshot.docs) {
        const userId = usersSnapshot.docs[i].id;
        const userDoc = usersSnapshot.docs[i].data();
        functions.logger.log(
          "User with Id",
          userId,
          "and Name:",
          userDoc.name,
          );
          // Get the Users events today
          const userEventsSnapshot = await db
          .collection("Users")
          .doc(userId)
          .collection("Events")
          .where('year', '==', today.getFullYear().toString())
          .where('month', '==', (today.getMonth()+1).toString())
          .where('day', '==', today.getDate().toString())
          .get();
          functions.logger.log(
            "User Events Num =",
            userEventsSnapshot.size,
            );
          // Get The Time of the First Event
          let firstHour = 100;
          let firstMinute = 100;
          let firstEventDoc;
          for (var i in userEventsSnapshot.docs) {
            const eventDoc = userEventsSnapshot.docs[i].data();
            if (eventDoc.hour < firstHour) {
              firstEventDoc = eventDoc;
            } else if (eventDoc.hour == firstHour) {
              if (eventDoc.minute < firstMinute) {
                firstEventDoc = eventDoc;
              }
            }
          }
          // Send Notification if there is an Event Today
          if (userEventsSnapshot.size > 0) {
            if (userEventsSnapshot.size == 1) {
              functions.logger.log(
                "One Event this User"
                );
                  // Send Good Morning Notification
                  var payload = 0;
                  if (userDoc.isTrainer == true) {
                    functions.logger.log(
                      "isTrainer"
                      );
                    let minutes = firstEventDoc.minute == "0" ? "00" : firstEventDoc.minute;
                    if (userDoc.idioma == "es") {
                      payload = {
                        notification: {
                          title: "Buenos días "+userDoc.firstName + " ☀️",
                          body: "⏰ Hoy tienes 1 sesión prevista. Empiezas a las "+firstEventDoc.hour+":"+minutes,
                        },
                        data: {
                          route: "SplashScreen",
                        },
                      };
                    } else {
                      payload = {
                        notification: {
                          title: "Bon dia "+userDoc.firstName + " ☀️",
                          body: "⏰ Avui tens 1 sessió prevista. Comences a les "+firstEventDoc.hour+":"+minutes,
                        },
                        data: {
                          route: "SplashScreen",
                        },
                      };
                    }
                  } else {
                    functions.logger.log(
                      "isClient"
                      );
                    let minutes = firstEventDoc.minute == "0" ? "00" : firstEventDoc.minute;
                    if (userDoc.idioma == "es") {
                      payload = {
                        notification: {
                          title: "Buenos días "+userDoc.firstName+ " ☀️",
                          body: "⚠️ ¡Recuerda! Hoy a las "+firstEventDoc.hour+":"+minutes+" - "+firstEventDoc.title,
                        },
                        data: {
                          route: "SplashScreen",
                        },
                      };
                    } else {
                      payload = {
                        notification: {
                          title: "Bon dia "+userDoc.firstName+ " ☀️",
                          body: "⚠️ Recorda! Avui a les "+firstEventDoc.hour+":"+minutes+" - "+firstEventDoc.title,
                        },
                        data: {
                          route: "SplashScreen",
                        },
                      };
                    }
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
                } else {
                  functions.logger.log(
                    "More Than Event this User"
                    );
                  // Send Good Morning Notification
                  var payload = 0;
                  if (userDoc.isTrainer == true) {
                   functions.logger.log(
                    "isTrainer"
                    );
                   let minutes = firstEventDoc.minute == "0" ? "00" : firstEventDoc.minute;
                   if (userDoc.idioma == "es") {
                    payload = {
                      notification: {
                        title: "Buenos días "+userDoc.firstName+ " ☀️",
                        body: "⏰ Hoy tienes "+userEventsSnapshot.size+" sesiones previstas. Empiezas a las "+firstEventDoc.hour+":"+minutes,
                      },
                      data: {
                        route: "SplashScreen0",
                      },
                    };
                  } else {
                    payload = {
                      notification: {
                        title: "Bon dia "+userDoc.firstName+ " ☀️",
                        body: "⏰ Avui tens "+userEventsSnapshot.size+" sessions previstes. Comences a les "+firstEventDoc.hour+":"+minutes,
                      },
                      data: {
                        route: "SplashScreen0",
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
                }
              }
            }
          }
          return null;
        });

// New User Situate in Test Group
exports.newUserAddsTestGroup = functions
.region("europe-west1")
.firestore
.document("/Users/{userId}")
.onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const userId = context.params.userId;
      // Get the number of total users
      const totalUsersSnapshot = await db.collection("Users").get();
      let numberUsers = totalUsersSnapshot.size;
      // Assign test group depending on isEven
      let testGroup = "A";
      if (numberUsers % 2 == 0) {
        testGroup = "B"
      }
      // Update Firebase
      await db
      .collection("Users")
      .doc(userId)
      .update({
       "testGroup": testGroup,
     });
      return null;
    });

// User Updates Cover Data
exports.userUpdatesCoverData = functions
.region("europe-west1")
.firestore
.document("/Users/{userId}")
.onUpdate( async (change, context) => {
      // Get the value of the context triggers.
      const userId = context.params.userId;
      // Get Value of the Change
      const before = change.before.data();
      const after = change.after.data();
      functions.logger.log(
        "BEFORE:",
        before,
        );
      functions.logger.log(
        "AFTER:",
        after,
        );
      // Check if Cover Data has changed:
      // COVER DATA: firstName, lastName, nick, imageUrl, noImageUrl, isTrainer, isPrivate, notificationToken
      let coverDataChange = false;
      if (before.firstName != after.firstName) {
        coverDataChange = true;
      } else if (before.lastName != after.lastName) {
        coverDataChange = true;
      } else if (before.nick != after.nick) {
        coverDataChange = true;
      } else if (before.imageUrl != after.imageUrl) {
        coverDataChange = true;
      } else if (before.noImageUrl != after.noImageUrl) {
        coverDataChange = true;
      } else if (before.isTrainer != after.isTrainer) {
        coverDataChange = true;
      } else if (before.isPrivate != after.isPrivate) {
        coverDataChange = true;
      } else if (before.notificationToken != after.notificationToken) {
        coverDataChange = true;
      }
      functions.logger.log(
        "COVER DATA CHANGED?",
        coverDataChange,
        );
      if (coverDataChange) {
        // Update the Users Subcollection in Brands
        const userBrandsSnapshot = await db.collection("Users").doc(userId).collection("Brands").get();
        functions.logger.log(
          "User Brands Num =",
          userBrandsSnapshot.size,
          );
        for (var i in userBrandsSnapshot.docs) {
          const id = userBrandsSnapshot.docs[i].id;
          await db
          .collection("Brands")
          .doc(id)
          .collection("Users")
          .doc(userId)
          .update({
            "name": after.firstName+" "+after.lastName,
            "firstName": after.firstName,
            "lastName": after.lastName,
            "nick": after.nick,
            "imageUrl": after.imageUrl,
            "noImageUrl": after.noImageUrl,
            "isTrainer": after.isTrainer,
            "isPrivate": after.isPrivate,
            "notificationToken": after.notificationToken,
          });
        }
        // Update the Users Subcollection in Events
        const userEventsSnapshot = await db.collection("Users").doc(userId).collection("Events").get();
        functions.logger.log(
          "User Events Num =",
          userEventsSnapshot.size,
          );
        for (var i in userEventsSnapshot.docs) {
          const id = userEventsSnapshot.docs[i].id;
          await db
          .collection("Events")
          .doc(id)
          .collection("Users")
          .doc(userId)
          .update({
            "name": after.firstName+" "+after.lastName,
            "firstName": after.firstName,
            "lastName": after.lastName,
            "nick": after.nick,
            "imageUrl": after.imageUrl,
            "noImageUrl": after.noImageUrl,
            "isTrainer": after.isTrainer,
            "isPrivate": after.isPrivate,
            "notificationToken": after.notificationToken,
          });
        }
      }
      return null;
    });

// Brand Updates Cover Data
exports.brandUpdatesCoverData = functions
.region("europe-west1")
.firestore
.document("/Brands/{brandId}")
.onUpdate( async (change, context) => {
      // Get the value of the context triggers.
      const brandId = context.params.brandId;
      // Get Value of the Change
      const before = change.before.data();
      const after = change.after.data();
      functions.logger.log(
        "BEFORE:",
        before,
        );
      functions.logger.log(
        "AFTER:",
        after,
        );
      // Check if Cover Data has changed:
      // COVER DATA: name, logoUrl
      let coverDataChange = false;
      if (before.name != after.name) {
        coverDataChange = true;
      } else if (before.logoUrl != after.logoUrl) {
        coverDataChange = true;
      }
      functions.logger.log(
        "COVER DATA CHANGED?",
        coverDataChange,
        );
      if (coverDataChange) {
        // Update the Brands Subcollection in Users
        const brandsUsersSnapshot = await db.collection("Brands").doc(brandId).collection("Users").get();
        functions.logger.log(
          "Brands Users Num =",
          brandsUsersSnapshot.size,
          );
        for (var i in brandsUsersSnapshot.docs) {
          const id = brandsUsersSnapshot.docs[i].id;
          await db
          .collection("Users")
          .doc(id)
          .collection("Brands")
          .doc(brandId)
          .update({
            "name": after.name,
            "logoUrl": after.logoUrl,
          });
        }
        // Update the Brands Subcollection in Events
        const brandEventsSnapshot = await db.collection("Brands").doc(brandId).collection("Events").get();
        functions.logger.log(
          "Brand Events Num =",
          brandEventsSnapshot.size,
          );
        for (var i in brandEventsSnapshot.docs) {
          const id = brandEventsSnapshot.docs[i].id;
          await db
          .collection("Events")
          .doc(id)
          .collection("Brands")
          .doc(brandId)
          .update({
            "name": after.name,
            "logoUrl": after.logoUrl,
          });
        }
      }
      return null;
    });

// Event Updates Data
exports.eventUpdatesCoverData = functions
.region("europe-west1")
.firestore
.document("/Events/{eventId}")
.onUpdate( async (change, context) => {
      // Get the value of the context triggers.
      const eventId = context.params.eventId;
      // Get Value of the Change
      const before = change.before.data();
      const after = change.after.data();
      functions.logger.log(
        "BEFORE:",
        before,
        );
      functions.logger.log(
        "AFTER:",
        after,
        );
      // Event Users Snapshot
      const eventUsersSnapshot = await db.collection("Events").doc(eventId).collection("Users").get();
      // Check if Location has changed:
      let locationChange = false;
      if (before.locationId != after.locationId) {
        locationChange = true;
      }
      functions.logger.log(
        "LOCATION CHANGED?",
        locationChange,
        );
      if (locationChange) {
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
        functions.logger.log(
          "Delete Event from Location",
          before.locationId,
          );
        // Delete Event From Old Location
        await db
        .collection("Locations")
        .doc(before.locationId)
        .collection("Events")
        .doc(eventId)
        .delete();
        // Add Event To New Location
        functions.logger.log(
          "Add Event To Location",
          after.locationId,
          );
        // Update Private Event
        if (after.isPrivate == true) {                 
         await db
         .collection("Locations")
         .doc(before.locationId)
         .collection("Events")
         .doc("Private Events")
         .collection("Private Events")
         .doc(eventId)
         .delete();
       }
        // Add Event to New Location
        await db
        .collection("Locations")
        .doc(after.locationId)
        .collection("Events")
        .doc(eventId).set({
          "title": after.title,
          "imageUrl": after.imageUrl,
          "year": after.year,
          "month": after.month,
          "day": after.day,
          "hour": after.hour,
          "minute": after.minute,
          "duration": after.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
          "maxMembers": after.maxMembers,
        });        
        // Update Private Event
        if (after.isPrivate == true) {                 
         await db
         .collection("Locations")
         .doc(after.locationId)
         .collection("Events")
         .doc("Private Events")
         .collection("Private Events")
         .doc(eventId)
         .set({
          "title": after.title,
          "imageUrl": after.imageUrl,
          "year": after.year,
          "month": after.month,
          "day": after.day,
          "hour": after.hour,
          "minute": after.minute,
          "duration": after.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
          "maxMembers": after.maxMembers,
        });
       }
       functions.logger.log(
        "DONE",
        );
     }
      // Check if Cover Data has changed:
      // COVER DATA: title, year, month, day, hour, minute, duration
      let coverDataChange = false;
      if (before.title != after.title) {
        coverDataChange = true;
      } else if (before.imageUrl != after.imageUrl) {
        coverDataChange = true;
      } else if (before.year != after.year) {
        coverDataChange = true;
      } else if (before.month != after.month) {
        coverDataChange = true;
      } else if (before.day != after.day) {
        coverDataChange = true;
      } else if (before.hour != after.hour) {
        coverDataChange = true;
      } else if (before.minute != after.minute) {
        coverDataChange = true;
      } else if (before.duration != after.duration) {
        coverDataChange = true;
      } else if (before.maxMembers != after.maxMembers) {
        coverDataChange = true;
      }
      functions.logger.log(
        "COVER DATA CHANGED?",
        coverDataChange,
        );
      if (coverDataChange) {
        functions.logger.log(
          "Event Users Num =",
          eventUsersSnapshot.size,
          );
        // Update the Event Subcollection in Users
        for (var i in eventUsersSnapshot.docs) {
          const id = eventUsersSnapshot.docs[i].id;
          await db
          .collection("Users")
          .doc(id)
          .collection("Events")
          .doc(eventId)
          .update({
            "title": after.title,
            "imageUrl": after.imageUrl,
            "year": after.year,
            "month": after.month,
            "day": after.day,
            "hour": after.hour,
            "minute": after.minute,
            "duration": after.duration,
            "maxMembers": after.maxMembers,
          });          
          // Update Private Event
          if (after.isPrivate == true) {                 
           await db
           .collection("Users")
           .doc(id)
           .collection("Events")
           .doc("Private Events")
           .collection("Private Events")
           .doc(eventId)
           .update({
            "title": after.title,
            "imageUrl": after.imageUrl,
            "year": after.year,
            "month": after.month,
            "day": after.day,
            "hour": after.hour,
            "minute": after.minute,
            "duration": after.duration,
            "maxMembers": after.maxMembers,
          });
         }
       }
        // Update the Event Subcollection in Brands
        const eventBrandsSnapshot = await db.collection("Events").doc(eventId).collection("Brands").get();
        functions.logger.log(
          "Event Brands Num =",
          eventBrandsSnapshot.size,
          );
        for (var i in eventBrandsSnapshot.docs) {
          const id = eventBrandsSnapshot.docs[i].id;
          await db
          .collection("Brands")
          .doc(id)
          .collection("Events")
          .doc(eventId)
          .update({
            "title": after.title,
            "imageUrl": after.imageUrl,
            "year": after.year,
            "month": after.month,
            "day": after.day,
            "hour": after.hour,
            "minute": after.minute,
            "duration": after.duration,
            "maxMembers": after.maxMembers,
          });                    
          // Update Private Event
          if (after.isPrivate == true) {                 
           await db
           .collection("Brands")
           .doc(id)
           .collection("Events")
           .doc("Private Events")
           .collection("Private Events")
           .doc(eventId)
           .update({
            "title": after.title,
            "imageUrl": after.imageUrl,
            "year": after.year,
            "month": after.month,
            "day": after.day,
            "hour": after.hour,
            "minute": after.minute,
            "duration": after.duration,
            "maxMembers": after.maxMembers,
          });
         }
       }
        // Update the Event Subcollection in Locations
        const eventLocationsSnapshot = await db.collection("Events").doc(eventId).collection("Locations").get();
        functions.logger.log(
          "Event Locations Num =",
          eventLocationsSnapshot.size,
          );
        for (var i in eventLocationsSnapshot.docs) {
          const id = eventLocationsSnapshot.docs[i].id;
          await db
          .collection("Locations")
          .doc(id)
          .collection("Events")
          .doc(eventId)
          .update({
            "title": after.title,
            "imageUrl": after.imageUrl,
            "year": after.year,
            "month": after.month,
            "day": after.day,
            "hour": after.hour,
            "minute": after.minute,
            "duration": after.duration,
            "maxMembers": after.maxMembers,
          });
          // Update Private Event
          if (after.isPrivate == true) {                 
           await db
           .collection("Locations")
           .doc(id)
           .collection("Events")
           .doc("Private Events")
           .collection("Private Events")
           .doc(eventId)
           .update({
            "title": after.title,
            "imageUrl": after.imageUrl,
            "year": after.year,
            "month": after.month,
            "day": after.day,
            "hour": after.hour,
            "minute": after.minute,
            "duration": after.duration,
            "maxMembers": after.maxMembers,
          });
         }
       }
     }
     return null;
   });

// Event Updates Data
exports.locationUpdatesCoverData = functions
.region("europe-west1")
.firestore
.document("/Locations/{locationId}")
.onUpdate( async (change, context) => {
      // Get the value of the context triggers.
      const locationId = context.params.locationId;
      // Get Value of the Change
      const before = change.before.data();
      const after = change.after.data();
      functions.logger.log(
        "BEFORE:",
        before,
        );
      functions.logger.log(
        "AFTER:",
        after,
        );
      // Check if Cover Data has changed:
      // COVER DATA: title, year, month, day, hour, minute, duration
      let coverDataChange = false;
      if (before.description != after.description) {
        coverDataChange = true;
      } else if (before.latitude != after.latitude) {
        coverDataChange = true;
      } else if (before.longitude != after.longitude) {
        coverDataChange = true;
      }
      functions.logger.log(
        "COVER DATA CHANGED?",
        coverDataChange,
        );
      if (coverDataChange) {
        // Update the Object Location in Brands
        await db
        .collection("Brands")
        .doc(after.brandID)
        .collection("Locations")
        .doc(locationId)
        .update({
          "description": after.description,
          "latitude": after.latitude,
          "longitude": after.longitude,
        });
        // Update All Events in this Location
        const eventLocationsSnapshot = await db.collection("Locations").doc(locationId).collection("Events").get();
        functions.logger.log(
          "Location Events Num =",
          eventLocationsSnapshot.size,
          );
        for (var i in eventLocationsSnapshot.docs) {
          const id = eventLocationsSnapshot.docs[i].id;
          await db
          .collection("Events")
          .doc(id)
          .collection("Locations")
          .doc(locationId)
          .update({
            "description": after.description,
            "latitude": after.latitude,
            "longitude": after.longitude,
          });
        }
      }
      return null;
    });

// User Joins Brand
exports.userJoinsBrand = functions
.region("europe-west1")
.firestore
.document("/Brands/{brandId}/Users/{userId}")
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
      const userSnapshot = await db.collection("Users").doc(userId).get();
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
      const brandSnapshot = await db.collection("Brands").doc(brandId).get();
      const brandDoc = brandSnapshot.data();
      functions.logger.log(
        "Brand Cover Data:",
        brandDoc,
        );

      // Get Data of the Brand Room
      const roomSnapshot = await db.collection("Rooms").doc(brandDoc.roomId).get();
      const roomDoc = roomSnapshot.data();

      var metadataMessage = {};
      var metadataRoom = {};

      functions.logger.log(
       "UserIds",
       roomDoc.userIds,
       );
      roomDoc.userIds.push(userId);

      // Get Data of the Brand Room
      if (roomDoc.lastMessages != undefined) {
        metadataMessage = roomDoc.lastMessages[0].metadata;
        metadataMessage[userId] = "delivered";
        // Updates all messages so that they are delivered for new user.
        await db.doc("Rooms" + "/" + brandDoc.roomId + "/messages/" + roomDoc.lastMessages[0].remoteId).update({
          metadata: metadataMessage,
          status: "delivered",
        })
      }

      // Creates metadata for new user and adds it.  
      metadataRoom = roomDoc.metadata;
      metadataRoom["trainer" + userId] = userDoc.isTrainer;
      metadataRoom["active" + userId] = false;
      await db.doc("Rooms" + "/" + brandDoc.roomId).update({
        metadata: metadataRoom,
        userIds: roomDoc.userIds,
      })

      // Add the Brand Cover Data to Users/Brands Collection
      let date = new Date();
      let day = date.getDate();
      let month = date.getMonth() + 1;
      if (month < 10) {
        month = "0"+month;
      }
      let year = date.getFullYear().toString();
      let result = year.slice(2, 4);
      var formatted = day+"-"+month+"-"+result;
      await db.doc("/Users/"+userId+"/Brands/"+brandId+"").set({
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
              title: "Has creado tu marca "+brandDoc.name+" ✅",
              body: "Ahora podrás usar todas las funcionalidades de calendarización, control y gestión que ofrece Mamba",
            },
            data: {
              route: "BrandPage",
            },
          };
        } else {
          payload = {
            notification: {
              title: "Has creat la teva marca "+brandDoc.name+" ✅",
              body: "Ara podràs usar totes les funcionalitats de calendarització, control i gestió que ofereix Mamba",
            },
            data: {
              route: "BrandPage",
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
            title: "Te has unido a "+brandDoc.name+" ✅",
            body: "Consulta el calendario para participar en tu primera sesión",
          },
          data: {
            route: "BrandPage",
          },
        };
      } else {
        payload = {
          notification: {
            title: "T'has unit a "+brandDoc.name+" ✅",
            body: "Consulta el calendari per participar en la teva primera sessió",
          },
          data: {
            route: "BrandPage",
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
        const adminSnapshot = await db.collection("Users").doc(brandDoc.adminID).get();
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
        const brandUsersSnapshot = await db.collection("Brands").doc(brandId).collection("Users").get();
        let numberMembers = brandUsersSnapshot.size;
        functions.logger.log(
          "Number Members",
          numberMembers,
          );
        if (adminDoc.idioma == "es") {
          payload = {
            notification: {
              title: "Nuevo miembro en "+brandDoc.name+" ➕1️⃣ ",
              body: userDoc.name+" se ha unido. Ya sois un total de "+numberMembers.toString()+" miembros",
            },
            data: {
              route: "Notifications",
            },
          };
        } else {
          payload = {
            notification: {
              title: "Nou membre a "+brandDoc.name+" ➕1️⃣ ",
              body: userDoc.name+" s'ha unit. Ja sou un total de "+numberMembers.toString()+" membres",
            },
            data: {
              route: "Notifications",
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
      // Count Brand Members
      brandUsersSnapshot = await db.collection("Brands").doc(brandId).collection("Users").get();
      let numClients = 0;
      let numTrainers = 0;
      for (var i in brandUsersSnapshot.docs) {
        const brandUsersDoc = brandUsersSnapshot.docs[i].data();
        if (brandUsersDoc.isTrainer) {
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
      // Update Brand Members
      await db
      .collection("Brands")
      .doc(brandId)
      .update({
        "numClients": numClients,
        "numTrainers": numTrainers,
      });
      return null;
    });

// User Leaves Brand
exports.userLeavesBrand = functions
.region("europe-west1")
.firestore
.document("/Brands/{brandId}/Users/{userId}")
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
      const brandSnapshot = await db.collection("Brands").doc(brandId).get();
      const brandDoc = brandSnapshot.data();
      functions.logger.log(
        "Brand Cover Data:",
        brandDoc,
        );
      // Delete Brand in User´s Brand Subcollection
      await db.collection("Users").doc(userId).collection("Brands").doc(brandId).delete();
      // Get Data of the Room
      const roomSnapshot = await db.collection("Rooms").doc(brandDoc.roomId).get();
      const roomDoc = roomSnapshot.data();
      var filtered = roomDoc.userIds.filter(function(element) {
        return element != userId;
      });
      await db.doc("Rooms" + "/" + brandDoc.roomId).update({
        userIds: filtered,
      });
      // Send Notification to Brand Owners
      const brandOwnersSnapshot = await db.collection("Brands")
      .doc(brandId)
      .collection("Users")
      .where("role", "=", 1)
      .get();
      // Count the number of Members
      const brandUsersSnapshot = await db.collection("Brands").doc(brandId).collection("Users").get();
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
              title: "Miembro ha abandonado "+brandDoc.name+" ➖1️⃣ ",
              body: userDoc.firstName+" "+userDoc.lastName+" se ha ido, ahora sois un total de "+numberMembers.toString()+" miembros",
            },
            data: {
              route: "Notifications",
            },
          };
        } else {
          payload = {
            notification: {
              title: "Membre ha abandonat "+brandDoc.name+" ➖1️⃣ ",
              body: userDoc.firstName+" "+userDoc.lastName+" ha marxat, ara sou un total "+numberMembers.toString()+" membres",
            },
            data: {
              route: "Notifications",
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
      // Count Brand Members
      let numClients = 0;
      let numTrainers = 0;
      for (var i in brandUsersSnapshot.docs) {
        const brandUsersDoc = brandUsersSnapshot.docs[i].data();
        if (brandUsersDoc.isTrainer) {
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
      // Update Brand Members
      await db
      .collection("Brands")
      .doc(brandId)
      .update({
        "numClients": numClients,
        "numTrainers": numTrainers,
      });
      return null;
    });

// User Adds Location
exports.userAddsLocation = functions
.region("europe-west1")
.firestore
.document("/Locations/{locationId}")
.onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const locationId = context.params.locationId;
      // Get Data of the Location
      const locationSnapshot = await db.collection("Locations").doc(locationId).get();
      const locationDoc = locationSnapshot.data();
      functions.logger.log(
        "Location Data:",
        locationDoc
        );
      // Add Location to Brands Collection
      await db.doc("/Brands/"+locationDoc.brandID+"/Locations/"+locationId+"").set({
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
.document("/Locations/{locationId}")
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
        .collection("Brands")
        .doc(locationDoc.brandID)
        .collection("Locations")
        .doc(locationId)
        .delete();
        /*
        // Check Location Has Future Events
        let futureEvents = [];
        let now = new Date();
        const locationEventsSnapshot = await db.collection("Locations").doc(locationId).collection("Events").get();
        for (var i in locationEventsSnapshot.docs) {
          const id = locationEventsSnapshot.docs[i].id;
          const data = locationEventsSnapshot.docs[i].data();
          let date = new Date(date.year, date.month-1, date.day, date.hour, date.minute);
          if (now < date) {
            futureEvents.push(id);
          }
        }
        functions.logger.log(
            "Events to be modified",
            futureEvents,
          );
        if (futureEvents.length != 0) {

           // Update Future Events To Base Location
           for (var i in futureEvents.length) {
             const eventId = futureEvents[i];

           }
           // Delete Previous Location
           await _firestore
               .collection("Events")
               .doc(eventId)
               .collection("Locations")
               .doc(previousLocation)
               .delete();
           // Add New Location
           Location location = await this.getSingleLocation(locationId);
           await _firestore
               .collection("Events")
               .doc(eventId)
               .collection("Locations")
               .doc(locationId)
               .set({
                 "description": location.description,
                 "longitude": location.longitude,
                 "latitude": location.latitude,
               });
             } */
             return null;
           });

// User Sends Request
exports.userSendsRequest = functions
.region("europe-west1")
.firestore
.document("/Users/{userId}/Requests/{requestId}")
.onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const requestId = context.params.requestId;
      const userId = context.params.userId;
      // Get Data of the Request
      const requestSnapshot = await db.collection("Users").doc(userId).collection("Requests").doc(requestId).get();
      const requestDoc = requestSnapshot.data();
      functions.logger.log(
        "Request Cover Data:",
        requestDoc.brandId,
        requestDoc.name,
        );
      // Get Data of the Brand
      const brandId = requestDoc.brandId;
      const brandSnapshot = await db.collection("Brands").doc(brandId).get();
      const brandDoc = brandSnapshot.data();
      functions.logger.log(
        "Brand Data:",
        brandDoc,
        );
      // Add Request to Brands Request collection
      await db
      .collection("Brands")
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
      const brandOwnersSnapshot = await db.collection("Brands")
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
              title: "Nueva solicitud de afiliación ⁉️",
              body: requestDoc.name+" quiere formar parte de tu marca "+ brandDoc.name,
            },
            data: {
              route: "Notifications",                
            },
          };
        } else {
          payload = {
            notification: {
              title: "Nova sol·licitud d'afiliació ⁉️",
              body: requestDoc.name+" vol formar part de la teva marca "+ brandDoc.name,
            },
            data: {
              route: "Notifications",                  
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
.document("/Users/{userId}/Requests/{requestId}")
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
      .collection("Brands")
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
.document("/Events/{eventId}")
.onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const eventId = context.params.eventId;
      // Get Data of the Event
      const eventSnapshot = await db.collection("Events").doc(eventId).get();
      const eventDoc = eventSnapshot.data();
      // Get Data of the Event Brand
      const eventBrandSnapshot = await db.collection("Events").doc(eventId).collection("Brands").get();
      // Get Data of the Event Users
      const eventUsersSnapshot = await db.collection("Events").doc(eventId).collection("Users").get();
      // Get Data of the Event Location
      const eventLocationsSnapshot = await db.collection("Events").doc(eventId).collection("Locations").get();
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
      /* Add Event to Brands Event Subcollection
      for (var i in eventBrandSnapshot.docs) {
        const id = eventBrandSnapshot.docs[i].id;
        await db
        .collection("Brands")
        .doc(id)
        .collection("Events")
        .doc(eventId).set({
          "title": eventDoc.title,
          "doneAt": eventDoc.doneAt,
          "year": eventDoc.year,
          "month": eventDoc.month,
          "day": eventDoc.day,
          "hour": eventDoc.hour,
          "minute": eventDoc.minute,
          "duration": eventDoc.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
          "maxMembers": eventDoc.maxMembers,
        });
      }
      */
      // Add Event to Locations Event Subcollection
      for (var i in eventLocationsSnapshot.docs) {
        const id = eventLocationsSnapshot.docs[i].id;
        await db
        .collection("Locations")
        .doc(id)
        .collection("Events")
        .doc(eventId).set({
          "isPrivate": eventDoc.isPrivate,
          "title": eventDoc.title,
          "imageUrl": eventDoc.imageUrl,
          "doneAt": eventDoc.doneAt,
          "year": eventDoc.year,
          "month": eventDoc.month,
          "day": eventDoc.day,
          "hour": eventDoc.hour,
          "minute": eventDoc.minute,
          "duration": eventDoc.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
          "maxMembers": eventDoc.maxMembers,
        });
        // If Event Private
        // Add to Locations/Events/Private Events/PrivateEvents
        if (eventDoc.isPrivate == true) {
         await db
         .collection("Locations")
         .doc(id)
         .collection("Events")
         .doc("Private Events")
         .collection("Private Events")
         .doc(eventId).set({
          "isPrivate": eventDoc.isPrivate,
          "title": eventDoc.title,
          "imageUrl": eventDoc.imageUrl,
          "doneAt": eventDoc.doneAt,
          "year": eventDoc.year,
          "month": eventDoc.month,
          "day": eventDoc.day,
          "hour": eventDoc.hour,
          "minute": eventDoc.minute,
          "duration": eventDoc.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
          "maxMembers": eventDoc.maxMembers,
        });
       }    
     }
     return null;
   });

// User Deletes Event
exports.userDeletesEvent = functions
.region("europe-west1")
.firestore
.document("/Events/{eventId}")
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
      const eventUsersSnapshot = await db.collection("Events").doc(eventId).collection("Users").get();
      functions.logger.log(
        "eventUsersSnapshot size",
        eventUsersSnapshot.size,
        );
      // Get Data of the Event Brand
      const eventBrandSnapshot = await db.collection("Events").doc(eventId).collection("Brands").get();
      functions.logger.log(
        "eventBrandSnapshot size",
        eventBrandSnapshot.size,
        );
      // Get Data of the Event Locations
      const eventLocationsSnapshot = await db.collection("Events").doc(eventId).collection("Locations").get();
      functions.logger.log(
        "eventLocationsSnapshot size",
        eventLocationsSnapshot.size,
        );
      // Delete Users Subcollection in Event
      for (var i in eventUsersSnapshot.docs) {
        await db
        .collection("Events")
        .doc(eventId)
        .collection("Users")
        .doc(eventUsersSnapshot.docs[i].id)
        .delete();
      }
      /* Delete Event in Brands Subcollection
      for (var i in eventBrandSnapshot.docs) {
        await db
        .collection("Brands")
        .doc(eventBrandSnapshot.docs[i].id)
        .collection("Events")
        .doc(eventId)
        .delete();
        // Delete Brands in Event
        await db
        .collection("Events")
        .doc(eventId)
        .collection("Brands")
        .doc(eventBrandSnapshot.docs[i].id)
        .delete();
      }*/
      // Delete Event in Locations Subcollection
      for (var i in eventLocationsSnapshot.docs) {
        await db
        .collection("Locations")
        .doc(eventLocationsSnapshot.docs[i].id)
        .collection("Events")
        .doc(eventId)
        .delete();
        // If Event Private
        // Delete from Locations/Events/Private Events/Private Events Subcollection
        if (eventDoc.isPrivate  == true) {
         await db
         .collection("Locations")
         .doc(eventLocationsSnapshot.docs[i].id)
         .collection("Events")
         .doc("Private Events")
         .collection("Private Events")
         .doc(eventId)
         .delete();
       }
        // Delete Locations in Event
        await db
        .collection("Events")
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
.document("/Events/{eventId}/Users/{userId}")
.onCreate( async (change, context) => {
      // Get the value of the context triggers.
      const eventId = context.params.eventId;
      const userId = context.params.userId;
      // Get Event Data      
      const eventSnapshot = await db.collection("Events").doc(eventId).get();
      const eventDoc = eventSnapshot.data();
      functions.logger.log(
        "eventDoc",
        eventDoc,
        );
      // Get User Data
      const userSnapshot = await db.collection("Users").doc(userId).get();
      const userDoc = userSnapshot.data();
      // Get Event User Data
      const eventUserSnapshot = await db.collection("Events").doc(eventId).collection("Users").doc(userId).get();
      const eventUserDoc = eventUserSnapshot.data();
      // Get Event Brands Data
      const eventBrandsSnapshot = await db.collection("Events").doc(eventId).collection("Brands").get();
      // Get Data of the Event Locations
      const eventLocationsSnapshot = await db.collection("Events").doc(eventId).collection("Locations").get();
      // Count the Number of Clients and Trainers
      const eventUsersSnapshot = await db.collection("Events").doc(eventId).collection("Users").get();
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
      /* Update Event Assisting Members
      await db
      .collection("Events")
      .doc(eventId)
      .update({
        "numClients": numClients,
        "numTrainers": numTrainers,
      });*/
      var isPrivate = false;
      if (eventDoc.isPrivate != undefined) {
        isPrivate == eventDoc.isPrivate;
      }
      // Add Event To Users Event Subcollection
      await db
      .collection("Users")
      .doc(userId)
      .collection("Events")
      .doc(eventId).set({
        "isPrivate": isPrivate,
        "title": eventDoc.title,
        "imageUrl": eventDoc.imageUrl,
        "doneAt": eventDoc.doneAt,
        "year": eventDoc.year,
        "month": eventDoc.month,
        "day": eventDoc.day,
        "hour": eventDoc.hour,
        "minute": eventDoc.minute,
        "duration": eventDoc.duration,
        "numTrainers": numTrainers,
        "numClients": numClients,
        "maxMembers": eventDoc.maxMembers,
      });
      // If Event Private
      // Add to Users/Events/Private Events/PrivateEvents
      if (eventDoc.isPrivate == true) {
       await db
       .collection("Users")
       .doc(userId)
       .collection("Events")
       .doc("Private Events")
       .collection("Private Events")
       .doc(eventId).set({
        "isPrivate": eventDoc.isPrivate,
        "title": eventDoc.title,
        "imageUrl": eventDoc.imageUrl,
        "doneAt": eventDoc.doneAt,
        "year": eventDoc.year,
        "month": eventDoc.month,
        "day": eventDoc.day,
        "hour": eventDoc.hour,
        "minute": eventDoc.minute,
        "duration": eventDoc.duration,
        "numTrainers": numTrainers,
        "numClients": numClients,
        "maxMembers": eventDoc.maxMembers,
      });
     }
      // Update Number of Client and Trainers on Each of Event Subcollection
      // User´s Event First
      for (var i in eventUsersSnapshot.docs) {
        const id = eventUsersSnapshot.docs[i].id;
        await db
        .collection("Users")
        .doc(id)
        .collection("Events")
        .doc(eventId)
        .update({
          "numClients": numClients,
          "numTrainers": numTrainers,
        });        
        // If Event Private
        // Update Cover Data Also
        if (eventDoc.isPrivate == true) {
          await db
          .collection("Users")
          .doc(id)
          .collection("Events")
          .doc("Private Events")
          .collection("Private Events")
          .doc(eventId)
          .update({
            "numClients": numClients,
            "numTrainers": numTrainers,
          });
        }
      }
      // Brand´s Event Second
      for (var i in eventBrandsSnapshot.docs) {
        const id = eventBrandsSnapshot.docs[i].id;
        await db
        .collection("Brands")
        .doc(id)
        .collection("Events")
        .doc(eventId)
        .update({
          "numClients": numClients,
          "numTrainers": numTrainers,
        });
        // If Event Private
        // Update Cover Data Also
        if (eventDoc.isPrivate == true) {
          await db
          .collection("Brands")
          .doc(id)
          .collection("Events")
          .doc("Private Events")
          .collection("Private Events")
          .doc(eventId)
          .update({
            "numClients": numClients,
            "numTrainers": numTrainers,
          });
        }
      }
      // Location´s Event Third
      for (var i in eventLocationsSnapshot.docs) {
        const id = eventLocationsSnapshot.docs[i].id;
        await db
        .collection("Locations")
        .doc(id)
        .collection("Events")
        .doc(eventId)
        .update({
          "numClients": numClients,
          "numTrainers": numTrainers,
        });
          // If Event Private
          // Update Cover Data Also
          if (eventDoc.isPrivate == true) {
            await db
            .collection("Locations")
            .doc(id)
            .collection("Events")
            .doc("Private Events")
            .collection("Private Events")
            .doc(eventId)
            .update({
              "numClients": numClients,
              "numTrainers": numTrainers,
            });
          }
        }
      // Send Notifications
      if (userDoc.isTrainer == false) {
        // Don´t Send Full Notification When it is a Private Event
        if (eventDoc.isPrivate != true) {            
          // Send Notification to Trainers if booked capacity == 100% or > 50%, only when Clients Join
          if (eventDoc.maxMembers == numClients) {
              // Event is full
              functions.logger.log(
                "NOTIFICATION IS FULL",
                );
              for (var i in eventUsersSnapshot.docs) {
                const id = eventUsersSnapshot.docs[i].id;
                const eventUsersDoc = eventUsersSnapshot.docs[i].data();
                if (eventUsersDoc.isTrainer) {
                  const trainerSnapshot = await db.collection("Users").doc(id).get();
                  const trainerDoc = trainerSnapshot.data();
                  functions.logger.log(
                    "trainerDoc",
                    trainerDoc,
                    );
                  var payload = 0;
                  let date = new Date(eventDoc.year, eventDoc.month-1, eventDoc.day);
                  if (trainerDoc.idioma == "es") {
                    // Date To String
                    let dateString = date.toLocaleDateString('es-ES', { weekday:"long", day:"numeric", month:"long"});
                    // Hour and Minutes to String
                    let eventTimeTime = eventDoc.hour+":";
                    let minutes = eventDoc.minute == "0" ? "00" : eventDoc.minute;
                    eventTimeTime += minutes;
                    // Send Payload
                    payload = {
                      notification: {
                        title: "Evento totalmente reservado 💯",
                        body: "El evento "+eventDoc.title+" se realizará el "+dateString+" a las "+eventTimeTime,
                      },
                      data: {
                        route: eventId,
                      },
                    };
                  } else {
                    // Date To String
                    let dateString = date.toLocaleDateString('ca-CA', { weekday:"long", day:"numeric", month:"long"});
                    // Hour and Minutes to String
                    let eventTimeTime = eventDoc.hour+":";
                    let minutes = eventDoc.minute == "0" ? "00" : eventDoc.minute;
                    eventTimeTime += minutes;
                    // Send Payload
                    payload = {
                      notification: {
                        title: "Esdeveniment totalment reservat 💯",
                        body: "L'esdeveniment "+eventDoc.title+" es realitzarà el "+dateString+" a les "+eventTimeTime,            
                      },
                      data: {
                        route: eventId,
                      },
                    };
                  }
                  functions.logger.log(
                    "Payload",
                    payload
                    );
                  response = await admin.messaging().sendToDevice(trainerDoc.notificationToken, payload);
                  functions.logger.log(
                    "Response",
                    response
                    );
                }
              }
            } else {
            // First one to go over 50%
            if (numClients / eventDoc.maxMembers > 0.49 && (numClients - 1) / eventDoc.maxMembers < 0.50) {
              // Send Over 50% Notification to All Event Trainers
              functions.logger.log(
                "NOTIFICATION OVER 50%",
                );
              for (var i in eventUsersSnapshot.docs) {
                const id = eventUsersSnapshot.docs[i].id;
                const eventUsersDoc = eventUsersSnapshot.docs[i].data();
                if (eventUsersDoc.isTrainer) {
                  const trainerSnapshot = await db.collection("Users").doc(id).get();
                  const trainerDoc = trainerSnapshot.data();
                  functions.logger.log(
                    "trainerDoc",
                    trainerDoc,
                    );
                  var payload = 0;
                  let date = new Date(eventDoc.year, eventDoc.month-1, eventDoc.day);
                  if (trainerDoc.idioma == "es") {
                      // Date To String
                      let dateString = date.toLocaleDateString('es-ES', { weekday:"long", day:"numeric", month:"long"});
                      // Hour and Minutes to String
                      let eventTimeTime = eventDoc.hour+":";
                      let minutes = eventDoc.minute == "0" ? "00" : eventDoc.minute;
                      eventTimeTime += minutes;
                      // Send Payload
                      payload = {
                        notification: {
                          title: "Cada vez quedan menos plazas ⏱️",
                          body: "El evento "+eventDoc.title+" ya tiene un 50% de las plazas reservadas",
                        },
                        data: {
                          route: eventId,
                        },
                      };
                    } else {
                      // Date To String
                      let dateString = date.toLocaleDateString('ca-CA', { weekday:"long", day:"numeric", month:"long"});
                      // Hour and Minutes to String
                      let eventTimeTime = eventDoc.hour+":";
                      let minutes = eventDoc.minute == "0" ? "00" : eventDoc.minute;
                      eventTimeTime += minutes;
                      // Send Payload
                      payload = {
                        notification: {
                          title: "Cada cop queden menys places ⏱️",
                          body: "L'esdeveniment "+eventDoc.title+" ja té un 50% de les places reservades",
                        },
                        data: {
                          route: eventId,
                        },
                      };
                    }
                    functions.logger.log(
                      "Payload",
                      payload
                      );
                    response = await admin.messaging().sendToDevice(trainerDoc.notificationToken, payload);
                    functions.logger.log(
                      "Response",
                      response
                      );
                  }
                }
              }
            }
          }
        }
      // Send Notification to User if added directly
      if (eventUserDoc.invitedDirectly == true) {
          // Invited to Event
          functions.logger.log(
            "NOTIFICATION CLIENT INVITED DIRECTLY TO EVENT",
            );
          functions.logger.log(
            "userDoc",
            userDoc,
            );
          var payload = 0;
          let date = new Date(eventDoc.year, eventDoc.month-1, eventDoc.day);
          if (userDoc.idioma == "es") {
           // Date To String
           let dateString = date.toLocaleDateString('es-ES', { weekday:"long", day:"numeric", month:"long"});
           // Hour and Minutes to String
           let eventTimeTime = eventDoc.hour+":";
           let minutes = eventDoc.minute == "0" ? "00" : eventDoc.minute;
           eventTimeTime += minutes;
           // Send Payload
           payload = {
             notification: {
               title: "Nuevo evento programado ⁉️ 🏋️‍♂️",
               body: "Te han añadido al evento "+eventDoc.title+". Se realizará el "+dateString+" a las "+eventTimeTime,
             },
             data: {
               route: eventId,
             },
           };
         } else {
           // Date To String
           let dateString = date.toLocaleDateString('ca-CA', { weekday:"long", day:"numeric", month:"long"});
           // Hour and Minutes to String
           let eventTimeTime = eventDoc.hour+":";
           let minutes = eventDoc.minute == "0" ? "00" : eventDoc.minute;
           eventTimeTime += minutes;
           // Send Payload
           payload = {
             notification: {
               title: "Nou esdeveniment programat ⁉️ 🏋️‍♂️",
               body: "T'han afegit a l'esdeveniment "+eventDoc.title+". Es realitzarà el "+dateString+" a les "+eventTimeTime,
             },
             data: {
               route: eventId,
             },
           };
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
       }
       return null;
     });

// User Leaves Event
exports.userLeavesEvent = functions
.region("europe-west1")
.firestore
.document("/Events/{eventId}/Users/{userId}")
.onDelete( async (change, context) => {
      // Get the value of the context triggers.
      const eventId = context.params.eventId;
      const userId = context.params.userId;
      // Get Event Data
      const eventSnapshot = await db.collection("Events").doc(eventId).get();
      const eventDoc = eventSnapshot.data();
      functions.logger.log(
        "eventDoc",
        eventDoc,
        );
      // Get Event Brands Data
      const eventBrandsSnapshot = await db.collection("Events").doc(eventId).collection("Brands").get();
      // Count the Number of Clients and Trainers
      const eventUsersSnapshot = await db.collection("Events").doc(eventId).collection("Users").get();
      // Get Data of the Event Locations
      const eventLocationsSnapshot = await db.collection("Events").doc(eventId).collection("Locations").get();
      functions.logger.log(
        "eventLocationsSnapshot size",
        eventLocationsSnapshot.size,
        );
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
      // Delete Event To Users Event Subcollection
      await db
      .collection("Users")
      .doc(userId)
      .collection("Events")
      .doc(eventId)
      .delete();
      // If Event Private
      // Delete to Users/Events/Private Events/PrivateEvents
      if (eventDoc == undefined || eventDoc.isPrivate == true) {
       await db
       .collection("Users")
       .doc(userId)
       .collection("Events")
       .doc("Private Events")
       .collection("Private Events")
       .doc(eventId)
       .delete();
     }
      /* Update Event Assisting Members
      await db
      .collection("Events")
      .doc(eventId)
      .update({
        "numClients": numClients,
        "numTrainers": numTrainers,
      });*/
      // Update Number of Client and Trainers on Each of Event Subcollection
      // User´s Event First
      for (var i in eventUsersSnapshot.docs) {
        const id = eventUsersSnapshot.docs[i].id;
        await db
        .collection("Users")
        .doc(id)
        .collection("Events")
        .doc(eventId)
        .update({
          "numClients": numClients,
          "numTrainers": numTrainers,
        });
          // If Event Private
          // Update Cover Data Also
          if (eventDoc == undefined || eventDoc.isPrivate == true) {
            await db
            .collection("Users")
            .doc(id)
            .collection("Events")
            .doc("Private Events")
            .collection("Private Events")
            .doc(eventId)
            .update({
              "numClients": numClients,
              "numTrainers": numTrainers,
            });
          }
        }
      // Brand´s Event Second
      for (var i in eventBrandsSnapshot.docs) {
        const id = eventBrandsSnapshot.docs[i].id;
        await db
        .collection("Brands")
        .doc(id)
        .collection("Events")
        .doc(eventId)
        .update({
          "numClients": numClients,
          "numTrainers": numTrainers,
        });
          // If Event Private
          // Update Cover Data Also
          if (eventDoc == undefined || eventDoc.isPrivate == true) {
            await db
            .collection("Brands")
            .doc(id)
            .collection("Events")
            .doc("Private Events")
            .collection("Private Events")
            .doc(eventId)
            .update({
              "numClients": numClients,
              "numTrainers": numTrainers,
            });
          }
        }
      // Location´s Event Third
      for (var i in eventLocationsSnapshot.docs) {
        const id = eventLocationsSnapshot.docs[i].id;
        await db
        .collection("Locations")
        .doc(id)
        .collection("Events")
        .doc(eventId)
        .update({
          "numClients": numClients,
          "numTrainers": numTrainers,
        });
        // If Event Private
        // Update Cover Data Also
        if (eventDoc == undefined || eventDoc.isPrivate == true) {
          await db
          .collection("Locations")
          .doc(id)
          .collection("Events")
          .doc("Private Events")
          .collection("Private Events")
          .doc(eventId)
          .update({
            "numClients": numClients,
            "numTrainers": numTrainers,
          });
        }
      }
      return null;
    });

// Change Message Status
exports.changeMessageStatus = functions
.region("europe-west1")
.firestore
.document("/Rooms/{roomId}/messages/{messageId}")
.onWrite(async (change, context) => {
    // Get context params
    const roomId = context.params.roomId;
    const messageId = context.params.messageId;
    // Message after Data
    const message = change.after.data();
    const previousValue = change.before.data();
    functions.logger.log(
     "BEFORE",
     previousValue
     );
    functions.logger.log(
     "AFTER",
     message
     );
    var payload = 0;
    // Get Room Data
    const roomSnapshot =  await db.collection("Rooms").doc(roomId).get();
    const roomDoc = roomSnapshot.data();
    functions.logger.log(
     "RoomDoc",
     roomDoc
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
        for (let i = 0; i < roomDoc.userIds.length; ++i) {
          functions.logger.log(
            "Incremental",
            roomDoc.userIds[i],
            );
          if (message.authorId != roomDoc.userIds[i] && roomDoc.metadata["active" + roomDoc.userIds[i]] == false) {
           const authorUserSnapshot = await db.collection("Users").doc(message.authorId).get();
           const authorUserDoc = authorUserSnapshot.data();
           functions.logger.log(
             "Es activo",
             roomDoc.userIds[i],
             );
           messageStatus = "delivered";
           metadata[roomDoc.userIds[i]] = "delivered";
           userSnapshot = await db.collection("Users").doc(roomDoc.userIds[i]).get();
           userDoc = userSnapshot.data();
           functions.logger.log(
            "User to Send Data",
            userDoc,
            );
             // Send Notification To Users who received the message and not active
             if (roomDoc.type == "group") {
              payload = {
                notification: {
                  title: roomDoc.name,
                  body: authorUserDoc.firstName + ' ' + authorUserDoc.lastName + ': ' + message.text,
                },
                data: {
                  route: "Chat",
                },
              };
            } else {
              payload = {
               notification: {
                 title: authorUserDoc.firstName + ' ' + authorUserDoc.lastName + ':',
                 body: message.text,
               },
               data: {
                 route: "Chat",
               },
             };
           }
           var response = await admin.messaging().sendToDevice(userDoc.notificationToken, payload);
           functions.logger.log(
             "Response",
             response
             );
         } else {
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
        return db.doc("Rooms" + "/" + roomId).update({
          lastMessages: [message],
          updatedAt: message.updatedAt,
        })
      }
    } else if (roomDoc.lastMessages[0].remoteId == message.remoteId) {
      functions.logger.log(
       "message ASQUI",
       message.metadata,
       );
      return db.doc("Rooms" + "/" + roomId).update({
        lastMessages: [message],
      })
    } else {
      return null
    }
  })


///////////////////////////////////////////////////////////////////////////////////////////////////////
// 7777 TEST ENVIRONMENT CLOUD FUNCTIONS
///////////////////////////////////////////////////////////////////////////////////////////////////////

// New User Situate in Test Group
exports.zzzzNewUserAddsTestGroup = functions
.region("europe-west1")
.firestore
.document("/7777 Users/{userId}")
.onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const userId = context.params.userId;
      // Get the number of total users
      const totalUsersSnapshot = await db.collection("7777 Users").get();
      let numberUsers = totalUsersSnapshot.size;
      // Assign test group depending on isEven
      let testGroup = "A";
      if (numberUsers % 2 == 0) {
        testGroup = "B"
      }
      // Update Firebase
      await db
      .collection("7777 Users")
      .doc(userId)
      .update({
       "testGroup": testGroup,
     });
      return null;
    });

// User Updates Cover Data
exports.zzzzUserUpdatesCoverData = functions
.region("europe-west1")
.firestore
.document("/7777 Users/{userId}")
.onUpdate( async (change, context) => {
      // Get the value of the context triggers.
      const userId = context.params.userId;
      // Get Value of the Change
      const before = change.before.data();
      const after = change.after.data();
      functions.logger.log(
        "BEFORE:",
        before,
        );
      functions.logger.log(
        "AFTER:",
        after,
        );
      // Check if Cover Data has changed:
      // COVER DATA: firstName, lastName, nick, imageUrl, noImageUrl, isTrainer, isPrivate, notificationToken
      let coverDataChange = false;
      if (before.firstName != after.firstName) {
        coverDataChange = true;
      } else if (before.lastName != after.lastName) {
        coverDataChange = true;
      } else if (before.nick != after.nick) {
        coverDataChange = true;
      } else if (before.imageUrl != after.imageUrl) {
        coverDataChange = true;
      } else if (before.noImageUrl != after.noImageUrl) {
        coverDataChange = true;
      } else if (before.isTrainer != after.isTrainer) {
        coverDataChange = true;
      } else if (before.isPrivate != after.isPrivate) {
        coverDataChange = true;
      } else if (before.notificationToken != after.notificationToken) {
        coverDataChange = true;
      }
      functions.logger.log(
        "COVER DATA CHANGED?",
        coverDataChange,
        );
      if (coverDataChange) {
        // Update the Users Subcollection in Brands
        const userBrandsSnapshot = await db.collection("7777 Users").doc(userId).collection("Brands").get();
        functions.logger.log(
          "User Brands Num =",
          userBrandsSnapshot.size,
          );
        for (var i in userBrandsSnapshot.docs) {
          const id = userBrandsSnapshot.docs[i].id;
          await db
          .collection("7777 Brands")
          .doc(id)
          .collection("Users")
          .doc(userId)
          .update({
            "name": after.firstName+" "+after.lastName,
            "firstName": after.firstName,
            "lastName": after.lastName,
            "nick": after.nick,
            "imageUrl": after.imageUrl,
            "noImageUrl": after.noImageUrl,
            "isTrainer": after.isTrainer,
            "isPrivate": after.isPrivate,
            "notificationToken": after.notificationToken,
          });
        }
        // Update the Users Subcollection in Events
        const userEventsSnapshot = await db.collection("7777 Users").doc(userId).collection("Events").get();
        functions.logger.log(
          "User Events Num =",
          userEventsSnapshot.size,
          );
        for (var i in userEventsSnapshot.docs) {
          const id = userEventsSnapshot.docs[i].id;
          await db
          .collection("7777 Events")
          .doc(id)
          .collection("Users")
          .doc(userId)
          .update({
            "name": after.firstName+" "+after.lastName,
            "firstName": after.firstName,
            "lastName": after.lastName,
            "nick": after.nick,
            "imageUrl": after.imageUrl,
            "noImageUrl": after.noImageUrl,
            "isTrainer": after.isTrainer,
            "isPrivate": after.isPrivate,
            "notificationToken": after.notificationToken,
          });
        }
      }
      return null;
    });

// Brand Updates Cover Data
exports.zzzzBrandUpdatesCoverData = functions
.region("europe-west1")
.firestore
.document("/7777 Brands/{brandId}")
.onUpdate( async (change, context) => {
      // Get the value of the context triggers.
      const brandId = context.params.brandId;
      // Get Value of the Change
      const before = change.before.data();
      const after = change.after.data();
      functions.logger.log(
        "BEFORE:",
        before,
        );
      functions.logger.log(
        "AFTER:",
        after,
        );
      // Check if Cover Data has changed:
      // COVER DATA: name, logoUrl
      let coverDataChange = false;
      if (before.name != after.name) {
        coverDataChange = true;
      } else if (before.logoUrl != after.logoUrl) {
        coverDataChange = true;
      }
      functions.logger.log(
        "COVER DATA CHANGED?",
        coverDataChange,
        );
      if (coverDataChange) {
        // Update the Brands Subcollection in Users
        const brandsUsersSnapshot = await db.collection("7777 Brands").doc(brandId).collection("Users").get();
        functions.logger.log(
          "Brands Users Num =",
          brandsUsersSnapshot.size,
          );
        for (var i in brandsUsersSnapshot.docs) {
          const id = brandsUsersSnapshot.docs[i].id;
          await db
          .collection("7777 Users")
          .doc(id)
          .collection("Brands")
          .doc(brandId)
          .update({
            "name": after.name,
            "logoUrl": after.logoUrl,
          });
        }
        // Update the Brands Subcollection in Events
        const brandEventsSnapshot = await db.collection("7777 Brands").doc(brandId).collection("Events").get();
        functions.logger.log(
          "Brand Events Num =",
          brandEventsSnapshot.size,
          );
        for (var i in brandEventsSnapshot.docs) {
          const id = brandEventsSnapshot.docs[i].id;
          await db
          .collection("7777 Events")
          .doc(id)
          .collection("Brands")
          .doc(brandId)
          .update({
            "name": after.name,
            "logoUrl": after.logoUrl,
          });
        }
      }
      return null;
    });

// Event Updates Data
exports.zzzzEventUpdatesCoverData = functions
.region("europe-west1")
.firestore
.document("/7777 Events/{eventId}")
.onUpdate( async (change, context) => {
      // Get the value of the context triggers.
      const eventId = context.params.eventId;
      // Get Value of the Change
      const before = change.before.data();
      const after = change.after.data();
      functions.logger.log(
        "BEFORE:",
        before,
        );
      functions.logger.log(
        "AFTER:",
        after,
        );
      // Event Users Snapshot
      const eventUsersSnapshot = await db.collection("7777 Events").doc(eventId).collection("Users").get();
      // Check if Location has changed:
      let locationChange = false;
      if (before.locationId != after.locationId) {
        locationChange = true;
      }
      functions.logger.log(
        "LOCATION CHANGED?",
        locationChange,
        );
      if (locationChange) {
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
        functions.logger.log(
          "Delete Event from Location",
          before.locationId,
          );
        // Delete Event From Old Location
        await db
        .collection("7777 Locations")
        .doc(before.locationId)
        .collection("Events")
        .doc(eventId)
        .delete();
        // Update Private Event
        if (after.isPrivate == true) {                 
         await db
         .collection("7777 Locations")
         .doc(before.locationId)
         .collection("Events")
         .doc("Private Events")
         .collection("Private Events")
         .doc(eventId)
         .delete();
       }
        // Add Event To New Location
        functions.logger.log(
          "Add Event To Location",
          after.locationId,
          );
        // Add Event to New Location
        await db
        .collection("7777 Locations")
        .doc(after.locationId)
        .collection("Events")
        .doc(eventId).set({
          "title": after.title,
          "imageUrl": after.imageUrl,
          "year": after.year,
          "month": after.month,
          "day": after.day,
          "hour": after.hour,
          "minute": after.minute,
          "duration": after.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
          "maxMembers": after.maxMembers,
        });
        // Update Private Event
        if (after.isPrivate == true) {                 
         await db
         .collection("7777 Locations")
         .doc(after.locationId)
         .collection("Events")
         .doc("Private Events")
         .collection("Private Events")
         .doc(eventId)
         .set({
          "title": after.title,
          "imageUrl": after.imageUrl,
          "year": after.year,
          "month": after.month,
          "day": after.day,
          "hour": after.hour,
          "minute": after.minute,
          "duration": after.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
          "maxMembers": after.maxMembers,
        });
       }
       functions.logger.log(
        "DONE",
        );
     }
      // Check if Cover Data has changed:
      // COVER DATA: title, year, month, day, hour, minute, duration
      let coverDataChange = false;
      if (before.title != after.title) {
        coverDataChange = true;
      } else if (before.imageUrl != after.imageUrl) {
        coverDataChange = true;
      } else if (before.year != after.year) {
        coverDataChange = true;
      } else if (before.month != after.month) {
        coverDataChange = true;
      } else if (before.day != after.day) {
        coverDataChange = true;
      } else if (before.hour != after.hour) {
        coverDataChange = true;
      } else if (before.minute != after.minute) {
        coverDataChange = true;
      } else if (before.duration != after.duration) {
        coverDataChange = true;
      } else if (before.maxMembers != after.maxMembers) {
        coverDataChange = true;
      }
       else if (before.bonos != after.bonos) {
              coverDataChange = true;
       }
      functions.logger.log(
        "COVER DATA CHANGED?",
        coverDataChange,
        );
      if (coverDataChange) {
        functions.logger.log(
          "Event Users Num =",
          eventUsersSnapshot.size,
          );        
        // Update the Event Subcollection in Users
        for (var i in eventUsersSnapshot.docs) {
          const id = eventUsersSnapshot.docs[i].id;
          await db
          .collection("7777 Users")
          .doc(id)
          .collection("Events")
          .doc(eventId)
          .update({
            "title": after.title,
            "imageUrl": after.imageUrl,
            "year": after.year,
            "month": after.month,
            "day": after.day,
            "hour": after.hour,
            "minute": after.minute,
            "duration": after.duration,
            "maxMembers": after.maxMembers,
            "bonos": after.bonos,
          });
          // Update Private Event
          if (after.isPrivate == true) {                 
           await db
           .collection("7777 Users")
           .doc(id)
           .collection("Events")
           .doc("Private Events")
           .collection("Private Events")
           .doc(eventId)
           .update({
            "title": after.title,
            "imageUrl": after.imageUrl,
            "year": after.year,
            "month": after.month,
            "day": after.day,
            "hour": after.hour,
            "minute": after.minute,
            "duration": after.duration,
            "maxMembers": after.maxMembers,
            "bonos": after.bonos,
          });
         }
       }
        // Update the Event Subcollection in Brands
        const eventBrandsSnapshot = await db.collection("7777 Events").doc(eventId).collection("Brands").get();
        functions.logger.log(
          "Event Brands Num =",
          eventBrandsSnapshot.size,
          );
        for (var i in eventBrandsSnapshot.docs) {
          const id = eventBrandsSnapshot.docs[i].id;
          await db
          .collection("7777 Brands")
          .doc(id)
          .collection("Events")
          .doc(eventId)
          .update({
            "title": after.title,
            "imageUrl": after.imageUrl,
            "year": after.year,
            "month": after.month,
            "day": after.day,
            "hour": after.hour,
            "minute": after.minute,
            "duration": after.duration,
            "maxMembers": after.maxMembers,
            "bonos": after.bonos,
          });
          // Update Private Event
          if (after.isPrivate == true) {                 
           await db
           .collection("7777 Brands")
           .doc(id)
           .collection("Events")
           .doc("Private Events")
           .collection("Private Events")
           .doc(eventId)
           .update({
            "title": after.title,
            "imageUrl": after.imageUrl,
            "year": after.year,
            "month": after.month,
            "day": after.day,
            "hour": after.hour,
            "minute": after.minute,
            "duration": after.duration,
            "maxMembers": after.maxMembers,
            "bonos": after.bonos,
          });
         }
       }
        // Update the Event Subcollection in Locations
        const eventLocationsSnapshot = await db.collection("7777 Events").doc(eventId).collection("Locations").get();
        functions.logger.log(
          "Event Locations Num =",
          eventLocationsSnapshot.size,
          );
        for (var i in eventLocationsSnapshot.docs) {
          const id = eventLocationsSnapshot.docs[i].id;
          await db
          .collection("7777 Locations")
          .doc(id)
          .collection("Events")
          .doc(eventId)
          .update({
            "title": after.title,
            "imageUrl": after.imageUrl,
            "year": after.year,
            "month": after.month,
            "day": after.day,
            "hour": after.hour,
            "minute": after.minute,
            "duration": after.duration,
            "maxMembers": after.maxMembers,
            "bonos": after.bonos,
          });
          // Update Private Event
          if (after.isPrivate == true) {                 
           await db
           .collection("7777 Locations")
           .doc(id)
           .collection("Events")
           .doc("Private Events")
           .collection("Private Events")
           .doc(eventId)
           .update({
            "title": after.title,
            "imageUrl": after.imageUrl,
            "year": after.year,
            "month": after.month,
            "day": after.day,
            "hour": after.hour,
            "minute": after.minute,
            "duration": after.duration,
            "maxMembers": after.maxMembers,
            "bonos": after.bonos,
          });
         }
       }
     }
     return null;
   });

// Event Updates Data
exports.zzzzLocationUpdatesCoverData = functions
.region("europe-west1")
.firestore
.document("/7777 Locations/{locationId}")
.onUpdate( async (change, context) => {
      // Get the value of the context triggers.
      const locationId = context.params.locationId;
      // Get Value of the Change
      const before = change.before.data();
      const after = change.after.data();
      functions.logger.log(
        "BEFORE:",
        before,
        );
      functions.logger.log(
        "AFTER:",
        after,
        );
      // Check if Cover Data has changed:
      // COVER DATA: title, year, month, day, hour, minute, duration
      let coverDataChange = false;
      if (before.description != after.description) {
        coverDataChange = true;
      } else if (before.latitude != after.latitude) {
        coverDataChange = true;
      } else if (before.longitude != after.longitude) {
        coverDataChange = true;
      }
      functions.logger.log(
        "COVER DATA CHANGED?",
        coverDataChange,
        );
      if (coverDataChange) {
        // Update the Object Location in Brands
        await db
        .collection("7777 Brands")
        .doc(after.brandID)
        .collection("Locations")
        .doc(locationId)
        .update({
          "description": after.description,
          "latitude": after.latitude,
          "longitude": after.longitude,
        });
        // Update All Events in this Location
        const eventLocationsSnapshot = await db.collection("7777 Locations").doc(locationId).collection("Events").get();
        functions.logger.log(
          "Location Events Num =",
          eventLocationsSnapshot.size,
          );
        for (var i in eventLocationsSnapshot.docs) {
          const id = eventLocationsSnapshot.docs[i].id;
          await db
          .collection("7777 Events")
          .doc(id)
          .collection("Locations")
          .doc(locationId)
          .update({
            "description": after.description,
            "latitude": after.latitude,
            "longitude": after.longitude,
          });
        }
      }
      return null;
    });

// User Joins Brand
exports.zzzzUserJoinsBrand = functions
.region("europe-west1")
.firestore
.document("/7777 Brands/{brandId}/Users/{userId}")
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
      const userSnapshot = await db.collection("7777 Users").doc(userId).get();
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
      const brandSnapshot = await db.collection("7777 Brands").doc(brandId).get();
      const brandDoc = brandSnapshot.data();
      functions.logger.log(
        "Brand Cover Data:",
        brandDoc,
        );

      // Get Data of the Brand Room
      const roomSnapshot = await db.collection("7777 Rooms").doc(brandDoc.roomId).get();
      const roomDoc = roomSnapshot.data();

      var metadataMessage = {};
      var metadataRoom = {};

      functions.logger.log(
       "UserIds",
       roomDoc.userIds,
       );
      roomDoc.userIds.push(userId);

      if (roomDoc.lastMessages != undefined) {
        metadataMessage = roomDoc.lastMessages[0].metadata;
        metadataMessage[userId] = "delivered";
        // Updates all messages so that they are delivered for new user.
        await db.doc("7777 Rooms" + "/" + brandDoc.roomId + "/messages/" + roomDoc.lastMessages[0].remoteId).update({
          metadata: metadataMessage,
          status: "delivered",
        })
      }

      // Creates metadata for new user and adds it.
      metadataRoom = roomDoc.metadata;
      metadataRoom["trainer" + userId] = userDoc.isTrainer;
      metadataRoom["active" + userId] = false;
      await db.doc("7777 Rooms" + "/" + brandDoc.roomId).update({
        metadata: metadataRoom,
        userIds: roomDoc.userIds,
      })

      // Add the Brand Cover Data to Users/Brands Collection
      let date = new Date();
      let day = date.getDate();
      let month = date.getMonth() + 1;
      if (month < 10) {
        month = "0"+month;
      }
      let year = date.getFullYear().toString();
      let result = year.slice(2, 4);
      var formatted = day+"-"+month+"-"+result;
      await db.doc("/7777 Users/"+userId+"/Brands/"+brandId+"").set({
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
              title: "Has creado tu marca "+brandDoc.name+" ✅",
              body: "Ahora podrás usar todas las funcionalidades de calendarización, control y gestión que ofrece Mamba",
            },
            data: {
              route: "BrandPage",
            },
          };
        } else {
          payload = {
            notification: {
              title: "Has creat la teva marca "+brandDoc.name+" ✅",
              body: "Ara podràs usar totes les funcionalitats de calendarización, control i gestió que ofereix Mamba",
            },
            data: {
              route: "BrandPage",
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
            title: "Te has unido a "+brandDoc.name+" ✅",
            body: "Consulta el calendario para participar en tu primera sesión",
          },
          data: {
            route: "BrandPage",
          },
        };
      } else {
        payload = {
          notification: {
            title: "T'has unit a "+brandDoc.name+" ✅",
            body: "Consulta el calendari per participar en la teva primera sessió",
          },
          data: {
            route: "BrandPage",
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
        const adminSnapshot = await db.collection("7777 Users").doc(brandDoc.adminID).get();
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
        const brandUsersSnapshot = await db.collection("7777 Brands").doc(brandId).collection("Users").get();
        let numberMembers = brandUsersSnapshot.size;
        functions.logger.log(
          "Number Members",
          numberMembers,
          );
        if (adminDoc.idioma == "es") {
         payload = {
          notification: {
            title: "Nuevo miembro en "+brandDoc.name+" ➕1️⃣ ",
            body: userDoc.name+" se ha unido. Ya sois un total de "+numberMembers.toString()+" miembros",
          },
          data: {
            route: "Notifications",
          },
        };
      } else {
        payload = {
          notification: {
            title: "Nou membre a "+brandDoc.name+" ➕1️⃣ ",
            body: userDoc.name+" s'ha unit. Ja sou un total de "+numberMembers.toString()+" membres",
          },
          data: {
            route: "Notifications",
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
      // Count Brand Members
      brandUsersSnapshot = await db.collection("7777 Brands").doc(brandId).collection("Users").get();
      let numClients = 0;
      let numTrainers = 0;
      for (var i in brandUsersSnapshot.docs) {
        const brandUsersDoc = brandUsersSnapshot.docs[i].data();
        if (brandUsersDoc.isTrainer) {
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
      // Update Brand Members
      await db
      .collection("7777 Brands")
      .doc(brandId)
      .update({
        "numClients": numClients,
        "numTrainers": numTrainers,
      });
      return null;
    });

// User Leaves Brand
exports.zzzzUserLeavesBrand = functions
.region("europe-west1")
.firestore
.document("/7777 Brands/{brandId}/Users/{userId}")
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
      const brandSnapshot = await db.collection("7777 Brands").doc(brandId).get();
      const brandDoc = brandSnapshot.data();
      functions.logger.log(
        "Brand Cover Data:",
        brandDoc,
        );
      // Delete Brand in User´s Brand Subcollection
      await db.collection("7777 Users").doc(userId).collection("Brands").doc(brandId).delete();
      // Get Data of the Room
      const roomSnapshot = await db.collection("7777 Rooms").doc(brandDoc.roomId).get();
      const roomDoc = roomSnapshot.data();
      var filtered = roomDoc.userIds.filter(function(element) {
        return element != userId;
      });
      await db.doc("7777 Rooms" + "/" + brandDoc.roomId).update({
        userIds: filtered,
      });
      // Send Notification to Brand Owners
      const brandOwnersSnapshot = await db.collection("7777 Brands")
      .doc(brandId)
      .collection("Users")
      .where("role", "=", 1)
      .get();
      // Count the number of Members
      const brandUsersSnapshot = await db.collection("7777 Brands").doc(brandId).collection("Users").get();
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
              title: "Miembro ha abandonado "+brandDoc.name+" ➖1️⃣ ",
              body: userDoc.firstName+" "+userDoc.lastName+" se ha ido, ahora sois un total de "+numberMembers.toString()+" miembros",
            },
            data: {
              route: "Notifications",
            },
          };
        } else {
          payload = {
            notification: {
              title: "Membre ha abandonat "+brandDoc.name+" ➖1️⃣ ",
              body: userDoc.firstName+" "+userDoc.lastName+" ha marxat, ara sou un total "+numberMembers.toString()+" membres",
            },
            data: {
              route: "Notifications",
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
      // Count Brand Members
      let numClients = 0;
      let numTrainers = 0;
      for (var i in brandUsersSnapshot.docs) {
        const brandUsersDoc = brandUsersSnapshot.docs[i].data();
        if (brandUsersDoc.isTrainer) {
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
      // Update Brand Members
      await db
      .collection("7777 Brands")
      .doc(brandId)
      .update({
        "numClients": numClients,
        "numTrainers": numTrainers,
      });
      return null;
    });

// User Adds Location
exports.zzzzUserAddsLocation = functions
.region("europe-west1")
.firestore
.document("/7777 Locations/{locationId}")
.onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const locationId = context.params.locationId;
      // Get Data of the Location
      const locationSnapshot = await db.collection("7777 Locations").doc(locationId).get();
      const locationDoc = locationSnapshot.data();
      functions.logger.log(
        "Location Data:",
        locationDoc
        );
      // Add Location to Brands Collection
      await db.doc("/7777 Brands/"+locationDoc.brandID+"/Locations/"+locationId+"").set({
       "isBaseLocation": locationDoc.isBaseLocation,
       "description": locationDoc.description,
       "latitude": locationDoc.latitude,
       "longitude": locationDoc.longitude,
     });
      return null;
    });

// User Deletes Location
exports.zzzzUserDeletesLocation = functions
.region("europe-west1")
.firestore
.document("/7777 Locations/{locationId}")
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
        .collection("7777 Brands")
        .doc(locationDoc.brandID)
        .collection("Locations")
        .doc(locationId)
        .delete();
        /*
        // Check Location Has Future Events
        let futureEvents = [];
        let now = new Date();
        const locationEventsSnapshot = await db.collection("7777 Locations").doc(locationId).collection("Events").get();
        for (var i in locationEventsSnapshot.docs) {
          const id = locationEventsSnapshot.docs[i].id;
          const data = locationEventsSnapshot.docs[i].data();
          let date = new Date(date.year, date.month-1, date.day, date.hour, date.minute);
          if (now < date) {
            futureEvents.push(id);
          }
        }
        functions.logger.log(
            "Events to be modified",
            futureEvents,
          );
        if (futureEvents.length != 0) {

           // Update Future Events To Base Location
           for (var i in futureEvents.length) {
             const eventId = futureEvents[i];

           }
           // Delete Previous Location
           await _firestore
               .collection("7777 Events")
               .doc(eventId)
               .collection("Locations")
               .doc(previousLocation)
               .delete();
           // Add New Location
           Location location = await this.getSingleLocation(locationId);
           await _firestore
               .collection("7777 Events")
               .doc(eventId)
               .collection("Locations")
               .doc(locationId)
               .set({
                 "description": location.description,
                 "longitude": location.longitude,
                 "latitude": location.latitude,
               });
             } */
             return null;
           });

// User Sends Request
exports.zzzzUserSendsRequest = functions
.region("europe-west1")
.firestore
.document("/7777 Users/{userId}/Requests/{requestId}")
.onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const requestId = context.params.requestId;
      const userId = context.params.userId;
      // Get Data of the Request
      const requestSnapshot = await db.collection("7777 Users").doc(userId).collection("Requests").doc(requestId).get();
      const requestDoc = requestSnapshot.data();
      functions.logger.log(
        "Request Cover Data:",
        requestDoc.brandId,
        requestDoc.name,
        );
      // Get Data of the Brand
      const brandId = requestDoc.brandId;
      const brandSnapshot = await db.collection("7777 Brands").doc(brandId).get();
      const brandDoc = brandSnapshot.data();
      functions.logger.log(
        "Brand Data:",
        brandDoc,
        );
      // Add Request to Brands Request collection
      await db
      .collection("7777 Brands")
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
      const brandOwnersSnapshot = await db.collection("7777 Brands")
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
              title: "Nueva solicitud de afiliación ⁉️",
              body: requestDoc.name+" quiere formar parte de tu marca "+ brandDoc.name,
            },
            data: {
              route: "Notifications",                
            },
          };
        } else {
          payload = {
            notification: {
              title: "Nova sol·licitud d'afiliació ⁉️",
              body: requestDoc.name+" vol formar part de la teva marca "+ brandDoc.name,
            },
            data: {
              route: "Notifications",                  
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
exports.zzzzUserDeletesRequest = functions
.region("europe-west1")
.firestore
.document("/7777 Users/{userId}/Requests/{requestId}")
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
      .collection("7777 Brands")
      .doc(requestDoc.brandId)
      .collection("Requests")
      .doc(requestId)
      .delete();
      return null;
    });

// User Adds Event
exports.zzzzUserAddsEvent = functions
.region("europe-west1")
.firestore
.document("/7777 Events/{eventId}")
.onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const eventId = context.params.eventId;
      // Get Data of the Event
      const eventSnapshot = await db.collection("7777 Events").doc(eventId).get();
      const eventDoc = eventSnapshot.data();
      // Get Data of the Event Brand
      const eventBrandSnapshot = await db.collection("7777 Events").doc(eventId).collection("Brands").get();
      // Get Data of the Event Users
      const eventUsersSnapshot = await db.collection("7777 Events").doc(eventId).collection("Users").get();
      // Get Data of the Event Location
      const eventLocationsSnapshot = await db.collection("7777 Events").doc(eventId).collection("Locations").get();
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
      let now = new Date();
      /* Add Event to Brands Event Subcollection
      for (var i in eventBrandSnapshot.docs) {
        const id = eventBrandSnapshot.docs[i].id;
        await db
        .collection("7777 Brands")
        .doc(id)
        .collection("Events")
        .doc(eventId).set({
          "title": eventDoc.title,
          "doneAt": eventDoc.doneAt,
          "year": eventDoc.year,
          "month": eventDoc.month,
          "day": eventDoc.day,
          "hour": eventDoc.hour,
          "minute": eventDoc.minute,
          "duration": eventDoc.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
          "maxMembers": eventDoc.maxMembers,
        });
      }
      */
      // Add Event to Locations Event Subcollection
      for (var i in eventLocationsSnapshot.docs) {
        const id = eventLocationsSnapshot.docs[i].id;
        await db
        .collection("7777 Locations")
        .doc(id)
        .collection("Events")
        .doc(eventId).set({
          "isPrivate": eventDoc.isPrivate,
          "title": eventDoc.title,
          "imageUrl": eventDoc.imageUrl,
          "doneAt": eventDoc.doneAt,
          "year": eventDoc.year,
          "month": eventDoc.month,
          "day": eventDoc.day,
          "hour": eventDoc.hour,
          "minute": eventDoc.minute,
          "duration": eventDoc.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
          "maxMembers": eventDoc.maxMembers,
        });
        // If Event Private
        // Add to Locations/Events/Private Events/PrivateEvents
        if (eventDoc.isPrivate == true) {
         await db
         .collection("7777 Locations")
         .doc(id)
         .collection("Events")
         .doc("Private Events")
         .collection("Private Events")
         .doc(eventId).set({
          "isPrivate": eventDoc.isPrivate,
          "title": eventDoc.title,
          "imageUrl": eventDoc.imageUrl,
          "doneAt": eventDoc.doneAt,
          "year": eventDoc.year,
          "month": eventDoc.month,
          "day": eventDoc.day,
          "hour": eventDoc.hour,
          "minute": eventDoc.minute,
          "duration": eventDoc.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
          "maxMembers": eventDoc.maxMembers,
        });
       }       
     }
     return null;
   });

// User Deletes Event
exports.zzzzUserDeletesEvent = functions
.region("europe-west1")
.firestore
.document("/7777 Events/{eventId}")
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
      const eventUsersSnapshot = await db.collection("7777 Events").doc(eventId).collection("Users").get();
      functions.logger.log(
        "eventUsersSnapshot size",
        eventUsersSnapshot.size,
        );
      // Get Data of the Event Brand
      const eventBrandSnapshot = await db.collection("7777 Events").doc(eventId).collection("Brands").get();
      functions.logger.log(
        "eventBrandSnapshot size",
        eventBrandSnapshot.size,
        );
      // Get Data of the Event Locations
      const eventLocationsSnapshot = await db.collection("7777 Events").doc(eventId).collection("Locations").get();
      functions.logger.log(
        "eventLocationsSnapshot size",
        eventLocationsSnapshot.size,
        );
      // Delete Users Subcollection in Event
      for (var i in eventUsersSnapshot.docs) {
        await db
        .collection("7777 Events")
        .doc(eventId)
        .collection("Users")
        .doc(eventUsersSnapshot.docs[i].id)
        .delete();
      }
      /* Delete Event in Brands Subcollection
      for (var i in eventBrandSnapshot.docs) {
        await db
        .collection("7777 Brands")
        .doc(eventBrandSnapshot.docs[i].id)
        .collection("Events")
        .doc(eventId)
        .delete();
        // Delete Brands in Event
        await db
        .collection("7777 Events")
        .doc(eventId)
        .collection("Brands")
        .doc(eventBrandSnapshot.docs[i].id)
        .delete();
      }
      */
      // Delete Event in Locations Subcollection
      for (var i in eventLocationsSnapshot.docs) {
        await db
        .collection("7777 Locations")
        .doc(eventLocationsSnapshot.docs[i].id)
        .collection("Events")
        .doc(eventId)
        .delete();
        // If Event Private
        // Delete from Locations/Events/Private Events/PrivateEvents Subcollection
        if (eventDoc.isPrivate == true) {
         await db
         .collection("7777 Locations")
         .doc(eventLocationsSnapshot.docs[i].id)
         .collection("Events")
         .doc("Private Events")
         .collection("Private Events")
         .doc(eventId)
         .delete();
       }
        // Delete Locations in Event
        await db
        .collection("7777 Events")
        .doc(eventId)
        .collection("Locations")
        .doc(eventLocationsSnapshot.docs[i].id)
        .delete();
      }
      return null;
    });

// User Joins Event
exports.zzzzUserJoinsEvent = functions
.region("europe-west1")
.firestore
.document("/7777 Events/{eventId}/Users/{userId}")
.onCreate( async (change, context) => {
      // Get the value of the context triggers.
      const eventId = context.params.eventId;
      const userId = context.params.userId;
      // Get Event Data
      const eventSnapshot = await db.collection("7777 Events").doc(eventId).get();
      const eventDoc = eventSnapshot.data();
      functions.logger.log(
        "eventDoc",
        eventDoc,
        );
      // Get User Data
      const userSnapshot = await db.collection("7777 Users").doc(userId).get();
      const userDoc = userSnapshot.data();
      // Get Event User Data
      const eventUserSnapshot = await db.collection("7777 Events").doc(eventId).collection("Users").doc(userId).get();
      const eventUserDoc = eventUserSnapshot.data();
      // Get Event Brands Data
      const eventBrandsSnapshot = await db.collection("7777 Events").doc(eventId).collection("Brands").get();
      // Get Data of the Event Locations
      const eventLocationsSnapshot = await db.collection("7777 Events").doc(eventId).collection("Locations").get();
      // Count the Number of Clients and Trainers
      const eventUsersSnapshot = await db.collection("7777 Events").doc(eventId).collection("Users").get();
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
      /* Update Event Assisting Members
      await db
      .collection("7777 Events")
      .doc(eventId)
      .update({
        "numClients": numClients,
        "numTrainers": numTrainers,
      });*/
      // Add Event To Users Event Subcollection
      await db
      .collection("7777 Users")
      .doc(userId)
      .collection("Events")
      .doc(eventId).set({
        "isPrivate": eventDoc.isPrivate,
        "title": eventDoc.title,
        "imageUrl": eventDoc.imageUrl,
        "doneAt": eventDoc.doneAt,
        "year": eventDoc.year,
        "month": eventDoc.month,
        "day": eventDoc.day,
        "hour": eventDoc.hour,
        "minute": eventDoc.minute,
        "duration": eventDoc.duration,
        "numTrainers": numTrainers,
        "numClients": numClients,
        "maxMembers": eventDoc.maxMembers,
      });

      //TODO AFEGIT JOAN MANEL INTEGRACIÓ BONOS
      /* Add event to purchase collection
      await db
        .collection("7777 Payments")
        .doc("Purchases")
        .collection("Purchases")
        .doc(eventUserDoc.purchaseId)
        .collection("Events")
        .doc(eventId)
        .set({
          "isPrivate": eventDoc.isPrivate,
          "title": eventDoc.title,
          "imageUrl": eventDoc.imageUrl,
          "doneAt": eventDoc.doneAt,
          "year": eventDoc.year,
          "month": eventDoc.month,
          "day": eventDoc.day,
          "hour": eventDoc.hour,
          "minute": eventDoc.minute,
          "duration": eventDoc.duration,
          "numTrainers": numTrainers,
          "numClients": numClients,
          "maxMembers": eventDoc.maxMembers,
      });
      */
      
      // If Event Private
      // Add to Users/Events/Private Events/PrivateEvents
      if (eventDoc.isPrivate == true) {
       await db
       .collection("7777 Users")
       .doc(userId)
       .collection("Events")
       .doc("Private Events")
       .collection("Private Events")
       .doc(eventId).set({
        "isPrivate": eventDoc.isPrivate,
        "title": eventDoc.title,
        "imageUrl": eventDoc.imageUrl,
        "doneAt": eventDoc.doneAt,
        "year": eventDoc.year,
        "month": eventDoc.month,
        "day": eventDoc.day,
        "hour": eventDoc.hour,
        "minute": eventDoc.minute,
        "duration": eventDoc.duration,
        "numTrainers": numTrainers,
        "numClients": numClients,
        "maxMembers": eventDoc.maxMembers,
      });
     }
      // Update Number of Client and Trainers on Each of Event Subcollection
      // User´s Event First
      for (var i in eventUsersSnapshot.docs) {
        const id = eventUsersSnapshot.docs[i].id;
        await db
        .collection("7777 Users")
        .doc(id)
        .collection("Events")
        .doc(eventId)
        .update({
          "numClients": numClients,
          "numTrainers": numTrainers,
        });
        // If Event Private
        // Update Cover Data Also
        if (eventDoc.isPrivate == true) {
          await db
          .collection("7777 Users")
          .doc(id)
          .collection("Events")
          .doc("Private Events")
          .collection("Private Events")
          .doc(eventId)
          .update({
            "numClients": numClients,
            "numTrainers": numTrainers,
          });
        }
      }
      // Brand´s Event Second
      for (var i in eventBrandsSnapshot.docs) {
        const id = eventBrandsSnapshot.docs[i].id;
        await db
        .collection("7777 Brands")
        .doc(id)
        .collection("Events")
        .doc(eventId)
        .update({
          "numClients": numClients,
          "numTrainers": numTrainers,
        });
        // If Event Private
        // Update Cover Data Also
        if (eventDoc.isPrivate == true) {
          await db
          .collection("7777 Brands")
          .doc(id)
          .collection("Events")
          .doc("Private Events")
          .collection("Private Events")
          .doc(eventId)
          .update({
            "numClients": numClients,
            "numTrainers": numTrainers,
          });
        }
      }
      // Location´s Event Third
      for (var i in eventLocationsSnapshot.docs) {
        const id = eventLocationsSnapshot.docs[i].id;
        await db
        .collection("7777 Locations")
        .doc(id)
        .collection("Events")
        .doc(eventId)
        .update({
          "numClients": numClients,
          "numTrainers": numTrainers,
        });
          // If Event Private
          // Update Cover Data Also
          if (eventDoc.isPrivate == true) {
            await db
            .collection("7777 Locations")
            .doc(id)
            .collection("Events")
            .doc("Private Events")
            .collection("Private Events")
            .doc(eventId)
            .update({
              "numClients": numClients,
              "numTrainers": numTrainers,
            });
          }
        }
      // Send Notifications
      if (userDoc.isTrainer == false) {
        // Don´t Send Full Notification When it is a Private Event
        if (eventDoc.isPrivate != true) {
          // Send Notification to Trainers if booked capacity == 100% or > 50%, only when Clients Join
          if (eventDoc.maxMembers == numClients) {
              // Event is full
              functions.logger.log(
                "NOTIFICATION IS FULL",
                );
              for (var i in eventUsersSnapshot.docs) {
                const id = eventUsersSnapshot.docs[i].id;
                const eventUsersDoc = eventUsersSnapshot.docs[i].data();
                if (eventUsersDoc.isTrainer) {
                  const trainerSnapshot = await db.collection("7777 Users").doc(id).get();
                  const trainerDoc = trainerSnapshot.data();
                  functions.logger.log(
                    "trainerDoc",
                    trainerDoc,
                    );
                  var payload = 0;
                  let date = new Date(eventDoc.year, eventDoc.month-1, eventDoc.day);
                  if (trainerDoc.idioma == "es") {
                    // Date To String
                    let dateString = date.toLocaleDateString('es-ES', { weekday:"long", day:"numeric", month:"long"});
                    // Hour and Minutes to String
                    let eventTimeTime = eventDoc.hour+":";
                    let minutes = eventDoc.minute == "0" ? "00" : eventDoc.minute;
                    eventTimeTime += minutes;
                    // Send Payload
                    payload = {
                      notification: {
                        title: "Evento totalmente reservado 💯",
                        body: "El evento "+eventDoc.title+" se realizará el "+dateString+" a las "+eventTimeTime,
                      },
                      data: {
                        route: eventId,
                      },
                    };
                  } else {
                    // Date To String
                    let dateString = date.toLocaleDateString('ca-CA', { weekday:"long", day:"numeric", month:"long"});
                    // Hour and Minutes to String
                    let eventTimeTime = eventDoc.hour+":";
                    let minutes = eventDoc.minute == "0" ? "00" : eventDoc.minute;
                    eventTimeTime += minutes;
                    // Send Payload
                    payload = {
                      notification: {
                        title: "Esdeveniment totalment reservat 💯",
                        body: "L'esdeveniment "+eventDoc.title+" es realitzarà el "+dateString+" a les "+eventTimeTime,            
                      },
                      data: {
                        route: eventId,
                      },
                    };
                  }
                  functions.logger.log(
                    "Payload",
                    payload
                    );
                  response = await admin.messaging().sendToDevice(trainerDoc.notificationToken, payload);
                  functions.logger.log(
                    "Response",
                    response
                    );
                }
              }
            } else {
            // First one to go over 50%
            if (numClients / eventDoc.maxMembers > 0.49 && (numClients - 1) / eventDoc.maxMembers < 0.50) {
              // Send Over 50% Notification to All Event Trainers
              functions.logger.log(
                "NOTIFICATION OVER 50%",
                );
              for (var i in eventUsersSnapshot.docs) {
                const id = eventUsersSnapshot.docs[i].id;
                const eventUsersDoc = eventUsersSnapshot.docs[i].data();
                if (eventUsersDoc.isTrainer) {
                  const trainerSnapshot = await db.collection("7777 Users").doc(id).get();
                  const trainerDoc = trainerSnapshot.data();
                  functions.logger.log(
                    "trainerDoc",
                    trainerDoc,
                    );
                  var payload = 0;
                  let date = new Date(eventDoc.year, eventDoc.month-1, eventDoc.day);
                  if (trainerDoc.idioma == "es") {
                      // Date To String
                      let dateString = date.toLocaleDateString('es-ES', { weekday:"long", day:"numeric", month:"long"});
                      // Hour and Minutes to String
                      let eventTimeTime = eventDoc.hour+":";
                      let minutes = eventDoc.minute == "0" ? "00" : eventDoc.minute;
                      eventTimeTime += minutes;
                      // Send Payload
                      payload = {
                        notification: {
                          title: "Cada vez quedan menos plazas ⏱️",
                          body: "El evento "+eventDoc.title+" ya tiene un 50% de las plazas reservadas",
                        },
                        data: {
                          route: eventId,
                        },
                      };
                    } else {
                      // Date To String
                      let dateString = date.toLocaleDateString('ca-CA', { weekday:"long", day:"numeric", month:"long"});
                      // Hour and Minutes to String
                      let eventTimeTime = eventDoc.hour+":";
                      let minutes = eventDoc.minute == "0" ? "00" : eventDoc.minute;
                      eventTimeTime += minutes;
                      // Send Payload
                      payload = {
                        notification: {
                          title: "Cada cop queden menys places ⏱️",
                          body: "L'esdeveniment "+eventDoc.title+" ja té un 50% de les places reservades",
                        },
                        data: {
                          route: eventId,
                        },
                      };
                    }
                    functions.logger.log(
                      "Payload",
                      payload
                      );
                    response = await admin.messaging().sendToDevice(trainerDoc.notificationToken, payload);
                    functions.logger.log(
                      "Response",
                      response
                      );
                  }
                }
              }
            }
          }
        }
      // Send Notification to User if added directly
      if (eventUserDoc.invitedDirectly == true) {
            // Invited to Event
            functions.logger.log(
              "NOTIFICATION CLIENT INVITED DIRECTLY TO EVENT",
              );
            functions.logger.log(
              "userDoc",
              userDoc,
              );
            var payload = 0;
            let date = new Date(eventDoc.year, eventDoc.month-1, eventDoc.day);
            if (userDoc.idioma == "es") {
             // Date To String
             let dateString = date.toLocaleDateString('es-ES', { weekday:"long", day:"numeric", month:"long"});
             // Hour and Minutes to String
             let eventTimeTime = eventDoc.hour+":";
             let minutes = eventDoc.minute == "0" ? "00" : eventDoc.minute;
             eventTimeTime += minutes;
             // Send Payload
             payload = {
               notification: {
                 title: "Nuevo evento programado ⁉️ 🏋️‍♂️",
                 body: "Te han añadido al evento "+eventDoc.title+". Se realizará el "+dateString+" a las "+eventTimeTime,
               },
               data: {
                 route: eventId,
               },
             };
           } else {
             // Date To String
             let dateString = date.toLocaleDateString('ca-CA', { weekday:"long", day:"numeric", month:"long"});
             // Hour and Minutes to String
             let eventTimeTime = eventDoc.hour+":";
             let minutes = eventDoc.minute == "0" ? "00" : eventDoc.minute;
             eventTimeTime += minutes;
             // Send Payload
             payload = {
               notification: {
                 title: "Nou esdeveniment programat ⁉️ 🏋️‍♂️",
                 body: "T'han afegit a l'esdeveniment "+eventDoc.title+". Es realitzarà el "+dateString+" a les "+eventTimeTime,
               },
               data: {
                 route: eventId,
               },
             };
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
         }
         return null;
       });

// User Leaves Event
exports.zzzzUserLeavesEvent = functions
.region("europe-west1")
.firestore
.document("/7777 Events/{eventId}/Users/{userId}")
.onDelete( async (change, context) => {
      // Get the value of the context triggers.
      const eventId = context.params.eventId;
      const userId = context.params.userId;
      // Get Event Data
      const eventSnapshot = await db.collection("7777 Events").doc(eventId).get();
      const eventDoc = eventSnapshot.data();
      functions.logger.log(
        "eventDoc",
        eventDoc,
        );
      // Get Event Brands Data
      const eventBrandsSnapshot = await db.collection("7777 Events").doc(eventId).collection("Brands").get();
      // Count the Number of Clients and Trainers
      const eventUsersSnapshot = await db.collection("7777 Events").doc(eventId).collection("Users").get();
      // Get Data of the Event Locations
      const eventLocationsSnapshot = await db.collection("7777 Events").doc(eventId).collection("Locations").get();
      functions.logger.log(
        "eventLocationsSnapshot size",
        eventLocationsSnapshot.size,
        );
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
      // Delete Event To Users Event Subcollection
      await db
      .collection("7777 Users")
      .doc(userId)
      .collection("Events")
      .doc(eventId)
      .delete();
      // If Event Private
      // Delete to Users/Events/Private Events/PrivateEvents
      if (eventDoc == undefined || eventDoc.isPrivate == true) {
       await db
       .collection("7777 Users")
       .doc(userId)
       .collection("Events")
       .doc("Private Events")
       .collection("Private Events")
       .doc(eventId)
       .delete();
     }
      /* Update Event Assisting Members
      await db
      .collection("7777 Events")
      .doc(eventId)
      .update({
        "numClients": numClients,
        "numTrainers": numTrainers,
      });*/
      // Update Number of Client and Trainers on Each of Event Subcollection
      // User´s Event First
      for (var i in eventUsersSnapshot.docs) {
        const id = eventUsersSnapshot.docs[i].id;
        await db
        .collection("7777 Users")
        .doc(id)
        .collection("Events")
        .doc(eventId)
        .update({
          "numClients": numClients,
          "numTrainers": numTrainers,
        });
          // If Event Private
          // Update Cover Data Also
          if (eventDoc == undefined || eventDoc.isPrivate == true) {
            await db
            .collection("7777 Users")
            .doc(id)
            .collection("Events")
            .doc("Private Events")
            .collection("Private Events")
            .doc(eventId)
            .update({
              "numClients": numClients,
              "numTrainers": numTrainers,
            });
          }
        }
      // Brand´s Event Second
      for (var i in eventBrandsSnapshot.docs) {
        const id = eventBrandsSnapshot.docs[i].id;
        await db
        .collection("7777 Brands")
        .doc(id)
        .collection("Events")
        .doc(eventId)
        .update({
          "numClients": numClients,
          "numTrainers": numTrainers,
        });
          // If Event Private
          // Update Cover Data Also
          if (eventDoc == undefined || eventDoc.isPrivate == true) {
            await db
            .collection("7777 Brands")
            .doc(id)
            .collection("Events")
            .doc("Private Events")
            .collection("Private Events")
            .doc(eventId)
            .update({
              "numClients": numClients,
              "numTrainers": numTrainers,
            });
          }
        }
      // Location´s Event Third
      for (var i in eventLocationsSnapshot.docs) {
        const id = eventLocationsSnapshot.docs[i].id;
        await db
        .collection("7777 Locations")
        .doc(id)
        .collection("Events")
        .doc(eventId)
        .update({
          "numClients": numClients,
          "numTrainers": numTrainers,
        });
        // If Event Private
        // Update Cover Data Also
        if (eventDoc == undefined || eventDoc.isPrivate == true) {
          await db
          .collection("7777 Locations")
          .doc(id)
          .collection("Events")
          .doc("Private Events")
          .collection("Private Events")
          .doc(eventId)
          .update({
            "numClients": numClients,
            "numTrainers": numTrainers,
          });
        }
      }
      return null;
    });

// Change Message Status
exports.zzzzChangeMessageStatus = functions
.region("europe-west1")
.firestore
.document("/7777 Rooms/{roomId}/messages/{messageId}")
.onWrite(async (change, context) => {
    // Get context params
    const roomId = context.params.roomId;
    const messageId = context.params.messageId;
    // Message after Data
    const message = change.after.data();
    const previousValue = change.before.data();
    functions.logger.log(
     "BEFORE",
     previousValue
     );
    functions.logger.log(
     "AFTER",
     message
     );
    var payload = 0;
    // Get Room Data
    const roomSnapshot =  await db.collection("7777 Rooms").doc(roomId).get();
    const roomDoc = roomSnapshot.data();
    functions.logger.log(
     "RoomDoc",
     roomDoc
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
        for (let i = 0; i < roomDoc.userIds.length; ++i) {
          functions.logger.log(
            "Incremental",
            roomDoc.userIds[i],
            );
          if (message.authorId != roomDoc.userIds[i] && roomDoc.metadata["active" + roomDoc.userIds[i]] == false) {
           const authorUserSnapshot = await db.collection("7777 Users").doc(message.authorId).get();
           const authorUserDoc = authorUserSnapshot.data();
           functions.logger.log(
             "Es activo",
             roomDoc.userIds[i],
             );
           messageStatus = "delivered";
           metadata[roomDoc.userIds[i]] = "delivered";
           userSnapshot = await db.collection("7777 Users").doc(roomDoc.userIds[i]).get();
           userDoc = userSnapshot.data();
           functions.logger.log(
            "User to Send Data",
            userDoc,
            );
             // Send Notification To Users who received the message and not active
             if (roomDoc.type == "group") {
              payload = {
                notification: {
                  title: roomDoc.name,
                  body: authorUserDoc.firstName + ' ' + authorUserDoc.lastName + ': ' + message.text,
                },
                data: {
                  route: "Chat",
                },
              };
            } else {
              payload = {
               notification: {
                 title: authorUserDoc.firstName + ' ' + authorUserDoc.lastName + ':',
                 body: message.text,
               },
               data: {
                 route: "Chat",
               },
             };
           }
           var response = await admin.messaging().sendToDevice(userDoc.notificationToken, payload);
           functions.logger.log(
             "Response",
             response
             );
         } else {
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
        return db.doc("7777 Rooms" + "/" + roomId).update({
          lastMessages: [message],
          updatedAt: message.updatedAt,
        })
      }
    } else if (roomDoc.lastMessages[0].remoteId == message.remoteId) {
      functions.logger.log(
       "message ASQUI",
       message.metadata,
       );
      return db.doc("7777 Rooms" + "/" + roomId).update({
        lastMessages: [message],
      })
    } else {
      return null
    }
  })

// User Sends Bono Request
exports.userSendsBonoRequest = functions
.region("europe-west1")
.firestore
.document("/7777 Brands/{brandId}/Bonos/Bonos Requests/Bonos Requests/{bonoRequestId}")
.onCreate( async (snap, context) => {
      // Get the value of the context triggers.
      const brandId = context.params.brandId;
      const bonoRequestId = context.params.bonoRequestId;

      // Get Data of the Request
      //const requestSnapshot = await db.collection("7777 Brands").doc(brandId).collection("Bonos").doc("Bonos Requests").collection("Bonos Requests").doc(bonoRequestId).get();
      const requestDoc = snap.data();

      // Get Data of Bono
      const bonoSnapshot = await db.collection("7777 Brands").doc(brandId).collection("Bonos").doc(requestDoc.bonoId).get();
      const bonoDoc = snap.data();

       // Get Data of the Brand
       const brandSnapshot = await db.collection("7777 Brands").doc(brandId).get();
       const brandDoc = brandSnapshot.data();

       functions.logger.log(
        "test",
        brandDoc.adminID
        );

       const userSnapshot = await db.collection("7777 Users").doc(brandDoc.adminID).get();
       const userDoc = userSnapshot.data();

       if (userDoc.idioma == "es") {
        payload = {
          notification: {
            title: "Nueva solicitud de compra 🤑📈",
            body: "Tu bono "+bonoDoc.title.toUpperCase()+" tiene mucho éxito",
          },
          data: {
            route: "BonosRequests",                
          },
        };
      } else {
        payload = {
          notification: {
            title: "Nova sol·licitud de compra 🤑📈",
            body: "El teu val "+bonoDoc.title.toUpperCase()+" té molt d'èxit",
          },
          data: {
            route: "BonosRequests",                  
          },
        }
      }
      functions.logger.log(
       "Payload",
       payload
       );
      var response = await admin.messaging().sendToDevice(userDoc.notificationToken, payload);


      return null;
    });

// User Purchases Bono
exports.userPurchasesBono = functions
.region("europe-west1")
.firestore
.document("/7777 Payments/Purchases/Purchases/{purchaseId}")
.onCreate( async (snap, context) => {

  const purchaseId = context.params.purchaseId;
  const purchaseDoc = snap.data();

  const userId = purchaseDoc.userId;
  const bonoId = purchaseDoc.bonoId;
  const brandId =  purchaseDoc.brandId;

       //Get data of the bono

       const bonoSnapshot = await db.collection("7777 Brands").doc(brandId).collection("Bonos").doc(bonoId).get();
       const bonoDoc = bonoSnapshot.data();

       //Add purchases

       await db.collection("7777 Brands").doc(brandId).collection("Bonos").doc(bonoId).collection("Purchases").doc(purchaseId).set({
         "purchasedAt": purchaseDoc.purchasedAt,
         "userId": purchaseDoc.userId,
         "price": purchaseDoc.price,
         "paymentMethod": purchaseDoc.paymentMethod,
       });

       await db.collection("7777 Brands").doc(brandId).collection("Users").doc(userId).collection("Purchases").doc(purchaseId).set({
         "purchasedAt": purchaseDoc.purchasedAt,
         "bonoId": purchaseDoc.bonoId,
         "price": purchaseDoc.price,
         "paymentMethod": purchaseDoc.paymentMethod,
       });

       await db.collection("7777 Users").doc(userId).collection("Purchases").doc(purchaseId).set({
         "purchasedAt": purchaseDoc.purchasedAt,
         "bonoId": purchaseDoc.bonoId,
         "price": purchaseDoc.price,
         "paymentMethod": purchaseDoc.paymentMethod,
         "brandId": purchaseDoc.brandId,
       });

       await db.collection("7777 Users").doc(userId).collection("Bonos").doc(bonoId).set({
         "title": bonoDoc.title,
         "sessions": bonoDoc.sessions,
         "price": purchaseDoc.price,
         "purchaseId": purchaseId,
         "brandId": purchaseDoc.brandId,
       });


       return null;
     });

     // Updates User Bono
     exports.zzzzupdateUserBono = functions
     .region("europe-west1")
     .firestore
     .document("/7777 Users/{userId}/Bonos/{bonoId}")
     .onUpdate( async (change, context) => {

        const userId = context.params.userId;
       const bonoId = context.params.bonoId;
       const before = change.before.data();
       const bonoDoc = change.after.data();

       if(bonoDoc.title != before.title || bonoDoc.sessions != before.sessions) {

            await db.collection("7777 Brands").doc(bonoDoc.brandId).collection("Users").doc(userId).collection("Bonos").doc(bonoId).update({
             "title": bonoDoc.title,
             "sessions": bonoDoc.sessions,
           });

            await db.collection("7777 Brands").doc(bonoDoc.brandId).collection("Bonos").doc(bonoId).collection("Users").doc(userId).update({
             "title": bonoDoc.title,
              "sessions": bonoDoc.sessions,
           });
           }


            return null;
          });

  // Creates User Bono
     exports.zzzzcreateUserBono = functions
     .region("europe-west1")
     .firestore
     .document("/7777 Users/{userId}/Bonos/{bonoId}")
     .onCreate( async (snap, context) => {

        const userId = context.params.userId;
       const bonoId = context.params.bonoId;
       const bonoDoc = snap.data();

            await db.collection("7777 Brands").doc(bonoDoc.brandId).collection("Users").doc(userId).collection("Bonos").doc(bonoId).set({
             "title": bonoDoc.title,
             "sessions": bonoDoc.sessions,
             "price": bonoDoc.price,
             "purchaseId": bonoDoc.purchaseId,
           });

            await db.collection("7777 Brands").doc(bonoDoc.brandId).collection("Bonos").doc(bonoId).collection("Users").doc(userId).set({
             "title": bonoDoc.title,
              "sessions": bonoDoc.sessions,
              "price": bonoDoc.price,
              "purchaseId": bonoDoc.purchaseId,
           });


            return null;
          });

// User Deletes Location
exports.zzzzDeleteUserBono = functions
.region("europe-west1")
.firestore
.document("/7777 Users/{userId}/Bonos/{bonoId}")
.onDelete( async (snap, context) => {

 const userId = context.params.userId;
       const bonoId = context.params.bonoId;
       const bonoDoc = snap.data();

            await db.collection("7777 Brands").doc(bonoDoc.brandId).collection("Users").doc(userId).collection("Bonos").doc(bonoId).delete();

            await db.collection("7777 Brands").doc(bonoDoc.brandId).collection("Bonos").doc(bonoId).collection("Users").doc(userId).delete();


            return null;
});

// User Purchases Event
exports.usersPurchasesEvent = functions
.region("europe-west1")
.firestore
.document("/7777 Payments/Purchases/Purchases/{purchaseId}/Events/{eventId}")
.onCreate( async (snap, context) => {

  const purchaseId = context.params.purchaseId;
  const eventId = context.params.eventId;

  const eventDoc = snap.data();

       //Get data of the purchase

       const purchaseSnapShot = await db.collection("7777 Payments").doc("Purchases").collection("Purchases").doc(purchaseId).get();
       const purchaseDoc = purchaseSnapShot.data();

       const userId = purchaseDoc.userId;
       const bonoId = purchaseDoc.bonoId;
       const brandId =  purchaseDoc.brandId;

       //Get data of the bono

       const bonoSnapshot = await db.collection("7777 Brands").doc(brandId).collection("Bonos").doc(bonoId).get();
       const bonoDoc = bonoSnapshot.data();

       //Get data of the bono user

       const bonoSnapshotUser = await db.collection("7777 Users").doc(userId).collection("Bonos").doc(bonoId).get();
       const bonoDocUser = bonoSnapshotUser.data();

       //Add events to purchases

       await db.collection("7777 Brands").doc(brandId).collection("Bonos").doc(bonoId).collection("Purchases").doc(purchaseId).collection("Events").doc(eventId).set({
         "isPrivate": eventDoc.isPrivate,
         "title": eventDoc.title,
         "doneAt": eventDoc.doneAt,
         "year": eventDoc.year,
         "month": eventDoc.month,
         "day": eventDoc.day,
         "hour": eventDoc.hour,
         "minute": eventDoc.minute,
         "duration": eventDoc.duration,
         "numTrainers": eventDoc.numTrainers,
         "numClients": eventDoc.numClients,
         "maxMembers": eventDoc.maxMembers,
       });
       await db.collection("7777 Brands").doc(brandId).collection("Users").doc(userId).collection("Purchases").doc(purchaseId).collection("Events").doc(eventId).set({
        "isPrivate": eventDoc.isPrivate,
        "title": eventDoc.title,
        "doneAt": eventDoc.doneAt,
        "year": eventDoc.year,
        "month": eventDoc.month,
        "day": eventDoc.day,
        "hour": eventDoc.hour,
        "minute": eventDoc.minute,
        "duration": eventDoc.duration,
        "numTrainers": eventDoc.numTrainers,
        "numClients": eventDoc.numClients,
        "maxMembers": eventDoc.maxMembers,
      });

       await db.collection("7777 Users").doc(userId).collection("Purchases").doc(purchaseId).collection("Events").doc(eventId).set({
        "isPrivate": eventDoc.isPrivate,
        "title": eventDoc.title,
        "doneAt": eventDoc.doneAt,
        "year": eventDoc.year,
        "month": eventDoc.month,
        "day": eventDoc.day,
        "hour": eventDoc.hour,
        "minute": eventDoc.minute,
        "duration": eventDoc.duration,
        "numTrainers": eventDoc.numTrainers,
        "numClients": eventDoc.numClients,
        "maxMembers": eventDoc.maxMembers,
      });

       functions.logger.log(
        "Bono Session",
        bonoDocUser.sessions
        );

       await db.collection("7777 Users").doc(userId).collection("Bonos").doc(bonoId).update({
         "sessions": bonoDocUser.sessions - 1,
       });

       return null;



     });



