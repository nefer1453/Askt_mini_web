set -e

echo "[1/6] Klasörler hazırlanıyor..."
mkdir -p android/app/src/main/java/com/nefer/sktmini
mkdir -p android/app/src/main/res/layout
mkdir -p .github/workflows

echo "[2/6] Gradle dosyaları yazılıyor..."
cat > android/settings.gradle <<'EOF'
rootProject.name = "sktmini"
include(":app")
EOF

cat > android/build.gradle <<'EOF'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath "com.android.tools.build:gradle:8.2.2"
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

cat > android/app/build.gradle <<'EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace "com.nefer.sktmini"
    compileSdk 34

    defaultConfig {
        applicationId "com.nefer.sktmini"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
        }
    }
}

dependencies {
    implementation "androidx.core:core-ktx:1.12.0"
    implementation "androidx.appcompat:appcompat:1.6.1"
}
EOF

echo "[3/6] AndroidManifest + layout + Kotlin yazılıyor..."
cat > android/app/src/main/AndroidManifest.xml <<'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="SKT Mini"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

cat > android/app/src/main/res/layout/activity_main.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<WebView xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/web"
    android:layout_width="match_parent"
    android:layout_height="match_parent" />
EOF

cat > android/app/src/main/java/com/nefer/sktmini/MainActivity.kt <<'EOF'
package com.nefer.sktmini

import android.os.Bundle
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val webView = WebView(this)
        setContentView(webView)

        webView.webViewClient = WebViewClient()

        val settings: WebSettings = webView.settings
        settings.javaScriptEnabled = true
        settings.domStorageEnabled = true

        // SENİN SKT sayfan:
        webView.loadUrl("https://nefer1453.github.io/skt/")
    }
}
EOF

echo "[4/6] GitHub Actions workflow yazılıyor..."
cat > .github/workflows/android.yml <<'EOF'
name: Build APK

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17

      - name: Build Debug APK
        run: |
          cd android
          chmod +x gradlew
          ./gradlew assembleDebug

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: sktmini-apk
          path: android/app/build/outputs/apk/debug/app-debug.apk
EOF

echo "[5/6] Gradle wrapper hazırlanıyor (Termux'ta gradle gerekir)..."
# Gradle yoksa kur:
if ! command -v gradle >/dev/null 2>&1; then
  echo "Gradle yok -> kuruluyor..."
  pkg update -y
  pkg install -y gradle
fi

cd android
gradle wrapper --gradle-version 8.2.1
chmod +x gradlew
cd ..

echo "[6/6] Commit + Push..."
git add .
git commit -m "Android APK: Kotlin WebView wrapper + actions" || true
git push -u origin main

echo
echo "OK ✅"
echo "GitHub Actions -> Artifacts -> sktmini-apk indirip kuracaksın."
