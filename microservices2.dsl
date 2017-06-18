microservices {
  consumer-data-starter {
    url = 'https://github.com/ElizabethGagne/jenkins_pipeline_try.git'
    branch = 'master'
    group = 'starter'
    downstreams = [ 'consumer-web' ]
    scriptfile = 'Jenkinsfile'
    description = 'base component for consumer'
  }
  consumer-web {
    url = 'https://github.com/ElizabethGagne/jenkins_pipeline_try.git'
    branch = 'master'
    group = 'webapp'
    scriptfile = 'Jenkinsfile2'
    description = 'consumer web app'
    downstreams = [ ]
  }
}
