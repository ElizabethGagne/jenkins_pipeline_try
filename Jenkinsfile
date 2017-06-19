// in this array we'll place the jobs that we wish to run
def branches = [:]

for (int i = 0; i < 1; i++) {
  def index = i
  branches["branch${i}"] = {
    build job: 'consumer_web', parameters: [[$class: 'StringParameterValue', name: 'PARAM1', value:
      'test1_param'], [$class: 'StringParameterValue', name:'PARAM2', value: 'test2_param'],
      [$class: 'StringParameterValue', name:'PARAM3', value: 'test3_param']]
    }
}


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