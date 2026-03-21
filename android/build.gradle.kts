plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin for Firebase integration
    id("com.google.gms.google-services")
}

android {
    namespace = "com.minggle.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Unique Application ID for Minggle App
        applicationId = "com.minggle.app"
        // Minimum SDK version 21 is required for Firebase services
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with the debug keys for now for testing
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM (Bill of Materials) for version management
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))

    // Firebase Authentication for Phone OTP login logic
    implementation("com.google.firebase:firebase-auth")      
    
    // Cloud Firestore to store user profiles and Minggle app data
    implementation("com.google.firebase:firebase-firestore") 
}
