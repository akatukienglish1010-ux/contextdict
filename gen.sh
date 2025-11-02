#!/usr/bin/env bash
set -euo pipefail

# まっさらから生成
rm -rf ContextDict
mkdir -p ContextDict/app/src/main/java/com/example/contextdict
mkdir -p ContextDict/app/src/main/res/layout
mkdir -p ContextDict/app/src/main/res/values

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

# gradle.properties（AndroidX 有効化）
cat > ContextDict/gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2g -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
EOF

# ルート build.gradle
cat > ContextDict/build.gradle <<'EOF'
plugins {
  id 'com.android.application' version '8.5.2' apply false
  id 'org.jetbrains.kotlin.android' version '1.9.24' apply false
}
EOF

# app/build.gradle
cat > ContextDict/app/build.gradle <<'EOF'
plugins {
  id 'com.android.application'
  id 'org.jetbrains.kotlin.android'
}

android {
  namespace 'com.example.contextdict'
  compileSdk 34

  defaultConfig {
    applicationId 'com.example.contextdict'
    minSdk 23
    targetSdk 34
    versionCode 1
    versionName '1.0'
  }

  buildTypes {
    release { minifyEnabled false }
  }

  compileOptions {
    sourceCompatibility JavaVersion.VERSION_17
    targetCompatibility JavaVersion.VERSION_17
  }
  kotlinOptions { jvmTarget = '17' }
  buildFeatures { viewBinding true }
}

dependencies {
  implementation 'androidx.core:core-ktx:1.13.1'
  implementation 'androidx.appcompat:appcompat:1.7.0'
  implementation 'com.google.android.material:material:1.12.0'
  implementation 'androidx.browser:browser:1.8.0'
}
EOF

# AndroidManifest.xml（★ android:exported を必ず指定）
cat > ContextDict/app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.contextdict">

  <application
      android:label="@string/app_name"
      android:allowBackup="true"
      android:theme="@style/AppTheme">

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

# MainActivity.kt
cat > ContextDict/app/src/main/java/com/example/contextdict/MainActivity.kt <<'EOF'
package com.example.contextdict

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.contextdict.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
  private lateinit var binding: ActivityMainBinding
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    binding = ActivityMainBinding.inflate(layoutInflater)
    setContentView(binding.root)
    binding.textView.text = "Hello ContextDict!"
  }
}
EOF

# レイアウト
cat > ContextDict/app/src/main/res/layout/activity_main.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:orientation="vertical">

  <TextView
      android:id="@+id/textView"
      android:layout_width="wrap_content"
      android:layout_height="wrap_content"
      android:text="Hello"/>
</LinearLayout>
EOF

# values
cat > ContextDict/app/src/main/res/values/strings.xml <<'EOF'
<resources>
  <string name="app_name">ContextDict</string>
</resources>
EOF

cat > ContextDict/app/src/main/res/values/themes.xml <<'EOF'
<resources>
  <style name="AppTheme" parent="Theme.MaterialComponents.DayNight.NoActionBar"/>
</resources>
EOF
