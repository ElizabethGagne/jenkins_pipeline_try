microservices {
  consumer_data_starter {
    url = 'https://github.com/ElizabethGagne/jenkins_pipeline_try.git'
    branch = 'master'
    group = 'starter'
    scriptfile = 'Jenkinsfile'
    description = 'base component for consumer'
    downstreams = 'consumer_web'
  }
  saml_starter {
    url = 'https://github.com/tek-mayo-jaguar/jaguar-saml-starter.git'
    branch = 'develop'
    group = 'starter'
    scriptfile = 'Jenkinsfile2'
    description = 'saml starter'
    downstreams = ''
  }
}
