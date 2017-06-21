microservices {
  parent {
    url = 'https://github.com/tek-mayo-jaguar/jaguar-parent.git'
    branch = 'develop'
    pipeline_type = 'build'
    group = 'starter'
    script_file = 'Jenkinsfile3'
    description = 'parent for starters build pipeline'
    downstreams = 'saml_starter'
  }
  saml_starter {
    url = 'https://github.com/tek-mayo-jaguar/jaguar-saml-starter.git'
    branch = 'develop'
    pipeline_type = 'build'
    group = 'starter'
    script_file = 'Jenkinsfile2'
    description = 'saml starter build pipeline'
    downstreams = ''
  }
  consumer_web_qa {
    pipeline_type = 'deploy'
    group = 'webapp'
    script_file = 'Jenkinsfile4'
    description = 'consumer webapp qa deployement pipeline'
    maven {
        group = 'edu.mayo.jaguar'
        artifact = 'jaguar-saml-starter'
        extension = 'jar'
    }
  }
}
