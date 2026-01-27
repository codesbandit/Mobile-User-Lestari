importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts(
  "https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js"
);

firebase.initializeApp({
  apiKey: "AIzaSyCe9lGU5ipFZqBXHED3VDoTmr4NkurOnSI",
  authDomain: "id-lestari-project.firebaseapp.com",
  projectId: "id-lestari-project",
  storageBucket: "id-lestari-project.firebasestorage.app",
  messagingSenderId: "825010792860",
  appId: "1:825010792860:web:56b9bc25291894162d0059",
  databaseURL: "https://id-lestari-project-default-rtdb.firebaseio.com/",
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
  const promiseChain = clients
    .matchAll({
      type: "window",
      includeUncontrolled: true,
    })
    .then((windowClients) => {
      for (let i = 0; i < windowClients.length; i++) {
        const windowClient = windowClients[i];
        windowClient.postMessage(payload);
      }
    })
    .then(() => {
      const title = payload.notification.title;
      const options = {
        body: payload.notification.score,
      };
      return registration.showNotification(title, options);
    });
  return promiseChain;
});
self.addEventListener("notificationclick", function (event) {
  console.log("notification received: ", event);
});
