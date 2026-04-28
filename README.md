# 🎁 2Goods Mate

> **Find your anime collectibles** — A centralized marketplace platform for buying and selling second-hand anime merchandise and collectibles for true collectors.

---

## 📖 Project Overview
**2Goods Mate** is a mobile application specifically designed for the collector community (figures, manga, limited edition items, etc.). It solves the problem of scattered second-hand item hunting by bringing everything into one unified platform. This app allows users to seamlessly search, view detailed information, place orders, and communicate directly with sellers through a clean, modern, and user-friendly interface.

---

## ✨ Key Features
List of fully implemented features:

* 🏠 **Marketplace:** A main feed displaying listed items, complete with categorization and tagging systems.
* 📦 **Item Details:** Comprehensive product pages featuring image carousels, pricing, condition, and rarity badges.
* ❤️ **Watchlist:** Save favorite items for later (includes an automatic "Sold Out" visual effect when an item is no longer available).
* 🛒 **Cart & Order System:** Fully functional shopping cart and checkout process with real-time inventory updates.
* 💬 **Real-time Chat:** Private messaging system allowing buyers and sellers to negotiate and ask questions directly.
* 🚩 **Report System:** Built-in item reporting to maintain community safety and platform standards.

---

## 🛠️ Tech Stack
* **Frontend:** Flutter
    * *State Management:* Riverpod
    * *Routing:* GoRouter
* **Backend & Database:** Firebase
    * *Authentication:* Firebase Auth
    * *Database:* Cloud Firestore
    * *Storage:* Firebase Storage 

---

## 🚀 Getting Started

Instructions on how to set up and run the project on your local environment.

### Prerequisites
Before running the project, please ensure you have the following tools installed:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest version)
* [Dart SDK](https://dart.dev/get-dart)
* An IDE such as [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)
* A registered project in the [Firebase Console](https://console.firebase.google.com/)



```markdown
### Installation & Setup

**1. Clone the repository**
```bash
git clone https://github.com/your-username/2goods-mate.git
cd 2goods-mate
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Setup Firebase Configuration**
* **Android:** Download the `google-services.json` file from Firebase and place it in the `android/app/` directory.

**4. Run the app**
```bash
flutter run
```
```
