# FKS Resell — FK Sarajevo Fan Shop

Mobilna marketplace aplikacija za navijače FK Sarajevo. Kupuj i prodaj dresove, dukseve, salove i aksesoar unutar bordo porodice.

---

## 📱 Screenshotovi

## 📱 Screenshotovi

<p float="left">
  <img src="assets/screenshots/sc1.jpg" width="200"/>
  <img src="assets/screenshots/sc2.jpg" width="200"/>
  <img src="assets/screenshots/sc3.jpg" width="200"/>
  <img src="assets/screenshots/sc4.jpg" width="200"/>
  <img src="assets/screenshots/sc5.jpg" width="200"/>
  <img src="assets/screenshots/sc6.jpg" width="200"/>
  <img src="assets/screenshots/sc7.jpg" width="200"/>
  <img src="assets/screenshots/sc8.jpg" width="200"/>
  <img src="assets/screenshots/sc9.jpg" width="200"/>
  <img src="assets/screenshots/sc10.jpg" width="200"/>
  <img src="assets/screenshots/sc11.jpg" width="200"/>
  <img src="assets/screenshots/sc12.jpg" width="200"/>
  <img src="assets/screenshots/sc13.jpg" width="200"/>
  <img src="assets/screenshots/sc14.jpg" width="200"/>
  <img src="assets/screenshots/sc15.jpg" width="200"/>
  <img src="assets/screenshots/sc16.jpg" width="200"/>
  <img src="assets/screenshots/sc17.jpg" width="200"/>
  <img src="assets/screenshots/sc18.jpg" width="200"/>
  <img src="assets/screenshots/sc19.jpg" width="200"/>
  <img src="assets/screenshots/sc20.jpg" width="200"/>
  <img src="assets/screenshots/sc21.jpg" width="200"/>
  <img src="assets/screenshots/sc22.jpg" width="200"/>
  <img src="assets/screenshots/sc23.jpg" width="200"/>
  <img src="assets/screenshots/sc24.jpg" width="200"/>
  <img src="assets/screenshots/sc25.jpg" width="200"/>

</p>

---

## ✨ Što aplikacija može

**Marketplace**
- Pregled svih oglasa sa filterima (kategorija, stanje, cijena) i sortiranjem
- Dodavanje artikla sa do 5 slika
- Uređivanje i brisanje vlastitih oglasa
- Označavanje artikla kao prodanog + evidentiranje kupca
- Full screen zoom slika

**Korisnici**
- Registracija i prijava (email/lozinka i Google Sign-In)
- Uređivanje profila (ime, prezime, slika, bio, telefon)
- Profil prodavača sa oglasima, ocjenama i statistikama
- Pretraga korisnika po imenu ili emailu
- Dojmovi i ocjene nakon kupovine

**Chat**
- Real-time chat između kupca i prodavača
- Lista konverzacija sa badge-om za nepročitane poruke

**Ostalo**
- Omiljeni artikli, korpa, kupljeni artikli
- In-app notifikacije
- Onboarding pri prvom pokretanju
- Statistike prodaje
- Dev/Prod flavors

---

## 🛠️ Tech Stack

| Tehnologija | Upotreba |
|---|---|
| Flutter | UI framework |
| Firebase Auth | Autentifikacija (email + Google) |
| Cloud Firestore | Baza podataka |
| Supabase Storage | Upload i hosting slika |
| Firebase Flavors | Dev/Prod okruženja |
| photo_view | Zoom slika |
| cached_network_image | Keširanje slika |
| shared_preferences | Lokalna pohrana |

---

## 🚀 Pokretanje

### Preduslovi

- Flutter SDK
- Android Studio / VS Code
- Firebase projekt (dev + prod)
- Supabase nalog (Storage za slike)

### Instalacija

```bash
git clone https://github.com/ammmarrovaski/fks_resell.git
cd fks_resell
flutter pub get
```

### Pokretanje

```bash
# Dev
flutter run --flavor dev -t lib/src/entry_points/main_dev.dart

# Prod
flutter run --flavor prod -t lib/src/entry_points/main_prod.dart
```

### Build APK

```bash
# Dev
flutter build apk --flavor dev -t lib/src/entry_points/main_dev.dart

# Prod
flutter build apk --flavor prod -t lib/src/entry_points/main_prod.dart
```

---

## 🔥 Firebase setup

1. Kreiraj dva Firebase projekta (dev + prod) na [console.firebase.google.com](https://console.firebase.google.com)
2. Dodaj Android app sa odgovarajućim package nameom
3. Preuzmi `google-services.json` i postavi u `android/app/`
4. Uključi **Authentication** (Email/Password + Google) i **Firestore**

**Firestore pravila:**

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    match /chatRooms/{roomId}/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /reviews/{reviewId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /notifications/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

**Composite indexi:**

| Kolekcija | Polje 1 | Polje 2 |
|---|---|---|
| `chatRooms` | `participants` (Arrays) | `lastMessageTime` (Desc) |
| `products` | `userId` (Asc) | `createdAt` (Desc) |

---

## 📦 Firestore struktura

```
products/{productId}
  title, price, category, condition, description
  imageUrls[], userId, sellerEmail, sellerDisplayName
  isSold, soldToUserId, isDeleted, createdAt

users/{userId}
  uid, email, ime, prezime, bio, telefon
  profilnaSlika, avgRating, reviewCount, createdAt
  favorites/{productId}
  cart/{productId}
  purchased/{productId}

reviews/{reviewId}
  productId, reviewerId, sellerId
  reviewerName, reviewerAvatar
  rating, poruka, createdAt

chatRooms/{roomId}
  participants[], lastMessage, lastMessageTime
  productId, productTitle, productImageUrl
  messages/{messageId}
    senderId, text, timestamp, isRead

notifications/{userId}/items/{notifId}
  type, title, body, productId, chatRoomId
  isRead, createdAt
```

---