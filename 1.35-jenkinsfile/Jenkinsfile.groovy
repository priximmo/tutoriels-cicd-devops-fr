
node(){
  try{
    def buildNum = env.BUILD_NUMBER
    def branchName= env.BRANCH_NAME
    
    print branchName

    stage('Env - generator'){
      git "http://gitlab.example.com/xavki/generator.git"
    }

    stage('Env - run postgres'){
      sh "./generator.sh -p"
      sh "docker ps -a"
      
    }

  } finally {
    cleanWs()
  }
}



