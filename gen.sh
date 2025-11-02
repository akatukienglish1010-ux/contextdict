#!/usr/bin/env bash
set -e

# ── ディレクトリ ─────────────────────────────────────────────
mkdir -p ContextDict/app/src/main/java/com/example/contextdict
mkdir -p ContextDict/app/src/main/res/layout
mkdir -p ContextDict/app/src/main/res/values

# ── settings.gradle ───────────────────────────────────────────
cat > ContextDict/settings.gradle <<'EOF'
pluginManagement { repositories { gradlePluginPortal(); google(); mavenCentral() } }
dependencyResolutionManagement {
  repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
  repositories { google(); mavenCentral() }
}
rootProject.name = "ContextDict"
include(":app")
EOF

# ── root build.gradle（空でOK） ───────────────────────────────
cat > ContextDict/build.gradle <<'EOF'
// root empty
EOF

# ── gradle.properties ─────────────────────────────────────────
cat > ContextDict/gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2g -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
EOF

# ── app/build.gradle ──────────────────────────────────────────
cat > ContextDict/app/build.gradle <<'EOF'
plugins {
  id 'com.android.application' version '8.5.2'
  id 'org.jetbrains.kotlin.android' version '1.9.24'
}
android {
  namespace 'com.example.contextdict'
  compileSdk 34
  defaultConfig {
    applicationId "com.example.contextdict"
    minSdk 23
    targetSdk 34
    versionCode 1
    versionName "1.0"
    vectorDrawables { useSupportLibrary = true }
  }
  buildTypes {
    release {
      minifyEnabled false
      proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
    debug { minifyEnabled false }
  }
  buildFeatures { viewBinding true }
  compileOptions {
    sourceCompatibility JavaVersion.VERSION_17
    targetCompatibility JavaVersion.VERSION_17
  }
  kotlinOptions { jvmTarget = '17' }
}
dependencies {
  implementation 'androidx.core:core-ktx:1.13.1'
  implementation 'androidx.appcompat:appcompat:1.7.0'
  implementation 'com.google.android.material:material:1.12.0'
}
EOF

# ── proguard-rules.pro ────────────────────────────────────────
cat > ContextDict/app/proguard-rules.pro <<'EOF'
# no rules
EOF

# ── AndroidManifest.xml ───────────────────────────────────────
# ※ ACTION_PROCESS_TEXT を宣言 → 文字選択メニューに「Dongriで検索」が出ます
cat > ContextDict/app/src/main/AndroidManifest.xml <<'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

  <uses-permission android:name="android.permission.INTERNET" />

  <application
      android:label="@string/app_name"
      android:allowBackup="true"
      android:supportsRtl="true"
      android:theme="@style/Theme.ContextDict">

    <activity
        android:name=".MainActivity"
        android:exported="true">
      <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
      </intent-filter>
    </activity>

    <!-- ▼ 選択メニューに出す「Dongriで検索」 ▼ -->
    <activity
        android:name=".ProcessTextActivity"
        android:exported="true"
        android:label="Dongriで検索">
      <intent-filter>
        <action android:name="android.intent.action.PROCESS_TEXT" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="text/plain" />
      </intent-filter>
    </activity>
    <!-- ▲ ここまで ▲ -->

  </application>
</manifest>
EOF

# ── MainActivity.kt（ACTION_VIEW/EXTRA open_url に対応） ────────
cat > ContextDict/app/src/main/java/com/example/contextdict/MainActivity.kt <<'EOF'
package com.example.contextdict

import android.annotation.SuppressLint
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import com.example.contextdict.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
  private lateinit var binding: ActivityMainBinding

  @SuppressLint("SetJavaScriptEnabled")
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    binding = ActivityMainBinding.inflate(layoutInflater)
    setContentView(binding.root)

    val wv = binding.webview
    wv.settings.javaScriptEnabled = true
    wv.settings.domStorageEnabled = true
    wv.webViewClient = WebViewClient()
    wv.webChromeClient = object : WebChromeClient() {
      override fun onProgressChanged(view: WebView?, newProgress: Int) {
        binding.progressBar.visibility = if (newProgress in 1..99) View.VISIBLE else View.GONE
      }
    }

    handleIntent(intent)  // 起動時
  }

  override fun onNewIntent(intent: Intent?) {
    super.onNewIntent(intent)
    if (intent != null) handleIntent(intent)
  }

  private fun handleIntent(i: Intent) {
    val openUrl = i.getStringExtra("open_url") ?: i.dataString
    val url = openUrl ?: getString(R.string.start_url)
    binding.webview.loadUrl(url)
  }

  override fun onBackPressed() {
    if (this::binding.isInitialized && binding.webview.canGoBack()) {
      binding.webview.goBack()
    } else {
      super.onBackPressed()
    }
  }
}
EOF

# ── ProcessTextActivity.kt（選択文字を受け取り→MainActivityで表示） ──
cat > ContextDict/app/src/main/java/com/example/contextdict/ProcessTextActivity.kt <<'EOF'
package com.example.contextdict

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import java.net.URLEncoder

class ProcessTextActivity : AppCompatActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val selected = intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()?.trim()
    if (!selected.isNullOrEmpty()) {
      val enc = URLEncoder.encode(selected, "UTF-8").replace("+", "%20")
      val url = "https://home.east-education.jp/dongri/search/all/$enc/HEADWORD/STARTWITH"
      val i = Intent(this, MainActivity::class.java).apply {
        putExtra("open_url", url)
        addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
      }
      startActivity(i)
    }
    finish()
  }
}
EOF

# ── layout/activity_main.xml ───────────────────────────────────
cat > ContextDict/app/src/main/res/layout/activity_main.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
  android:layout_width="match_parent"
  android:layout_height="match_parent">

  <WebView
    android:id="@+id/webview"
    android:layout_width="match_parent"
    android:layout_height="match_parent" />

  <ProgressBar
    android:id="@+id/progressBar"
    style="?android:attr/progressBarStyleLarge"
    android:layout_width="56dp"
    android:layout_height="56dp"
    android:layout_gravity="center"
    android:visibility="gone" />
</FrameLayout>
EOF

# ── values/strings.xml ─────────────────────────────────────────
cat > ContextDict/app/src/main/res/values/strings.xml <<'EOF'
<resources>
  <string name="app_name">ContextDict</string>
  <!-- 起動時のページ（お好みで変更可） -->
  <string name="start_url">https://ejje.weblio.jp/</string>
</resources>
EOF

# ── values/themes.xml ──────────────────────────────────────────
cat > ContextDict/app/src/main/res/values/themes.xml <<'EOF'
<resources>
  <style name="Theme.ContextDict" parent="Theme.Material3.DayNight.NoActionBar"/>
</resources>
EOF

echo "Project generated (WebView + ACTION_PROCESS_TEXT 'Dongriで検索')."
