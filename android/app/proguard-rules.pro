# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Sign In
-keep class com.google.android.gms.auth.** { *; }

# AdMob
-keep class com.google.android.gms.ads.** { *; }

# Google Play Core (Deferred components / SplitInstall)
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

# Local Auth / Biometrics
-keep class androidx.biometric.** { *; }

# Health Integration
-keep class androidx.health.** { *; }

# TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.**

# Machine Learning (if using ML Kit or TensorFlow Lite)
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.tflite.** { *; }
-dontwarn com.google.mlkit.**

# Uncomment this to preserve the line number information for
# debugging stack traces.
-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
-renamesourcefileattribute SourceFile

# Keep Dart VM service related classes
-keep class io.flutter.plugins.** { *; }

# Keep annotation default values (e.g., retrofit2.http.Field.encoded)
-keepattributes AnnotationDefault

# Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items).
-keep,allowshrinking,allowobfuscation interface retrofit2.Call
-keep,allowshrinking,allowobfuscation class retrofit2.Response

# With R8 full mode generic signatures are stripped for classes that are not
# kept. Suspend functions are wrapped in continuations where the type argument
# is used.
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation
