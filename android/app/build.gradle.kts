import java.io.FileInputStream
import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is read from android/key.properties (never committed).
// When the file is missing, release builds fall back to the debug key so
// `flutter build apk` keeps working on development machines.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Values from --dart-define / --dart-define-from-file (env/*.json) reach
// Gradle as a comma-separated list of base64 encoded KEY=VALUE pairs.
val dartDefines: Map<String, String> =
    (project.findProperty("dart-defines") as String?)
        ?.split(",")
        ?.mapNotNull { entry ->
            val pair = String(Base64.getDecoder().decode(entry), Charsets.UTF_8)
            val index = pair.indexOf('=')
            if (index <= 0) null else pair.substring(0, index) to pair.substring(index + 1)
        }
        ?.toMap()
        ?: emptyMap()

// AdMob app id for the manifest. Without ADMOB_APP_ID, Google's public test
// app id is used, which only ever serves test ads.
val admobTestAppId = "ca-app-pub-3940256099942544~3347511713"
val admobAppId = dartDefines["ADMOB_APP_ID"]?.takeIf { it.isNotBlank() } ?: admobTestAppId
if (dartDefines["ENV"] == "production" && admobAppId == admobTestAppId) {
    logger.warn("WARNING: ADMOB_APP_ID is not set for a production build; using the AdMob test app id.")
}

android {
    namespace = "com.kavodnik.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.kavodnik.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = admobAppId
    }

    signingConfigs {
        if (hasReleaseKeystore) {
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
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
