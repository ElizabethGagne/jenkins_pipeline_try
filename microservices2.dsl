microservices {
  parent {
    url = 'https://github.com/tek-mayo-jaguar/jaguar-parent.git'
    branch = 'develop'
    group = 'starter'
    scriptfile = 'Jenkinsfile3'
    description = 'parent for every starters'
    downstreams = 'saml_starter'
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
