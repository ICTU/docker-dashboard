pipeline {
    agent {
      label 'build-slave-1'
    }
    parameters {
      string(name: 'TARGET_URL', defaultValue: 'http://www.dashboard.acc.ictu', description: 'The base URL of the BigBoat instance under test')
    }
    stages {
        stage('NPM install') {
            steps {
                ansiColor('xterm') {
                    sh 'docker run --rm -v \$(pwd):/work -w /work -u \$(id -u):\$(id -g) greyarch/nocker npm i --only=dev'
                }
            }
        }
        stage('Run ART') {
            steps {
                ansiColor('xterm') {
                    sh "docker run --rm -t -v \$(pwd):/work -w /work --net=host -v /var/run/docker.sock:/var/run/docker.sock greyarch/nocker npm run art -- --baseUrl=${TARGET_URL}"
                }
            }
        }
    }
    post {
      always {
        archiveArtifacts artifacts: 'tests/results/'
      }
      failure {
        sh 'docker kill bigboat-art-selenium-server'
      }
    }
}
