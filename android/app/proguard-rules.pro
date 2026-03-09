# ========================================
# COMPLETE proguard-rules.pro for NotiBuku
# Flutter + Sqflite + Riverpod + Play Store
# ========================================

# 🔥 SQFLITE / DATABASE - FIXES PLAY STORE CRASH
-keep class com.tekartik.sqflite.** { *; }
-keep class io.flutter.plugins.sqflite.** { *; }
-keep class net.sqlite3.** { *; }
-dontwarn com.tekartik.sqflite.**
-dontwarn net.sqlite3.**

# 🔥 RIVERPOD STATE MANAGEMENT
-keep class riverpod.** { *; }
-keep class hooks_riverpod.** { *; }
-keep class flutter_riverpod.** { *; }

# ========================================
# FLUTTER FRAMEWORK (Keep wrapper classes)
# ========================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# PATH PROVIDER (for app directories)
-keep class io.flutter.plugins.pathprovider.** { *; }

# ========================================
# ANDROID / PLAY CORE (Suppress warnings)
# ========================================
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.**
-dontwarn androidx.**

# ========================================
# NATIVE METHODS & REFLECTION
# ========================================
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom application classes
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends androidx.recyclerview.widget.RecyclerView.Adapter
-keep public class * extends androidx.fragment.app.Fragment

# Keep view constructors (XML inflation)
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

# Keep enum values (reflection)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ========================================
# DEBUG & R CLASS PRESERVATION
# ========================================
# Preserve line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable,Signature
-renamesourcefileattribute SourceFile

# Preserve BuildConfig
-keep class **.BuildConfig { *; }

# Keep R classes
-keep class **.R {
    <fields>;
}
-keep class **.R$* {
    <fields>;
}

# ========================================
# PERFORMANCE OPTIMIZATIONS
# ========================================
# Remove logging in release (APK size -10%)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Remove test code
-dontwarn org.junit.**
-dontwarn junit.**
-dontwarn android.test.**
