pipeline {
  agent { label 'file-uploading-ecs' }

  environment {
    AWS_REGION = "ap-south-1"
    ECR_REPO = "file-upload-app"
    ACCOUNT_ID = "123456789012"   // change this
    IMAGE_TAG = "${BUILD_NUMBER}"
    ECR_URI = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('ECR Login') {
      steps {
        sh '''
          aws ecr get-login-password --region $AWS_REGION \
          | docker login --username AWS --password-stdin $ECR_URI
        '''
      }
    }

    stage('Pull Previous Image (Cache)') {
      steps {
        sh '''
          docker pull $ECR_URI/$ECR_REPO:latest || true
        '''
      }
    }

    stage('Build Image (Multi-stage + Cache)') {
      steps {
        sh '''
          docker build \
          --cache-from $ECR_URI/$ECR_REPO:latest \
          -t $ECR_REPO:$IMAGE_TAG \
          -t $ECR_REPO:latest .
        '''
      }
    }

    stage('Tag Image') {
      steps {
        sh '''
          docker tag $ECR_REPO:$IMAGE_TAG $ECR_URI/$ECR_REPO:$IMAGE_TAG
          docker tag $ECR_REPO:latest $ECR_URI/$ECR_REPO:latest
        '''
      }
    }

    stage('Push to ECR') {
      steps {
        sh '''
          docker push $ECR_URI/$ECR_REPO:$IMAGE_TAG
          docker push $ECR_URI/$ECR_REPO:latest
        '''
      }
    }
  }

  post {
    always {
      sh 'docker system prune -f'
    }
  }
}
