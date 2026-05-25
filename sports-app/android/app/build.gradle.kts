plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // Correct plugin Kotlin
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Google services plugin
}

android {
    namespace = "com.example.moez_project"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.moez_project"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Plateforme BoM pour Firebase
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))

    // Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // (optionnel) Ajoute ici d'autres dépendances Firebase si besoin
    // Exemple : Firebase Auth
    // implementation("com.google.firebase:firebase-auth")
}
