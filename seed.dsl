String gitUrl = 'https://github.com/ElizabethGagne/jenkins_pipeline_try.git'
String mainFolder = 'POC'

folder("$mainFolder") {
    description 'POC Folder'
}

job("$mainFolder/seed") {
    scm {
        git{
            remote {
                url("$gitUrl")
            }
            branch('master')
        }
    }
    triggers {
        scm 'H/5 * * * *'
    }
    steps {
        dsl {
            external('pipeline_nested_nested_view2.dsl')
            additionalClasspath('src/main/groovy')
            removeAction('DELETE')
        }
    }
}