import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Release signing — reads credentials from android/key.properties.
// That file is .gitignored and must never be committed.
// See android/key.properties.template for the required format.
// ---------------------------------------------------------------------------
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.church.church_analytics"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.church.church_analytics"
        // FEAT-008: minSdk raised from flutter.minSdkVersion (resolves to 16
        // on Flutter 3.22) to 21.  Foreground Services require API 21+; at
        // minSdk 16 the ForegroundService class is not available on Android 4.x
        // devices and the app would crash at runtime on those devices.
        // Android 4.x accounts for < 0.1% of the active install base and all
        // other packages in this project (Kotlin coroutines, flutter_local_
        // notifications, Material 3) have practical API 21+ floors anyway.
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use the release keystore when key.properties is present (CI / production).
            // Falls back to debug signing on developer machines that have not yet
            // configured a keystore — avoids blocking local builds while ensuring
            // published APKs always use the same consistent release key.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
