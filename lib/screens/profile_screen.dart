// lib/screens/profile_screen.dart
// User's own profile page with editable fields, liked profiles, and settings.

import 'package:flutter/material.dart';
import '../models/app_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _state = AppState.instance;
  bool _editMode = false;

  // Editable fields (would persist to backend in production)
  late String _name;
  late String _bio;
  late String _location;
  late List<String> _interests;

  final _bioController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetFields();
  }

  void _resetFields() {
    final me = _state.myProfile;
    _name = me.name;
    _bio = me.bio;
    _location = me.location;
    _interests = List.from(me.interests);
    _bioController.text = _bio;
    _locationController.text = _location;
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = _state.myProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F5),
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xFFE91E8C),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE91E8C), Color(0xFF7B2FF7)],
                      ),
                    ),
                  ),
                  // Avatar
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundImage: NetworkImage(me.imageUrl),
                            onBackgroundImageError: (_, __) {},
                            backgroundColor: Colors.white24,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Photo upload coming soon!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFFE91E8C)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _location,
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => setState(() => _editMode = !_editMode),
                icon: Icon(_editMode ? Icons.close : Icons.edit_rounded,
                    color: Colors.white, size: 18),
                label: Text(
                  _editMode ? 'Cancel' : 'Edit',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Completion banner
                  _CompletionBanner(),

                  const SizedBox(height: 16),

                  // About section
                  _SectionCard(
                    title: 'About Me',
                    child: _editMode
                        ? TextField(
                            controller: _bioController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Tell people about yourself…',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          )
                        : Text(
                            _bio,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                          ),
                  ),

                  const SizedBox(height: 12),

                  // Location
                  _SectionCard(
                    title: 'Location',
                    child: _editMode
                        ? TextField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              hintText: 'Your city',
                              border: OutlineInputBorder(),
                              isDense: true,
                              prefixIcon: Icon(Icons.location_on, color: Color(0xFF9B59B6)),
                            ),
                          )
                        : Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFF9B59B6), size: 18),
                              const SizedBox(width: 6),
                              Text(_location, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                  ),

                  const SizedBox(height: 12),

                  // Interests
                  _SectionCard(
                    title: 'Interests',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _interests
                          .map((tag) => _InterestChip(
                                label: tag,
                                editable: _editMode,
                                onRemove: () => setState(() => _interests.remove(tag)),
                              ))
                          .toList()
                        ..addAll(_editMode
                            ? [
                                GestureDetector(
                                  onTap: _showAddInterestDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFF7B2FF7)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add, size: 14, color: Color(0xFF7B2FF7)),
                                        SizedBox(width: 4),
                                        Text('Add', style: TextStyle(fontSize: 12, color: Color(0xFF7B2FF7))),
                                      ],
                                    ),
                                  ),
                                )
                              ]
                            : []),
                    ),
                  ),

                  // Save button in edit mode
                  if (_editMode) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          backgroundColor: const Color(0xFFE91E8C),
                        ),
                        child: const Text('Save Changes',
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Stats ─────────────────────────────────────────────
                  _StatsRow(likedCount: _state.likedProfiles.length),

                  const SizedBox(height: 20),

                  // ── Settings list ─────────────────────────────────────
                  _SettingsSection(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddInterestDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Interest'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Cooking'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => _interests.add(controller.text.trim()));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    setState(() {
      _bio = _bioController.text.trim().isEmpty ? _bio : _bioController.text.trim();
      _location = _locationController.text.trim().isEmpty ? _location : _locationController.text.trim();
      _editMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated! ✨'),
        backgroundColor: const Color(0xFF7B2FF7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Profile completion banner ─────────────────────────────────────────────────
class _CompletionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE4F3), Color(0xFFEEE0FF)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFE91E8C), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Complete your profile',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFE91E8C)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 3),
                const Text('65% complete', style: TextStyle(fontSize: 11, color: Color(0xFF9B59B6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int likedCount;
  const _StatsRow({required this.likedCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(value: '$likedCount', label: 'Likes'),
        const SizedBox(width: 12),
        _StatBox(value: '2', label: 'Matches'),
        const SizedBox(width: 12),
        _StatBox(value: '5', label: 'Messages'),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE91E8C))),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// ── Settings section ──────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final List<_SettingItem> items = const [
    _SettingItem(icon: Icons.notifications_rounded, label: 'Notifications', color: Color(0xFF7B2FF7)),
    _SettingItem(icon: Icons.privacy_tip_rounded, label: 'Privacy', color: Color(0xFFE91E8C)),
    _SettingItem(icon: Icons.shield_rounded, label: 'Safety', color: Color(0xFF27AE60)),
    _SettingItem(icon: Icons.help_outline_rounded, label: 'Help & Support', color: Color(0xFFF39C12)),
    _SettingItem(icon: Icons.logout_rounded, label: 'Log Out', color: Color(0xFFE74C3C)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: e.value.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(e.value.icon, color: e.value.color, size: 20),
                      ),
                      title: Text(e.value.label,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: () {},
                    ),
                    if (e.key < items.length - 1)
                      const Divider(height: 1, indent: 56, endIndent: 16),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final Color color;
  const _SettingItem({required this.icon, required this.label, required this.color});
}

// ── Reusable section card ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF9B59B6))),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ── Interest chip ─────────────────────────────────────────────────────────────
class _InterestChip extends StatelessWidget {
  final String label;
  final bool editable;
  final VoidCallback? onRemove;
  const _InterestChip({required this.label, this.editable = false, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFE4F3), Color(0xFFEEE0FF)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF7B2FF7), fontWeight: FontWeight.w500)),
          if (editable) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 14, color: Color(0xFFE91E8C)),
            ),
          ],
        ],
      ),
    );
  }
}
