importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

const firebaseConfig1 = {
  apiKey: "AIzaSyByAwOkUBofOmpKygDwCfEQtRT2I5ml5Lw",
  authDomain: "web-epsilon-diary.firebaseapp.com",
  projectId: "web-epsilon-diary",
  storageBucket: "web-epsilon-diary.appspot.com",
  messagingSenderId: "37324427087",
  appId: "1:37324427087:web:57870e64256b8c6a29ff3a",
  measurementId: "G-23LRNKNQ0B"
};

const firebaseConfig2 = {
  apiKey: "AIzaSyAov6g9VxMSwr_lZS4Cu3asLTdIDo-zpLY",
  authDomain: "epsilondiary.firebaseapp.com",
  projectId: "epsilondiary",
  storageBucket: "epsilondiary.firebasestorage.app",
  messagingSenderId: "533307753828",
  appId: "1:533307753828:web:77fbc8d1ecc0db79cfa671",
  measurementId: "G-HY5D5TCHEQ"
};

// Choose the correct config dynamically based on the hostname
const firebaseConfig = location.hostname.includes("web-epsilon-diary.web.app")
  ? firebaseConfig1
  : firebaseConfig2;

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();
