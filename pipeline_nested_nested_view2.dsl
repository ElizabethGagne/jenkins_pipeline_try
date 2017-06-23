import jenkins.model.*

def slurper = new ConfigSlurper()
// fix classloader problem using ConfigSlurper in job dsl
slurper.classLoader = this.class.classLoader
def config = slurper.parse(readFileFromWorkspace('microservices2.dsl'))
def jenkins_config = slurper.parse(readFileFromWorkspace('config.dsl'))
def folder = jenkins_config.jenkins.folder.name

// create jobs and views for the microservices
def microservicesByPipelineType = config.microservices.groupBy { name, data -> data.pipeline_type }
microservicesByPipelineType.each { type, services ->
    if (type == 'build') {

         def jobsForEachService = [:]

         // create jobs for every microservices/branches
         services.each { name, data ->
            jobsForEachService[name] = createBuildPipelineJobsForAllBranches(name, data)
         }

         // create view by services group
         def microservicesByGroup = services.groupBy { name,data -> data.group }
         createViewPerService(folder + '/Build Pipeline', 'Shows the service build pipelines', microservicesByGroup, jobsForEachService)
    } else {

        // create job for every microservices
        services.each { name, data ->
            createDeployPipelineJob(name, data)
        }

        // create view by services environment
        def microservicesByGroup = services.groupBy { name,data -> data.environment }
        createViewPerEnvironment(folder + '/Deploy Pipeline', 'Shows the service deploy pipelines', microservicesByGroup)
    }
}


def getCredentials(credId) {
    def creds = com.cloudbees.plugins.credentials.CredentialsProvider.lookupCredentials(
      com.cloudbees.plugins.credentials.common.StandardUsernameCredentials.class,
      Jenkins.instance,
      null,
      null
    );

    def username = ""
    def password = ""

    for (c in creds) {
      if (c.id == credId) {
        username = c.username
        password = c.password
      }
    }

    return [username,password]
}

def getAllBranchesForRepo(credId, project) {
    def branches = []

    (username,password) = getCredentials(credId)

    def pattern = "(develop|master|.*iteration.*)"
    def process = "git ls-remote --heads https://${username}:${password}@github.com/${project}".execute()
    process.text.eachLine {
      def branch = it.split(/refs\/heads\//)[1]

      if (branch ==~ ~pattern) {
        branches << branch
      }
    }
    return branches.toList()
}

def createBuildPipelineJobsForAllBranches(name, data) {
    def jobNames = []
    def result = getAllBranchesForRepo(data.git.credId, data.git.project)
    result.each{ branchName ->
        def jobName = "${name}-${branchName}".replaceAll('/','-')
        jobNames << jobName
        createBuildPipelineJob(jobName,branchName, data)
    }
    return jobNames
}

def createViewPerEnvironment(viewName, viewDescription, microservicesByGroup) {
    nestedView(viewName) {
       description(viewDescription)
       columns {
          status()
          weather()
       }
       views {
          microservicesByGroup.each { group, services ->
             def service_names_list = services.keySet() as List
             def innerNestedView = delegate
             innerNestedView.listView(group) {
                description("Shows the service '" + group + "' pipelines")
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
}

def createViewPerService(viewName, viewDescription, microservicesByGroup, jobsForEachService) {

    nestedView(viewName) {
        description(viewDescription)
        columns {
            status()
            weather()
        }
        views {
            microservicesByGroup.each { group, services ->
                def innerNestedView = delegate
                innerNestedView.nestedView(group) {
                    description("Shows the service group '" + group + "' pipelines")
                    columns {
                        status()
                        weather()
                    }
                    views {
                        def innerNestedView2 = delegate
                        services.each { service_name, data ->
                            def jobs_list = jobsForEachService[service_name]
                            innerNestedView2.listView(service_name) {
                                description("Shows the service name '" + service_name + "' pipelines")
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
                                   jobs_list.each{job_name ->
                                     name(job_name)
                                   }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

def createBuildPipelineJob(name, branchName, data ) {
    pipelineJob(data.folder + '/' + name) {
        println "creating build pipeline job ${name} with description '" + data.description + "'"
        description(data.description)

        scm {
            git {
                remote {
                  url(data.git.url)
                  credentials(data.git.credId)
                }
                branch(branchName)
            }
        }

        triggers {
            scm('H/10 * * * *')
        }
        concurrentBuild(false)

        parameters {
            stringParam('GIT_URL', data.git.url, 'Git Url of the project to build')
            stringParam('GIT_BRANCH', branchName, 'Git Branch to pick')
            stringParam('GIT_CRED_ID', data.git.credId, 'Jenkins Credentials Id used to fetch git account credentials')
            stringParam('DOWNSTREAMS' , data.downstreams, 'Comma Separated List of Downstream Services To Trigger')
        }

        def runScript = readFileFromWorkspace(data.script_file)
        def commonScript = readFileFromWorkspace('common.groovy')

        definition {
            cps {
                script(runScript + commonScript)
            }
        }
    }
}

def createDeployPipelineJob(name, data ) {
    pipelineJob(data.folder + '/' + name) {
        println "creating deploy pipeline job ${name} with description '" + data.description + "'"
        description(data.description)

        concurrentBuild(false)

        parameters {
            stringParam('MAVEN_GROUP', data.maven.group, 'Maven Artifact Group')
            stringParam('MAVEN_ARTIFACT', data.maven.artifact, 'Maven Artifact Name')
            stringParam('MAVEN_EXTENSION', data.maven.extension, 'Maven Artifact Extension')
            stringParam('MAVEN_VERSION', data.maven.version, 'Maven Artifact Version')
        }

        def runScript = readFileFromWorkspace(data.script_file)
        def commonScript = readFileFromWorkspace('common.groovy')

        definition {
            cps {
                script(runScript + commonScript)
            }
        }
    }
}