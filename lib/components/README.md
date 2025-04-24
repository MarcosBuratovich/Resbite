# Resbite Shadcn Component System

This directory contains the Resbite app's component system, inspired by [shadcn/ui](https://ui.shadcn.com/). The component system is built using Flutter and follows a utility-first approach to styling with Tailwind CSS-like utilities.

## Structure

- `/ui`: Contains individual UI components like buttons, cards, inputs, etc.
- `/layouts`: Contains layout components that combine UI components for common page layouts
- `/styles`: Contains styling utilities like colors, typography, and themes

## Usage

### Importing Components

You can import individual components directly:

```dart
import 'package:resbite_app/components/ui/button.dart';
```

Or use the barrel files for easier imports:

```dart
import 'package:resbite_app/components/ui.dart'; // For UI components
import 'package:resbite_app/components/layouts.dart'; // For layout components
import 'package:resbite_app/components.dart'; // For all components
```

### Using Components

#### Buttons

```dart
// Primary button
ShadButton.primary(
  text: 'Click me',
  onPressed: () {},
);

// Secondary button
ShadButton.secondary(
  text: 'Cancel',
  onPressed: () {},
);

// Button with icon
ShadButton.primary(
  text: 'Add Item',
  icon: Icons.add,
  onPressed: () {},
);

// Loading state
ShadButton.primary(
  text: 'Loading',
  isLoading: true,
  onPressed: () {},
);
```

#### Cards

```dart
ShadCard.default_(
  title: 'Card Title',
  subtitle: 'Card subtitle',
  child: Text('Card content goes here'),
);

ShadCard.elevated(
  title: 'Elevated Card',
  child: Text('This card has a shadow but no border'),
);
```

#### Inputs

```dart
// Text input
ShadInput.text(
  labelText: 'Name',
  hintText: 'Enter your name',
  controller: _nameController,
);

// Email input
ShadInput.email(
  labelText: 'Email',
  controller: _emailController,
);

// Password input
ShadInput.password(
  labelText: 'Password',
  controller: _passwordController,
);
```

#### Badges

```dart
ShadBadge.primary(text: 'New');
ShadBadge.secondary(text: 'Popular');
ShadBadge.outline(text: 'Draft');
ShadBadge.destructive(text: 'Deleted');
```

#### Avatars

```dart
// Image avatar
ShadAvatar(
  imageUrl: 'https://example.com/avatar.jpg',
);

// Initials avatar
ShadAvatar(
  initials: 'JD',
);

// Avatar with status
ShadAvatar(
  initials: 'JD',
  statusColor: TwColors.success,
);
```

#### Layouts

```dart
CardLayout(
  title: 'Page Title',
  subtitle: 'Page description',
  content: YourContent(),
  actions: [
    ShadButton.secondary(text: 'Cancel', onPressed: () {}),
    ShadButton.primary(text: 'Save', onPressed: () {}),
  ],
);
```

## Styling Utilities

### TwColors

Color constants following Tailwind CSS naming conventions:

```dart
Text(
  'Primary text',
  style: TextStyle(color: TwColors.primary),
);

Container(
  color: TwColors.slate100,
);
```

### TwTypography

Typography styles:

```dart
Text(
  'Heading',
  style: TwTypography.heading1(context),
);

Text(
  'Body text',
  style: TwTypography.body(context),
);
```

### Widget Extensions

Utility extensions for common styling:

```dart
// Padding
Text('Padded text').p4

// Margin
Text('With margin').m2

// Rounded corners
Image(...).roundedLg

// Shadow
Card(...).shadowMd
```

## Demo

Check out the Shadcn Demo screen to see all components in action:

```dart
Navigator.of(context).pushNamed('/shadcn-demo');
```