# FKS Resell & Fan Shop 🔴⚪

**FKS Resell** je moderna Flutter aplikacija namijenjena ljubiteljima i kolekcionarima sportske opreme. Aplikacija omogućava korisnicima da pretražuju, kupuju i prodaju artikle, uz potpunu integraciju sa Firebase bazom podataka i Cloudinary servisom za upravljanje slikama.

---

## 🚀 Funkcionalnosti (Features)

- **Authentication:** Sigurna prijava i registracija korisnika putem Firebase-a.
- **Shop System:** Pregled dostupnih artikala po kategorijama.
- **Cart & Favorites:** Dodavanje artikala u korpu i listu želja za kasniju kupovinu.
- **Product Management:** Prodavci mogu lako dodavati nove artikle sa slikama (Cloudinary integracija).
- **Modern UI:** Intuitivan dizajn baziran na Flutter shell arhitekturi.

---

## 🛠️ Tehnologije (Tech Stack)

- **Frontend:** [Flutter](https://flutter.dev) (Dart)
- **Backend/Database:** [Firebase Firestore](https://firebase.google.com)
- **Auth:** Firebase Auth
- **Image Storage:** [Supabase](https://supabase.com)
- **State Management:** Riverpod (ili onaj koji koristiš)

---

## 📦 Instalacija i pokretanje

Da biste pokrenuli projekat lokalno, pratite ove korake:

1. **Klonirajte repozitorij:**
   ```bash
   git clone [https://github.com/ammmarrovaski/fks_resell.git](https://github.com/ammmarrovaski/fks_resell.git)
Instalirajte pakete:

Bash
flutter pub get
Pokrenite aplikaciju:

Bash
flutter run --flavor dev -t lib/src/entry_points/main_dev.dart
📂 Struktura Projekta
Projekt prati clean architecture principe:

lib/src/features/authentication - Logika za korisnike.

lib/src/features/shop - Logika za artikle i prodavnicu.

lib/src/features/cart - Sistem korpe i narudžbi.

lib/src/features/common - Ponovno iskoristive komponente.

🤝 Doprinosi (Contributing)
Ako želite doprinijeti projektu:

Napravite novi branch (git checkout -b feature/NovaFunkcionalnost)

Commit-ujte promjene (git commit -m 'Dodata nova funkcionalnost')

Push-ujte na branch (git push origin feature/NovaFunkcionalnost)

Otvorite Pull Request

📝 Licenca
Ovaj projekat je kreiran u edukativne svrhe. Sva prava zadržana.
