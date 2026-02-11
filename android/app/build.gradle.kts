plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "in.devh.voidx"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // 'jvmTarget: String' is deprecated. Please migrate to the compilerOptions DSL.
        // Updated syntax for jvmTarget
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "in.devh.voidx"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("/home/naveenxd/JKSKEYS/my-release-key.jks") // Change 'user' to your actual username
            storePassword = "devhxd"
            keyAlias = "devhxd"
            keyPassword = "devhxd"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
        implementation("androidx.sqlite:sqlite-bundled:2.6.0") 
}

flutter {
    source = "../.."
}