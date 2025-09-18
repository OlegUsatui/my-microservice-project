pipeline {
  agent {
    kubernetes {
      label 'kaniko'
    }
  }

  options {
    timestamps()
    ansiColor('xterm')
  }

  environment {
    AWS_REGION   = 'eu-central-1'
    ECR_ACCOUNT  = '598357935226'
    ECR_REPO     = 'django-app'
    ECR_REGISTRY = "${ECR_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"

  GITOPS_REPO   = 'git@github.com:OlegUsatui/my-django-gitops.git'
  GITOPS_BRANCH = 'main'
  GITOPS_PATH   = 'charts/django-app/values.yaml'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Prepare tag') {
      steps {
        script {
          GIT_COMMIT_SHORT = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
          env.IMAGE_TAG = "${GIT_COMMIT_SHORT}-${env.BUILD_NUMBER}"
          echo "IMAGE_TAG=${env.IMAGE_TAG}"
        }
      }
    }

    stage('Build & Push to ECR') {
      steps {
        container('kaniko') {
          withCredentials([usernamePassword(credentialsId: 'aws-ecr-creds',
                                            usernameVariable: 'AWS_ACCESS_KEY_ID',
                                            passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
            sh '''
set -euo pipefail

/kaniko/executor \
  --context `pwd` \
  --dockerfile Dockerfile \
  --destination ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG} \
  --cache=true
'''
          }
        }
      }
    }

    stage('Update GitOps values.yaml') {
      steps {
        container('kaniko') {
          sshagent (credentials: ['gitops-deploy-key']) {
            sh '''
set -euo pipefail

rm -rf gitops && git clone --branch ${GITOPS_BRANCH} ${GITOPS_REPO} gitops
cd gitops

# Якщо є yq, краще так:
if command -v yq >/dev/null 2>&1; then
  yq -i '.image.tag = env(IMAGE_TAG)' ${GITOPS_PATH}
else
  sed -ri "s#^(\\s*tag:\\s*).*$#\\1\\\"${IMAGE_TAG}\\\"#g" ${GITOPS_PATH}
fi

git config user.name "jenkins"
git config user.email "jenkins@local"
git add ${GITOPS_PATH}
git commit -m "ci: bump django image tag to ${IMAGE_TAG}"
git push origin ${GITOPS_BRANCH}
'''
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Built and pushed ${ECR_REPO}:${IMAGE_TAG}, updated GitOps values.yaml"
    }
    failure {
      echo "❌ Pipeline failed"
    }
  }
}
