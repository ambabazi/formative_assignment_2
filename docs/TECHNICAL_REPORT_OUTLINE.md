# Technical Report Outline — ALU Connect

Use this structure for your PDF: `YourName_FinalFlutterProject.pdf`

---

## 1. Introduction (1 page)
- Problem: ALU students struggle to find internships; startups need help
- Solution: ALU Connect — mobile platform connecting students with ALU startups
- Target users: students, startup admins, ALU staff (verification)

## 2. System Architecture (1–2 pages)
- Layered architecture diagram:
  ```
  Screens → Providers (Riverpod) → Repositories → Firebase
  ```
- Why repository pattern? (testability, swap Firebase without touching UI)
- Folder structure explanation

## 3. Firebase Backend Structure (1–2 pages)
- ERD / collections diagram:
  - `users` — profiles, roles, skills
  - `startups` — company info, `verified` flag
  - `opportunities` — job postings
  - `applications` — student submissions, status
- Screenshot of Firestore console with real data
- Security rules summary (paste key rules from `firestore.rules`)

## 4. State Management (1 page)
- Riverpod chosen over setState / Provider
- `StreamProvider` for real-time Firestore snapshots
- `StateProvider` for logged-in user
- Example: application status change propagates to student screen live

## 5. Application Workflows (1–2 pages + screenshots)
Include screenshots for each:
1. Student sign-up → onboarding (skills)
2. Startup registration → pending verification
3. ALU admin verifies startup
4. Startup posts opportunity
5. Student discovers with match %
6. Student applies
7. Startup reviews applicants → changes status
8. Student sees live status update

## 6. UI/UX Reasoning (1 page)
- ALU brand colors (navy `#00234B`, red `#C61D23`)
- Separate flows for student vs startup admin
- Match % badge instead of flat list
- "Skills to grow into" language on apply screen

## 7. Scalability Considerations (0.5 page)
- Repository abstraction
- Firestore composite indexes (if you hit index errors)
- Security rules server-side enforcement
- Pagination as future improvement

## 8. Challenges & Lessons Learned (0.5 page)
- Real examples: composite index error, Riverpod 3 StateProvider legacy import, asset loading
- What you learned about Flutter + Firebase

## 9. Testing Strategy (0.5 page)
- Manual testing on Android emulator
- `flutter analyze` for static checks
- Firebase Console side-by-side verification

## 10. Limitations & Future Improvements (0.5 page)
- No push notifications yet
- No bookmarking
- No messaging between student and startup
- Alumni accounts out of scope

## 11. References (APA or IEEE)
- Flutter documentation
- Firebase documentation
- Riverpod documentation

---

## Demo Video Checklist (7–10 minutes)

- [ ] Run on **Android emulator** (not browser only)
- [ ] Show Firebase Authentication tab when user signs up
- [ ] Show Firestore collections updating live
- [ ] Explain StreamProvider + status change without refresh
- [ ] Show security rules in console
- [ ] Explain why startup admin has different UI than student
