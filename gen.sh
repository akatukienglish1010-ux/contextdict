#!/usr/bin/env bash
set -euo pipefail

# 一旦まっさらに作る
rm -rf ContextDict
mkdir -p ContextDict/app/src/main/java/com/example/contextdict
mkdir -p ContextDict/app/src/main/res/{layout,values}

# settings.gradle
cat > ContextDict/settings.gradle <<'EOF'
pluginManagement { repositories { gradlePluginPortal(); google(); mavenCentral() } }
dependencyResolutionManagement {
  repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
  repositories { google(); mavenCentral() }
}
rootProject.name = "ContextDict"
include(":app")
EOF

# ルート（空でOK）
cat > ContextDict/build.gradle <<'EOF'
EOF

# gradle.properties（AndroidX 有効化）
cat > ContextDict/gradle.properties <<'EOF'
android.useAndroidX=true
kotlin.code.style=official
org.gradle.jvmargs=-Xmx2g -Dfile.encoding=UTF-8
EOF

# app/build.gradle
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
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug { minifyEnabled false }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = '17' }
    buildFeatures { viewBinding true }
}

dependencies {
    implementation 'org.jetbrains.kotlin:kotlin-stdlib:1.9.24'
    implementation 'androidx.core:core-ktx:1.13.1'
    implementation 'androidx.appcompat:appcompat:1.7.0'
    implementation 'com.google.android.material:material:1.12.0'
    # 必要なら後で追加： implementation 'androidx.browser:browser:1.8.0'
}
EOF

# AndroidManifest
cat > ContextDict/app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="@string/app_name"
        android:allowBackup="true"
        android:supportsRtl="true"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar">
        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# strings.xml
cat > ContextDict/app/src/main/res/values/strings.xml <<'EOF'
<resources>
    <string name="app_name">ContextDict</string>
</resources>
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
        android:id="@+id/hello"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello ContextDict!" />
</LinearLayout>
EOF

# MainActivity.kt
cat > ContextDict/app/src/main/java/com/example/contextdict/MainActivity.kt <<'EOF'
package com.example.contextdict

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }
}
EOF

# proguard
cat > ContextDict/app/proguard-rules.pro <<'EOF'
# no rules
EOF
