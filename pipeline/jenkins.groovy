pipeline {
    agent any
 environment {
 REPO = "https://github.com/srudyka/kbot"
 BRANCH = "main"
}
    parameters {
        choice(
            name: 'OS',
            choices: ['linux', 'darwin', 'windows'],
            description: 'Target operating system'
        )
        choice(
            name: 'ARCH',
            choices: ['amd64', 'arm64'],
            description: 'Target architecture'
        )
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Skip running tests'
        )
        booleanParam(
            name: 'SKIP_LINT',
            defaultValue: false,
            description: 'Skip running linter'
        )
    }
 stages {

   stage("clone") {
     steps {
     echo 'CLONE REPOSITORY'
       git branch: "${BRANCH}", url: "${REPO}"
     }
   }
   stage("lint") {
    when {
       expression { return !params.SKIP_LINT }
    }
     steps {
      echo "TEST EXECUTION STARTED"
      sh 'make lint'
     }
   }
   stage("test") {
    when {
      expression { return !params.SKIP_TESTS }
    }       
     steps {
      echo "TEST EXECUTION STARTED"
      sh 'make test'
     }
   }

   stage("build") {
     steps {
       echo "BUILD EXECUTION STARTED"
       sh "export PATH=$PATH:/usr/local/go/bin && export GOPATH=$HOME/go && make build GITHUBACTOR=srudyka"
     }
   }
   stage("image") {
     steps {
      script {
       echo "BUILD EXECUTION STARTED"
       sh 'make image REGISTRY=docker.io/sergeyrudyka'
     }
   }
   }

   stage("push") {
     steps {
       script {
         docker.withRegistry('', "dockerhub" ) {
         sh 'make push REGISTRY=docker.io/sergeyrudyka'
       }
     }
   }
}

}
 post {
        always {
            echo "Pipeline finished. Cleaning workspace."
            sh 'make clean'
        }
        success {
            echo "Pipeline succeeded."
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
