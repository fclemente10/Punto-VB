# Regras para javax.annotation
-dontwarn javax.annotation.**
-keep interface javax.annotation.* { *; }
-keep class javax.annotation.* { *; }

# Regras para anotações de concorrência
-keep class javax.annotation.concurrent.* { *; }
-dontwarn javax.annotation.concurrent.**

# Regras para anotações do Tink
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Regras para Error Prone
-dontwarn com.google.errorprone.annotations.**
-keep @interface com.google.errorprone.annotations.* { *; }
-keep class com.google.errorprone.annotations.* { *; }

# Regras gerais de manutenção
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable