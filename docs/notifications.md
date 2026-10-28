# Push notifications

The mobile app registers its FCM token at login and calls `Auth/UpdateFirebaseToken`
on refresh, after login, at startup for saved sessions, and on app resume. Failed
token registration is retried on the next resume. Guests are not registered with
the backend. Missing permission, APNs readiness, or Play Services does not block login.

## Sending

Send through the backend or Firebase HTTP v1 using the device's FCM token:

```json
{
  "message": {
    "token": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "MediCard",
      "body": "Your request status has changed"
    },
    "data": { "route": "/medicard-invoices/history" },
    "android": {
      "priority": "high",
      "notification": { "channel_id": "medicard_updates" }
    },
    "apns": { "payload": { "aps": { "sound": "default" } } }
  }
}
```

Supported routes: `/medicard-home`, `/medicard-network`, `/medicard-invoices`,
`/medicard-invoices/history`, `/medicard-support`. Unknown or external destinations
fall back to home. Query parameters (including card/account identifiers) are
discarded. Notification taps wait until splash/authentication completes.

Foreground messages are shown as native local notifications. In the background,
FCM displays notification payloads; the background handler only displays data-only
messages with string `title`/`body` fields, avoiding duplicate alerts. Silent data
messages without either field do not display anything. Prefer the notification
payload above for visible delivery: operating systems may throttle data-only
background messages, especially on iOS.

## Platform setup

- Android: Firebase client configuration, runtime notification permission, a high
  importance channel, and a monochrome notification icon are included.
- iOS: Firebase options, push entitlement, background modes, and notification
  delegate are included. Firebase 5 requires iOS 15 or newer.
- In Firebase Console, upload an APNs authentication key for `com.khusm.medicard`.
  Enable Push Notifications for that Apple App ID and regenerate distribution
  profiles as necessary. These account-side settings cannot be verified from this
  checkout. Codemagic must use a profile that includes the push entitlement.
- Firebase configurations in this repository are public client identifiers, not
  server credentials. Never include service-account or APNs private keys here.
- Windows and web push are not configured by this mobile implementation.

## Device acceptance check

1. Install the app on a physical device, log in, and grant notification permission.
2. Send the example payload with the app open, in background, and terminated.
3. Check one alert per message and tap through to invoice history in each state.
4. Repeat with data-only `title`, `body`, and `route` on Android.
5. Deny notification permission and confirm login still works; re-enable it in
   system settings, resume, and confirm registration is retried.
6. Open a notification while signed out, then log in: the destination should be
   retained and use the current account, never an account from the payload.

Automated coverage: `flutter test`. Native push delivery, APNs credentials, and
distribution signing still require the device/account checks above.

References: [Firebase Flutter receiving messages](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages)
and [platform setup](https://firebase.google.com/docs/cloud-messaging/flutter/get-started).
