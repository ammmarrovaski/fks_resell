import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_model.dart';
import '../../../features/shop/presentation/seller_profile_screen.dart';

class _Colors {
  static const Color bordo = Color(0xFF722F37);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color divider = Color(0xFF2E2E2E);
}

class UsersSearchScreen extends StatefulWidget {
  const UsersSearchScreen({Key? key}) : super(key: key);

  @override
  State<UsersSearchScreen> createState() => _UsersSearchScreenState();
}

class _UsersSearchScreenState extends State<UsersSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  List<UserModel> _results = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final q = query.trim().toLowerCase();
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('ime')
          .get();

      final results = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) {
            final punoIme = user.punoIme.toLowerCase();
            final email = user.email.toLowerCase();
            return punoIme.contains(q) || email.contains(q);
          })
          .toList();

      if (mounted) setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Colors.background,
      appBar: AppBar(
        backgroundColor: _Colors.background,
        foregroundColor: _Colors.textPrimary,
        elevation: 0,
        title: const Text(
          'Pretraga korisnika',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _Colors.cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: _Colors.inputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _Colors.bordo.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: _Colors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Pretraži po imenu ili emailu...',
                  hintStyle: const TextStyle(color: _Colors.textMuted, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: _Colors.bordo, size: 22),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: _Colors.textMuted, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                              _results = [];
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (value) {
                  setState(() => _query = value);
                  _search(value);
                },
              ),
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _Colors.bordo))
                : _query.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _Colors.cardBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.people_outline_rounded,
                                  size: 40, color: _Colors.textMuted),
                            ),
                            const SizedBox(height: 16),
                            const Text('Pretražite korisnike',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: _Colors.textSecondary)),
                            const SizedBox(height: 6),
                            const Text('Unesite ime ili email adresu',
                                style: TextStyle(
                                    fontSize: 13, color: _Colors.textMuted)),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_search_rounded,
                                    size: 56, color: _Colors.textMuted),
                                const SizedBox(height: 16),
                                const Text('Nema rezultata',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: _Colors.textSecondary)),
                                const SizedBox(height: 6),
                                Text('Nema korisnika za "$_query"',
                                    style: const TextStyle(
                                        fontSize: 13, color: _Colors.textMuted)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _results.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _UserCard(user: _results[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SellerProfileScreen(
            userId: user.uid,
            sellerName: user.punoIme.isNotEmpty ? user.punoIme : 'Korisnik',
            sellerEmail: user.email,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _Colors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _Colors.textMuted.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF722F37).withOpacity(0.15),
                border: Border.all(
                    color: const Color(0xFF722F37).withOpacity(0.3)),
                image: user.profilnaSlika != null
                    ? DecorationImage(
                        image: NetworkImage(user.profilnaSlika!),
                        fit: BoxFit.cover)
                    : null,
              ),
              child: user.profilnaSlika == null
                  ? const Icon(Icons.person_rounded,
                      color: Color(0xFF722F37), size: 26)
                  : null,
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.punoIme.isNotEmpty ? user.punoIme : 'Korisnik',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _Colors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.email,
                    style: const TextStyle(
                        fontSize: 12, color: _Colors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.reviewCount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFB300), size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${user.avgRating.toStringAsFixed(1)} (${user.reviewCount})',
                          style: const TextStyle(
                              fontSize: 12, color: _Colors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded,
                color: _Colors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}