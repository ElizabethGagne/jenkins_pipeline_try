microservices {
  parent {
    url = 'https://github.com/tek-mayo-jaguar/jaguar-parent.git'
    project = 'tek-mayo-jaguar/jaguar-parent'
    credId = 'GitHub_Account_Creds'
    pipeline_type = 'build'
    group = 'starter'
    script_file = 'Jenkinsfile3'
    description = 'parent for starters build pipeline'
    downstreams = 'saml_starter'
  }
  saml-starter {
    url = 'https://github.com/tek-mayo-jaguar/jaguar-saml-starter.git'
    project = 'tek-mayo-jaguar/jaguar-saml-starter'
    credId = 'GitHub_Account_Creds'
    pipeline_type = 'build'
    group = 'starter'
    script_file = 'Jenkinsfile2'
    description = 'saml starter build pipeline'
    downstreams = ''
  }
  consumer-web-qa {
    pipeline_type = 'deploy'
    group = 'webapp'
    environment = 'qa'
    script_file = 'Jenkinsfile4'
    description = 'consumer webapp qa deployement pipeline'
    maven {
        group = 'edu.mayo.jaguar'
        artifact = 'jaguar-saml-starter'
        extension = 'jar'
        version = '1.0.1-SNAPSHOT'
    }
  }
}
