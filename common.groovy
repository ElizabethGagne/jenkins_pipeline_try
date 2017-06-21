
@NonCPS
def jobs(jobRegexp) {
  Jenkins.instance.getAllItems()
         .grep { it.name ==~ ~"${jobRegexp}"  }
         .collect { [ name : it.name.toString(),
                      fullName : it.fullName.toString() ] }
}


def transformIntoStep(jobFullName) {
    // We need to wrap what we return in a Groovy closure, or else it's invoked
    // when this method is called, not when we pass it to parallel.
    // To do this, you need to wrap the code below in { }, and either return
    // that explicitly, or use { -> } syntax.
    return {
       // Job parameters can be added to this step
       build jobFullName
    }
}

// Return a map of jobs of the Downstreams that needed to be called
def getParallelStepsForDownstreamJobs(listOfDownstreamJobs) {

    def stepsForParallel = [:]
    String regexString = '(' + listOfDownstreamJobs.replaceAll(',', '|') + ')'

    j = jobs(regexString)
    for (int i=0; i < j.size(); i++) {
        stepsForParallel["${j[i].name}"] = transformIntoStep(j[i].fullName)
    }

    return stepsForParallel
}

