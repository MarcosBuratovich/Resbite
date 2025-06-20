// Temporary alias while migrating from Circle to Group.
// The underlying data structure remains the same to keep backwards
// compatibility during the sprint. New code should import `Group`.
// TODO: Replace alias with dedicated Group model once migration stabilises.

import 'circle.dart';

typedef Group = Circle;
