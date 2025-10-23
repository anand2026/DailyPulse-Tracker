# DailyPulse - Personal Wellness Tracker

# Claude Operating Manual (CLAUDE.md)

## 0) Stack & Architecture

* **Stack:** Flutter + Riverpod + go_router + Sqflite + Firebase (Auth + Firestore).
* **Architecture:** Simplified Architecture → Models → Services → Presentation.
* **Data Storage:** Local device-based with Firebase cloud backup.

## 1) Folder Structure

```
lib/
  app/
    theme.dart
    router.dart
    route_endpoints.dart
  core/
    database_helper.dart
  features/
    <feature_name>/
      models/
      services/
      presentation/
```

## 2) Layer Rules

* **Models:** Plain Dart classes with JSON serialization for local storage.
* **Services:** Handles local data operations and business logic.
  - **Structure:** Main public functions at top, supportive private functions at bottom after `// ===== SUPPORTIVE FUNCTIONS =====` separator.
  - **Exceptions:** Use generic exceptions only - avoid specific exception types for consistency. Don't wrap operations in try-catch if you're just going to throw an exception anyway.
* **Presentation:** Single controller + screens/widgets.
* UI Theme: All UI must strictly use the defined theme colors from app/theme.

## 3) State Management

* Riverpod (StateNotifier / AsyncNotifier).
* Providers local to feature.

## 4) Data Persistence

* All data stored locally using SQLite.
* Firebase Firestore for cloud backup.

## 5) Models

* Plain Dart classes.
* JSON serialization with JsonSerializable for local storage.
* **All model fields must be nullable** to prevent crashes on data changes.
* **Database Operations:** Models should contain their own SQLite database methods:
  - `save()` - Insert/update record
  - `toMap()` - Convert to database map
  - `static fromMap(map)` - Create from database map
  - **Null Safety:** All database operations must handle null values gracefully without throwing exceptions
  - **Table Schema:** Design tables to accept null values for all non-essential fields

## 6) Local Storage

* **SQLite Database:** Use Sqflite for complex data storage, relationships, and queries.
  - Database queries should be implemented directly in the model classes.
  - Use for all app data, user records, and persistent storage.
* **SharedPreferences:** Use only for simple key-value pairs.
  - User preferences, settings, flags.
  - Simple state persistence.
  - **Never use for complex data structures or large datasets.**

## 7) Data Management

**Pattern:**

* All data operations are local to the device.
* Services handle SQLite database operations directly.
* Firebase sync for backup.

**Data Fields:**

* id
* createdAt
* updatedAt
* deleted

**Data Operations:**

* Direct database reads/writes
* Cloud sync with Firestore
* All changes persist locally first

## 8) Navigation

* go_router with typed routes.
* Use AppRouteEndpoints.dart class with static variables for all route paths.

## 9) User Management

* Firebase Authentication for user accounts.
* User data stored locally in SQLite.
* User preferences managed via local storage.

## 10) Service Organization

* **Function Order:**
  - Main public methods at the top
  - Supportive private methods at the bottom after separator
  - Use `// ===== SUPPORTIVE FUNCTIONS =====` separator line

* **Exception Handling:**
  - Use generic `Exception()` only
  - Avoid specific exception types
  - Keep error messages descriptive but generic

## 11) Code Style

* final for locals, const widgets.
* Max 40 lines per method.
* **Current Task Only**: Create only what's needed for the current message/task. Don't add methods, components, classes, or variables for future features or "just in case" scenarios.

## 12) Security

* No secrets in repo.
* Validate inputs, sanitize outputs.
* Firebase credentials handled via firebase_options.dart (generated).
