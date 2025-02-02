def registry = 'https://trialyjhrvn.jfrog.io'
def imageName = 'trialyjhrvn.jfrog.io/tttrend-docker-local/tttrend'
def version   = '2.1.3'
pipeline {
    agent any
environment {
    PATH = "/opt/apache-maven-3.9.9/bin:$PATH"
    KUBECONFIG = "/var/lib/jenkins/.kube/config"
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
        stage("Jar Publish") {
            steps {
                script {
                    echo '<--------------- Jar Publish Started --------------->'
                     def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"jfrog-cred"
                     def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                     def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "jarstaging/(*)",
                              "target": "tttrend-libs-release-local/{1}",
                              "flat": "false",
                              "props" : "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
                     def buildInfo = server.upload(uploadSpec)
                     buildInfo.env.collect()
                     server.publishBuildInfo(buildInfo)
                     echo '<--------------- Jar Publish Ended --------------->'  
            
            }
        }   
    }
        stage(" Docker Build ") {
          steps {
            script {
               echo '<--------------- Docker Build Started --------------->'
               app = docker.build(imageName+":"+version)
               echo '<--------------- Docker Build Ends --------------->'
        }
      }
    }

        stage (" Docker Publish "){
            steps {
                script {
                   echo '<--------------- Docker Publish Started --------------->'  
                    docker.withRegistry(registry, 'jfrog-cred'){
                    app.push()
                }    
               echo '<--------------- Docker Publish Ended --------------->'  
            }
        }
    }
        stage('Setup kubeconfig') {
            steps {
                sh '''
                    rm -rf ~/.kube
                    mkdir -p ~/.kube
                    aws eks --region us-east-1 update-kubeconfig --name valaxy-eks-01
                '''
            }
        }
        
        stage("Deploy to Kubernetes") {
    steps {
        script {
            echo '<--------------- Deploying to Kubernetes --------------->'
            sh '''
            chmod +x deploy.sh
            ./deploy.sh
            '''
            echo '<--------------- Deployment Completed --------------->'
        }
    }
}       
}
}
