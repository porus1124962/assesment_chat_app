import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/constants.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController nameController;
  late final String _initialName;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    final currentName = authState is AuthSuccess ? authState.user.name : '';
    _initialName = currentName;
    nameController = TextEditingController(text: currentName);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      AppSnackBar.showError(context, 'Please enter name');
      return false;
    }
    if (name.length < minUsernameLength) {
      AppSnackBar.showError(
        context,
        'Name must be at least $minUsernameLength characters',
      );
      return false;
    }
    if (name.length > maxUsernameLength) {
      AppSnackBar.showError(
        context,
        'Name must be at most $maxUsernameLength characters',
      );
      return false;
    }

    return true;
  }

  Future<void> _handleSave() async {
    if (!_validateForm()) return;
    await context.read<AuthCubit>().updateProfileName(nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentName = nameController.text.trim();
    final isChanged = currentName != _initialName.trim();
    final isSaveEnabled = currentName.isNotEmpty && isChanged;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          defaultPadding,
          defaultPadding,
          defaultPadding,
          defaultPadding * 1.4,
        ),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              AppSnackBar.showError(context, state.message);
            } else if (state is AuthSuccess) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: const LoadingWidget(message: 'Saving profile...'),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    _initialsFromName(currentName),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: defaultPadding),
                Text(
                  'Update your display name',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'This name will be visible to everyone in chats.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: defaultPadding * 1.5),
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      defaultBorderRadius + 4,
                    ),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your display name',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: .6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              defaultBorderRadius,
                            ),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${currentName.length}/$maxUsernameLength',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: defaultPadding * 1.5),
                ElevatedButton(
                  onPressed: isSaveEnabled ? _handleSave : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadius),
                    ),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
