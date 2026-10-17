import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.aikodeware.notibuku"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Load keystore properties if available
    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties().apply {
        if (keystorePropertiesFile.exists()) {
            load(FileInputStream(keystorePropertiesFile))
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(
                org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
            )
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID.
        applicationId = "com.aikodeware.notibuku"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyAlias = keystoreProperties.getProperty("keyAlias")
            val keyPassword = keystoreProperties.getProperty("keyPassword")
            val storePassword = keystoreProperties.getProperty("storePassword")
            val storeFilePath = keystoreProperties.getProperty("storeFile")

            if (
                keyAlias != null &&
                keyPassword != null &&
                storePassword != null &&
                storeFilePath != null
            ) {
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
                this.storePassword = storePassword
                this.storeFile = file(storeFilePath)
            } else {
                logger.warn(
                    "WARNING: Keystore properties incomplete. " +
                        "Build will fail if signing is required."
                )
                logger.warn(
                    "Ensure all properties are set in android/key.properties"
                )
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}