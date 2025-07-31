import com.android.build.gradle.BaseExtension
import org.gradle.api.Project

allprojects {
    repositories {
        google()
        mavenCentral()
        maven(url = "https://seeso.jfrog.io/artifactory/visualcamp-eyedid-sdk-android-release")
    }

    subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            val androidExtension = extensions.getByName("android") as BaseExtension
            if (androidExtension.namespace.isNullOrEmpty()) {
                androidExtension.namespace = project.group.toString()
            }
        }
    }
}
    
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
