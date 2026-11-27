# PlayDesk Owner Stories — Gaming Venue Analytics Demo

A Flutter demo built for PC and PS5 gaming venue owners (featuring fictional venue **"Level Up Arena"** with 10 PCs and 4 PS5s). The owner can open the app, tap through three quick daily stories, and learn actionable business insights in under a minute.

---

## 📱 Features

- **Owner Stories Full-Screen Viewer**:
  - Instagram-style animated progress bars.
  - Left / right tap to navigate between stories.
  - Tap-and-hold to pause.
  - Swipe-down gesture or close button to dismiss.
  - Dynamic glassmorphic detail drawer with key operational metrics.
  - Custom branded portrait imagery (18 vertical 9:16 graphics tailored to each story).

- **The Three-Day Pilot (6 Batches / 18 Stories)**:
  - **Day 1 Morning (10:00 am)**:
    1. Money collected yesterday
    2. Yesterday's best-selling food by units sold
    3. PC with the most playing time yesterday
  - **Day 1 Evening (5:30 pm)**:
    4. Tonight's upcoming group bookings
    5. Players who extended a session today
    6. Prepaid packages expiring this weekend
  - **Day 2 Morning (10:00 am)**:
    7. Regularly quiet time for an offer (based on past 4 weeks)
    8. Yesterday's most-played game by hours
    9. Busiest hour and top bill closer yesterday
  - **Day 2 Evening (5:30 pm)**:
    10. Free PS5 walk-in availability 7–8 pm
    11. Gaming bills with food & drinks combo today
    12. Outstanding unpaid amount on completed sessions
  - **Day 3 Morning (10:00 am)**:
    13. 2nd visit returning players yesterday
    14. Most popular session length
    15. Yesterday's collections by UPI vs Cash
  - **Day 3 Evening (5:30 pm)**:
    16. 10th visit milestone achieved today
    17. Booked time freed by evening cancellations
    18. Collections by 5:30 pm vs same time last week

- **Interactive Demo Controls & Dynamic Verification**:
  - **Day & Slot Selector**: Toggle between Day 1 / 2 / 3 and Morning / Evening directly on the home screen.
  - **Data Editor Sheet (Demo Verification)**:
    - Tap the debug icon on the home screen header.
    - **Food Order Test**: Increase fries units sold so it overtakes burgers; stories immediately refresh to show fries as the top seller.
    - **Milestone Drop Test**: Decrease a player's visits from 10 to 9. The milestone story card drops and automatically pulls an unused reserve story or gracefully shows fewer cards.
    - **Reset Button**: One-tap restore to initial sample dataset.

---

## 🏗️ Architecture & Clean Code

- **Separation of Concerns**:
  - `lib/data/`: Domain models (`Bill`, `Booking`, `Device`, `FoodOrder`, `Package`, `Player`, `Session`), snapshot provider, and local JSON venue repository.
  - `lib/stories/calculators/`: Pure Dart calculators for all 18 story cards with zero UI dependencies.
  - `lib/stories/batch_builder.dart`: Batch assembly engine with primary-to-reserve fallback logic and eligibility rules.
  - `lib/stories/story_templates.dart`: Centralized reusable text templates, formatters, and photo mappings.
  - `lib/ui/`: Presentation layer with Riverpod state management (`flutter_riverpod`).

---

## 🚀 How to Run

1. Ensure Flutter 3.11+ is installed.
2. Clone repository or extract the project ZIP.
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app on an Android, iOS, or Web emulator/device:
   ```bash
   flutter run
   ```

---

## 📂 Sample Data

Fictional venue records are stored in [`assets/data/sample_data.json`](assets/data/sample_data.json) covering realistic venue activity across all devices, player bookings, food orders, and billing transactions.
