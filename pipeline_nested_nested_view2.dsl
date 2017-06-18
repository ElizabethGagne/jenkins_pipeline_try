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
//nestedView('Build Pipeline 2') {
//   description('Shows the service build pipelines')
//   columns {
//      status()
//      weather()
//   }
//   views {
//      microservicesByGroup.each { group, services ->
//         nestedView("${group}") {
//            description('Shows the service build pipelines')
//            columns {
//               status()
//               weather()
//            }
//            views {
//               def innerNestedView = delegate
//               services.each { name,data ->
//                  innerNestedView.buildPipelineView("${name}") {
//                     selectedJob("${name}")
//                     triggerOnlyLatestJob(true)
//                     alwaysAllowManualTrigger(true)
//                     showPipelineParameters(true)
//                     showPipelineParametersInHeaders(true)
//                     showPipelineDefinitionHeader(true)
//                     startsWithParameters(true)
//                  }
//               }
//            }
//         }
//      }
//   }
//}

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
         def s = ""
         service_names_list.collect { s += "'$it',"  }
         s = s.substring(0, s.length()-1)

         println "creating view for group ${group} with jobs " + s

         listView("${group}") {
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
                names(s)
            }
         }
      }
   }
}

//nestedView('Build Pipeline') {
//   description('Shows all microservices pipelines')
//   columns {
//      status()
//      weather()
//   }
//   views {
//        listView('starter') {
//            description('Shows the starter build pipelines')
//            columns {
//                status()
//                weather()
//                name()
//                lastSuccess()
//                lastFailure()
//                lastDuration()
//                buildButton()
//            }
//            jobs {
//                name('consumer_data_starter')
//            }
//        }
//        listView('web') {
//            description('Shows the web build pipelines')
//            columns {
//                status()
//                weather()
//                name()
//                lastSuccess()
//                lastFailure()
//                lastDuration()
//                buildButton()
//            }
//            jobs {
//                name('consumer_web')
//            }
//        }
//   }
//}

def createPipelineJob(name, data ) {
    pipelineJob("${name}") {
        println "creating pipeline job ${name} with description " + data.description
        description(data.description)

        scm {
            git {
                remote {
                  url(data.url)
                }
                branch(data.branch)
            }
        }

        triggers {
            scm('H/10 * * * *')
        }
        concurrentBuild(false)

        parameters {
            stringParam('PARAM1' , "", 'First param')
            stringParam('PARAM2', "", 'Second param')
            stringParam('PARAM3', "", 'Third param')
       }

        println "fetching file " + data.scriptfile
        def runScript = readFileFromWorkspace(data.scriptfile)

        definition {
            cps {
                script(runScript)
            }
        }

        publishers {
            downstream(data.downstreams, 'SUCCESS')
        }
    }
}

def createFreeStyleJob(name,data) {

  freeStyleJob("${name}") {

    println "creating pipeline job ${name} with for url " + data.url
    scm {
      git {
        remote {
          url(data.url)
        }
        branch(data.branch)
      }
    }

    triggers {
       scm('H/15 * * * *')
    }

    steps {
      //maven {
      //  mavenInstallation('3.1.1')
        //goals('clean install')
      //}
    }

    publishers {
      //archiveJunit('/target/surefire-reports/*.xml')
      downstream(data.downstreams, 'SUCCESS')
    }
  }

}


