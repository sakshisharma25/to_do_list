# ToDoList App

A feature-rich task management application built with Flutter, following clean architecture principles.

![ToDoList App Link](https://drive.google.com/file/d/1ryvbuI4DKNtKPgBROB-ljS4b2k20deid/view?usp=sharing)

![ToDoList App Documentation](https://docs.google.com/document/d/1mkWIaH9gD0KvihPo6xNY4JPiiuWnjGXA4LqMbCbHSQ8/edit?usp=sharing)

## Features

- **Task Management**: Create, edit, and delete tasks
- **Priority Levels**: Assign low, medium, or high priority to tasks
- **Due Dates**: Set due dates and times for tasks
- **Smart Notifications**: Receive reminders at strategic intervals:
  - At the exact due time
  - 15 minutes before due time (for all tasks)
  - 1 hour before due time (for medium and high priority tasks)
  - 1 day before due time (for high priority tasks)
- **Task Filtering**: Filter tasks by All, Today, Upcoming, and Completed
- **Task Sorting**: Sort by creation date, due date, or priority
- **Search Functionality**: Quickly find tasks by title or description
- **Intuitive UI**: Clean, modern interface with Material Design

## Architecture

The app follows the Model-View-Controller (MVC) architecture pattern:

- **Models**: Define data structures for tasks
- **Views**: UI components and screens
- **Controllers**: Business logic and state management using GetX

## Getting Started

# Clone the repository
git clone https://github.com/yourusername/todolist_app.git

# Install dependencies
flutter pub get

# Run the app
flutter run
