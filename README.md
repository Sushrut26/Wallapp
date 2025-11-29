# Wallapp - Fridge Tablet Assistant

A Flutter application designed for tablets mounted on fridges, providing family organization features including to-do lists, AI-powered meal planning, and calendar management.

## Features

### 1. Family To-Do List
- Separate to-do lists for each family member (Sushrut, Shilpa, Guest)
- Add, complete, and delete tasks
- Filter tasks by family member
- Persistent storage using SharedPreferences

### 2. AI Meal Planner
- AI-powered vegetarian meal suggestions
- Tracks meal history to provide personalized suggestions
- Manual meal entry option
- Categorized by meal type (Breakfast, Lunch, Dinner, Snack)
- Mark meals as cooked
- View meal history

### 3. Calendar Event Tracker
- Visual calendar with event markers
- Add, view, and delete events
- Support for all-day events
- Color-coded events
- Time and location tracking
- Sync-ready architecture (phone sync can be enabled)

## Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Local Storage**: SharedPreferences, SQLite (sqflite)
- **UI Components**: Material Design 3, Google Fonts
- **Calendar**: table_calendar
- **AI/LLM**: Local LLM support via Ollama (with fallback suggestions)

## Setup Instructions

### Prerequisites

1. Install Flutter SDK (3.0.0 or higher)
2. Install an IDE (VS Code, Android Studio, or IntelliJ)
3. Install Android SDK for Android deployment
4. (Optional) Install Ollama for AI meal suggestions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Wallapp
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Android
flutter run -d <device-id>

# For Web
flutter run -d chrome

# For specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

### Setting up Local LLM (Optional)

For AI meal suggestions to work with a local LLM:

1. Install Ollama from https://ollama.ai
2. Pull a model:
```bash
ollama pull llama2
```

3. Run Ollama:
```bash
ollama serve
```

4. The app will automatically connect to `http://localhost:11434`

**Note**: If Ollama is not available, the app will use built-in fallback meal suggestions.

### Building for Production

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### Web
```bash
flutter build web --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── todo_item.dart
│   ├── meal.dart
│   └── calendar_event.dart
├── providers/                # State management
│   ├── todo_provider.dart
│   ├── meal_provider.dart
│   └── calendar_provider.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── todo_list_screen.dart
│   ├── meal_planner_screen.dart
│   └── calendar_screen.dart
├── services/                 # Business logic
│   └── llm_service.dart
└── widgets/                  # Reusable widgets
```

## Usage Guide

### To-Do List
1. Tap "To-Do List" from the home screen
2. Select a family member using the chips at the top
3. Tap "+" to add a new task
4. Check the checkbox to mark tasks as complete
5. Tap the delete icon to remove tasks

### Meal Planner
1. Tap "Meal Planner" from the home screen
2. Use the date selector to navigate days
3. Tap the AI icon to get meal suggestions
4. Or tap "Add Meal" to manually add a meal
5. Tap on a meal card to expand and see details
6. Tap the history icon to view past meals

### Calendar
1. Tap "Calendar" from the home screen
2. Select a date from the calendar
3. Tap "Add Event" to create a new event
4. Fill in event details (title, time, location, etc.)
5. Events appear as markers on the calendar
6. Tap an event to view details or delete

## Customization

### Adding More Family Members

Edit `lib/providers/todo_provider.dart`:
```dart
final List<String> _familyMembers = ['Sushrut', 'Shilpa', 'Guest', 'NewMember'];
```

### Changing LLM Endpoint

Edit `lib/services/llm_service.dart`:
```dart
LLMService({
  this.baseUrl = 'http://your-llm-server:11434',
  this.model = 'your-model-name',
});
```

### Customizing Meal Categories

Edit the `categories` list in `lib/screens/meal_planner_screen.dart`:
```dart
final categories = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'NewCategory'];
```

## Future Enhancements

- [ ] Calendar sync with Google Calendar / Apple Calendar
- [ ] Shopping list integration from meal plans
- [ ] Recipe database with images
- [ ] Voice input for adding tasks/events
- [ ] Family photo gallery
- [ ] Weather widget
- [ ] Notification reminders
- [ ] Multi-device sync via Firebase
- [ ] Recipe sharing between family members

## Troubleshooting

### LLM Not Working
- Ensure Ollama is running: `ollama serve`
- Check the endpoint is accessible: `curl http://localhost:11434/api/generate`
- The app will use fallback suggestions if LLM is unavailable

### Data Not Persisting
- Check SharedPreferences permissions
- Ensure app has storage permissions on Android

### Calendar Sync Issues
- Phone calendar sync requires additional permissions
- Refer to `device_calendar` package documentation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Contact

For questions or support, please open an issue on GitHub.
