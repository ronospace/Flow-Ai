plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.flowai.app"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.flowai.app"
        minSdk = flutter.minSdkVersion  // Support Android 5.0 and above
        targetSdk = flutter.targetSdkVersion  // Updated target SDK for latest Play Store requirements
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Add multiDex support for large apps
        multiDexEnabled = true
        
        // Vector drawables support
        vectorDrawables.useSupportLibrary = true
        
        // Add test instrumentation runner
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            // Enable optimization for production builds
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            // Production signing - replace with actual keystore for App Store release
            signingConfig = signingConfigs.getByName("debug")
            
            // Optimize for production
            isDebuggable = false
            isJniDebuggable = false
            isRenderscriptDebuggable = false
            isPseudoLocalesEnabled = false
        }
        debug {
            // Keep debug builds fast
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
            // Temporarily removed debug suffix to match Firebase config
            // applicationIdSuffix = ".debug"
        }
    }
}

flutter {
    source = "../.."
}

// Exclude duplicate Play Core Common classes from all configurations to avoid R8 duplicate class errors
configurations.configureEach {
    exclude(group = "com.google.android.play", module = "core-common")
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.2")
    implementation("com.google.android.play:core:1.10.3")
    implementation("androidx.multidex:multidex:2.0.1")
}
