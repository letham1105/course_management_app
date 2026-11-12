
import 'package:flutter/material.dart';

import '../models/giang_vien_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'add_giang_vien_screen.dart';
import 'login_screen.dart';
import 'edit_giang_vien_screen.dart';

class GiangVienListScreen extends StatefulWidget {
  const GiangVienListScreen({super.key});

  @override
  State<GiangVienListScreen> createState() => _GiangVienListScreenState();
}

class _GiangVienListScreenState extends State<GiangVienListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedId = 'All';

  static const Color primaryColor = Color(0xFF5146E5);
  static const String defaultAssetImagePath =
      'assets/default_product.png';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GiangVien> _filterGiangViens(List<GiangVien> giangViens) {
    return giangViens.where((giangVien) {
      final query = _searchQuery.toLowerCase();

      final matchesSearch =
          giangVien.fullname.toLowerCase().contains(query) ||
          giangVien.idgv.toLowerCase().contains(query);

      final matchesId =
          _selectedId == 'All' || giangVien.idgv == _selectedId;

      return matchesSearch && matchesId;
    }).toList();
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true) return;

    try {
      await AuthService().signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  Future<void> _confirmDelete(GiangVien giangVien) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Delete Lecturer'),
        content: Text(
          'Are you sure you want to delete "${giangVien.fullname}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await _firestoreService.deleteGiangVien(giangVien);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lecturer deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting lecturer: $e')),
      );
    }
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Image.asset(
        defaultAssetImagePath,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        defaultAssetImagePath,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildGiangVienCard(GiangVien giangVien) {
    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFEEEEF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(giangVien.image),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                    color: Colors.white,
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditGiangVienScreen(
                              giangVien: giangVien,
                            ),
                          ),
                        );
                      } else if (value == 'delete') {
                        _confirmDelete(giangVien);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    icon: const CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  giangVien.fullname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF20243A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'ID: ${giangVien.idgv}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  '${giangVien.sumClass} classes',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiangVienListTile(GiangVien giangVien) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEF3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 65,
            height: 65,
            child: _buildImage(giangVien.image),
          ),
        ),
        title: Text(
          giangVien.fullname,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${giangVien.idgv}  •  ${giangVien.sumClass} classes',
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditGiangVienScreen(
                    giangVien: giangVien,
                  ),
                ),
              );
            } else if (value == 'delete') {
              _confirmDelete(giangVien);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditGiangVienScreen(
                giangVien: giangVien,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.school_rounded, color: primaryColor),
            SizedBox(width: 10),
            Text(
              'Lecturer Manager',
              style: TextStyle(
                color: Color(0xFF20243A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout, color: Colors.black87),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddGiangVienScreen(),
            ),
          );
        },
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Lecturer'),
      ),
      body: StreamBuilder<List<GiangVien>>(
        stream: _firestoreService.getGiangViensStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading lecturers: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          final allGiangViens = snapshot.data ?? [];

          final lecturerIds = allGiangViens
              .map((giangVien) => giangVien.idgv)
              .where((id) => id.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          final filteredGiangViens = _filterGiangViens(allGiangViens);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lecturers',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF20243A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${allGiangViens.length} lecturers in your collection',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by lecturer name or ID...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                icon: const Icon(Icons.close),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'All',
                          ...lecturerIds,
                        ].map((id) {
                          final selected = _selectedId == id;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(id),
                              selected: selected,
                              onSelected: (_) {
                                setState(() => _selectedId = id);
                              },
                              selectedColor: primaryColor,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide.none,
                              showCheckmark: false,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredGiangViens.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              allGiangViens.isEmpty
                                  ? 'No lecturers yet'
                                  : 'No matching lecturers found',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 650;

                          if (!isWide) {
                            return ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                16, 4, 16, 90,
                              ),
                              itemCount: filteredGiangViens.length,
                              itemBuilder: (context, index) {
                                return _buildGiangVienListTile(
                                  filteredGiangViens[index],
                                );
                              },
                            );
                          }

                          final crossAxisCount =
                              constraints.maxWidth >= 1000 ? 4 : 3;

                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              20, 4, 20, 90,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: filteredGiangViens.length,
                            itemBuilder: (context, index) {
                              return _buildGiangVienCard(
                                filteredGiangViens[index],
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
