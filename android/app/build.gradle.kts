import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val requiredReleaseSigningKeys = listOf(
    "storeFile",
    "storePassword",
    "keyAlias",
    "keyPassword",
)

fun releaseSigningValue(name: String): String? =
    (keystoreProperties[name] as String?)?.trim()?.takeIf { it.isNotEmpty() }

fun releaseStoreFileCandidate(): java.io.File? {
    val configuredStoreFile = releaseSigningValue("storeFile") ?: return null
    val rootCandidate = rootProject.file(configuredStoreFile)
    return if (rootCandidate.exists()) rootCandidate else file(configuredStoreFile)
}

val releaseStoreFile = releaseStoreFileCandidate()
val releaseSigningConfigured =
    requiredReleaseSigningKeys.all { releaseSigningValue(it) != null } &&
        releaseStoreFile?.exists() == true

gradle.taskGraph.whenReady {
    val releaseTaskRequested = allTasks.any { task ->
        val taskName = task.name.lowercase()
        taskName.contains("release") &&
            (taskName.contains("assemble") ||
                taskName.contains("bundle") ||
                taskName.contains("package"))
    }

    if (releaseTaskRequested && !releaseSigningConfigured) {
        throw GradleException(
            "Missing Android release signing configuration. " +
                "Create android/key.properties with storeFile, storePassword, " +
                "keyAlias, and keyPassword; ensure storeFile points to an " +
                "existing keystore. Refusing to build Android release with " +
                "debug or unsigned signing.",
        )
    }
}

android {
    lint {
        checkReleaseBuilds = true
        abortOnError = true
    }

    namespace = "com.flowai.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
                isCoreLibraryDesugaringEnabled = true
sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.flowai.app"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseSigningConfigured) {
                keyAlias = releaseSigningValue("keyAlias")
                keyPassword = releaseSigningValue("keyPassword")
                storePassword = releaseSigningValue("storePassword")
                storeFile = releaseStoreFile
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.tensorflow:tensorflow-lite-gpu:2.14.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
