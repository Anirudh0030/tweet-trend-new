pipeline {
    agent any
environment {
    PATH = "/opt/apache-maven-3.9.9/bin:$PATH"
}
    stages {
        stage("build"){
            steps{
                echo "---------build started------------"
                sh 'mvn clean deploy -Dmaven.test.skip=true'
                echo "---------build completed-----------"
            }
        }
        stage("test"){
            steps{
                echo "--------unit test started---------"
                sh 'mvn surefire-report:report'
                echo "--------unit tesst completed-------"
            }
        }

        stage("Sonarqube"){
        environment {
            scannerHome = tool 'vivobook-sonar-scanner';
        }
        steps{
        withSonarQubeEnv('vivobook-sonarqube-server') { // If you have configured more than one global server connection, you can specify its name
        sh "${scannerHome}/bin/sonar-scanner"   }
        }
    }
       stage("Quality Gate"){
           steps {
               script {
          timeout(time: 1, unit: 'HOURS') {
              def qg = waitForQualityGate()
              if (qg.status != 'OK') {
                  error "Pipeline aborted due to quality gate failure: ${qg.status}"
              }
          }
      }
}
}
    }
}
