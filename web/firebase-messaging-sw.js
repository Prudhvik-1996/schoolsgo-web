importScripts("https://www.gstatic.com/firebasejs/7.15.5/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.15.5/firebase-messaging.js");

//Using singleton breaks instantiating messaging()
// App firebase = FirebaseWeb.instance.app;


firebase.initializeApp({
                         apiKey: "AIzaSyByAwOkUBofOmpKygDwCfEQtRT2I5ml5Lw",
                         authDomain: "web-epsilon-diary.firebaseapp.com",
                         projectId: "web-epsilon-diary",
                         storageBucket: "web-epsilon-diary.appspot.com",
                         messagingSenderId: "37324427087",
                         appId: "1:37324427087:web:57870e64256b8c6a29ff3a",
                         measurementId: "G-23LRNKNQ0B"
                       });

const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            return registration.showNotification("New Message");
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});