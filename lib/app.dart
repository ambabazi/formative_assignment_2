import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/alu_theme.dart';
import 'providers/auth_providers.dart';
import 'features/authscreens/signin.dart';
import 'features/authscreens/student_onboarding.dart';
import 'features/authscreens/admin_verify.dart';
import 'features/opportunitiesscreens/discovery.dart';
import 'features/opportunitiesscreens/startup_dashboard.dart';
import 'features/applicationsscreens/myapplication.dart';
import 'features/applicationsscreens/startup_applications.dart';
import 'features/applicationsscreens/edit_skills.dart';
import 'models/user_model.dart';

class AluConnectApp extends ConsumerWidget {
  const AluConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ALU Connect',
      debugShowCheckedModeBanner: false,
      theme: buildAluTheme(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loggedInUserProvider);

    if (user == null) {
      return const SignInScreen();
    }

    if (user.role == UserRole.admin) {
      return const AdminVerifyScreen();
    }

    if (!user.onboardingComplete && user.role == UserRole.student) {
      return const StudentOnboardingScreen();
    }

    if (user.role == UserRole.startupAdmin) {
      return const StartupMainShell();
    }

    return const StudentMainShell();
  }
}

class StudentMainShell extends StatefulWidget {
  const StudentMainShell({super.key});

  @override
  State<StudentMainShell> createState() => _StudentMainShellState();
}

class _StudentMainShellState extends State<StudentMainShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DiscoveryScreen(),
      const MyApplicationScreen(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        backgroundColor: AluColors.white,
        indicatorColor: AluColors.red.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AluColors.red),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: AluColors.red),
            label: 'Applications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AluColors.red),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class StartupMainShell extends StatefulWidget {
  const StartupMainShell({super.key});

  @override
  State<StartupMainShell> createState() => _StartupMainShellState();
}

class _StartupMainShellState extends State<StartupMainShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const StartupDashboardScreen(),
      const StartupApplicationsScreen(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        backgroundColor: AluColors.white,
        indicatorColor: AluColors.red.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AluColors.red),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AluColors.red),
            label: 'Applicants',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AluColors.red),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loggedInUserProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    return Scaffold(
      backgroundColor: AluColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 48,
                backgroundColor: AluColors.navy,
                child: Text(
                  user.names.isNotEmpty ? user.names[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    color: AluColors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.names,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AluColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.location.isNotEmpty ? user.location : 'ALU Campus',
                style: const TextStyle(color: AluColors.lightGrey),
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                style: const TextStyle(color: AluColors.lightGrey, fontSize: 13),
              ),
              const SizedBox(height: 32),
              _ProfileTile(
                icon: Icons.badge_outlined,
                label: 'Role',
                value: _roleLabel(user.role),
              ),
              if (user.role == UserRole.student) ...[
                const SizedBox(height: 12),
                _ProfileTile(
                  icon: Icons.psychology_outlined,
                  label: 'Skills',
                  value: user.skills.isEmpty ? 'None added yet' : user.skills.join(', '),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditSkillsScreen()),
                    );
                  },
                  actionLabel: 'Edit',
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authRepoProvider).signOut();
                    ref.read(loggedInUserProvider.notifier).state = null;
                  },
                  icon: const Icon(Icons.logout, color: AluColors.red),
                  label: const Text('Logout', style: TextStyle(color: AluColors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AluColors.red),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.startupAdmin:
        return 'Startup Admin';
      case UserRole.admin:
        return 'ALU Admin';
    }
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final String? actionLabel;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AluColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AluColors.navy),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AluColors.lightGrey, fontSize: 12)),
                  Text(value, style: const TextStyle(color: AluColors.navy, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (actionLabel != null)
              Text(
                actionLabel!,
                style: const TextStyle(color: AluColors.red, fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }
}
