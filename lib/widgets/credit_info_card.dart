import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/user_model.dart';
import '../utils/theme.dart';

class CreditInfoCard extends StatefulWidget {
  final UserProfile userProfile;

  const CreditInfoCard({super.key, required this.userProfile});

  @override
  State<CreditInfoCard> createState() => _CreditInfoCardState();
}

class _CreditInfoCardState extends State<CreditInfoCard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _chartController;
  late Animation<double> _progressAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation =
        Tween<double>(
          begin: 0.0,
          end: widget.userProfile.creditUsagePercentage / 100,
        ).animate(
          CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
        );

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _progressController.forward();
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Credit Information',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Credit Usage Chart
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: AnimatedBuilder(
                  animation: _chartAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CreditChartPainter(
                        progress:
                            _progressAnimation.value * _chartAnimation.value,
                        colors: colors,
                        userProfile: widget.userProfile,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(widget.userProfile.creditUsagePercentage * _chartAnimation.value).toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                            ),
                            Text(
                              'Credit Used',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Credit Details
            _buildCreditDetailRow(
              'Credit Limit',
              '${widget.userProfile.creditLimit.toStringAsFixed(0)} JOD',
              Icons.credit_card,
              colors.primary,
            ),
            const SizedBox(height: 16),
            _buildCreditDetailRow(
              'Available Credit',
              '${widget.userProfile.availableCredit.toStringAsFixed(0)} JOD',
              Icons.check_circle,
              colors.statusSuccess,
            ),
            const SizedBox(height: 16),
            _buildCreditDetailRow(
              'Used Credit',
              '${widget.userProfile.usedCredit.toStringAsFixed(0)} JOD',
              Icons.shopping_cart,
              colors.statusWarning,
            ),
            const SizedBox(height: 16),
            _buildCreditDetailRow(
              'Total Debt',
              '${widget.userProfile.totalDebt.toStringAsFixed(0)} JOD',
              Icons.warning,
              colors.statusError,
            ),
            const SizedBox(height: 24),

            // Credit History Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCreditHistory(context),
                icon: const Icon(Icons.history),
                label: const Text('View Credit History'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showCreditHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CreditHistoryModal(userProfile: widget.userProfile),
    );
  }
}

class CreditChartPainter extends CustomPainter {
  final double progress;
  final AppColors colors;
  final UserProfile userProfile;

  CreditChartPainter({
    required this.progress,
    required this.colors,
    required this.userProfile,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Background circle
    final backgroundPaint = Paint()
      ..color = colors.backgroundTertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [colors.primary, colors.primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = colors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CreditHistoryModal extends StatelessWidget {
  final UserProfile userProfile;

  const CreditHistoryModal({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.history, color: colors.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Credit History',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart placeholder
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: colors.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'Credit History Chart',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Implementation coming soon...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
