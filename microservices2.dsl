microservices {
  consumer_data_starter {
    url = 'https://github.com/ElizabethGagne/jenkins_pipeline_try.git'
    branch = 'master'
    group = 'starter'
    scriptfile = 'Jenkinsfile'
    description = 'base component for consumer'
    downstreams = [ 'consumer_web' ]
  }
  consumer_web {
    url = 'https://github.com/ElizabethGagne/jenkins_pipeline_try.git'
    branch = 'master'
    group = 'webapp'
    scriptfile = 'Jenkinsfile2'
    description = 'consumer web app'
    downstreams = [ ]
  }
}
