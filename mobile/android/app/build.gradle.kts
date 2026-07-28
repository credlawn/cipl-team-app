import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.credlawn.cipl"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.credlawn.cipl"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                val storeFilePath = keystoreProperties.getProperty("storeFile")
                if (storeFilePath != null) {
                    storeFile = rootProject.file(storeFilePath)
                }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.findByName("release")
            if (releaseConfig?.storeFile?.exists() == true) {
                signingConfig = releaseConfig
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    // ── 16 KB page-size compatibility ─────────────────────────────────────────
    // useLegacyPackaging=false is required so the OS can mmap .so files directly
    // from the APK at 16 KB page-aligned offsets (Android 15+).
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }

}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.exifinterface:exifinterface:1.3.7")

    val cameraxVersion = "1.3.1"
    implementation("androidx.camera:camera-core:${cameraxVersion}")
    implementation("androidx.camera:camera-camera2:${cameraxVersion}")
    implementation("androidx.camera:camera-lifecycle:${cameraxVersion}")
    implementation("androidx.camera:camera-view:${cameraxVersion}")
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

// ── 16 KB ELF alignment post-processor ────────────────────────────────────────
//
// google_mlkit_text_recognition ships libimage_processing_util_jni.so with
// p_align=0x1000 (4 KB). Android 16 (API 36) enforces 16 KB alignment on
// all LOAD segments. We re-align the binary after mergeNativeLibs using a
// Python script that rebuilds the ELF with properly aligned segments.
//
// libVkLayer_khronos_validation.so is a Vulkan validation layer only needed
// in debug builds — we exclude it entirely from release APKs.
// ─────────────────────────────────────────────────────────────────────────────

// rootProject.projectDir = android/ directory
val alignScript = rootProject.file("scripts/align_elf_16k.py").absolutePath

// Libraries that need 16 KB re-alignment (add more if a new plugin regresses)
val soFilesToAlign = listOf("libimage_processing_util_jni.so")

androidComponents {
    onVariants { variant ->
        val variantNameCapitalized = variant.name
            .replaceFirstChar { it.uppercaseChar() }

        // ── Exclude VkLayer from release builds only ───────────────────────
        if (variant.name == "release") {
            variant.packaging.jniLibs.excludes.add("**/libVkLayer_khronos_validation.so")
        }

        // ── Re-align 4 KB-aligned .so files after merge ────────────────────
        val mergeTaskName = "merge${variantNameCapitalized}NativeLibs"

        project.tasks.matching { it.name == mergeTaskName }.configureEach {
            doLast {
                val outDir = project.layout.buildDirectory
                    .dir("intermediates/merged_native_libs/${variant.name}/merge${variantNameCapitalized}NativeLibs/out/lib")
                    .get().asFile

                if (!outDir.exists()) return@doLast

                outDir.walkTopDown()
                    .filter { it.isFile && it.name in soFilesToAlign }
                    .forEach { soFile ->
                        logger.lifecycle("[16KB-align] Processing ${soFile.name} (${soFile.parentFile.name})")
                        val result = exec {
                            commandLine(
                                "python3", alignScript,
                                soFile.absolutePath,
                                soFile.absolutePath   // in-place
                            )
                            isIgnoreExitValue = true
                        }
                        when (result.exitValue) {
                            0    -> logger.lifecycle("[16KB-align] ✓ ${soFile.name} re-aligned successfully")
                            2    -> logger.lifecycle("[16KB-align] ✓ ${soFile.name} already aligned, skipped")
                            else -> logger.error("[16KB-align] ✗ Failed to align ${soFile.name}")
                        }
                    }
            }
        }
    }
}
