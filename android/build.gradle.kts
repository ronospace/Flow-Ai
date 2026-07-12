allprojects {
    repositories {
        google()
        mavenCentral()
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
val kotlin_version by extra("1.9.20")


// FLOWAI_FINAL_STRICT_NOISE_GUARD
subprojects {
    tasks.withType<JavaCompile>().configureEach {
        options.isWarnings = false
        options.isDeprecation = false
        options.compilerArgs.addAll(listOf("-Xlint:none", "-nowarn"))
    }
    tasks.matching { it.name.contains("compileReleaseKotlin") }.configureEach {
        if (this is org.jetbrains.kotlin.gradle.tasks.KotlinCompile) {
            compilerOptions.suppressWarnings.set(true)
        }
    }
}
