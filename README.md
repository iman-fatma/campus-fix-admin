# CampusFix — Admin App (`campus_fix_admin`)

> Paste this file at the start of a new AI chat. Last updated: 2026-10-20.
> Companion app: the Student app (`campus_fix`). Both use the SAME Firebase project.

## 0. How to work with the developer (read first)

- Developer: Iman, CS undergraduate, learning Flutter. Act as a sincere senior Flutter developer / teacher: explain WHY, share tools and tricks, teach good practice.
- Always give COMPLETE changed files (not snippets), pasted as text in the chat (no downloadable attachments), and say which OTHER files are needed or must change too.
- When something breaks, ask for the exact error text + file/line before guessing. Do not rewrite files you have not seen; ask the developer to paste them.
- Keep the admin and student apps in sync (see section 7).

## 1. What CampusFix is

Campus maintenance reporting for KFUEIT (Rahim Yar Khan, Pakistan). Students report issues from the student app; this admin app (web-first, responsive down to mobile) lets staff review reports, see the student's photo, location, registration number and email, assign technicians, add remarks, and change status.

## 2. Tech stack

- Flutter, state management + navigation + snackbars: **GetX**
- `google_fonts` (Inter), `intl` (date formatting)
- `firebase_auth`, `cloud_firestore`
- `url_launcher` (open Google Maps from a ticket)
- Photos are uploaded by the STUDENT app to Cloudinary; this app only displays the URL (thumbnails use a Cloudinary URL transformation, `w_240,h_240,c_fill,q_auto,f_auto`)
- IDE: Android Studio on Windows. Dart package name: `campus_fix_admin`

## 3. Setup notes

- Same Firebase project as the student app; `firebase_options.dart` present.
- Rules in section 6 must be published.
- If the admin runs on an Android phone, add the `<queries>` VERIFY/https intent to `AndroidManifest.xml` for url_launcher. Web/desktop need nothing.
- An admin account needs: a document at `admins/{uid}` AND a verified email (rules `isAdmin()`).

## 4. Folder structure (`lib/`)

Files marked ★ were written/reviewed in the latest work. "VERIFY" = not seen by the assistant.

```
lib/
├── main.dart                         (VERIFY)
├── firebase_options.dart
├── controllers/
│   ├── tickets_controller.dart ★     streams `complaints`, filters, counts, update/create/delete
│   ├── admin_shell_controller.dart   selectedIndex, scaffoldKey, isSidebarExpanded
│   ├── students_controller.dart      (VERIFY)
│   ├── announcements_controller.dart (VERIFY)
│   └── (auth controllers — VERIFY)
├── core/
│   ├── app_theme.dart                AppTheme (primaryNavy, backgroundLight, borderLight, textDark,
│   │                                 textMedium, textMuted, textSubtle, accentTeal, rejectedText, ...)
│   └── responsive.dart               ResponsiveHelper.isMobile(context)
├── models/
│   ├── ticket_model.dart ★           SHARED with student app, must stay byte-identical
│   └── (student / announcement models — VERIFY)
├── views/
│   ├── admin_app_gate.dart           decides login / verify / not-authorized / shell (VERIFY)
│   ├── admin_shell_screen.dart       sidebar (desktop) or drawer (mobile) + IndexedStack of 5 pages
│   ├── complaints_admin_screen.dart  OBSOLETE first attempt, safe to DELETE
│   ├── auth/                         login / register screens (VERIFY)
│   ├── dashboard/admin_dashboard_screen.dart   (VERIFY: real data or dummy?)
│   ├── tickets/tickets_screen.dart   ★ search + filters + list
│   ├── students/students_screen.dart (VERIFY)
│   ├── announcements/announcements_screen.dart (VERIFY)
│   └── settings/admin_settings_screen.dart     (VERIFY)
└── widgets/
    ├── admin_sidebar.dart, admin_top_nav.dart (VERIFY)
    ├── ticket_item_card.dart ★       list card with photo thumbnail
    ├── ticket_detail_sheet.dart ★    detail dialog (desktop) / bottom sheet (mobile)
    ├── new_ticket_dialog.dart        admin-created ticket (VERIFY fields)
    ├── priority_badge.dart, status_badge.dart
    ├── custom_button.dart            CustomButton(text, variant, isLoading, onPressed)
    └── empty_state_view.dart         EmptyStateView(icon, title, message, buttonText, onButtonPressed)
```

Shell pages (index order): Dashboard, Tickets / Issues, Students & Users, Announcements, Admin Settings. Controllers are `Get.put` in the shell's initState and deleted in dispose.

## 5. Features

### Done and working

Tickets page
- `TicketsController` streams the **`complaints`** collection (ordered by `createdAt` desc). `_normalize()` fills gaps (ticket number, createdAt, legacy `pending` -> `Open`).
- Search (ticket no, title, description, location, student name/id), status chips with live counts (All, Open, Assigned, In Progress, Resolved, Rejected), priority and category dropdowns, reset button, empty state.
- `TicketItemCard`: ticket no, category, priority/status badges, title, description, photo thumbnail (Cloudinary-resized), location, `studentLabel` ("Name (REG NO)"), assignee, date. The earlier 60px RenderFlex overflow is fixed (every info text is width-constrained with ellipsis).
- `TicketDetailSheet`: full photo (tap to zoom, loading/error states), description, category, location, address, Reported By, Registration No (copy button), Student Email (copy button), submitted date, "View on Google Maps", status chips, assign technician, remarks, delete (confirm), save.
- Mobile FAB opens `NewTicketDialog` (admin creates a ticket).
- Registration no: stored `regNo`, else derived from the uni email, else a short legacy id. Email missing on old complaints shows N/A (data was never saved).

Auth (from earlier conversations; code not reviewed recently, VERIFY)
- Admin register screen mirrors student rules (name/username availability via `usernames`, strong password).
- Self-registration creates `admins/{uid}` when the correct invite code (stored in `config/adminInvite`, readable only by the rules) is supplied; verified email required to count as admin; Google Sign-In being added. The old `adminRequests` flow (owner approval) still exists.

### Not done / known issues / backlog

- [ ] Admin search does not match the registration number (it tests `studentId`, which is the Firebase uid). One-line fix in `tickets_controller.dart`: also test `t.registrationNo`.
- [ ] Dashboard, Students, Announcements, Settings pages: VERIFY whether they use real data; the dashboard probably reads TicketsController counts.
- [ ] `NewTicketDialog` must match current vocabulary (categories, priorities incl. Urgent) and write to `complaints` via `TicketsController.createTicket`: VERIFY.
- [ ] Rules do not let admins change `priority`; the detail sheet has no priority editor. Add `priority` to the allowed update keys if wanted.
- [ ] `updateTicketStatus` only writes remarks when non-empty, so remarks can't be cleared; `assignedTo` is written even if empty.
- [ ] No notification to students when status changes (no FCM); students only see live updates while the app is open.
- [ ] Admin `remarks` are visible to students; decide whether to add a private internal-notes field.
- [ ] Deleting a ticket does not delete its Cloudinary image (needs the API secret, so server/Cloud Function only).
- [ ] Legacy `tickets` collection is ignored; delete old test data. The temporary catch-all rule should eventually be replaced by exact rules.
- [ ] `complaints_admin_screen.dart` is obsolete: delete it.
- [ ] No pagination (all complaints stream at once), no export/reports, no assignment to real staff accounts (free-text technician), no automated tests.
- [ ] Admin tickets screen has no per-ticket quick status change (`onQuickStatusChange` exists on the card but is unused).

## 6. Firestore data model and rules (project-wide, summarized)

Collections: `students/{uid}`, `admins/{uid}`, `adminRequests/{uid}` (old flow), `usernames/{key}`, `config/adminInvite` (secret), `users` (legacy, admin only), `complaints/{id}`, `tickets` (legacy, ignored).

Helpers: `isSignedIn()`, `isAdmin()` (verified email + doc in `admins/`), `hasUniEmail()` (`@kfueit.edu.pk`), `isUniUser()`.

`admins/{uid}` create (self-registration) requires: uni email, own uid, `hasOnly([uid, fullName, username, email, role, active, inviteCode, createdAt])`, role 'admin', active true, email matches auth email, `inviteCode == config/adminInvite.code`. Never updatable/deletable from the app. `get` allowed for own doc even before email verification.

`complaints/{id}` (written by the student app):

```
category        one of the 6 admin categories (section 7)
title           5..100
description     15..1000
locationDetail  1..100            (building/room)
priority        Low | Medium | High (student)   [admin can create any value]
imageUrl        null OR https://res.cloudinary.com/...
latitude/longitude  numbers in range
address         <= 300
status          'Open' on create
studentId       == uid
studentName     <= 100
studentEmail    == auth email
regNo           <= 30 (may be empty)
createdAt       == request.time (serverTimestamp)
```
Admin-added fields over time: `assignedTo`, `remarks`, `adminNote`, `updatedAt`, and (admin-created tickets) `ticketNumber`, `location`.

Complaint rules: create = verified student with exactly the allowed fields, or any admin; read = admin or the owning student; update = admin only, keys limited to `status, assignedTo, remarks, adminNote, updatedAt`, status in Open | Assigned | In Progress | Resolved | Rejected; delete = admin only.

A temporary catch-all covers any other collection for verified students/admins; every collection with its own rules MUST be in its exclusion list (rules are OR-ed).

## 7. Cross-app contract (student <-> admin)

1. ONE `ticket_model.dart`, identical in both apps. Adding a complaint field: model (both apps) -> `newComplaintMap` -> rules `hasOnly` + checks -> UI. Skipping the rules step gives "Missing or insufficient permissions".
2. Admin vocabulary is the standard.
   - Status: `Open, Assigned, In Progress, Resolved, Rejected`
   - Priority: `Low, Medium, High, Urgent`
   - Categories: `HVAC / Air Conditioning, Electrical & Lighting, Plumbing & Restroom, Furniture & Classroom, Network & WiFi, Other Facility Issue`
3. Student tile -> category mapping lives in `TicketModel.categoryForTile` (AC & Fans -> HVAC; Electricity -> Electrical; Water -> Plumbing; Wi-Fi -> Network; Furniture -> Furniture; Cleaning/Lab Equip/Other -> Other Facility Issue).
4. Ticket number = stored `ticketNumber` or `#` + first 6 chars of the document id, uppercased (the student app uses the same rule).
5. `TicketModel` getters used by the UI: `hasImage`, `thumbnailUrl`, `hasCoordinates`, `mapsUrl`, `registrationNo`, `studentLabel`, `regNoFromEmail()`.

## 8. Architecture and conventions

- GetX controllers own state and Firestore access; views render with `Obx`; reusable pieces in `widgets/`; responsive via `ResponsiveHelper.isMobile` (sidebar width 260/72 on desktop, drawer on mobile).
- Detail UI is a dialog (max width 680) on desktop and a bottom sheet on mobile.
- Not yet: Bindings/named routes, repository layer, shared constants for status/category strings.

## 9. Manual test checklist

1. Submit a complaint with a photo from the student app; it appears in Tickets as Open with a thumbnail; counts update.
2. Open it: photo zooms, address shows, Registration No and Email show with copy buttons, "View on Google Maps" opens the right spot.
3. Change status, assign a technician, add a remark, Save; the student app updates live.
4. Search by title, name, location; filter by status/priority/category; Reset.
5. Narrow the window to mobile width: no overflow errors; FAB opens the new ticket dialog.