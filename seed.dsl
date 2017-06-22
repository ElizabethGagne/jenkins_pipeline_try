String gitUrl = 'https://github.com/ElizabethGagne/jenkins_pipeline_try.git'

job("seed") {
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