# Project Instructions for AI

## Critical Rules
- Kabhi bhi build commands mat chalana (`flutter build`, `npm run build`, `flutter run`, `npm run dev`, etc.)
- Koi bhi destructive command (move, delete, write) run karne se pehle mujhse confirmation lo
- Changes suggest karo, directly execute mat karo jab tak main "ha karo" na kahun

## Project Structure
- `backend/` — PocketBase Go server
- `admin-portal/` — React/Vite TypeScript admin panel
- `mobile/` — Flutter mobile app
  - `mobile/android/` — Android-specific config, Gradle, scripts
  - `mobile/android/scripts/align_elf_16k.py` — 16KB ELF alignment script (runs automatically via Gradle)
  - `mobile/lib/` — Dart source code
  - `mobile/ios/` — iOS config

## Goals
- ✅ Flutter app ko `mobile/` folder me shift karna — **DONE**
- 16 KB page size alignment fix for Android 16 — ✅ **DONE** (align_elf_16k.py Gradle hook)

## Notes
- Previous restructure attempt failed because `build/` folder root pe chhod diya tha
- Alignment script (`android/scripts/align_elf_16k.py`) 32-bit ELF handle nahi karta — pre-existing issue
