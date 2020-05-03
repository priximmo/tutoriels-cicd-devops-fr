// Define your secret project token here
def project_token = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEF'

// Reference the GitLab connection name from your Jenkins Global configuration (https://JENKINS_URL/configure, GitLab section)
properties([
    gitLabConnection('your-gitlab-connection-name'),
    pipelineTriggers([
        [
            $class: 'GitLabPushTrigger',
            branchFilterType: 'All',
            triggerOnPush: true,
            triggerOnMergeRequest: true,
            triggerOpenMergeRequestOnPush: "never",
            triggerOnNoteRequest: true,
            noteRegex: "Jenkins please retry a build",
            skipWorkInProgressMergeRequest: true,
            secretToken: project_token,
            ciSkip: false,
            setBuildDescription: true,
            addNoteOnMergeRequest: true,
            addCiMessage: true,
            addVoteOnMergeRequest: true,
            acceptMergeRequestOnSuccess: true,
            branchFilterType: "NameBasedFilter",
            includeBranchesSpec: "",
            excludeBranchesSpec: "",
        ]
    ])
])


node {
    try {

        def buildNum = env.BUILD_NUMBER
        def branchName= env.BRANCH_NAME

        stage('POSTGRESQL - Git checkout'){
        git 'http://gitlab.example.com/root/pipeline-docker-generator.git'
        }

        stage('POSTGRESQL - Container run'){
        sh "./generator.sh -pos"
        sh "docker ps -a"
        }

        stage('SERVICE - Git checkout'){
        git branch: branchName, url: 'http://gitlab.example.com/root/pipeline-myapp1.git'}
        
	/* Variables */
        def imageName='192.168.5.5:5000/first-pipeline'

        if (branchName == "dev" ){
        extension = "-SNAPSHOT"
	}
        if (branchName == "stage" ){
        extension = "-RC"
	}
        if (branchName == "master" ){
        extension = ""
	}

        def commitIdLong = sh returnStdout: true, script: 'git rev-parse HEAD'
        def commitId = commitIdLong.take(7)
        sh "sed -i s/'-XXX'/${extension}/g pom.xml"
	def version = sh returnStdout: true, script: "cat pom.xml | grep -A1 '<artifactId>myapp1' | tail -1 |perl -nle 'm{.*<version>(.*)</version>.*};print \$1' | tr -d '\n'"
        print """
	#################################################
	BanchName: $branchName
        CommitID: $commitId
        AppVersion: $version
	JobNumber: $buildNum
	ImageName: $imageName
	#################################################
	"""

        stage('SERVICE - Tests unitaires'){
        sh 'docker run --rm --name maven-${commitIdLong} -v /var/lib/jenkins/maven/:/root/.m2 -v "$(pwd)":/usr/src/mymaven --network generator_generator -w /usr/src/mymaven maven:3.3-jdk-8 mvn -B clean test'
        }

        stage('SERVICE - Jar'){
        sh 'docker run --rm --name maven${commitIdLong} -v /var/lib/jenkins/maven/:/root/.m2 -v "$(pwd)":/usr/src/mymaven --network generator_generator -w /usr/src/mymaven maven:3.3-jdk-8 mvn -B clean install'
        }

        stage('DOCKER - Build/Push registry'){
            print "$imageName:${version}-${commitId}"
            docker.withRegistry('http://192.168.5.5:5000', 'myregistry_login') {
            def customImage = docker.build("$imageName:${version}-${commitId}")
            customImage.push()
            }
            sh "docker rmi $imageName:${version}-${commitId}"
        }

        stage('DOCKER - check registry'){
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'myregistry_login',usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
             sh 'curl -sk --user $USERNAME:$PASSWORD https://192.168.5.5:5000/v2/first-pipeline/tags/list'
            }
        }

        stage('ANSIBLE - Deploy'){
        git branch: 'master', url: 'https://gitlab.com/pipeline-1/deploy-ansible.git'
        sh "mkdir roles"
        sh "sed -i '5,/old/ s/version: master/version: ${branchName}/g' requirements.yml"
        sh "ansible-galaxy install --roles-path roles -r requirements.yml"
        ansiblePlaybook (
              colorized: true,
              playbook: "install-myapp1.yml",
              credentialsId: 'ssh_vagrant',
              hostKeyChecking: false,
              inventory: "env/${branchName}/hosts",
              extras: "-e 'image=$imageName:${version}-${commitId}' -e 'version=${version}'"
              )
	}
    } finally {
        sh 'docker rm -f postgres'
        cleanWs()
    }
}

