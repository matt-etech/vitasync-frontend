import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/carer_session.dart';
import '../models/family_session.dart';
import '../services/carer_auth_contract.dart';
import '../services/family_access_contract.dart';

class CarerLoginScreen extends StatefulWidget {
  const CarerLoginScreen({
    required this.authService,
    required this.familyAccess,
    required this.onAuthenticated,
    required this.onFamilyAuthenticated,
    super.key,
  });

  final CarerAuthPort authService;
  final FamilyAccessPort familyAccess;
  final ValueChanged<CarerSession> onAuthenticated;
  final ValueChanged<FamilySession> onFamilyAuthenticated;

  @override
  State<CarerLoginScreen> createState() => _CarerLoginScreenState();
}

class _CarerLoginScreenState extends State<CarerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _accessType = _LoginAccessType.carer;
  var _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (_accessType == _LoginAccessType.carer) {
        final session = await widget.authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (!mounted) {
          return;
        }

        widget.onAuthenticated(session);
      } else {
        final familySession = await widget.familyAccess.login(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (!mounted) {
          return;
        }

        widget.onFamilyAuthenticated(familySession);
      }
    } on CarerAuthException catch (error) {
      setState(() => _errorMessage = error.message);
    } on FamilyAccessException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() {
        _errorMessage =
            'Backend unavailable at ${AppConfig.backendBaseUrl}. Check the service is running and reachable.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _LoginHeader(),
                    const SizedBox(height: 28),
                    SegmentedButton<_LoginAccessType>(
                      segments: const [
                        ButtonSegment<_LoginAccessType>(
                          value: _LoginAccessType.carer,
                          icon: Icon(Icons.badge_outlined),
                          label: Text('Carer'),
                        ),
                        ButtonSegment<_LoginAccessType>(
                          value: _LoginAccessType.family,
                          icon: Icon(Icons.family_restroom_outlined),
                          label: Text('Family'),
                        ),
                      ],
                      selected: {_accessType},
                      onSelectionChanged: _isSubmitting
                          ? null
                          : (selection) {
                              setState(() {
                                _accessType = selection.first;
                                _errorMessage = null;
                              });
                            },
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return const Color(0xFF0F766E);
                            }

                            return const Color(0xFF40525A);
                          },
                        ),
                        side: WidgetStateProperty.all(
                          const BorderSide(color: Color(0xFFB7C2CA)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null) ...[
                      _AlertBanner(message: _errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      autofillHints: const [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Enter your email address.';
                        }
                        if (!email.contains('@')) {
                          return 'Enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      autofillHints: const [AutofillHints.password],
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Enter your password.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: Text(
                        _isSubmitting
                            ? 'Checking access'
                            : _accessType.submitLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _LoginAccessType { carer, family }

extension _LoginAccessTypePresentation on _LoginAccessType {
  String get submitLabel {
    switch (this) {
      case _LoginAccessType.carer:
        return 'Sign in as carer';
      case _LoginAccessType.family:
        return 'Sign in as family';
    }
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.health_and_safety_outlined,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text('VitaSync Login', style: textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Use the access type assigned by the care team.',
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E5),
          border: Border.all(color: const Color(0xFFB45309)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_outlined, color: Color(0xFF92400E)),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
