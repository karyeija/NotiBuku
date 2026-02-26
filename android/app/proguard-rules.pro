# Flutter app-specific obfuscation rules

# Keep Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Suppress warnings for Play Core classes not included in this build
# (Flutter references them for deferred components, but they're optional)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom application classes
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends androidx.recyclerview.widget.RecyclerView
-keep public class * extends androidx.fragment.app.Fragment

# Keep view constructors for inflation from XML
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

# Keep enum values (required for reflection)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Preserve line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Preserve BuildConfig
-keep class **.BuildConfig { *; }

# Keep R classes
-keep class **.R$* {
    public static <fields>;
}

# Remove logging in release build for better APK size
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
