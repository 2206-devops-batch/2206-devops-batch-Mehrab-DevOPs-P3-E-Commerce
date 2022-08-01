pipeline {
    options {
        skipDefaultCheckout()
        timeout(time: 1, unit: 'HOURS')
    }
    agent none

    stages {
        stage('Verify Build Tools') {
            agent { label 'build-agent' }
            steps {
                sh '''
                echo 'Verify Our Build Tools'
                docker version
                docker info
                docker compose version
                curl --version
                jq --version
                '''
            }
        }
        stage('Verify Deploy Tools') {
            agent { label 'deploy-agent' }
            steps {
                sh '''
                echo 'Verify Our Deployment Tools'
                docker version
                docker info
                docker compose version
                curl --version
                jq --version
                '''
            }
        }
    }
}
