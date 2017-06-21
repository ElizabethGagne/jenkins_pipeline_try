def slurper = new ConfigSlurper()
// fix classloader problem using ConfigSlurper in job dsl
slurper.classLoader = this.class.classLoader
def config = slurper.parse(readFileFromWorkspace('microservices2.dsl'))


// create job for every microservice
config.microservices.each { name, data ->
  createPipelineJob(name,data)
}

def microservicesByGroup = config.microservices.groupBy { name,data -> data.group }

// create nested build pipeline view
nestedView('Build Pipeline') {
   description('Shows the service build pipelines')
   columns {
      status()
      weather()
   }
   views {
      microservicesByGroup.each { group, services ->
         def service_names_list = services.keySet() as List
         def innerNestedView = delegate
         innerNestedView.listView(group) {
            description('Shows the service build pipelines')
            columns {
                status()
                weather()
                name()
                lastSuccess()
                lastFailure()
                lastDuration()
                buildButton()
            }
            jobs {
               service_names_list.each{service_name ->
                 name(service_name)
               }
            }
         }
      }
   }
}


def createPipelineJob(name, data ) {
    pipelineJob(name) {
        println "creating pipeline job ${name} with description " + data.description
        description(data.description)

        scm {
            git {
                remote {
                  url(data.url)
                  credentials('GitHub_Account_Creds')
                }
                branch(data.branch)
            }
        }

        triggers {
            scm('H/10 * * * *')
        }
        concurrentBuild(false)

        parameters {
            stringParam('GIT_URL', data.url, 'Git Url of the project to build')
            stringParam('GIT_BRANCH', data.branch, 'Git Branch to pick')
            stringParam('DOWNSTREAMS' , data.downstreams, 'Comma Separated List of Downstream Jobs To Trigger')
            activeChoiceParam('CHOICE1') {
                description('Allows user choose from multiple choices')
                filterable()
                choiceType('SINGLE_SELECT')
                groovyScript {
                    script('')
                    fallbackScript('')
                }
            }
        }

        def runScript = readFileFromWorkspace(data.scriptfile)
        def commonScript = readFileFromWorkspace('common.groovy')

        definition {
            cps {
                script(runScript + commonScript)
            }
        }
    }
}


