plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.u_teen"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.u_teen"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
        
        ndk {
            abiFilters.addAll(setOf("armeabi-v7a", "arm64-v8a", "x86_64"))
        }
    }

    buildTypes {
        getByName("debug") {
            isDebuggable = true
            isJniDebuggable = true
        }
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    packagingOptions {
        resources.excludes.addAll(
            setOf(
                "/META-INF/{AL2.0,LGPL2.1}",
                "**/kotlin/**",
                "**/DebugProbesKt.bin"
            )
        )
    }

    buildFeatures {
        buildConfig = true
        viewBinding = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
}