# ==============================================================================
# WUA Mobile — ProGuard / R8 Configuration Rules
# ==============================================================================

# ── Flutter Engine & Core ─────────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Preserve Flutter generated registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# ── Flutter Secure Storage ────────────────────────────────────────────────────
# Preserves native Android Keystore and EncryptedSharedPreferences bindings
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# ── SharedPreferences & Native KeyStore ───────────────────────────────────────
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# ── Network & Connectivity (connectivity_plus) ────────────────────────────────
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# ── Retain Stack Traces and Annotations for Crash Telemetry ──────────────────
# Essential for de-obfuscating crash logs with line numbers intact
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses,EnclosingMethod

# Suppress known harmless warnings from third-party libraries
-dontwarn okio.**
-dontwarn javax.annotation.**
