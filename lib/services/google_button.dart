import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'google_drive_service.dart';

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const GoogleSignInButton({super.key, this.onPressed});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    if (!context.mounted) {
      return;
    }
    await context.read<GoogleDriveService>().signIn(() {});
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        disabledBackgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFFDADADA)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(240, 48),
      ),
      child: _isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4285F4)))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Google "G" logo SVG rendered as a custom painter
                const _GoogleLogo(size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Sign in with Google',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Roboto', color: Color(0xFF3C4043), letterSpacing: 0.25),
                ),
              ],
            ),
    );
  }
}

// Google "G" Logo using CustomPainter
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Draw each colored arc segment
    final segments = [
      // [startAngle (deg), sweepAngle (deg), color]
      [330.0, 90.0, 0xFF4285F4], // Blue (top-right)
      [60.0, 90.0, 0xFF34A853], // Green (bottom-right)
      [150.0, 90.0, 0xFFFBBC05], // Yellow (bottom-left)
      [240.0, 90.0, 0xFFEA4335], // Red (top-left)
    ];

    const double degToRad = 3.14159265 / 180.0;

    for (final seg in segments) {
      final paint = Paint()
        ..color = Color(seg[2].toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72), seg[0] * degToRad, seg[1] * degToRad, false, paint);
    }

    // White cutout for the "G" bar — horizontal white line into center
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18;

    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.72, cy), whitePaint);

    // Blue fill for the right half (for the "G" crossbar area)
    final blueFill = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18;

    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.72, cy), blueFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
