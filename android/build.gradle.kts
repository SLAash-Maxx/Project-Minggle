plugins {
    // Keep this as 8.11.1
    id("com.android.application") version "8.11.1" apply false
    
    // Change 1.8.22 to 2.2.20 as requested by the error
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    
    // Keep this as 4.4.0
    id("com.google.gms.google-services") version "4.4.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Fix namespace issue for google_ml_kit and other legacy library modules
    afterEvaluate {
        if (pluginManager.hasPlugin("com.android.library")) {
            val androidExtension = extensions.findByName("android")
            if (androidExtension is com.android.build.gradle.LibraryExtension) {
                if (androidExtension.namespace == null) {
                    // Assign namespace based on project name
                    androidExtension.namespace = when {
                        project.name.contains("google_ml_kit") -> "com.b.biradar.google_ml_kit"
                        else -> "com.minggle.lib.${project.name.replace("-", "").replace("_", "")}"
                    }
                }
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
