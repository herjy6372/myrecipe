import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasKeystoreProperties = keystorePropertiesFile.exists()
if (hasKeystoreProperties) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.terablack.myrecipe"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.terablack.myrecipe"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasKeystoreProperties) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // key.properties가 없으면 release 빌드를 debug 키로 조용히 서명하지 않고 실패시킨다.
            // debug 서명된 release APK는 Play 심사에서 거부되거나 공개된 debug 키로 배포될 수 있다.
            // CI에서 서명 없이 임시로 빌드해야 한다면 -PallowDebugSigning 옵션을 명시적으로 추가한다.
            signingConfig = if (hasKeystoreProperties) {
                signingConfigs.getByName("release")
            } else if (project.hasProperty("allowDebugSigning")) {
                signingConfigs.getByName("debug")
            } else {
                throw GradleException(
                    "android/key.properties가 없습니다. release 빌드는 서명 키가 필요합니다. " +
                        "debug 키로 임시 빌드하려면 -PallowDebugSigning 옵션을 추가하세요."
                )
            }
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
