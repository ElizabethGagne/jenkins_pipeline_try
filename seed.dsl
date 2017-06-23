import jenkins.model.*

def slurper = new ConfigSlurper()
// fix classloader problem using ConfigSlurper in job dsl
slurper.classLoader = this.class.classLoader
def config = slurper.parse(readFileFromWorkspace('config.dsl'))

folder(config.jenkins.folder.name) {
    description(config.jenkins.folder.description)
}

job(config.jenkins.folder.name + "/seed") {

    logRotator {
        numToKeep(10)
        artifactNumToKeep(10)
    }
    scm {
        git{
            remote {
                url(config.jenkins.seed.gitUrl)
            }
            branch('master')
        }
    }
    triggers {
        cron '*/10 * * * *'
    }
    steps {
        dsl {
            external('pipeline_nested_nested_view2.dsl')
            additionalClasspath('src/main/groovy')
            removeAction('DELETE')
            removeViewAction('DELETE')
        }
    }
}