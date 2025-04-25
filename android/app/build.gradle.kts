plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.jornada_punto_con"
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
        applicationId = "com.example.jornada_punto_con"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Adicione estas dependências
    implementation("com.google.errorprone:error_prone_annotations:2.19.1")
    implementation("javax.annotation:javax.annotation-api:1.3.2")
    implementation("org.jetbrains:annotations:24.0.1")
    implementation("com.google.code.findbugs:jsr305:3.0.2")
}

flutter {
    source = "../.."
}