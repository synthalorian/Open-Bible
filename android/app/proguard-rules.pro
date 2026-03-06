# ProGuard rules for Open Bible App

# Keep Hive classes
-keep class com.hivedb.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Flutter TTS
-keep class com.tundralabs.fluttertts.** { *; }

# Keep SharedPreferences
-keep class android.content.SharedPreferences { *; }

# Keep application class
-keep class app.openbible.** { *; }

# Keep all model classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Prevent obfuscation of platform channel code
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Flutter plugin registrant
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Play Core (for deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep path provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Keep shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep local notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep workmanager
-keep class be.tramckrijte.workmanager.** { *; }
