import 'package:flutter/material.dart';
import 'package:resbite_app/components/layouts.dart';
import 'package:resbite_app/components/ui.dart';
import 'package:resbite_app/components/ui/button.dart';
import 'package:resbite_app/components/ui/badge.dart';
import 'package:resbite_app/styles/tailwind_theme.dart';

/// A demonstration screen showcasing all the shadcn-inspired components.
/// This screen serves as both documentation and a visual reference for the
/// component system being implemented.
class ShadcnDemoScreen extends StatefulWidget {
  const ShadcnDemoScreen({super.key});

  @override
  State<ShadcnDemoScreen> createState() => _ShadcnDemoScreenState();
}

class _ShadcnDemoScreenState extends State<ShadcnDemoScreen> {
  final _textController = TextEditingController();
  final _emailController = TextEditingController(text: 'example@email.com');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _textController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardLayout(
      title: 'Shadcn Component System',
      subtitle: 'A showcase of all available components',
      titleIcon: Icons.design_services,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Typography', _buildTypographyShowcase()),

          _buildSection('Buttons', _buildButtonsShowcase()),

          _buildSection('Input Fields', _buildInputsShowcase()),

          _buildSection('Cards', _buildCardsShowcase()),

          _buildSection('Badges', _buildBadgesShowcase()),

          _buildSection('Avatars', _buildAvatarsShowcase()),
        ],
      ),
      actions: [
        ShadButton.secondary(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        ShadButton.primary(
          text: 'Save',
          onPressed: () {
            // Show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Components saved successfully!',
                  style: TwTypography.body(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                backgroundColor: TwColors.success,
              ),
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TwTypography.heading5(context).copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Divider(),
        const SizedBox(height: 16),
        content,
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTypographyShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Heading 1', style: TwTypography.heading1(context)),
        const SizedBox(height: 8),
        Text('Heading 2', style: TwTypography.heading2(context)),
        const SizedBox(height: 8),
        Text('Heading 3', style: TwTypography.heading3(context)),
        const SizedBox(height: 8),
        Text('Heading 4', style: TwTypography.heading4(context)),
        const SizedBox(height: 8),
        Text('Heading 5', style: TwTypography.heading5(context)),
        const SizedBox(height: 8),
        Text('Heading 6', style: TwTypography.heading6(context)),
        const SizedBox(height: 16),
        Text('Body text (large)', style: TwTypography.body(context)),
        const SizedBox(height: 8),
        Text('Body text (medium)', style: TwTypography.bodySm(context)),
        const SizedBox(height: 8),
        Text('Body text (small)', style: TwTypography.bodyXs(context)),
        const SizedBox(height: 16),
        Text('Label (large)', style: TwTypography.label(context)),
        const SizedBox(height: 8),
        Text('Label (medium)', style: TwTypography.labelSm(context)),
        const SizedBox(height: 8),
        Text('Label (small)', style: TwTypography.labelXs(context)),
      ],
    );
  }

  Widget _buildButtonsShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Button variants
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [
            ShadButton.primary(text: 'Primary', onPressed: () {}),
            ShadButton.secondary(text: 'Secondary', onPressed: () {}),
            ShadButton.ghost(text: 'Ghost', onPressed: () {}),
            ShadButton.destructive(text: 'Destructive', onPressed: () {}),
            ShadButton.link(text: 'Link', onPressed: () {}),
          ],
        ),

        const SizedBox(height: 20),

        // Button sizes
        Wrap(
          spacing: 8,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ShadButton.primary(
              text: 'Small',
              size: ButtonSize.sm,
              onPressed: () {},
            ),
            ShadButton.primary(text: 'Medium', onPressed: () {}),
            ShadButton.primary(
              text: 'Large',
              size: ButtonSize.lg,
              onPressed: () {},
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Buttons with icons
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [
            ShadButton.primary(
              text: 'Leading Icon',
              icon: Icons.add,
              onPressed: () {},
            ),
            ShadButton.primary(
              text: 'Trailing Icon',
              icon: Icons.arrow_forward,
              iconTrailing: true,
              onPressed: () {},
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Loading and disabled buttons
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [
            ShadButton.primary(
              text: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
            ShadButton.primary(text: 'Disabled', onPressed: null),
            ShadButton.secondary(text: 'Disabled', onPressed: null),
          ],
        ),
      ],
    );
  }

  Widget _buildInputsShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Standard text input
        ShadInput.text(
          labelText: 'Standard Input',
          hintText: 'Enter some text',
          controller: _textController,
        ),
        const SizedBox(height: 16),

        // Email input
        ShadInput.email(
          labelText: 'Email Input',
          controller: _emailController,
          helperText: 'This is a specialized input for email addresses',
        ),
        const SizedBox(height: 16),

        // Password input
        ShadInput.password(
          labelText: 'Password Input',
          controller: _passwordController,
        ),
        const SizedBox(height: 16),

        // Number input
        ShadInput.number(labelText: 'Number Input', hintText: 'Enter a number'),
        const SizedBox(height: 16),

        // Multiline input
        ShadInput.multiline(
          labelText: 'Multiline Input',
          hintText: 'Enter multiple lines of text',
          maxLines: 4,
        ),
        const SizedBox(height: 16),

        // Input with error
        ShadInput.text(
          labelText: 'Input with Error',
          hintText: 'This input has an error',
          errorText: 'This field is required',
        ),
        const SizedBox(height: 16),

        // Disabled input
        ShadInput.text(
          labelText: 'Disabled Input',
          hintText: 'This input is disabled',
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildCardsShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Default card
        ShadCard.default_(
          title: 'Default Card',
          subtitle: 'With title and subtitle',
          child: const Text(
            'This is a default card with a border and a shadow.',
          ),
        ),
        const SizedBox(height: 16),

        // Elevated card
        ShadCard.elevated(
          title: 'Elevated Card',
          subtitle: 'No border, just shadow',
          child: const Text(
            'This card has no border but has a shadow for elevation.',
          ),
        ),
        const SizedBox(height: 16),

        // Outlined card
        ShadCard.outlined(
          title: 'Outlined Card',
          subtitle: 'Border without shadow',
          child: const Text('This card has a border but no shadow.'),
        ),
        const SizedBox(height: 16),

        // Flat card
        ShadCard.flat(
          title: 'Flat Card',
          subtitle: 'No border, no shadow',
          child: const Text('This card has neither border nor shadow.'),
        ),
        const SizedBox(height: 16),

        // Card with actions
        ShadCard.default_(
          title: 'Card with Actions',
          subtitle: 'This card has action buttons',
          actions: [
            ShadButton.ghost(
              text: 'Cancel',
              size: ButtonSize.sm,
              onPressed: () {},
            ),
            ShadButton.primary(
              text: 'Save',
              size: ButtonSize.sm,
              onPressed: () {},
            ),
          ],
          child: const Text(
            'You can add action buttons to cards for common operations.',
          ),
        ),
        const SizedBox(height: 16),

        // Card with leading/trailing
        ShadCard.default_(
          title: 'Card with Icons',
          subtitle: 'This card has leading and trailing icons',
          leading: const Icon(Icons.star, color: TwColors.warning),
          trailing: const Icon(Icons.chevron_right),
          child: const Text(
            'Leading and trailing widgets can be added to cards for extra information.',
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge variants
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [
            ShadBadge.primary(text: 'Primary'),
            ShadBadge.secondary(text: 'Secondary'),
            ShadBadge.outline(text: 'Outline'),
            ShadBadge.destructive(text: 'Destructive'),
          ],
        ),

        const SizedBox(height: 20),

        // Badge sizes
        Wrap(
          spacing: 8,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ShadBadge.primary(text: 'Small', size: BadgeSize.sm),
            ShadBadge.primary(text: 'Medium'),
            ShadBadge.primary(text: 'Large', size: BadgeSize.lg),
          ],
        ),

        const SizedBox(height: 20),

        // Badges with icons
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [
            ShadBadge.primary(text: 'New', icon: Icons.star),
            ShadBadge.secondary(
              text: 'Settings',
              icon: Icons.settings,
              iconTrailing: true,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Interactive badges
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [
            ShadBadge.primary(
              text: 'Clickable',
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Badge clicked!')));
              },
            ),
            ShadBadge.secondary(
              text: 'Removable',
              removable: true,
              onRemove: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Badge removed!')));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarsShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar sizes
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ShadAvatar.xs(initials: 'XS'),
            ShadAvatar.sm(initials: 'SM'),
            ShadAvatar(initials: 'MD'),
            ShadAvatar.lg(initials: 'LG'),
            ShadAvatar.xl(initials: 'XL'),
          ],
        ),

        const SizedBox(height: 24),

        // Avatar types
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Image avatar (using a placeholder image)
            ShadAvatar(imageUrl: 'https://i.pravatar.cc/150?img=1'),

            // Initials avatar
            ShadAvatar(
              initials: 'JD',
              backgroundColor: TwColors.primary,
              textColor: TwColors.textLight,
            ),

            // Fallback icon
            ShadAvatar(
              fallback: const Icon(Icons.person, color: TwColors.textLight),
              backgroundColor: TwColors.secondary,
            ),

            // With border
            ShadAvatar(
              initials: 'AB',
              hasBorder: true,
              borderColor: TwColors.primary,
              borderWidth: 2,
            ),

            // With status
            ShadAvatar(initials: 'ON', statusColor: TwColors.success),
          ],
        ),
      ],
    );
  }
}
