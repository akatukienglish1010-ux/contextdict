#!/usr/bin/env bash
set -e

# ディレクトリ作成
mkdir -p ContextDict/app/src/main/java/com/example/contextdict
mkdir -p ContextDict/app/src/main/res/layout
mkdir -p ContextDict/app/src/main/res/values

################################
# settings.gradle
################################
cat > ContextDict/settings.gradle <<'EOF'
pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "ContextDict"
include(":app")
EOF

################################
# ルート build.gradle（最小）
################################
cat > ContextDict/build.gradle <<'EOF'
// empty root build file (pluginsは子モジュールで指定)
EOF

################################
# gradle.properties
################################
cat > ContextDict/gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2g -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
EOF

################################
# app/build.gradle
################################
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
        debug {
            minifyEnabled false
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = '17'
    }

    buildFeatures {
        viewBinding true
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.13.1'
    implementation 'androidx.appcompat:appcompat:1.7.0'
    implementation 'com.google.android.material:material:1.12.0'
}
EOF

################################
# proguard-rules.pro（空でOK）
################################
cat > ContextDict/app/proguard-rules.pro <<'EOF'
# no rules
EOF

################################
# AndroidManifest.xml
# ※ android:theme を追加（AppCompatActivity用のテーマ）
# ※ android:icon は付けない（リソース未作成でエラーになるため）
################################
cat > ContextDict/app/src/main/AndroidManifest.xml <<'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.contextdict">

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

    </application>
</manifest>
EOF

################################
# MainActivity.kt（ViewBinding使用）
################################
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

        binding.helloText.text = "Hello ContextDict!"
    }
}
EOF

################################
# res/layout/activity_main.xml
################################
cat > ContextDict/app/src/main/res/layout/activity_main.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <TextView
        android:id="@+id/helloText"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello ContextDict!"
        android:textSize="24sp"
        android:layout_gravity="center" />
</FrameLayout>
EOF

################################
# res/values/strings.xml
################################
cat > ContextDict/app/src/main/res/values/strings.xml <<'EOF'
<resources>
    <string name="app_name">ContextDict</string>
</resources>
EOF

################################
# res/values/themes.xml（AppCompat/Material3 テーマ）
################################
cat > ContextDict/app/src/main/res/values/themes.xml <<'EOF'
<resources>
    <!-- AppCompatActivity 用のテーマ。Material3 の DayNight・NoActionBar を使用 -->
    <style name="Theme.ContextDict" parent="Theme.Material3.DayNight.NoActionBar"/>
</resources>
EOF

echo "Project generated."
