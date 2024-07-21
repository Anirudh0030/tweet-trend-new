pipeline {
    agent {
        node {
            label 'maven'
        }
    }
environment {
    PATH = "/opt/apache-maven-3.9.8/bin:$PATH"
}
    stages {
        stage("build"){
            steps{
                sh 'mvn clean deploy'
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
}
}
