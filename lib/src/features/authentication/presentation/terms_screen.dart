import 'package:flutter/material.dart';

class _Colors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color divider = Color(0xFF2E2E2E);
}

class _Section {
  final String title;
  final String content;
  final IconData icon;
  const _Section({required this.title, required this.content, required this.icon});
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  static const _sections = [
    _Section(
      icon: Icons.storefront_rounded,
      title: '1. O platformi',
      content:
          'FKS Resell je platforma namijenjena navijačima FK Sarajevo za kupovinu i prodaju dresova, dukseva, šalova, aksesoara i ostalih artikala povezanih sa klubom. Platforma funkcioniše kao oglasnik — Anthropic ne učestvuje u transakcijama i nije odgovoran za ishod dogovora između korisnika.',
    ),
    _Section(
      icon: Icons.person_rounded,
      title: '2. Registracija i nalog',
      content:
          'Korisnici moraju imati najmanje 16 godina. Svaki korisnik je odgovoran za tačnost podataka koje unosi prilikom registracije. Zabranjeno je kreiranje više naloga u svrhu zloupotrebe platforme. Nalog je osoban i ne smije se dijeliti s drugim osobama.',
    ),
    _Section(
      icon: Icons.sell_rounded,
      title: '3. Pravila oglašavanja',
      content:
          'Dozvoljeno je oglašavati isključivo artikle vezane za FK Sarajevo i navijačku kulturu. Zabranjeno je oglašavanje falsifikata, ukradene robe ili artikala koji nisu u vlasništvu prodavača. Fotografije i opisi moraju vjerno prikazivati stanje artikla. Lažno oglašavanje rezultira trajnom blokadom naloga.',
    ),
    _Section(
      icon: Icons.handshake_rounded,
      title: '4. Odgovornost za transakcije',
      content:
          'FKS Resell je posrednik koji omogućava kontakt između kupca i prodavača. Platforma ne garantuje kvalitet, autentičnost niti isporuku artikala. Korisnici se dogovaraju direktno o načinu plaćanja, cijeni i preuzimanju. Svaki spor rješava se između korisnika bez učešća platforme.',
    ),
    _Section(
      icon: Icons.shield_rounded,
      title: '5. Zabranjen sadržaj',
      content:
          'Strogo je zabranjeno postavljati uvredljiv, diskriminatoran ili nezakonit sadržaj. Zabranjeno je slanje neželjenih poruka (spam), promocija vanjskih stranica ili lažnih oglasa. Korisnici koji krše ova pravila biće trajno uklonjeni s platforme.',
    ),
    _Section(
      icon: Icons.lock_rounded,
      title: '6. Privatnost podataka',
      content:
          'Vaši lični podaci (email, ime) koriste se isključivo za funkcionisanje aplikacije. Podaci se ne prodaju trećim stranama. Firebase Firestore i Firebase Auth koriste se za sigurno čuvanje podataka u skladu s GDPR regulativom. Fotografije artikala čuvaju se putem Cloudinary servisa.',
    ),
    _Section(
      icon: Icons.star_rounded,
      title: '7. Ocjene i recenzije',
      content:
          'Platforma trenutno ne podržava sistem ocjenjivanja korisnika. Eventualne buduće funkcionalnosti biće uređene dopunom ovih uslova. Korisnici su dužni ponašati se korektno i poštovati dogovorene uvjete kupoprodaje.',
    ),
    _Section(
      icon: Icons.update_rounded,
      title: '8. Izmjene uslova',
      content:
          'FKS Resell zadržava pravo izmjene ovih uslova korišćenja u bilo kom trenutku. Korisnici će biti obaviješteni o značajnim izmjenama putem aplikacije. Nastavak korišćenja platforme nakon izmjena smatra se prihvatanjem novih uslova.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Colors.background,
      appBar: AppBar(
        backgroundColor: _Colors.background,
        foregroundColor: _Colors.textPrimary,
        elevation: 0,
        title: const Text(
          'Uslovi korištenja',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_Colors.bordo, _Colors.bordoLight],
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
                    child: const Icon(Icons.description_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Uslovi korištenja',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Posljednje ažuriranje: mart 2025.',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.75)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Korištenjem FKS Resell aplikacije prihvatate sljedeće uslove. Molimo vas da ih pažljivo pročitate.',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85), height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Sections
            ..._sections.map((section) => _buildSection(section)),

            // Footer
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _Colors.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _Colors.textMuted.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.email_outlined, color: _Colors.bordo.withOpacity(0.7), size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pitanja o uslovima?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _Colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'fksresell@gmail.com',
                          style: TextStyle(fontSize: 13, color: _Colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(_Section section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: _Colors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _Colors.textMuted.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _Colors.bordo.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(section.icon, color: _Colors.bordo, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _Colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      section.content,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _Colors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
