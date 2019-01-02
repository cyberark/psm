pipeline {
  agent {
    node {
      label 'ansible'
    }
  }
  stages {
    stage('Install required libraries for testing environment') {
      steps {
        script {
          sh(script: 'sudo yum install -y jq')
        }
      }
    }
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
          sh(script: 'rpm -qa | grep -qw chefdk-3.6.57-1.el7.x86_64 || sudo yum install -y https://packages.chef.io/files/stable/chefdk/3.6.57/el/7/chefdk-3.6.57-1.el7.x86_64.rpm')
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
          sh(script: 'export AWS_DEFAULT_REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)', returnStdout: true)
          sh(script: "chmod +x tests/inventory/ec2.py", returnStdout: true)
          sh(script: 'sed -i -- "s/region_placeholder/$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)/g" tests/inventory/ec2.ini', returnStdout: true)
          sh(script: 'ansible-inventory -i tests/inventory/ec2.py --list tag_kitchen_type_windows --export -y > ./tests/inventory/hosts', returnStdout: true)
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
    stage('Destroy testing environment') {
      steps {
        script {
          sh(script: "kitchen destroy", returnStdout: true)
        }
      }
    }
  }
}
