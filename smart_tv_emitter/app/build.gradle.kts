plugins {
    alias(libs.plugins.androidApplication)
    alias(libs.plugins.jetbrainsKotlinAndroid)
}

android {
    namespace = "com.devjmestrada.smarttvemitter"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.devjmestrada.smarttvemitter"
        minSdk = 28
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        buildConfigField("long", "TIME_SHOW_IMG_MOD_MS", "150")
        buildConfigField("long", "FREQUENCY_MS", "1000")

    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
    buildFeatures {
        buildConfig = true
    }
}

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)

}