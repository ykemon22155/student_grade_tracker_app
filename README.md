# Student Grade Tracker App

A Flutter application built for Ostad Module 5 Assignment. This app tracks student subjects, marks, and updates real-time analytics using Provider state management.

## Features
- **Add Subject Screen:** Form with strict validation (0-100 marks).
- **Subject List Screen:** Custom ListView with Swipe-to-Delete functionality.
- **Summary Screen:** Live calculation of total subjects, average marks, and overall grade.
- **Custom Theme Toggle:** Fully adaptive light and dark themes using `Theme.of(context)`.

## Architecture & Requirements Met
- **State Management:** 100% Provider (Zero `setState` inside application logic).
- **Encapsulation:** `Subject` class uses a private `_mark` field with a custom `grade` getter.
- **Functional Programming:** Used `.where()` to dynamically filter passing subjects.

## How to Run
1. Clone this repository.
2. Run `flutter pub get`.
3. Connect a device/emulator and run `flutter run`.
