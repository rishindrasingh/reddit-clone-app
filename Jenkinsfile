pipeline {
  agent {
    docker {
      image 'rishindra2308/maven-docker-gcloud-agent:v1'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock' // mount Docker socket to access the host's Docker daemon
    }
  }
    environment {
            PROJECT_ID = 'devopslearning-463313'
            BRANCH = 'gcp'
	    REGION = 'us-central1'
	    REPO_NAME = 'poc-repo'
	    IMAGE_NAME = "reddit-clone-app"
           // REPO_DIR = 'java-maven-sonar-argocd-helm-k8s'
	    DOCKER_IMAGE = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${BUILD_NUMBER}"
            GCP_CREDENTIALS = credentials('gcp-artifact-cred')
            GIT_REPO_NAME = "reddit-clone-app"
            GIT_USER_NAME = "rishindrasingh"
	    SONAR_URL = "http://34.131.105.151:9000"
        
    }  
  stages {
    stage('Checkout') {
      steps {
        sh 'echo passed successfull'
        //git branch: 'rishindra', url: 'https://github.com/rishindrasingh/Jenkins-Zero-To-Hero.git'
      }
    }
	
	stage('Artifact Registry Login'){
		steps{
		  script{
			sh """
			#!/bin/bash
			
			set -e
			
			GCLOUD_PROJECT='devopslearning'
			GCLOUD=/tmp/google-cloud-sdk/bin/gcloud
			
			if gcloud version 2>&1 >> /dev/null; then
				echo "GCloud SDK is already installed"
			else
				cd /tmp
				wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-373.0.0-linux-x86_64.tar.gz -O cloud-sdk.tar.gz
				tar -xzvf cloud-sdk.tar.gz
			
			fi
			"""
			withCredentials([file(credentialsId: 'gcp-artifact-cred', variable: 'saa')]) {
				sh("/tmp/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file=${saa}")
			  }
			sh "/tmp/google-cloud-sdk/bin/gcloud config set project ${PROJECT_ID}"
			sh "/tmp/google-cloud-sdk/bin/gcloud auth configure-docker us-central1-docker.pkg.dev"
			sh "/tmp/google-cloud-sdk/bin/gcloud artifacts repositories list"
			sh "ln -sf /tmp/google-cloud-sdk/bin/docker-credential-gcloud /usr/local/bin/"
			sh "ln -sf /tmp/google-cloud-sdk/bin/gcloud /usr/local/bin/"
                       // sh "/tmp/google-cloud-sdk/bin/gcloud container clusters get-credentials $CLUSTER_NAME --zone $LOCATION"
			}
			}
	
	}

        stage('Docker Image Build'){
            steps{
              script{
		       // Build and push Docker image
	         	  sh '''
				docker build -t ${DOCKER_IMAGE} .
				docker push ${DOCKER_IMAGE}
			  '''
                    }
                } 
        }
		
        stage('Update Deployment File') {
		steps {
			withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
				sh '''
					git config user.email "rishindrasingh23@gmail.com"
					git config user.name "Rishindra Singh"
					BUILD_NUMBER=${BUILD_NUMBER}
					sed -i "s|image:.*poc-repo/reddit-clone-app:.*|image: poc-repo/reddit-clone-app:${BUILD_NUMBER}|g" reddit-clone-app-manifest/deployment.yml
					git add reddit-clone-app-manifest/deployment.yml
					git commit -m "Update deployment image to version ${BUILD_NUMBER}"
					git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:${BRANCH}
					'''
				}
			}
		}

  }
}
