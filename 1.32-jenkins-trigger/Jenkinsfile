def project_token = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEF'

properties([
    gitLabConnection('si_connection'),
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


node{
    cleanWs()
    try{
        stage('PremiereEtape'){
            sh "echo 'Hello World !!'"
        }
        stage('DeuxiemeEtape'){
            sh "echo 'Hello World !!'"
        }
    }
    finally{
        cleanWs()
    }
}
