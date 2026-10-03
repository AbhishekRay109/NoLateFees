import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

// A Play Store bundle must never be signed with the public test key: the
// first upload would make it the app's upload key.
if (keystoreProperties.isEmpty() &&
    gradle.startParameter.taskNames.any { it.contains("bundleRelease", ignoreCase = true) }) {
    throw GradleException("Release bundles need android/key.properties with your upload key (see docs/RELEASE.md).")
}

android {
    namespace = "com.nolatefees.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications needs core library desugaring.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Change before the first Play Store upload; it can never change afterwards.
        applicationId = "com.nolatefees.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Real id from the ADMOB_APP_ID environment variable (set by CI from
        // env.json); otherwise Google's sample app id, which only serves test ads.
        manifestPlaceholders["admobAppId"] =
            System.getenv("ADMOB_APP_ID")?.takeIf { it.isNotBlank() } ?: "ca-app-pub-3940256099942544~3347511713"
    }

    signingConfigs {
        // Test-only key committed to the repo (password is public) so every
        // build has the same SHA-1/SHA-256, which Firebase needs for Google and
        // phone sign-in. Real Play Store releases use android/key.properties.
        create("ciTest") {
            storeFile = file("ci-test.jks")
            storePassword = "nolatefees-test"
            keyAlias = "nolatefees-test"
            keyPassword = "nolatefees-test"
        }
        if (!keystoreProperties.isEmpty()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("ciTest")
        }
        release {
            // Uses android/key.properties when present (see docs/RELEASE.md),
            // otherwise the shared test key.
            signingConfig = if (keystoreProperties.isEmpty()) signingConfigs.getByName("ciTest")
                            else signingConfigs.getByName("release")
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
