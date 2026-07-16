import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/startup_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/opportunity_provider.dart';
import '../../utils/alu_theme.dart';

class AdminStartupDetailScreen extends ConsumerStatefulWidget {
  final StartupModel startup;

  const AdminStartupDetailScreen({super.key, required this.startup});

  @override
  ConsumerState<AdminStartupDetailScreen> createState() =>
      _AdminStartupDetailScreenState();
}

class _AdminStartupDetailScreenState extends ConsumerState<AdminStartupDetailScreen> {
  UserModel? founder;
  bool isLoading = true;
  bool isVerifying = false;
  bool isRejecting = false;

  @override
  void initState() {
    super.initState();
    _loadFounder();
  }

  Future<void> _loadFounder() async {
    final user = await ref.read(authRepoProvider).getUserById(widget.startup.adminId);
    if (mounted) {
      setState(() {
        founder = user;
        isLoading = false;
      });
    }
  }

  Future<void> verifyStartup() async {
    setState(() => isVerifying = true);
    try {
      await ref.read(startupRepoProvider).setVerified(widget.startup.id, true);
      ref.invalidate(unverifiedStartupsProvider);
      ref.invalidate(opportunitiesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.startup.companyName} verified')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not verify: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isVerifying = false);
    }
  }

  Future<void> rejectStartup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject startup?'),
        content: Text(
          'Reject ${widget.startup.companyName}? It will be removed from the verification queue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AluColors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isRejecting = true);
    try {
      await ref.read(startupRepoProvider).rejectStartup(widget.startup.id);
      ref.invalidate(unverifiedStartupsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.startup.companyName} rejected')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not reject: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isRejecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startup = widget.startup;

    return Scaffold(
      backgroundColor: AluColors.surface,
      appBar: AppBar(title: Text(startup.companyName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.hourglass_top, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Awaiting ALU verification',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Registered by',
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: CircularProgressIndicator(),
                  )
                : founder == null
                    ? const Text('Founder profile not found')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AluColors.navy,
                                child: Text(
                                  founder!.names.isNotEmpty
                                      ? founder!.names[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(color: AluColors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      founder!.names,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AluColors.navy,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      founder!.email,
                                      style: const TextStyle(
                                        color: AluColors.lightGrey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (founder!.location.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.location_on_outlined,
                              label: 'Location',
                              value: founder!.location,
                            ),
                          ],
                        ],
                      ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'About the business',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.business_outlined,
                  label: 'Company',
                  value: startup.companyName,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.description_outlined,
                  label: 'Description',
                  value: startup.description,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.category_outlined,
                  label: 'Industry',
                  value: startup.industry.isNotEmpty ? startup.industry : 'Not specified',
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.location_city_outlined,
                  label: 'Business location',
                  value: startup.location.isNotEmpty ? startup.location : 'Not specified',
                ),
                if (startup.website.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.link,
                    label: 'Website',
                    value: startup.website,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: isVerifying ? null : verifyStartup,
            child: isVerifying
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AluColors.white,
                    ),
                  )
                : const Text('Verify startup'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: isRejecting ? null : rejectStartup,
            style: OutlinedButton.styleFrom(
              foregroundColor: AluColors.red,
              side: const BorderSide(color: AluColors.red),
            ),
            child: isRejecting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Reject startup'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AluColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AluColors.navy,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AluColors.lightGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AluColors.lightGrey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(color: AluColors.navy, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
