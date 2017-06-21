import jenkins.model.*

pipeline {
    agent any
    parameters {
        string(name: 'Greeting', defaultValue: 'Hello', description: 'How should I greet the world?')
    }
    stages {
        stage('Example') {
            steps {
                echo "${params.Greeting} World!"
            }
        }
        stage('Trigger downstreams') {
            when {
                expression {
                    DOWNSTREAMS != null
                }
            }
            steps {
               build job: DOWNSTREAMS, parameters: [[$class: 'StringParameterValue', name: 'DOWNSTREAMS', value:
                     'test1_param'], [$class: 'StringParameterValue', name:'PARAM2', value: 'test2_param'],
                     [$class: 'StringParameterValue', name:'PARAM3', value: 'test3_param']]
            }
        }
    }
}