# FKS Resell — FK Sarajevo Fan Shop

> Mobilna marketplace aplikacija za navijače FK Sarajevo. Kupuj i prodaj dresove, dukseve, salove i aksesoar unutar bordo porodice.

---

## 📱 Screenshotovi

<!-- Dodaj screenshotove ovdje -->

---

## ✨ Funkcionalnosti

### 🛒 Marketplace
- Pregled svih oglasa sa filterima i sortiranjem
- Filter po kategoriji, stanju artikla, rasponu cijene
- Sortiranje po datumu i cijeni
- Dodavanje artikla sa do 5 slika
- Uređivanje i brisanje vlastitih oglasa
- Označavanje artikla kao prodanog
- Full screen zoom slika (pinch-to-zoom)

### 👤 Korisnici
- Registracija i prijava (email/lozinka)
- Google Sign-In
- Uređivanje profila
- Profil prodavača sa svim oglasima i statistikama

### 💬 Chat
- Real-time chat između kupca i prodavača
- Lista svih konverzacija
- Nepročitane poruke badge na tab baru

### 🔔 Notifikacije
- In-app notifikacije (lajk, poruka)
- Badge za nepročitane notifikacije
- Klik na notifikaciju otvara odgovarajući screen

### 🎨 Ostalo
- Onboarding screen pri svakom pokretanju
- Tamna tema (dark mode)
- Omiljeni artikli
- Korpa
- Kupljeni artikli
- Moji oglasi
- Uslovi korištenja i politika privatnosti
- Statistike

---

## 🏗️ Arhitektura

```
lib/
├── src/
│   ├── app.dart                          # MaterialApp, routing, tema
│   ├── theme_provider.dart               # ThemeProvider (ChangeNotifier)
│   ├── flavors.dart                      # Dev/Prod flavor config
│   ├── entry_points/
│   │   ├── main_dev.dart
│   │   └── main_prod.dart
│   └── features/
│       ├── authentication/
│       │   ├── data/
│       │   │   └── auth_repository.dart
│       │   └── presentation/
│       │       ├── login_screen.dart
│       │       ├── register_screen.dart
│       │       ├── onboarding_screen.dart
│       │       ├── home_screen.dart
│       │       ├── main_shell.dart
│       │       ├── profile_screen.dart
│       │       ├── edit_profile_screen.dart
│       │       ├── settings_screen.dart
│       │       ├── my_listings_screen.dart
│       │       ├── favorites_screen.dart
│       │       ├── cart_screen.dart
│       │       ├── purchased_screen.dart
│       │       ├── statistics_screen.dart
│       │       ├── help_screen.dart
│       │       └── terms_screen.dart
│       ├── shop/
│       │   ├── data/
│       │   │   ├── shop_repository.dart
│       │   │   └── supabase_service.dart
│       │   ├── domain/
│       │   │   └── product.dart
│       │   └── presentation/
│       │       ├── add_product_screen.dart
│       │       ├── edit_product_screen.dart
│       │       ├── product_detail_screen.dart
│       │       └── seller_profile_screen.dart
│       ├── chat/
│       │   ├── data/
│       │   │   └── chat_repository.dart
│       │   ├── domain/
│       │   │   └── chat_message.dart
│       │   └── presentation/
│       │       ├── chat_list_screen.dart
│       │       └── chat_detail_screen.dart
│       └── notifications/
│           ├── data/
│           │   └── notification_repository.dart
│           └── presentation/
│               └── notifications_screen.dart
```

---

## 🛠️ Tech Stack

| Tehnologija | Upotreba |
|---|---|
| Flutter | UI framework |
| Firebase Auth | Autentifikacija |
| Cloud Firestore | Baza podataka |
| Supabase Storage | Upload i hosting slika |
| Firebase Flavors | Dev/Prod okruženja |
| photo_view | Zoom slika |
| cached_network_image | Keširanje slika |
| shared_preferences | Lokalna pohrana |
| provider | State management |

---

## 🚀 Pokretanje

### Preduslovi
- Flutter SDK
- Android Studio / VS Code
- Firebase projekt (dev + prod)
- Supabase nalog (Storage za slike)

### Instalacija

```bash
# Kloniraj repozitorij
git clone https://github.com/tvoj-username/fks-resell.git
cd fks-resell

# Instaliraj dependencies
flutter pub get
```

### Pokretanje

```bash
# Dev okruženje
flutter run --flavor dev -t lib/src/entry_points/main_dev.dart

# Prod okruženje
flutter run --flavor prod -t lib/src/entry_points/main_prod.dart
```

### Build APK

```bash
# Dev APK
flutter build apk --flavor dev -t lib/src/entry_points/main_dev.dart

# Prod APK
flutter build apk --flavor prod -t lib/src/entry_points/main_prod.dart
```

---

## 🔥 Firebase konfiguracija

1. Kreiraj Firebase projekt na [console.firebase.google.com](https://console.firebase.google.com)
2. Dodaj Android app (dev + prod package name)
3. Preuzmi `google-services.json` i postavi u `android/app/`
4. Postavi Firestore pravila:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
    match /chatRooms/{roomId}/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /notifications/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

5. Kreiraj Firestore composite indexe:

| Kolekcija | Polje 1 | Polje 2 |
|---|---|---|
| `chatRooms` | `participants` (Arrays) | `lastMessageTime` (Desc) |
| `products` | `userId` (Asc) | `createdAt` (Desc) |

---

## 📦 Firestore struktura

```
products/
  {productId}/
    title, price, category, condition
    imageUrls[], description
    userId, sellerEmail, sellerDisplayName
    isSold, createdAt

users/
  {userId}/
    favorites/   {productId}
    cart/        {productId}
    purchased/   {productId}

chatRooms/
  {roomId}/
    participants[], lastMessage, lastMessageTime
    productId, productTitle, productImageUrl
    messages/
      {messageId}/
        senderId, text, timestamp, isRead

notifications/
  {userId}/
    items/
      {notifId}/
        type, title, body
        productId, chatRoomId
        isRead, createdAt
```

---

## 👨‍💻 Autor

---
