# CI/CD với Shorebird Code Push - Hướng Dẫn

## Mục lục
1. [Tổng quan](#tổng-quan)
2. [Cấu trúc hiện tại](#cấu-trúc-hiện-tại)
3. [Setup ban đầu](#setup-ban-đầu)
4. [Chạy CI/CD](#chạy-cicd)
5. [Các lỗi thường gặp](#các-lỗi-thường-gặp)
6. [Debug](#debug)

---

## Tổng quan

Shorebird cho phép cập nhật app Flutter mà KHÔNG cần submit lên App Store/Play Store. Thay vì build lại toàn bộ APK, Shorebird chỉ cần patch binary - tải nhanh hơn, tiết kiệm data.

**Luồng hoạt động:**
```
Code Change → Git Push → GitHub Actions (CI/CD) → Build APK + Shorebird Patch → Firebase Distribution
```

- **Lần đầu**: Build full APK, upload lên Firebase
- **Các lần sau** (code thay đổi): Tạo Shorebird patch, tự động update qua Firebase

---

## Cấu trúc hiện tại

### 1. GitHub Actions Workflow (`.github/workflows/firebase_distribute.yml`)

```yaml
name: 🚀 Build & Distribute to Firebase QA

on:
  push:
    branches: ["master", "main"]
  workflow_dispatch:

jobs:
  build_and_release:
    runs-on: ubuntu-latest
    steps:
      # 1. Checkout code
      - uses: actions/checkout@v4

      # 2. Setup Java 17
      - uses: actions/setup-java@v4
        with:
          java-version: "17"

      # 3. Setup Flutter
      - uses: subosito/flutter-action@v2
        with:
          channel: "stable"
          cache: true

      # 4. Setup Shorebird
      - uses: shorebirdtech/setup-shorebird@v1
        with:
          cache: true

      # 5. Tạo google-services.json từ Secret
      - name: 📝 Create google-services.json
        run: printf '%s' "$GOOGLE_SERVICES_JSON" > android/app/google-services.json

      # 6. Restore Keystore từ Secret (QUAN TRỌNG!)
      - name: 🔐 Setup Keystore
        run: echo "$KEYSTORE_BASE64" | base64 -d > android/app/release.jks

      # 7. Auto increment version
      - name: 🔢 Auto Increment Version
        run: |
          VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
          IFS='+' read -r VERSION_PART BUILD_PART <<< "$VERSION"
          IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_PART"
          NEW_BUILD=$((BUILD_PART + 1))
          NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}+${NEW_BUILD}"
          sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
          sed -i "s/versionCode = flutter.versionCode/versionCode = $NEW_BUILD/" android/app/build.gradle.kts
          sed -i "s/versionName = flutter.versionName/versionName = \"$NEW_VERSION\"/" android/app/build.gradle.kts

      # 8. Build & Distribute via Fastlane
      - name: 🚀 Build and Distribute APK
        run: bundle exec fastlane distribute_to_qa
```

### 2. Fastlane (`android/fastlane/Fastfile`)

```ruby
default_platform(:android)

platform :android do
  desc "Build APK và đẩy lên Firebase cho Tester"
  lane :distribute_to_qa do
    sh("cd ../.. && flutter clean")
    sh("cd ../.. && flutter build apk --release")
    firebase_app_distribution(
      app: "1:664280682142:android:830fe892c914d908fc358f",
      apk_path: "../build/app/outputs/flutter-apk/app-release.apk",
      testers: "trunghungpq456@gmail.com",
      release_notes: "Bản build tự động từ CI/CD!"
    )
  end

  desc "Tạo Shorebird patch cho OTA update"
  lane :shorebird_patch do
    sh("cd ../.. && flutter clean")
    sh("cd ../.. && shorebird patch android")
  end
end
```

### 3. Version trong `pubspec.yaml`

```yaml
version: 1.0.0+1
#          │ │ │ └── build number (tăng mỗi lần build)
#          │ └── patch version
#          └── minor version
#          major version
```

---

## Setup ban đầu

### Bước 1: Cài đặt Shorebird CLI

```bash
dart pub global activate shorebird
```

### Bước 2: Khởi tạo Shorebird trong project

```bash
shorebird init
```

File `shorebird.yaml` sẽ được tạo:
```yaml
app_id: "your-app-id-from-firebase"
flavors:
  production:
    app_id: "1:xxx:android:xxx"
```

### Bước 3: Tạo Keystore cho Android

```bash
# Tạo keystore mới
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release

# Export base64 để lưu vào GitHub Secret
base64 -i release.jks | pbcopy
```

### Bước 4: Thêm GitHub Secrets

Vào **GitHub → Settings → Secrets and variables → Actions**:

| Secret Name | Value |
|-------------|-------|
| `KEYSTORE_BASE64` | Base64 của file `release.jks` |
| `FIREBASE_TOKEN` | Token từ `firebase login:ci` |
| `SHOREBIRD_TOKEN` | Token từ `shorebird auth` |
| `GOOGLE_SERVICES_JSON` | Nội dung file `google-services.json` |

### Bước 5: Đăng ký SHA-1 fingerprint trong Firebase Console

1. Lấy SHA-1 từ keystore:
   ```bash
   keytool -list -v -keystore release.jks -alias release
   ```

2. Vào **Firebase Console → Project → App → Settings → SHA certificate fingerprints**

3. Thêm SHA-1 vào

⚠️ **ĐÂY LÀ NGUYÊN NHÂN THƯỜNG GẶP NHẤT KHIẾN APP KHÔNG CÀI ĐƯỢC!**

---

## Chạy CI/CD

### Cách 1: Push code lên branch

```bash
git add .
git commit -m "your message"
git push
```

Workflow sẽ tự động chạy khi push lên `master` hoặc `main`.

### Cách 2: Chạy thủ công

Vào **GitHub → Actions → Build & Distribute to Firebase QA → Run workflow**

---

## Các lỗi thường gặp

### ❌ Lỗi "App not installed"

**Nguyên nhân:** SHA-1 fingerprint trong Firebase Console không khớp keystore.

**Cách fix:**
1. Lấy SHA-1 từ keystore đang dùng
2. Thêm vào Firebase Console
3. Xóa app cũ trên thiết bị
4. Cài lại

### ❌ Lỗi "versionCode already exists"

**Nguyên nhân:** Firebase đã có versionCode đó rồi.

**Cách fix:** Tăng version trong `pubspec.yaml` trước khi build:
```yaml
version: 1.0.0+4  # tăng từ +3 lên +4
```

### ❌ Workflow không tăng version

**Nguyên nhân:** Khi re-run workflow, git state không đổi nên version cũ được dùng lại.

**Cách fix:** Phải push code thay đổi lên thì version mới tăng.

### ❌ Lỗi Shorebird auth

**Nguyên nhân:** `SHOREBIRD_TOKEN` hết hạn hoặc chưa set.

**Cách fix:**
```bash
shorebird auth
# Copy token và thêm vào GitHub Secret
```

### ❌ Lỗi Firebase permission

**Nguyên nhân:** `FIREBASE_TOKEN` hết hạn hoặc không có quyền.

**Cách fix:**
```bash
firebase login:ci
# Copy token và thêm vào GitHub Secret
```

### ❌ APK build thành công nhưng upload fail

**Nguyên nhân:** Đường dẫn APK sai trong Fastfile.

**Kiểm tra:**
```bash
ls build/app/outputs/flutter-apk/
```

---

## Debug

### Xem log GitHub Actions

1. Vào **GitHub → Actions → workflow run → job**
2. Click vào từng step để xem log chi tiết

### Test local trước

```bash
# Build local
cd android
bundle exec fastlane distribute_to_qa

# Hoặc chỉ build
flutter build apk --release

# Test Shorebird patch
shorebird patch android
```

### Kiểm tra version hiện tại

```bash
grep "^version:" pubspec.yaml
```

---

## Best Practices

1. **LUÔN dùng keystore cố định** - Không tạo keystore mới sau khi đã release
2. **Đăng ký SHA-1 đúng** - Firebase Console phải có SHA-1 khớp với keystore
3. **Version phải tăng** - Mỗi lần distribute phải tăng version
4. **Test local trước** - Chạy `flutter build apk --release` local trước khi push
5. **Giữ Secrets an toàn** - Không commit secrets vào git

---

## Lệnh hữu ích

```bash
# Lấy SHA-1 từ keystore
keytool -list -v -keystore android/app/release.jks -alias release

# Tạo keystore backup
keytool -export -keystore release.jks -alias release -file certificate.cer

# Kiểm tra version hiện tại
grep "^version:" pubspec.yaml

# Force rebuild
flutter clean && flutter pub get && flutter build apk --release

# Login Shorebird
shorebird auth

# Check Shorebird status
shorebird doctor
```
