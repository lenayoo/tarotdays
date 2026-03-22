import java.util.Properties
import java.io.FileInputStream
import org.gradle.api.tasks.bundling.Zip

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. 키 정보 로드 부분
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.verydays.tarotdays"
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
        applicationId = "com.verydays.tarotdays"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 2. 서명 설정 (이름을 release로 명시)
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            ndk {
                // Include full native debug metadata so Play Console can symbolicate crashes/ANRs.
                debugSymbolLevel = "FULL"
            }
            // 3. 위에서 만든 release 설정을 실제 빌드에 적용
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

val releaseNativeLibsDir = layout.buildDirectory.dir(
    "intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib"
)

val zipReleaseNativeSymbols by tasks.registering(Zip::class) {
    dependsOn("mergeReleaseNativeLibs")
    from(releaseNativeLibsDir)
    destinationDirectory.set(layout.buildDirectory.dir("outputs/native-debug-symbols/release"))
    archiveFileName.set("native-debug-symbols.zip")
    includeEmptyDirs = false
}

afterEvaluate {
    tasks.named("bundleRelease") {
        finalizedBy(zipReleaseNativeSymbols)
    }
}
