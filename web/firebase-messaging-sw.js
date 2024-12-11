importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDB-nTSoJYNEb-OVY9VtgICnZcSFtdTVbw",
  authDomain: "tour-management-app-29401.firebaseapp.com",
  projectId: "tour-management-app-29401",
  storageBucket: "tour-management-app-29401.appspot.com",
  messagingSenderId: "428973781436",
  appId: "1:428973781436:web:11094c041b660f814cfbb9",
  measurementId: "G-GVSDPS5HKC"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});