#!/usr/bin/env bash
set -euo pipefail

# === create folders ===
mkdir -p ContextDict/app/src/main/java/com/example/contextdict
mkdir -p ContextDict/app/src/main/res/layout

# === settings.gradle ===
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

# === root build.gradle ===
cat > ContextDict/build.gradle <<'EOF'
buildscript {
  repositories { google(); mavenCentral() }
}
plugins {
  id 'com.android.application' version '8.5.2' apply false
  id 'org.jetbrains.kotlin.android' version '1.9.24' apply false
}
EOF

# === gradle.properties ===
cat > ContextDict/gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2g -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
EOF

# === app/build.gradle ===
cat > ContextDict/app/build.gradle <<'EOF'
plugins {
  id 'com.android.application'
  id 'org.jetbrains.kotlin.android'
}

android {
  namespace "com.example.contextdict"
  compileSdk 34

  defaultConfig {
    applicationId "com.example.contextdict"
    minSdk 23
    targetSdk 34
    versionCode 1
    versionName "1.0"
  }

  buildTypes {
    release { minifyEnabled false }
    debug  { minifyEnabled false }
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
}
EOF

# === AndroidManifest.xml ===
cat > ContextDict/app/src/main/AndroidManifest.xml <<'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.contextdict">

    <application android:label="ContextDict">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <activity
            android:name=".SecondActivity"
            android:exported="false" />
    </application>
</manifest>
EOF

# === MainActivity.kt ===
cat > ContextDict/app/src/main/java/com/example/contextdict/MainActivity.kt <<'EOF'
package com.example.contextdict

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.contextdict.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.message.text = "Hello ContextDict!"
        binding.goButton.setOnClickListener {
            startActivity(Intent(this, SecondActivity::class.java))
        }
    }
}
EOF

# === SecondActivity.kt ===
cat > ContextDict/app/src/main/java/com/example/contextdict/SecondActivity.kt <<'EOF'
package com.example.contextdict

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.contextdict.databinding.ActivitySecondBinding

class SecondActivity : AppCompatActivity() {
    private lateinit var binding: ActivitySecondBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySecondBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.secondMessage.text = "Second Screen!"
    }
}
EOF

# === layout: activity_main.xml ===
cat > ContextDict/app/src/main/res/layout/activity_main.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:orientation="vertical"
    android:padding="24dp">

    <TextView
        android:id="@+id/message"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello ContextDict!"
        android:textSize="22sp" />

    <Button
        android:id="@+id/goButton"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:text="Go to Second" />
</LinearLayout>
EOF

# === layout: activity_second.xml ===
cat > ContextDict/app/src/main/res/layout/activity_second.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:orientation="vertical"
    android:padding="24dp">

    <TextView
        android:id="@+id/secondMessage"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Second Screen!"
        android:textSize="22sp" />
</LinearLayout>
EOF

# === proguard (empty) ===
cat > ContextDict/app/proguard-rules.pro <<'EOF'
# no rules
EOF

echo "Project files generated."
