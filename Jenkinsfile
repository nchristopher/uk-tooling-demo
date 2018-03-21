#!groovy

import groovy.json.JsonSlurperClassic
node {

    def BUILD_NUMBER = env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR = "tests/${BUILD_NUMBER}"
    def SFDC_USERNAME

    def HUB_ORG = 'HUB_ORG'
    //def SFDC_HOST = env.SFDC_HOST_DH
    //def JWT_KEY_CRED_ID = env.JWT_KEY_FILE
    def JWT_KEY_CRED_ID = 'JWT_KEY_FILE'
    def CONNECTED_APP_CONSUMER_KEY = 'CONNECTED_APP_CONSUMER_KEY'


    stage('checkout source') {
        // when running in multi-branch job, one must issue this command
        checkout scm
    }

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file'),
        string(credentialsId: HUB_ORG, variable: 'HUB'),
        string(credentialsId: CONNECTED_APP_CONSUMER_KEY, variable: 'CONNECTED_APP_KEY')
    ]) {
        stage('Create Scratch Org') {

            rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${CONNECTED_APP_KEY} --username ${HUB} --jwtkeyfile ${jwt_key_file} --setdefaultdevhubusername "
            if (rc != 0) {
                error 'hub org authorization failed'
            }

            // need to pull out assigned username
            rmsg = sh returnStdout: true, script: "sfdx force:org:create --definitionfile config/project-scratch-def.json --json --setdefaultusername"
            println('Hello from a Job DSL script!')
            println('rmsg:' + rmsg)
            def beginIndex = rmsg.indexOf('{')
            def endIndex = rmsg.indexOf('}')
            println('beginIndex: ' + beginIndex)
            println('endIndex: ' + endIndex)
            def jsobSubstring = rmsg.substring(beginIndex)
            println('jsobSubstring: ' + jsobSubstring)
            def jsonSlurperClass = new JsonSlurperClassic()
            def robj = jsonSlurperClass.parseText(jsobSubstring)
            println('robj: ' + robj)
            //if (robj.status != "ok") { error 'org creation failed: ' + robj.message }
            SFDC_USERNAME = robj.result.username
            robj = null

        }
        stage('Push Source Test Org') {
            rc = sh returnStatus: true, script: "sfdx force:source:push --targetusername ${SFDC_USERNAME}"
            if (rc != 0) {
                error 'push failed'
            }
            // assign permset
            rc = sh returnStatus: true, script: "sfdx force:user:permset:assign --targetusername ${SFDC_USERNAME} --permsetname DreamHouse"
            if (rc != 0) {
                error 'permset:assign failed'
            }
        }
        /*stage('Run Apex Test') {
            sh "mkdir -p ${RUN_ARTIFACT_DIR}"
            timeout(time: 120, unit: 'SECONDS') {
                rc = sh returnStatus: true, script: "sfdx force:apex:test:run --testlevel RunLocalTests --outputdir ${RUN_ARTIFACT_DIR} --resultformat tap --targetusername ${SFDC_USERNAME}"
                if (rc != 0) {
                    error 'apex test run failed'
                }
            }
        }*/
        stage('Delete Test Org') {

            timeout(time: 120, unit: 'SECONDS') {
                rc = sh returnStatus: true, script: "sfdx force:org:delete --targetusername ${SFDC_USERNAME} --noprompt"
                if (rc != 0) {
                    error 'org deletion request failed'
                }
            }
        }
        
    }
}

