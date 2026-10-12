# CampusFix Admin

Responsive Flutter admin portal for CampusFix. The admin web app uses the same
Firebase project as the CampusFix app: `campus-fix-9565f`.

## Run on phone and laptop

The web target uses the existing Firebase web app configuration and adapts to
phone and laptop browser widths:

```sh
flutter run -d chrome
```

Build it for web hosting with:

```sh
flutter build web
```

The Android and iOS Firebase options also target `campus-fix-9565f`. Before
building the Android admin app, register its application ID
(`com.example.campus_fix_admin`) in that Firebase project and replace
`android/app/google-services.json` with the generated configuration. Register
the iOS bundle ID in Firebase before building for iOS. Native Windows and
macOS require app registrations and fresh FlutterFire configuration; the app
intentionally refuses to initialize with placeholder configuration.

## Authorize an administrator

There is no public admin registration or bootstrap password. A trusted Firebase
project owner must:

1. Enable Email/Password in Firebase Authentication and create the admin user.
2. Copy that user's Authentication UID.
3. In Firestore, create `admins/{uid}` with at least:

   ```json
   {
     "email": "admin@example.edu",
     "fullName": "Campus Facilities Admin",
     "role": "admin",
     "active": true
   }
   ```

The app only opens the admin shell when the signed-in user's UID has an active
document in `admins` with an allowed admin role. Remove or disable that document
to revoke portal access.

Protect `admins` membership and the `tickets`, `announcements`, `students`, and
other sensitive collections with Firestore Security Rules. Only trusted
project owners or a trusted backend should be able to grant or revoke admin
membership. The portal's client-side gate is not a replacement for Firestore
Security Rules. Merge the required checks with the rules already used by the
CampusFix app; do not replace the shared project's rules without preserving its
existing mobile-app access policies.

The portal reads and writes the shared `tickets`, `announcements`, and
`students` collections. It does not seed demo records into the live database.
