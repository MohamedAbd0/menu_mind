import 'package:flutter/material.dart';
import '../../core/di/injection.dart';
import '../../domain/services/model_loader_service.dart';
import 'home_screen.dart';

class ModelInitializationScreen extends StatefulWidget {
  const ModelInitializationScreen({super.key});

  @override
  State<ModelInitializationScreen> createState() =>
      _ModelInitializationScreenState();
}

class _ModelInitializationScreenState extends State<ModelInitializationScreen>
    with TickerProviderStateMixin {
  bool _isInitializing = true;
  String _statusMessage = 'Initializing AI Engine...';
  double? _progress;
  String? _errorMessage;

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Start animations
    _pulseController.repeat(reverse: true);
    _fadeController.forward();

    _initializeModel();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializeModel() async {
    try {
      final modelLoader = getIt<ModelLoaderService>();

      if (modelLoader.isModelInitialized) {
        /// delay for better UX
        Future.delayed(const Duration(seconds: 2), () {
          _navigateToHome();
        });
        return;
      }

      await modelLoader.initializeModel(
        onStatusUpdate: (status) {
          if (mounted) {
            setState(() {
              _statusMessage = status;
              _errorMessage = null;
              _isInitializing = true;
            });
          }
        },
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _errorMessage = null;
              _isInitializing = true;
            });
          }
        },
      );

      if (mounted) {
        /// delay for better UX
        Future.delayed(const Duration(seconds: 2), () {
          _navigateToHome();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Failed to initialize AI model: $e';
        });
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _retryInitialization() {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
      _statusMessage = 'Initializing...';
      _progress = null;
    });
    _initializeModel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.05),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                      theme.colorScheme.tertiary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(35),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.psychology_rounded,
                                  size: 70,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // App Title with better typography
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'MenuMind',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'AI-Powered Menu Translation',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Instant • Accurate • Cultural',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isInitializing) ...[
                        _buildLoadingSection(theme, size),
                      ] else if (_errorMessage != null) ...[
                        _buildErrorSection(theme),
                      ],
                    ],
                  ),

                  SizedBox(height: 16),
                  // Footer
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFooter(theme),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSection(ThemeData theme, Size size) {
    return Column(
      children: [
        // Enhanced loading animation with multiple circles
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            // Inner spinner
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Status Message with better styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            _statusMessage,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // Enhanced Progress Bar
        if (_progress != null) ...[
          Container(
            width: size.width * 0.7,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Downloading AI Model',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                  minHeight: 6,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_progress! * 100).toInt()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Feature highlights while loading
        _buildFeatureHighlights(theme),
      ],
    );
  }

  Widget _buildErrorSection(ThemeData theme) {
    return Column(
      children: [
        // Error Icon with animation
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            size: 40,
            color: theme.colorScheme.error,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Initialization Failed',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _errorMessage!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 32),

        ElevatedButton.icon(
          onPressed: _retryInitialization,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry Setup'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureHighlights(ThemeData theme) {
    final features = [
      {
        'icon': Icons.translate,
        'title': 'Instant Translation',
        'desc': 'Real-time menu translation in 15+ languages',
      },
      {
        'icon': Icons.health_and_safety,
        'title': 'Allergy Detection',
        'desc': 'Smart allergen identification and warnings',
      },
      {
        'icon': Icons.public,
        'title': 'Cultural Insights',
        'desc': 'Learn about local dishes and traditions',
      },
    ];

    return Column(
      children: [
        Text(
          'What you\'ll get:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        for (final feature in features)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        feature['desc'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'First launch may take 2-3 minutes',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'AI model will be cached for faster future launches',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
