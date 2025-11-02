#!/usr/bin/env bash
set -e

# ====== 設定（ここだけ変えればOK）======
START_URL="https://home.east-education.jp/dongri/search/all"   # ← 開きたいサイトに変更可（https 推奨）
APP_ID="com.example.contextdict"
APP_NAME="ContextDict"
MIN_SDK=23
TARGET_SDK=34
COMPILE_SDK=34
KOTLIN_JVM="17"
# =====================================

# ディレクトリ作成
mkdir -p ContextDict/app/src/main/java/com/example/contextdict
mkdir -p ContextDict/app/src/main/res/layout
mkdir -p ContextDict/app

# settings.gradle
cat > ContextDict/settings.gradle <<'EOF'
pluginManagement {
  repositories { gradlePluginPortal(); google(); mavenCentral() }
}
dependencyResolutionManagement {
  repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
  repositories { google(); mavenCentral() }
}
rootProject.name = "ContextDict"
include(":app")
EOF

# ルート build.gradle
cat > ContextDict/build.gradle <<'EOF'
buildscript { repositories { google(); mavenCentral() } }
plugins {
  id "com.android.application" version "8.5.2" apply false
  id "org.jetbrains.kotlin.android" version "1.9.24" apply false
}
EOF

# gradle.properties
cat > ContextDict/gradle.properties <<EOF
org.gradle.jvmargs=-Xmx2g -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
EOF

# app/build.gradle
cat > ContextDict/app/build.gradle <<EOF
plugins {
  id "com.android.application"
  id "org.jetbrains.kotlin.android"
}

android {
  namespace "${APP_ID}"
  compileSdk ${COMPILE_SDK}

  defaultConfig {
    applicationId "${APP_ID}"
    minSdk ${MIN_SDK}
    targetSdk ${TARGET_SDK}
    versionCode 1
    versionName "1.0"
  }

  buildTypes {
    release { minifyEnabled false }
    debug   { minifyEnabled false }
  }

  compileOptions {
    sourceCompatibility JavaVersion.VERSION_${KOTLIN_JVM}
    targetCompatibility JavaVersion.VERSION_${KOTLIN_JVM}
  }
  kotlinOptions { jvmTarget = "${KOTLIN_JVM}" }
  buildFeatures { viewBinding true }
}

dependencies {
  implementation "androidx.core:core-ktx:1.13.1"
  implementation "androidx.appcompat:appcompat:1.7.0"
  implementation "com.google.android.material:material:1.12.0"
  implementation "androidx.activity:activity-ktx:1.9.2"
}
EOF

# Manifest
cat > ContextDict/app/src/main/AndroidManifest.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="${APP_ID}">
    <uses-permission android:name="android.permission.INTERNET"/>
    <application
        android:label="${APP_NAME}"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="true"
        android:supportsRtl="true"
        android:usesCleartextTraffic="true">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# レイアウト（WebView 全画面）
cat > ContextDict/app/src/main/res/layout/activity_main.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <WebView
        android:id="@+id/webview"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />
</FrameLayout>
EOF

# MainActivity（WebView 設定＆読み込み）
cat > ContextDict/app/src/main/java/com/example/contextdict/MainActivity.kt <<EOF
package com.example.contextdict

import android.os.Bundle
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.ComponentActivity

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val webView = findViewById<WebView>(R.id.webview)
        with(webView.settings) {
            javaScriptEnabled = true
            domStorageEnabled = true
            useWideViewPort = true
            loadWithOverviewMode = true
            cacheMode = WebSettings.LOAD_DEFAULT
        }
        webView.webViewClient = WebViewClient()
        webView.loadUrl("${START_URL}")
    }
}
EOF

# proguard（空）
cat > ContextDict/app/proguard-rules.pro <<'EOF'
# no rules
EOF

echo "Project generated."
