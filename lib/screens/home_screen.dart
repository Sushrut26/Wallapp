import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'todo_list_screen.dart';
import 'meal_planner_screen.dart';
import 'calendar_screen.dart';
import '../utils/app_animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateWithAnimation(Widget screen) {
    // Haptic feedback for better tablet experience
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      AppAnimations.createRoute(page: screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32.0), // Larger padding for tablets
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAnimations.slideInFromBottom(
                    offset: 30,
                    child: Text(
                      'Wallapp',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 56, // Larger for tablets
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppAnimations.slideInFromBottom(
                    duration: const Duration(milliseconds: 400),
                    offset: 30,
                    child: Text(
                      'Your Family Assistant',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 24,
                          ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive grid for different tablet sizes
                        final crossAxisCount = constraints.maxWidth > 800 ? 3 : 2;
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          children: [
                            _buildAnimatedFeatureCard(
                              context,
                              index: 0,
                              title: 'To-Do List',
                              icon: Icons.checklist_rounded,
                              color: Colors.blue,
                              onTap: () => _navigateWithAnimation(const TodoListScreen()),
                            ),
                            _buildAnimatedFeatureCard(
                              context,
                              index: 1,
                              title: 'Meal Planner',
                              icon: Icons.restaurant_menu_rounded,
                              color: Colors.orange,
                              onTap: () => _navigateWithAnimation(const MealPlannerScreen()),
                            ),
                            _buildAnimatedFeatureCard(
                              context,
                              index: 2,
                              title: 'Calendar',
                              icon: Icons.calendar_month_rounded,
                              color: Colors.green,
                              onTap: () => _navigateWithAnimation(const CalendarScreen()),
                            ),
                            if (crossAxisCount == 2)
                              _buildAnimatedFeatureCard(
                                context,
                                index: 3,
                                title: 'Settings',
                                icon: Icons.settings_rounded,
                                color: Colors.purple,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Settings coming soon!'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      action: SnackBarAction(
                                        label: 'OK',
                                        onPressed: () {},
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFeatureCard(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: _buildFeatureCard(
        context,
        title: title,
        icon: icon,
        color: color,
        onTap: onTap,
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shadowColor: color.withOpacity(0.3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withOpacity(0.3),
          highlightColor: color.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(32), // Larger padding for tablet
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'icon_$title',
                  child: Container(
                    padding: const EdgeInsets.all(24), // Larger touch target
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 72, // Larger icon for tablets
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24, // Larger text for tablets
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
