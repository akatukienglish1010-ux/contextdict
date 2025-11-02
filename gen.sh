#!/usr/bin/env bash
set -e

# ── ディレクトリ作成 ─────────────────────────────────────────────
mkdir -p ContextDict/app/src/main/java/com/example/contextdict
mkdir -p ContextDict/app/src/main/res/layout
mkdir -p ContextDict/app/src/main/res/values
mkdir -p ContextDict/app/src/main/res/drawable
mkdir -p ContextDict/app/src/main/res/mipmap-anydpi-v26

# ── settings.gradle ─────────────────────────────────────────────
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

# ── ルート build.gradle（空でOK） ──────────────────────────────
cat > ContextDict/build.gradle <<'EOF'
// root empty
EOF

# ── gradle.properties ──────────────────────────────────────────
cat > ContextDict/gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2g -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
EOF

# ── app/build.gradle ───────────────────────────────────────────
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

# ── proguard-rules.pro ─────────────────────────────────────────
cat > ContextDict/app/proguard-rules.pro <<'EOF'
# no rules
EOF

# ── AndroidManifest.xml（INTERNET + テーマ + icon あり） ───────
cat > ContextDict/app/src/main/AndroidManifest.xml <<'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:label="@string/app_name"
        android:allowBackup="true"
        android:supportsRtl="true"
        android:icon="@mipmap/ic_launcher"
        android:theme="@style/Theme.ContextDict">

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

# ── MainActivity.kt（WebView + コンテクストメニュー「Dongriで検索」） ──
cat > ContextDict/app/src/main/java/com/example/contextdict/MainActivity.kt <<'EOF'
package com.example.contextdict

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.ActionMode
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import com.example.contextdict.databinding.ActivityMainBinding
import java.net.URLEncoder

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding

    companion object {
        private const val MENU_DONGRI = 1001
    }

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
                binding.progressBar.visibility =
                    if (newProgress in 1..99) View.VISIBLE else View.GONE
            }
        }

        // テキスト選択のツールバーに「Dongriで検索」を追加
        wv.setCustomSelectionActionModeCallback(object : ActionMode.Callback {
            private fun ensureItem(menu: Menu) {
                if (menu.findItem(MENU_DONGRI) == null) {
                    menu.add(0, MENU_DONGRI, 0, "Dongriで検索")
                        .setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM)
                }
            }
            override fun onCreateActionMode(mode: ActionMode, menu: Menu): Boolean {
                ensureItem(menu); return true
            }
            override fun onPrepareActionMode(mode: ActionMode, menu: Menu): Boolean {
                ensureItem(menu); return true
            }
            override fun onDestroyActionMode(mode: ActionMode) {}

            override fun onActionItemClicked(mode: ActionMode, item: MenuItem): Boolean {
                if (item.itemId != MENU_DONGRI) return false

                val js = """
                    (function(){
                      var s = window.getSelection().toString();
                      if(!s){
                        var el = document.activeElement;
                        if(el && (el.tagName==='INPUT' || el.tagName==='TEXTAREA')){
                          try {
                            s = el.value.substring(el.selectionStart||0, el.selectionEnd||0);
                          } catch(e){}
                        }
                      }
                      return s;
                    })();
                """.trimIndent()

                wv.evaluateJavascript(js) { raw ->
                    val selected = raw
                        ?.trim('"')
                        ?.replace("\\n", " ")
                        ?.replace("\\t", " ")
                        ?.replace("\\u3000", " ")
                        ?.replace("\\\"", "\"")
                        ?.trim()
                        ?: ""

                    if (selected.isNotBlank()) {
                        val enc = URLEncoder.encode(selected, "UTF-8").replace("+", "%20")
                        val url = "https://home.east-education.jp/dongri/search/all/$enc/HEADWORD/STARTWITH"
                        wv.loadUrl(url)
                    }
                    mode.finish()
                }
                return true
            }
        })

        // 起動ページ（必要なら strings.xml の start_url を変更）
        wv.loadUrl(getString(R.string.start_url))
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

# ── レイアウト（WebView＋中央ローディング） ────────────────────
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

# ── 文字列リソース（起動URL） ─────────────────────────────────
cat > ContextDict/app/src/main/res/values/strings.xml <<'EOF'
<resources>
    <string name="app_name">ContextDict</string>
    <string name="start_url">https://ejje.weblio.jp/</string>
</resources>
EOF

# ── テーマ（AppCompat / Material3） ───────────────────────────
cat > ContextDict/app/src/main/res/values/themes.xml <<'EOF'
<resources>
    <style name="Theme.ContextDict" parent="Theme.Material3.DayNight.NoActionBar"/>
</resources>
EOF

# ── アイコン（AAPT用に最低限の adaptive icon 一式を自動生成） ─────
# 前景（白い丸）
cat > ContextDict/app/src/main/res/drawable/ic_launcher_foreground.xml <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#FFFFFF"
        android:pathData="M20,54a34,34 0 1,0 68,0a34,34 0 1,0 -68,0"/>
</vector>
EOF

# 背景色
cat > ContextDict/app/src/main/res/values/ic_launcher_background.xml <<'EOF'
<resources>
    <color name="ic_launcher_bg">#6200EE</color>
</resources>
EOF

# adaptive icon 定義
cat > ContextDict/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml <<'EOF'
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_bg"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
EOF

echo "Project generated (WebView + context menu + theme + icons)."
