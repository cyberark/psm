pipeline {
  agent {
    node {
      label 'ansible'
    }
  }
  stages {
    stage('Install virtual environment') {
      steps {
        script {
          sh(script: 'python -m pip install --user virtualenv')
          sh(script: 'python -m virtualenv --no-site-packages .testenv')
          sh(script: 'source ./.testenv/bin/activate')
          sh(script: '.testenv/bin/pip install -r tests/requirements.txt --no-cache-dir')
        }
      }
    }
    stage('ansible-lint validation') {
      steps {
        script {
          sh(script: ".testenv/bin/ansible-lint tasks/* defaults/* meta/*", returnStdout: true)
        }
      }
    }
    stage('yamllint validation') {
      steps {
        script {
          sh(script: ".testenv/bin/yamllint .", returnStdout: true)
        }
      }
    }
    stage('Install kitchen environment') {
      steps {
        script {
          sh(script: 'sudo yum install -y https://packages.chef.io/files/stable/chefdk/3.6.57/el/7/chefdk-3.6.57-1.el7.x86_64.rpm')
          sh(script: 'chef gem install "winrm"')
          sh(script: 'chef gem install "winrm-fs"')
          sh(script: 'chef gem install "kitchen-ansible"')
          sh(script: 'chef gem install "kitchen-pester"')
        }
      }
    }
    stage('Provision testing environment') {
      steps {
        script {
          sh(script: "kitchen create", returnStdout: true)
        }
      }
    }
    stage('Update hosts file') {
      steps {
        script {
          sh(script: "cd tests && ./inventory/generate_inventory.sh && cd ..", returnStdout: true)
        }
      }
    }
    stage('Run playbook on windows machine') {
      steps {
        script {
          sh(script: "kitchen converge", returnStdout: true)
        }
      }
    }
    stage('Run pester tests') {
      steps {
        script {
          sh(script: "kitchen verify", returnStdout: true)
        }
      }
    }
  }
}
