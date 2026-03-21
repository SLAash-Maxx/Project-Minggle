import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'get_started_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _whatsappStatuses = const [
    "Available",
    "Busy",
    "At school",
    "At the movies",
    "At work",
    "Battery about to die",
    "Can't talk, Minggle only",
  ];

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Logout", style: TextStyle(color: Color(0xFFFF4D6D))),
        content: const Text("Are you sure you want to logout?",
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const GetStartedScreen()),
                  (route) => false,
                );
              }
            },
            child:
                const Text("Yes", style: TextStyle(color: Color(0xFFFF4D6D))),
          ),
        ],
      ),
    );
  }

  void _showEditBioDialog(
      BuildContext context, String currentBio, String userId) {
    TextEditingController bioController =
        TextEditingController(text: currentBio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit About",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Select Default",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const Divider(color: Colors.white10),
            SizedBox(
              height: 180,
              child: ListView.builder(
                itemCount: _whatsappStatuses.length,
                itemBuilder: (context, index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_whatsappStatuses[index],
                      style: const TextStyle(color: Colors.white70)),
                  onTap: () => bioController.text = _whatsappStatuses[index],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D6D),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({'bio': bioController.text});
                if (context.mounted) {
                  Navigator.pop(context); // Close the sheet after saving
                }
              },
              child: const Text("Save",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getGeoZones(dynamic map) {
    if (map is List) {
      return map
          .whereType<Map>()
          .map((raw) => raw.map<String, dynamic>(
              (key, value) => MapEntry(key.toString(), value)))
          .map((zone) => {
                'name': zone['name'] ?? 'Unnamed',
                'radius': zone['radius'] ?? 1.0,
                'hidden': zone['hidden'] ?? true,
                'latitude': zone['latitude'] ?? 0.0,
                'longitude': zone['longitude'] ?? 0.0,
              })
          .toList();
    }
    return [
      {
        'name': 'Home',
        'radius': 1.0,
        'hidden': true,
        'latitude': 0.0,
        'longitude': 0.0,
      },
      {
        'name': 'Work',
        'radius': 1.0,
        'hidden': true,
        'latitude': 0.0,
        'longitude': 0.0,
      },
    ];
  }

  Future<LatLng?> _pickGeoZoneLocation(
      BuildContext context, LatLng initial) async {
    LatLng selected = initial;
    final result = await showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (sheetContext) {
        return StatefulBuilder(builder: (mapContext, setState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition:
                        CameraPosition(target: selected, zoom: 14.0),
                    onTap: (latLng) {
                      selected = latLng;
                      setState(() {});
                    },
                    markers: {
                      Marker(
                          markerId: const MarkerId('zone-target'),
                          position: selected),
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Lat: ${selected.latitude.toStringAsFixed(6)}, Lng: ${selected.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4D6D)),
                        onPressed: () {
                          Navigator.pop(sheetContext, selected);
                        },
                        child: const Text('Use this location'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF373737)),
                        onPressed: () {
                          Navigator.pop(sheetContext, null);
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
    return result;
  }

  Future<void> _saveGeoZones(
      String userId, List<Map<String, dynamic>> zones) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'geoBlockingZones': zones});
  }

  void _showAddGeoZoneDialog(
      BuildContext context,
      String userId,
      List<Map<String, dynamic>> zones,
      void Function(List<Map<String, dynamic>>) onUpdate) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController radiusController = TextEditingController();
    LatLng selectedLocation = const LatLng(0.0, 0.0);
    bool hidden = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add Geo Blocking Zone",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Zone Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: radiusController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Radius (km)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Lat: ${selectedLocation.latitude.toStringAsFixed(6)}\nLng: ${selectedLocation.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF373737),
                    ),
                    onPressed: () async {
                      final LatLng? loc =
                          await _pickGeoZoneLocation(context, selectedLocation);
                      if (loc != null) {
                        setState(() {
                          selectedLocation = loc;
                        });
                      }
                    },
                    child: const Text('Add location',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hidden in this zone',
                      style: TextStyle(color: Colors.white70)),
                  Switch(
                    value: hidden,
                    onChanged: (value) => setState(() => hidden = value),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D6D),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final String name = nameController.text.trim();
                  final double radius =
                      double.tryParse(radiusController.text) ?? 1.0;
                  if (name.isEmpty) return;

                  final newZones = List<Map<String, dynamic>>.from(zones);
                  newZones.add({
                    'name': name,
                    'radius': radius,
                    'hidden': hidden,
                    'latitude': selectedLocation.latitude,
                    'longitude': selectedLocation.longitude,
                  });
                  await _saveGeoZones(userId, newZones);
                  onUpdate(newZones);

                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save Zone',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditGeoZoneDialog(
      BuildContext context,
      String userId,
      int index,
      List<Map<String, dynamic>> zones,
      void Function(List<Map<String, dynamic>>) onUpdate) {
    final Map<String, dynamic> zone = zones[index];
    final TextEditingController nameController =
        TextEditingController(text: zone['name']?.toString() ?? '');
    final TextEditingController radiusController =
        TextEditingController(text: (zone['radius']?.toString() ?? '1.0'));
    LatLng selectedLocation = LatLng(
      (zone['latitude'] as num?)?.toDouble() ?? 0.0,
      (zone['longitude'] as num?)?.toDouble() ?? 0.0,
    );
    bool hidden = zone['hidden'] is bool ? zone['hidden'] : true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Edit Geo Blocking Zone",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Zone Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: radiusController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Radius (km)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Lat: ${selectedLocation.latitude.toStringAsFixed(6)}\nLng: ${selectedLocation.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF373737),
                    ),
                    onPressed: () async {
                      final LatLng? loc =
                          await _pickGeoZoneLocation(context, selectedLocation);
                      if (loc != null) {
                        setState(() {
                          selectedLocation = loc;
                        });
                      }
                    },
                    child: const Text('Edit location',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hidden in this zone',
                      style: TextStyle(color: Colors.white70)),
                  Switch(
                    value: hidden,
                    activeThumbColor: const Color(0xFFFF4D6D),
                    onChanged: (value) => setState(() => hidden = value),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D6D),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final String name = nameController.text.trim();
                  final double radius =
                      double.tryParse(radiusController.text) ?? 1.0;
                  if (name.isEmpty) return;

                  final updatedZones = List<Map<String, dynamic>>.from(zones);
                  updatedZones[index] = {
                    'name': name,
                    'radius': radius,
                    'hidden': hidden,
                    'latitude': selectedLocation.latitude,
                    'longitude': selectedLocation.longitude,
                  };
                  await _saveGeoZones(userId, updatedZones);
                  onUpdate(updatedZones);

                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save Zone',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeoBlockingSection(
      BuildContext context,
      String userId,
      List<Map<String, dynamic>> geoZones,
      void Function(List<Map<String, dynamic>>) onUpdate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text("Geo Blocking",
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ),
        const SizedBox(height: 10),
        if (geoZones.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No geo-blocking zones yet. Add one to hide your location in selected areas.',
              style: TextStyle(color: Colors.white70),
            ),
          )
        else
          Column(
            children: geoZones.map((zone) {
              String zoneName = zone['name']?.toString() ?? 'Unnamed Zone';
              double radius = (zone['radius'] is num)
                  ? (zone['radius'] as num).toDouble()
                  : 1.0;
              bool isHidden = zone['hidden'] is bool ? zone['hidden'] : true;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  title: Text(zoneName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Radius: ${radius.toStringAsFixed(1)} km',
                          style: const TextStyle(color: Colors.white70)),
                      Text(
                          'Lat: ${((zone['latitude'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(5)}, Lng: ${((zone['longitude'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(5)}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        activeThumbColor: const Color(0xFFFF4D6D),
                        value: isHidden,
                        onChanged: (newValue) async {
                          final updatedZones = geoZones.map((z) {
                            if ((z['name'] ?? '') == zoneName) {
                              return {
                                'name': zoneName,
                                'radius': radius,
                                'hidden': newValue
                              };
                            }
                            return z;
                          }).toList();
                          await _saveGeoZones(userId, updatedZones);
                          onUpdate(updatedZones);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () => _showEditGeoZoneDialog(context, userId,
                            geoZones.indexOf(zone), geoZones, onUpdate),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF1A1A1A),
                                  title: const Text('Delete zone',
                                      style: TextStyle(color: Colors.white)),
                                  content: const Text(
                                      'Are you sure you want to delete this geo-blocking zone? You can add it again later.',
                                      style: TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete',
                                            style: TextStyle(
                                                color: Colors.redAccent))),
                                  ],
                                ),
                              ) ??
                              false;
                          if (!confirmed) return;

                          final updatedZones =
                              List<Map<String, dynamic>>.from(geoZones);
                          updatedZones.removeAt(geoZones.indexOf(zone));
                          await _saveGeoZones(userId, updatedZones);
                          onUpdate(updatedZones);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showAddGeoZoneDialog(context, userId, geoZones, onUpdate),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: Color(0xFFFF4D6D))),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add new zone',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    _showAddGeoZoneDialog(context, userId, geoZones, onUpdate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF373737),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Manage all zones',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF4D6D)));
          }

          var userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};

          // These fetch from what user entered in Sign Up / Profile
          String name = userData['name'] ?? "User";
          String pic =
              userData['profilePic'] ?? "https://via.placeholder.com/150";
          String bio = userData['bio'] ?? "Available";
          String location = userData['location'] ?? "Sri Lanka";

          // Fetch hobbies from Firestore (Ensure they are saved as a List)
          dynamic hobbiesData = userData['hobbies'];
          List<dynamic> hobbies = (hobbiesData is List)
              ? hobbiesData
              : ['Music', 'Travel', 'Coding'];

          // Geo blocking zones from Firestore
          List<Map<String, dynamic>> geoZones =
              _getGeoZones(userData['geoBlockingZones']);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              colors: [Color(0xFFFF4D6D), Colors.orangeAccent]),
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey[900],
                          backgroundImage: NetworkImage(pic),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () =>
                              _showEditBioDialog(context, bio, currentUserId),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                color: Color(0xFFFF4D6D),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  location,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => _showEditBioDialog(context, bio, currentUserId),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("About Me",
                                style: TextStyle(
                                    color: Color(0xFFFF4D6D),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            Icon(Icons.edit, color: Colors.white24, size: 16),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(bio,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Hobbies",
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children: hobbies
                        .map((h) => Chip(
                              backgroundColor:
                                  const Color(0xFFFF4D6D).withOpacity(0.15),
                              label: Text(h.toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 25),
                _buildGeoBlockingSection(context, currentUserId, geoZones,
                    (updatedZones) {
                  setState(() {});
                }),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showLogoutDialog(context), // Confirmation dialog
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Logout",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
