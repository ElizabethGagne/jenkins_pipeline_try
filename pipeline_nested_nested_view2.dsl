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
            data.downstreams.each { nextjob ->
              downstream("${nextjob}", 'SUCCESS')
           }
        }
    }
}

//def createPipelineJob(name, data ) {

//    pipelineJob("${name}") {
//        description("${data.description}")

//        scm {
//            git {
//                remote {
//                  url(data.url)
//                }
//                branch(data.branch)
//            }
//        }

//        triggers {
//            scm('H/10 * * * *')
//        }
//        concurrentBuild(false)

//        parameters {
//            stringParam('PARAM1' , "", 'First param')
//            stringParam('PARAM2', "", 'Second param')
//            stringParam('PARAM3', "", 'Third param')
//       }

//        def runScript = readFileFromWorkspace(data.scriptfile)

//        definition {
//            cps {
//                script(runScript)
//            }
//        }

//        publishers {
//            data.downstreams.each { nextjob ->
//              downstream("${nextjob}", 'SUCCESS')
//           }
//        }
//    }
//}


