# NotiBuku

**Your thoughts. Your tasks. Your space to organize.**

NotiBuku is a Flutter-powered notebook application designed to help you capture ideas, organize everyday notes, manage tasks, and keep important information within easy reach.

Whether you're recording personal thoughts, organizing business notes, collecting learning materials, or tracking your to-do list, NotiBuku brings your notes together in one convenient workspace.

> Write it down. Organize it. Get it done.

## Table of Contents

- [Features](#features)
- [Built With](#built-with)
- [Getting Started](#getting-started)
- [How to Use NotiBuku](#how-to-use-notibuku)
- [Project Structure](#project-structure)
- [Development](#development)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Privacy and Data](#privacy-and-data)
- [License](#license)
- [Links and Resources](#links-and-resources)

## Features

### Note-Taking

- Create, edit, and delete notes.
- Organize notes into categories.
- Browse notes by category or view all notes.
- Keep note content and associated details organized.

### To-Do Checklists

- Create checklist-style notes.
- Add, edit, and remove tasks.
- Mark tasks as completed.
- Organize checklists in a dedicated To-Do category.

### Categories

Organize your notes using the following categories:

- **Personal** — Everyday notes and personal reminders.
- **Business** — Work-related notes and information.
- **To-Do** — Tasks, checklists, and action items.
- **Learning** — Study notes and learning materials.
- **Ideas** — Inspiration, concepts, and brainstorming.
- **Urgent** — Important information requiring attention.
- **All Notes** — Browse your complete collection.

### Search and Filtering

- Search notes by title and content.
- Filter notes by date.
- Browse notes by category.
- Clear active filters to return to a broader view.

### Personalization

- Customize note and text colors where supported.
- Choose available font families and font sizes.
- Use an interface designed to adapt to different screen sizes and orientations.

### Navigation

- Navigate between categories and their notes.
- Open individual notes for editing.
- Return to categories using the app's navigation controls.
- Support Android system back gestures when navigating from a notes view to its categories.
- Access additional options through the navigation drawer.

### Data Management

- Create, update, and delete notes.
- Manage to-do items.
- Use the application's configured database service to persist data.
- Refresh displayed information after changes.

## Built With

NotiBuku is built using the Flutter development ecosystem.

- **[Flutter](https://flutter.dev/)** — Cross-platform application framework.
- **[Dart](https://dart.dev/)** — Programming language.
- **[Riverpod](https://riverpod.dev/)** — State management.
- **[SQLite](https://www.sqlite.org/)** — Local database technology, where configured by the application.
- **Material Design** — UI components and visual design.

The exact dependencies and supported platforms are determined by the project's current configuration.

## Getting Started

Follow these instructions to set up NotiBuku on your development machine.

### Prerequisites

Install the following tools:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Git](https://git-scm.com/downloads)
- [Visual Studio Code](https://code.visualstudio.com/) or another compatible IDE
- An Android device, emulator, or another supported Flutter target

For Android development, configure the Android SDK and required build tools.

### 1. Clone the Repository

```bash
git clone https://github.com/karyeija/NotiBuku.git
```

### 2. Open the Project Directory

```bash
cd NotiBuku
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Check Your Environment

```bash
flutter doctor
```

Resolve any required configuration issues reported by Flutter before proceeding.

### 5. Run the Application

Connect a device or start an emulator, then run:

```bash
flutter devices
flutter run
```

Flutter will build and launch the application on the selected device.

### 6. Build an Android APK

Generate a release APK using:

```bash
flutter build apk --release
```

The APK is typically generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### 7. Open the Project in Visual Studio Code

From the project directory, run:

```bash
code .
```

Ensure that the Flutter and Dart extensions are installed and configured.

## How to Use NotiBuku

### Create a Note

1. Open NotiBuku.
2. Select a category.
3. Tap the new-note button.
4. Enter a title and your note content.
5. Save your changes.

### Manage a To-Do List

1. Open the To-Do category.
2. Create a new checklist.
3. Add tasks to the list.
4. Mark tasks as completed as you progress.
5. Edit or remove tasks when necessary.

### Find a Note

1. Open a category or select All Notes.
2. Search by title or content.
3. Apply a date filter when needed.
4. Clear filters to broaden your results.

### Personalize Your Notes

Use the available formatting options to customize supported note colors, text colors, fonts, and font sizes.

### Navigate Between Categories and Notes

1. Open a category to view its notes.
2. Select a note to open or edit it.
3. Use the available navigation controls to return to the category list.
4. On Android, use the supported system back gesture to navigate back from the notes view.

The exact controls may vary depending on the current application interface.

## Project Structure

NotiBuku organizes its code into directories for reusable interface components, application screens, state management, data models, and supporting services.

```text
NotiBuku/
├── android/
├── lib/
│   ├── buttons/
│   ├── constants/
│   ├── forms/
│   ├── models/
│   ├── pages/
│   ├── pickers/
│   ├── providers/
│   ├── services/
│   ├── utils/
│   ├── widgets/
│   └── main.dart
├── test/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

### Directory Overview

- **`buttons/`** — Reusable button components and button-related functionality.
- **`constants/`** — Shared constants and application-wide configuration values.
- **`forms/`** — Form components and input-related UI.
- **`models/`** — Data models representing application entities, such as notes and to-do items.
- **`pages/`** — Application screens and page-level UI.
- **`pickers/`** — Components for selecting supported values, such as dates or colors.
- **`providers/`** — Riverpod providers and state-management logic.
- **`services/`** — Database operations, data access, and other application services.
- **`utils/`** — Helper functions and shared utilities.
- **`widgets/`** — Reusable interface components used throughout the application.
- **`main.dart`** — The application entry point.

The directory descriptions are based on the current folder names and intended responsibilities. The actual contents may evolve as development continues.

## Development

Run the following commands from the project root when developing or maintaining NotiBuku.

### Analyze the Code

Check the project for Dart and Flutter issues:

```bash
flutter analyze
```

### Run Automated Tests

Execute the available automated tests:

```bash
flutter test
```

### Format Dart Files

Format the Dart source files in the `lib` directory:

```bash
dart format lib/
```

### Check Connected Devices

List devices and emulators available to Flutter:

```bash
flutter devices
```

### Development Guidelines

- Keep widgets focused and reusable.
- Separate presentation, state management, and data access where practical.
- Follow Dart and Flutter coding conventions.
- Preserve existing note data when modifying models or database schemas.
- Handle empty states, invalid input, and asynchronous operations carefully.
- Test navigation using both app-bar controls and device system gestures.
- Check layouts across different screen sizes and orientations.
- Run `flutter analyze` and relevant tests before committing changes.

## Roadmap

Potential future improvements include:

- [ ] Note reminders and scheduled notifications.
- [ ] Advanced sorting and filtering.
- [ ] Note pinning and favorites.
- [ ] Recycle bin and note recovery.
- [ ] Note export and import.
- [ ] Backup and restore functionality.
- [ ] Additional themes and accessibility improvements.
- [ ] Expanded automated test coverage.

These are possible future enhancements, not claims that the functionality is already available.

## Contributing

Contributions, bug reports, suggestions, and improvements are welcome.

To contribute:

1. Fork the repository.
2. Create a feature branch.
3. Implement and test your changes.
4. Commit your changes with a descriptive message.
5. Submit a pull request explaining the changes.

When reporting a bug, include:

- A clear description of the problem.
- Steps to reproduce it.
- The expected behavior.
- The actual behavior.
- Relevant error messages or screenshots, where appropriate.

Please keep changes focused and ensure that existing functionality continues to work.

## Privacy and Data

NotiBuku uses its configured data-storage implementation to manage notes and related information.

The exact storage location, backup behavior, and any data transmission depend on the application's implementation and integrations.

Local storage alone does not guarantee that your notes are backed up. Keep independent copies of important information until a backup and recovery workflow has been verified.

Avoid sharing sensitive information when submitting bug reports or screenshots.

## License

No open-source license has been specified in this README.

Before distributing NotiBuku as open-source software, add an appropriate `LICENSE` file and update this section to reflect the chosen license. Until then, do not assume that the project is available for unrestricted reuse.

## Links and Resources

- **Source code:** [GitHub — NotiBuku](https://github.com/karyeija/NotiBuku)
- **Flutter documentation:** [flutter.dev](https://docs.flutter.dev/)
- **Dart documentation:** [dart.dev](https://dart.dev/)
- **Riverpod documentation:** [riverpod.dev](https://riverpod.dev/)
- **SQLite documentation:** [sqlite.org](https://www.sqlite.org/)

## Built for Everyday Productivity

NotiBuku brings note-taking and task management into one practical workspace. Its goal is simple: make it easier to capture ideas, organize information, and keep track of the things that matter.

**NotiBuku — your notebook, your workflow.**
