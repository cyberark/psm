pipeline {
  agent {
    node {
      label 'ansible'
    }
  }
  stages {
    stage('Install required libraries for testing environment') {
      steps {
        sh 'sudo yum install -y jq'
      }
    }
    stage('Install virtual environment') {
      steps {
        sh '''
            python -m pip install --user virtualenv
            python -m virtualenv --no-site-packages .testenv
            source ./.testenv/bin/activate
            .testenv/bin/pip install -r tests/requirements.txt --no-cache-dir
        '''
      }
    }
    stage('ansible-lint validation') {
      steps {
        sh '.testenv/bin/ansible-lint tasks/* defaults/* meta/*'
      }
    }
    stage('yamllint validation') {
      steps {
        sh '.testenv/bin/yamllint .'
      }
    }
    stage('Install kitchen environment') {
      steps {
        sh '''
            rpm -qa | grep -qw chefdk-3.6.57-1.el7.x86_64 || sudo yum install -y https://packages.chef.io/files/stable/chefdk/3.6.57/el/7/chefdk-3.6.57-1.el7.x86_64.rpm
            chef gem install "winrm"
            chef gem install "winrm-fs"
            chef gem install "kitchen-ansible"
            chef gem install "kitchen-pester"
        '''
      }
    }
    stage('Provision testing environment') {
      steps {
        sh 'kitchen create'
      }
    }
    stage('Update hosts file') {
      steps {
        sh '''
            export AWS_DEFAULT_REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
            chmod +x tests/inventory/ec2.py
            ansible-inventory -i tests/inventory/ec2.py --list tag_kitchen_type_windows --export -y > ./tests/inventory/hosts
        '''
      }
    }
    stage('Run playbook on windows machine') {
      steps {
        sh 'kitchen converge'
      }
    }
    stage('Run pester tests') {
      steps {
        sh 'kitchen verify'
      }
    }
  }
  post {
    always {
      sh 'kitchen destroy'
    }
  } 
}
