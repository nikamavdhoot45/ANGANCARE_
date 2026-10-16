const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");

initializeApp();

const db = getFirestore();
const auth = getAuth();

exports.createWorkerAccount = onCall(async (request) => {
  // ---------------------------------------------------------
  // 1. Check that the caller is logged in
  // ---------------------------------------------------------
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "You must be logged in to create a worker account.",
    );
  }

  const adminUid = request.auth.uid;

  // ---------------------------------------------------------
  // 2. Check that the caller is an Admin
  // ---------------------------------------------------------
  const adminDoc = await db.collection("users").doc(adminUid).get();

  if (!adminDoc.exists) {
    throw new HttpsError(
        "permission-denied",
        "Admin profile was not found.",
    );
  }

  const adminData = adminDoc.data();

  if (adminData.role !== "admin") {
    throw new HttpsError(
        "permission-denied",
        "Only administrators can create worker accounts.",
    );
  }

  // ---------------------------------------------------------
  // 3. Read worker information
  // ---------------------------------------------------------
  const data = request.data || {};

  const name = String(data.name || "").trim();
  const email = String(data.email || "").trim().toLowerCase();
  const phone = String(data.phone || "").trim();
  const centerId = String(data.centerId || "").trim();
  const password = String(data.password || "");

  // ---------------------------------------------------------
  // 4. Validate information
  // ---------------------------------------------------------
  if (!name || !email || !phone || !centerId || !password) {
    throw new HttpsError(
        "invalid-argument",
        "Name, email, phone, center ID and password are required.",
    );
  }

  if (password.length < 6) {
    throw new HttpsError(
        "invalid-argument",
        "Password must contain at least 6 characters.",
    );
  }

  // ---------------------------------------------------------
  // 5. Create Firebase Authentication account
  // ---------------------------------------------------------
  let workerUser;

  try {
    workerUser = await auth.createUser({
      email: email,
      password: password,
      displayName: name,
    });
  } catch (error) {
    if (error.code === "auth/email-already-exists") {
      throw new HttpsError(
          "already-exists",
          "An account with this email already exists.",
      );
    }

    throw new HttpsError(
        "internal",
        "Unable to create the worker authentication account.",
    );
  }

  // ---------------------------------------------------------
  // 6. Save worker profile in Firestore
  // ---------------------------------------------------------
  try {
    await db.collection("workers").doc(workerUser.uid).set({
      uid: workerUser.uid,
      name: name,
      email: email,
      phone: phone,
      centerId: centerId,
      role: "worker",
      isActive: true,
      createdBy: adminUid,
      createdAt: FieldValue.serverTimestamp(),
    });

    // Also create the user's role document.
    await db.collection("users").doc(workerUser.uid).set({
      uid: workerUser.uid,
      name: name,
      email: email,
      role: "worker",
      centerId: centerId,
      isActive: true,
      createdAt: FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      uid: workerUser.uid,
      message: "Worker account created successfully.",
    };
  } catch (error) {
    // -------------------------------------------------------
    // Roll back Authentication account if Firestore fails
    // -------------------------------------------------------
    try {
      await auth.deleteUser(workerUser.uid);
    } catch (deleteError) {
      console.error(
          "Failed to roll back worker Auth account:",
          deleteError,
      );
    }

    console.error("Failed to save worker profile:", error);

    throw new HttpsError(
        "internal",
        "Worker account could not be saved.",
    );
  }
});
