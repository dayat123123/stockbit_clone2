import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/widgets/custom_window_caption_buttons.dart';
import 'package:stockbit_clone2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:stockbit_clone2/features/auth/presentation/bloc/auth_event.dart';
import 'package:stockbit_clone2/features/auth/presentation/bloc/auth_state.dart';

/// Fixed-size, professional dark terminal login form screen filling the compact OS desktop window
/// with custom frameless window controls (Minimize and Close).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController =
      TextEditingController(text: 'trader_pro');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    context.read<AuthBloc>().add(
          LoginSubmittedEvent(
            username: _usernameController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.systemBackgroundDark,
      body: RepaintBoundary(
        child: Column(
          children: [
            // ── Frameless Title Bar (Drag & Custom Window Controls) ────────
            Container(
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.headerBg,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 0.8),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.trending_up, size: 14, color: AppColors.primaryDark),
                  const SizedBox(width: 6),
                  const Text(
                    'Stockbit Desktop Pro',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Expanded(
                    child: DragToMoveArea(
                      child: SizedBox(height: 32),
                    ),
                  ),
                  const CustomWindowCaptionButtons(
                    showMaximize: false, // Login is non-resizable
                    height: 32,
                  ),
                ],
              ),
            ),

            // ── Main Login Content Area ───────────────────────────────────
            Expanded(
              child: Row(
                children: [
                  // Sisi Kiri: Branding & Info (340px)
                  Container(
                    width: 340,
                    padding: const EdgeInsets.all(28),
                    decoration: const BoxDecoration(
                      color: AppColors.sidebarBg,
                      border: Border(
                        right: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.trending_up,
                                color: AppColors.primaryDark,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'STOCKBIT',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.badgePurple.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.badgePurple,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        const Text(
                          'Institutional-Grade\nTrading Terminal',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Modular multi-window 2D grid workspace, level 2 orderbook depth, and instant transaction routing.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            height: 1.45,
                          ),
                        ),

                        const Spacer(),

                        Row(
                          children: [
                            const Icon(Icons.shield_outlined, size: 14, color: AppColors.primaryDark),
                            const SizedBox(width: 8),
                            Text(
                              'IDX & OJK Regulated System',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primaryDark.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Sisi Kanan: Form Input Login
                  Expanded(
                    child: Container(
                      color: AppColors.cardBg,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoadingState;
                          final errorMsg = state is AuthUnauthenticatedState
                              ? state.errorMessage
                              : null;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sign In to Terminal',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Enter credentials to unlock workspace',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 18),

                              if (errorMsg != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.offerRed.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.offerRed.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, size: 13, color: AppColors.offerRed),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          errorMsg,
                                          style: const TextStyle(fontSize: 10.5, color: AppColors.offerRed),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Username Input
                              const Text(
                                'USERNAME / TRADER ID',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: TextField(
                                  controller: _usernameController,
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter username',
                                    hintStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    prefixIcon: Icon(Icons.person_outline, size: 15, color: AppColors.textMuted),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                                    isDense: true,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Password Input
                              const Text(
                                'PASSWORD',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary),
                                  onSubmitted: (_) => _submitLogin(),
                                  decoration: InputDecoration(
                                    hintText: 'Enter password',
                                    hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    prefixIcon: const Icon(Icons.lock_outline, size: 15, color: AppColors.textMuted),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        size: 15,
                                        color: AppColors.textMuted,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                                    isDense: true,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Sign In Button
                              SizedBox(
                                width: double.infinity,
                                height: 36,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: isLoading ? null : _submitLogin,
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                        )
                                      : const Text(
                                          'Unlock Trading Terminal',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
