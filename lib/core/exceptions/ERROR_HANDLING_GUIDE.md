# 🚨 Error Handling Guide - 2GoodsMate

## 改善内容 (What's been improved)

✅ **สร้าง AppException class** - Custom exception สำหรับ error handling consistent
✅ **Updated all repositories** - throw AppException พร้อม error code
✅ **Enhanced ErrorHandler** - Handle AppException + user-friendly messages
✅ **Logging system** - Detailed error info for developers (console only)

---

## 📌 How to Use (วิธีใช้)

### 1️⃣ Repository Layer (สร้าง AppException)

**AuthRepository.dart:**
```dart
try {
  return await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
} on FirebaseAuthException catch (e) {
  throw _handleAuthException(e);  // ← Throw AppException
}

// Convert to AppException with user-friendly message
AppException _handleAuthException(FirebaseAuthException e) {
  final userMessage = _getUserFriendlyMessage(e.code);
  return AppException(
    message: userMessage,
    code: e.code,
    originalError: e,
  );
}
```

**UserRepository.dart / HomeRepository.dart:**
```dart
try {
  // ... Firebase operation
} on FirebaseException catch (e) {
  throw AppException(
    message: _getFirestoreUserMessage(e.code),
    code: e.code,
    originalError: e,
  );
}
```

### 2️⃣ Screen Layer (แสดง Error ให้ User)

**❌ OLD WAY (ไม่ดี):**
```dart
try {
  await _authService.signInWithEmail(...);
} catch (e) {
  setState(() => _error = e.toString()); // ← Expose backend error!
}
```

**✅ NEW WAY (แนวใหม่):**
```dart
try {
  await _authService.signInWithEmail(...);
} catch (e) {
  // 1. Log to console (for developers)
  ErrorHandler.logError('MyScreen._login()', e);

  // 2. Get user-friendly message
  final message = ErrorHandler.getUserMessage(e);

  // 3. Show to user
  setState(() => _error = message);
}
```

### 3️⃣ ErrorHandler Methods

**For getting message only:**
```dart
try {
  await repo.fetchData();
} catch (e) {
  final userMessage = ErrorHandler.getUserMessage(e);
  setState(() => _errorText = userMessage);
}
```

**For logging only:**
```dart
ErrorHandler.logError('my_screen.method_name()', error, stackTrace: st);
```

**For showing error + logging (All-in-one):**
```dart
try {
  await repo.doSomething();
} catch (e) {
  ErrorHandler.showError(
    context,
    e,
    contextLabel: 'settings_screen.updateProfile()',
  );
}
```

**For showing success/info:**
```dart
ErrorHandler.showSuccess(context, 'Profile updated!');
ErrorHandler.showInfo(context, 'Please check your email');
```

---

## 🎯 Error Message Flow

```
┌─────────────────────────────────────────────────┐
│ Firebase Error                                  │
│ (user-not-found, network-request-failed, etc)  │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ Repository catches & throws AppException       │
│ code: "user-not-found"                          │
│ message: "Invalid email or password" ← USER MSG │
│ originalError: FirebaseAuthException            │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│ Screen catches error                            │
│                                                 │
│ ErrorHandler.logError() ───► CONSOLE (devs)    │
│ ErrorHandler.getUserMessage() ───► DISPLAY    │
│ ErrorHandler.showError() ───► ALL IN ONE       │
└─────────────────────────────────────────────────┘
               │
               ▼
        ┌─────────────┐
        │ User sees   │
        │ friendly    │
        │ message ✅  │
        └─────────────┘
```

---

## 🔍 What Developers See (Console Logs)

When ErrorHandler.logError() is called:

```
┌─────────────────────────────────────────
│ ERROR in login_screen._signIn()
├─────────────────────────────────────────
│ Type: App Exception
│ Code: invalid-credential
│ Message: Invalid email or password
│ Original Error: FirebaseAuthException: ...
│ Stack Trace:
│ #0 AuthRepository._handleAuthException
│ #1 AuthRepository.signInWithEmail
│ ...
└─────────────────────────────────────────
```

---

## 📋 Repository Template

Copy this template for any new repository:

```dart
import 'package:anigoods/core/exceptions/app_exception.dart';

class MyRepository {
  Future<void> doSomething() async {
    try {
      // ... Firebase operation
    } on FirebaseException catch (e) {
      throw AppException(
        message: _getUserMessage(e.code),
        code: e.code,
        originalError: e,
      );
    }
  }

  String _getUserMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Permission denied. Please sign in again';
      case 'not-found':
        return 'Item not found';
      default:
        return 'Something went wrong. Please try again';
    }
  }
}
```

---

## ✨ Benefits

| Before ❌ | After ✅ |
|----------|---------|
| Inconsistent error display | Same message everywhere |
| Users see backend errors | User-friendly messages only |
| Hard to debug | Full logs for developers |
| No error tracking | Error code tracking |
| Mixed concerns | Separation of concerns |

---

## 🚀 Quick Checklist

When creating new Repository:
- [ ] Import `app_exception.dart`
- [ ] Wrap Firebase calls in try-catch
- [ ] Throw `AppException` with code + user message
- [ ] Add `_getUserMessage(code)` method

When handling error in Screen:
- [ ] Use `ErrorHandler.logError()` for console
- [ ] Use `ErrorHandler.getUserMessage()` for display
- [ ] OR use `ErrorHandler.showError()` for all-in-one
- [ ] Never show raw exception to user
