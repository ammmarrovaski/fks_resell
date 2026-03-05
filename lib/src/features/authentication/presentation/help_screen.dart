import 'package:flutter/material.dart';

class _HelpColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color green = Color(0xFF4CAF50);
}

class _FaqItem {
  final String question;
  final String answer;
  final IconData icon;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.icon,
  });
}

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedIndex;

  final List<_FaqItem> _generalFaq = [
    _FaqItem(
      question: 'Sta je FKS Resell?',
      answer:
          'FKS Resell je platforma za navijace FK Sarajevo gdje mozete kupovati i prodavati dresove, salone, dukseve i druge artikle povezane sa klubom. Platforma je namijenjena bordo porodici.',
      icon: Icons.storefront_rounded,
    ),
    _FaqItem(
      question: 'Kako kreirati nalog?',
      answer:
          'Kliknite na "Registruj se" na pocetnom ekranu. Unesite svoju email adresu, ime i lozinku. Nakon uspjesne registracije, bićete automatski prijavljeni i mozete poceti koristiti aplikaciju.',
      icon: Icons.person_add_rounded,
    ),
    _FaqItem(
      question: 'Da li je aplikacija besplatna?',
      answer:
          'Da, FKS Resell je potpuno besplatan za koristenje. Ne naplacujemo nikakvu proviziju na prodaju niti kupovinu artikala.',
      icon: Icons.money_off_rounded,
    ),
  ];

  final List<_FaqItem> _sellingFaq = [
    _FaqItem(
      question: 'Kako objaviti artikal?',
      answer:
          'Kliknite na "Objavi" tab u donjem meniju. Dodajte fotografije artikla (do 5), unesite naziv, opis, cijenu, odaberite kategoriju i stanje artikla. Kliknite "Objavi" i vas artikal ce biti vidljiv svim korisnicima.',
      icon: Icons.add_box_rounded,
    ),
    _FaqItem(
      question: 'Koliko artikala mogu objaviti?',
      answer:
          'Nema ogranicenja na broj artikala koje mozete objaviti. Objavite onoliko artikala koliko zelite.',
      icon: Icons.inventory_2_rounded,
    ),
    _FaqItem(
      question: 'Kako oznaciti artikal kao prodan?',
      answer:
          'Otvorite detalje vaseg artikla i kliknite na "Oznaci kao prodano". Artikal ce i dalje biti vidljiv, ali ce imati oznaku "PRODANO" i nece se moci kupiti.',
      icon: Icons.sell_rounded,
    ),
    _FaqItem(
      question: 'Mogu li obrisati svoju objavu?',
      answer:
          'Da, otvorite detalje vaseg artikla i kliknite na ikonu za brisanje. Imajte na umu da je ova akcija nepovratna - artikal i sve fotografije ce biti trajno uklonjeni.',
      icon: Icons.delete_outline_rounded,
    ),
  ];

  final List<_FaqItem> _buyingFaq = [
    _FaqItem(
      question: 'Kako kupiti artikal?',
      answer:
          'Pronadjite artikal koji zelite, dodajte ga u korpu, a zatim kontaktirajte prodavca putem emaila kako biste dogovorili detalje kupovine i preuzimanja.',
      icon: Icons.shopping_cart_rounded,
    ),
    _FaqItem(
      question: 'Kako kontaktirati prodavca?',
      answer:
          'Na stranici detalja artikla kliknite dugme "Kontaktiraj prodavca". Prikazat ce se email adresa prodavca koju mozete kopirati i koristiti za komunikaciju.',
      icon: Icons.email_rounded,
    ),
    _FaqItem(
      question: 'Sta su omiljeni artikli?',
      answer:
          'Mozete sacuvati artikle koji vas zanimaju klikom na ikonu srca. Sacuvani artikli se nalaze u sekciji "Omiljeni" na vasem profilu za lakse pronalazenje.',
      icon: Icons.favorite_rounded,
    ),
    _FaqItem(
      question: 'Gdje vidim kupljene artikle?',
      answer:
          'Svi artikli koje ste kupili nalaze se u sekciji "Kupljeni artikli" na vasem profilu. Tu mozete vidjeti kompletnu historiju kupovine.',
      icon: Icons.receipt_long_rounded,
    ),
  ];

  final List<_FaqItem> _accountFaq = [
    _FaqItem(
      question: 'Kako promijeniti lozinku?',
      answer:
          'Idite na Profil > Postavke > Promijeni lozinku. Unesite trenutnu lozinku i novu lozinku. Takodjer mozete koristiti opciju "Reset lozinke putem emaila".',
      icon: Icons.lock_rounded,
    ),
    _FaqItem(
      question: 'Kako urediti profil?',
      answer:
          'Na vrhu profil ekrana kliknite na ikonu za uredjivanje (olovka). Mozete promijeniti vase ime koje se prikazuje na artiklima koje prodajete.',
      icon: Icons.edit_rounded,
    ),
    _FaqItem(
      question: 'Kako obrisati nalog?',
      answer:
          'Idite na Profil > Postavke > Obrisi nalog. Imajte na umu da je ova akcija nepovratna i svi vasi podaci ce biti trajno obrisani.',
      icon: Icons.person_remove_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _HelpColors.background,
      appBar: AppBar(
        backgroundColor: _HelpColors.background,
        foregroundColor: _HelpColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Pomoc',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _HelpColors.cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _HelpColors.bordo,
                    _HelpColors.bordoLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Kako vam mozemo pomoci?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pronadjite odgovore na najcesca pitanja o FKS Resell aplikaciji.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // General FAQ
            _buildFaqSection('OPSTA PITANJA', _generalFaq, 0),
            const SizedBox(height: 24),

            // Selling FAQ
            _buildFaqSection('PRODAJA', _sellingFaq, _generalFaq.length),
            const SizedBox(height: 24),

            // Buying FAQ
            _buildFaqSection(
              'KUPOVINA',
              _buyingFaq,
              _generalFaq.length + _sellingFaq.length,
            ),
            const SizedBox(height: 24),

            // Account FAQ
            _buildFaqSection(
              'NALOG',
              _accountFaq,
              _generalFaq.length + _sellingFaq.length + _buyingFaq.length,
            ),

            const SizedBox(height: 28),

            // Contact support card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _HelpColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _HelpColors.textMuted.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _HelpColors.bordo.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: _HelpColors.bordo,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Niste pronasli odgovor?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _HelpColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Kontaktirajte nas direktno i rado cemo vam pomoci.',
                    style: TextStyle(
                      fontSize: 13,
                      color: _HelpColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Kontakt: fksresell@gmail.com'),
                            backgroundColor: _HelpColors.bordo,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                      icon: const Icon(Icons.email_outlined, size: 20),
                      label: const Text(
                        'Kontaktirajte nas',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _HelpColors.bordo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection(String title, List<_FaqItem> items, int startIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _HelpColors.textMuted,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          final globalIndex = startIndex + entry.key;
          final item = entry.value;
          final isExpanded = _expandedIndex == globalIndex;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _HelpColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isExpanded
                      ? _HelpColors.bordo.withOpacity(0.4)
                      : _HelpColors.textMuted.withOpacity(0.1),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? null : globalIndex;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _HelpColors.bordo.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item.icon,
                                color: _HelpColors.bordo,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.question,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isExpanded
                                      ? _HelpColors.textPrimary
                                      : _HelpColors.textSecondary,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: isExpanded
                                    ? _HelpColors.bordo
                                    : _HelpColors.textMuted,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: const EdgeInsets.only(top: 12, left: 52),
                            child: Text(
                              item.answer,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _HelpColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                          crossFadeState: isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
