import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}
// 릴리스 서명에 필요한 네 가지 키가 모두 채워졌는지 확인
val hasReleaseKeystore = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
    .all { !keystoreProperties.getProperty(it).isNullOrBlank() }

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle 플러그인은 Android/Kotlin 플러그인 이후에 적용해야 함
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.bigbattery"
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
        applicationId = "com.bigbattery"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        val debug by getting
        create("release") {
            if (hasReleaseKeystore) {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            } else {
                // keystore 미지정 시 디버그 설정으로 대체해 빌드가 멈추지 않게 함
                initWith(debug)
                println("Warning: key.properties not found. Using debug signing for release builds.")
            }
        }
    }

    buildTypes {
        release {
            // 릴리스 서명 구성을 우선 사용하고 값이 없으면 디버그 설정으로 대체
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
