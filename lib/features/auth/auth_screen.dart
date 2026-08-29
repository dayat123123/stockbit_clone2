import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/utils/desktop_window_helper.dart';
import 'package:stockbit_clone2/core/blocs/auth/auth_bloc.dart';
import 'package:stockbit_clone2/core/blocs/auth/auth_event.dart';
import 'package:stockbit_clone2/core/blocs/auth/auth_state.dart';

/// Pixel-perfect replica of the official Stockbit Desktop Login Screen.
/// Left: Isometric line-art trading terminal desk with IDX copyright footer.
/// Right: Clean Stockbit auth form (Google login, username/password, Trouble logging in?, Login button).
/// Entire surface is draggable on Desktop with a single top-right close button.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController(
    text: 'trader_pro',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'password123',
  );
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    context.read<AuthBloc>().add(
      LoginWithEmailEvent(
        usernameOrEmail: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  void _fillDemoCredentials() {
    _usernameController.text = 'trader_pro';
    _passwordController.text = 'password123';
    _submitLogin();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: const Color(0xFF14171A),
      body: RepaintBoundary(
        child: Stack(
          children: [
            // ── 1. Split Layout (Illustration on Left, Form on Right) ──────
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;

                if (isWide) {
                  return Row(
                    children: [
                      // Left: Stockbit Isometric Line-Art Illustration (46%)
                      const Expanded(
                        flex: 46,
                        child: _StockbitLeftIllustrationPanel(),
                      ),

                      // Right: Stockbit Login Form (54%)
                      Expanded(flex: 54, child: _buildLoginForm()),
                    ],
                  );
                }

                // Compact Single Column for small windows / mobile
                return SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      child: _buildLoginForm(isNarrow: true),
                    ),
                  ),
                );
              },
            ),

            // ── 2. Top-Right Clean Close Button ────────────────────────────
            if (DesktopWindowHelper.isDesktop)
              Positioned(
                top: 10,
                right: 10,
                child: _CloseHoverButton(onTap: DesktopWindowHelper.close),
              ),
          ],
        ),
      ),
    );

    if (DesktopWindowHelper.isDesktop) {
      return DragToMoveArea(child: content);
    }
    return content;
  }

  Widget _buildLoginForm({bool isNarrow = false}) {
    return Container(
      color: const Color(0xFF1B1E23),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 20 : 44,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoadingState;
            final errorMsg = state is AuthErrorState ? state.message : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Stockbit Logo (Speech Bubble with graph)
                Center(child: _StockbitLogoBadge()),
                const SizedBox(height: 18),

                // 2. Heading
                const Center(
                  child: Text(
                    'Welcome to Stockbit',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Login with Google Button
                InkWell(
                  onTap: _fillDemoCredentials,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22262C),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF323842),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGoogleIcon(),
                        const SizedBox(width: 10),
                        const Text(
                          'Login with Google',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD1D5DB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Divider with "or"
                Row(
                  children: const [
                    Expanded(
                      child: Divider(color: Color(0xFF2E343E), thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'or',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Color(0xFF2E343E), thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (errorMsg != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.offerRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.offerRed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      errorMsg,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.offerRed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 5. Username or email Input
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14171A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF2E343E),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _usernameController,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Username or email',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6B7280),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 6. Password Input
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14171A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF2E343E),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    onSubmitted: (_) => _submitLogin(),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6B7280),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 17,
                          color: const Color(0xFF6B7280),
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 7. Trouble Logging In? (Aligned to the Right)
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: _fillDemoCredentials,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Trouble Logging In?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00C076),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 8. Solid Green Login Button
                SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C076),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoading ? null : _submitLogin,
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Text(
            'G',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4285F4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stockbit Logo Speech Bubble with Colorful Market Line
class _StockbitLogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C076).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(26, 14),
          painter: _StockbitChartIconPainter(),
        ),
      ),
    );
  }
}

class _StockbitChartIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGreen = Paint()
      ..color = const Color(0xFF00C076)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintOrange = Paint()
      ..color = const Color(0xFFFF9800)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintPurple = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Segment 1 (Purple down-up)
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width * 0.33, size.height * 0.8),
      paintPurple,
    );

    // Segment 2 (Orange up)
    canvas.drawLine(
      Offset(size.width * 0.33, size.height * 0.8),
      Offset(size.width * 0.66, size.height * 0.2),
      paintOrange,
    );

    // Segment 3 (Green up-trend)
    canvas.drawLine(
      Offset(size.width * 0.66, size.height * 0.2),
      Offset(size.width, size.height * 0.5),
      paintGreen,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stockbit Left Illustration Panel matching the official Stockbit desktop art
class _StockbitLeftIllustrationPanel extends StatelessWidget {
  const _StockbitLeftIllustrationPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF14171A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CustomPaint(painter: _StockbitIsometricDeskPainter()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '© PT. Stockbit Sekuritas Digital',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Isometric Vector Illustration of Stockbit Trading Terminal Desk
class _StockbitIsometricDeskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mintGreen = Paint()
      ..color = const Color(0xFF00C076)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final purple = Paint()
      ..color = const Color(0xFFA855F7)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // ── 1. Background Rays / Speed Lines ─────────────────────────────────────
    canvas.drawLine(
      Offset(w * 0.15, h * 0.2),
      Offset(w * 0.35, h * 0.28),
      mintGreen,
    );
    canvas.drawLine(
      Offset(w * 0.2, h * 0.26),
      Offset(w * 0.42, h * 0.35),
      mintGreen,
    );
    canvas.drawLine(
      Offset(w * 0.35, h * 0.16),
      Offset(w * 0.55, h * 0.24),
      purple,
    );
    canvas.drawLine(
      Offset(w * 0.8, h * 0.35),
      Offset(w * 0.95, h * 0.42),
      mintGreen,
    );
    canvas.drawLine(
      Offset(w * 0.82, h * 0.48),
      Offset(w * 0.98, h * 0.54),
      purple,
    );
    canvas.drawLine(
      Offset(w * 0.45, h * 0.82),
      Offset(w * 0.55, h * 0.86),
      purple,
    );

    // ── 2. Top-Right Pie Chart ───────────────────────────────────────────────
    final pieCenter = Offset(w * 0.65, h * 0.14);
    canvas.drawOval(
      Rect.fromCenter(center: pieCenter, width: w * 0.16, height: h * 0.08),
      mintGreen,
    );
    canvas.drawLine(
      pieCenter,
      Offset(pieCenter.dx, pieCenter.dy - h * 0.04),
      mintGreen,
    );
    canvas.drawLine(
      pieCenter,
      Offset(pieCenter.dx + w * 0.06, pieCenter.dy + h * 0.02),
      mintGreen,
    );

    // ── 3. Top-Right Modular Blocks / Windows ────────────────────────────────
    _drawIsoBlock(
      canvas,
      Offset(w * 0.8, h * 0.26),
      w * 0.08,
      h * 0.05,
      mintGreen,
    );
    _drawIsoBlock(
      canvas,
      Offset(w * 0.86, h * 0.29),
      w * 0.07,
      h * 0.04,
      mintGreen,
    );

    // ── 4. Main Isometric Monitor Screen ─────────────────────────────────────
    final monitorPath = Path();
    // Screen Outer Frame
    monitorPath.moveTo(w * 0.22, h * 0.38);
    monitorPath.lineTo(w * 0.74, h * 0.22);
    monitorPath.lineTo(w * 0.74, h * 0.52);
    monitorPath.lineTo(w * 0.22, h * 0.68);
    monitorPath.close();
    canvas.drawPath(monitorPath, mintGreen);

    // Monitor 3D Base & Stand
    final standPath = Path()
      ..moveTo(w * 0.48, h * 0.60)
      ..lineTo(w * 0.48, h * 0.66)
      ..lineTo(w * 0.56, h * 0.63)
      ..lineTo(w * 0.56, h * 0.57);
    canvas.drawPath(standPath, mintGreen);

    final basePath = Path()
      ..moveTo(w * 0.42, h * 0.66)
      ..lineTo(w * 0.58, h * 0.60)
      ..lineTo(w * 0.62, h * 0.62)
      ..lineTo(w * 0.46, h * 0.68)
      ..close();
    canvas.drawPath(basePath, mintGreen);

    // Monitor Chart Line inside screen
    final chartPath = Path()
      ..moveTo(w * 0.31, h * 0.54)
      ..lineTo(w * 0.36, h * 0.50)
      ..lineTo(w * 0.42, h * 0.48)
      ..lineTo(w * 0.47, h * 0.42)
      ..lineTo(w * 0.54, h * 0.42)
      ..lineTo(w * 0.61, h * 0.36)
      ..lineTo(w * 0.67, h * 0.37);
    canvas.drawPath(chartPath, mintGreen);

    // Left Floating Small Chart Card
    final leftCardPath = Path()
      ..moveTo(w * 0.16, h * 0.40)
      ..lineTo(w * 0.32, h * 0.34)
      ..lineTo(w * 0.32, h * 0.48)
      ..lineTo(w * 0.16, h * 0.54)
      ..close();
    canvas.drawPath(leftCardPath, mintGreen);

    // Bar chart lines inside small card
    canvas.drawLine(
      Offset(w * 0.20, h * 0.49),
      Offset(w * 0.20, h * 0.44),
      mintGreen,
    );
    canvas.drawLine(
      Offset(w * 0.24, h * 0.47),
      Offset(w * 0.24, h * 0.39),
      mintGreen,
    );
    canvas.drawLine(
      Offset(w * 0.28, h * 0.45),
      Offset(w * 0.28, h * 0.41),
      mintGreen,
    );

    // ── 5. Isometric Keyboard ────────────────────────────────────────────────
    final kbPath = Path()
      ..moveTo(w * 0.41, h * 0.74)
      ..lineTo(w * 0.72, h * 0.63)
      ..lineTo(w * 0.84, h * 0.70)
      ..lineTo(w * 0.53, h * 0.81)
      ..close();
    canvas.drawPath(kbPath, mintGreen);

    // Keyboard Key Grid Lines
    for (int i = 1; i <= 4; i++) {
      final t = i / 5.0;
      final start = Offset.lerp(
        Offset(w * 0.41, h * 0.74),
        Offset(w * 0.53, h * 0.81),
        t,
      )!;
      final end = Offset.lerp(
        Offset(w * 0.72, h * 0.63),
        Offset(w * 0.84, h * 0.70),
        t,
      )!;
      canvas.drawLine(start, end, mintGreen);
    }

    // ── 6. Isometric Mouse ───────────────────────────────────────────────────
    final mouseRect = Rect.fromCenter(
      center: Offset(w * 0.86, h * 0.63),
      width: w * 0.14,
      height: h * 0.07,
    );
    canvas.drawOval(mouseRect, mintGreen);
    canvas.drawLine(
      Offset(w * 0.83, h * 0.61),
      Offset(w * 0.88, h * 0.62),
      mintGreen,
    );

    // ── 7. Potted Plant on Left Desk ─────────────────────────────────────────
    // Pot
    final potPath = Path()
      ..moveTo(w * 0.25, h * 0.77)
      ..lineTo(w * 0.39, h * 0.75)
      ..lineTo(w * 0.37, h * 0.88)
      ..lineTo(w * 0.27, h * 0.89)
      ..close();
    canvas.drawPath(potPath, mintGreen);

    // Pot Rim
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.32, h * 0.76),
        width: w * 0.16,
        height: h * 0.05,
      ),
      mintGreen,
    );

    // Plant Leaves with Purple Accents
    _drawLeaf(
      canvas,
      Offset(w * 0.28, h * 0.74),
      Offset(w * 0.26, h * 0.67),
      purple,
    );
    _drawLeaf(
      canvas,
      Offset(w * 0.32, h * 0.74),
      Offset(w * 0.31, h * 0.64),
      purple,
    );
    _drawLeaf(
      canvas,
      Offset(w * 0.36, h * 0.74),
      Offset(w * 0.38, h * 0.68),
      purple,
    );
  }

  void _drawIsoBlock(
    Canvas canvas,
    Offset pos,
    double w,
    double h,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(pos.dx, pos.dy)
      ..lineTo(pos.dx + w * 0.6, pos.dy - h * 0.5)
      ..lineTo(pos.dx + w, pos.dy)
      ..lineTo(pos.dx + w * 0.4, pos.dy + h * 0.5)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawLeaf(Canvas canvas, Offset base, Offset tip, Paint paint) {
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(base.dx - 8, (base.dy + tip.dy) / 2, tip.dx, tip.dy)
      ..quadraticBezierTo(
        base.dx + 8,
        (base.dy + tip.dy) / 2,
        base.dx,
        base.dy,
      );
    canvas.drawPath(path, paint);
    canvas.drawLine(base, tip, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CloseHoverButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CloseHoverButton({required this.onTap});

  @override
  State<_CloseHoverButton> createState() => _CloseHoverButtonState();
}

class _CloseHoverButtonState extends State<_CloseHoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.offerRed : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Icon(
              Icons.close,
              size: 16,
              color: _isHovered ? Colors.white : const Color(0xFF8B949E),
            ),
          ),
        ),
      ),
    );
  }
}
