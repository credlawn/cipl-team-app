# Project Instructions for AI

## Critical Rules
- Kabhi bhi build commands mat chalana (`flutter build`, `npm run build`, `flutter run`, `npm run dev`, etc.)
- Koi bhi destructive command (move, delete, write) run karne se pehle mujhse confirmation lo
- Changes suggest karo, directly execute mat karo jab tak main "ha karo" na kahun
- Jab kuch puchu to sirf answer do, change nahi karo bina meri approval ke

## Project Structure
- `backend/` — PocketBase Go server
- `admin-portal/` — React/Vite TypeScript admin panel
- `android/`, `ios/`, `lib/`, etc. — Flutter mobile app (root pe hai, restructuring pending)

## Goals
- Flutter app ko `mobile/` folder me shift karna (backend + admin-portal + mobile structure)
- 16 KB page size alignment fix for Android 16

## Notes
- Previous restructure attempt failed because `build/` folder root pe chhod diya tha
- Alignment script (`android/scripts/align_elf_16k.py`) 32-bit ELF handle nahi karta — pre-existing issue
