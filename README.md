# Care:Circle – Orphanage Management & Donation System

**Care:Circle** is a Flutter application designed to connect donors with orphanages and simplify the management of essential requirements and donations. It provides dedicated interfaces for donors, orphanages, and administrators, with Firebase supporting authentication and cloud data storage.

## Features

### Donor Module
- Register and sign in to a donor account.
- Browse registered orphanages and view their profiles.
- Explore active and urgent requirements.
- Submit item donation requests.
- Track donation requests and their approval status.
- View donation history and impact information.

### Orphanage Module
- Register and sign in to an orphanage account.
- Manage orphanage profile information.
- Add, edit, and manage item requirements.
- View donation requests and confirmed donations.
- Monitor requirements and donation activity through a dashboard.

### Admin Module
- Sign in using Firebase Authentication with an admin custom claim.
- View the administrative dashboard.
- Review and verify registered orphanages.
- Monitor requirements, users, and donations.
- Approve or reject donation requests.
- Sign out securely.

## Donation Workflow

1. An orphanage publishes an item requirement.
2. A donor browses the requirement and submits a donation request.
3. The request is initially marked **Pending**.
4. An administrator reviews and approves or rejects the request.
5. Approved donations appear as **Confirmed** in the donor's history and the orphanage's received donations.

## Tech Stack

- Flutter & Dart - Cross-platform application development 
- Provider - State management 
- Firebase Authentication - Donor, orphanage, and admin authentication 
- Cloud Firestore - Cloud database for app records 
- Firebase Admin SDK - Assigning admin custom claims from a trusted environment 
- Google Fonts & Font Awesome - UI typography and icons

>**Project Notes** Firestore Security Rules still require hardening before public deployment. This repository should be treated as a development/portfolio project, not a production-ready donation platform. Do not use real sensitive user or donation data until authorization rules have been reviewed and secured.
