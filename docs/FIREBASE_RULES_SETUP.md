# Firebase Security Rules — How to Deploy

Your rules file is `firestore.rules` in the project root.

## Option 1: Firebase Console (easiest for demo)

1. Go to [Firebase Console](https://console.firebase.google.com) → your project **alu-connect-b0090**
2. Click **Firestore Database** → **Rules** tab
3. Open `firestore.rules` from this project in VS Code
4. Copy the entire file contents
5. Paste into the Firebase Console rules editor
6. Click **Publish**

## Option 2: Firebase CLI

```bash
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules
```

Run from your project folder where `firestore.rules` and `firebase.json` live.

## What the rules protect

| Collection | Who can read | Who can write |
|------------|--------------|---------------|
| `users` | Any signed-in user | Only your own profile |
| `startups` | Any signed-in user | Create: startup admin. Verify: ALU admin only |
| `opportunities` | Any signed-in user | Only the startup that owns it |
| `applications` | Student (own) or startup admin | Student creates, startup admin updates status |

## Important: switch off test mode

If your rules still say `allow read, write: if true`, replace them with `firestore.rules` and publish.

## Demo tip

Show the rules tab in Firebase Console during your video and explain:
- ALU email check on sign-up
- Only admins can set `verified: true`
- Students can only create applications for themselves
