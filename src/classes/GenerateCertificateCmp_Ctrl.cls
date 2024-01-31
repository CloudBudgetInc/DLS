/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 10/04/2023
 * @last modified by  : Dhinesh Kumar
**/
public class GenerateCertificateCmp_Ctrl {
    @auraEnabled
    public static GenerateCertificateWrap getStudentListAndCongaSessionId(String projectId){
       GenerateCertificateWrap wrapObj = new GenerateCertificateWrap(); 
        Boolean skipFRUPFolderCheckOrAllowBoxFolderCreation = Boolean.valueOf(Label.skipFRUPFolderCheckOrAllowBoxFolderCreation);
        String folderName = null;
        String projectRelOppId = null;        
        Set<Id> recordIds = new Set<Id>();
        String objName = 'AcctSeed__Project__c';
        Boolean isDODAProj = false;
        Boolean isFCSProj = false;
        String testingProjBccAdditionalEmailAdd = /*getIsSandbox() ? 'dlsleads@softsquare.biz' :*/ 'support@dlsdc.com';
        
        List <AcctSeed__Project__c>  proList = [SELECT Id,Name,AcctSeed__Opportunity__c,AcctSeed__Opportunity__r.Name, DLS_Ref__c,
                                                AcctSeed__Account__r.Name, RecordType.DeveloperName,Test_Type__c 
                                                FROM AcctSeed__Project__c WHERE Id =:projectId LIMIT 1];
        if(proList.size() > 0 ){
            folderName = proList[0].Name;
            recordIds.add(proList[0].Id);
            projectRelOppId = proList[0].Id;
            
            if(proList[0].AcctSeed__Opportunity__c != null){
                recordIds.add(proList[0].AcctSeed__Opportunity__c);
                projectRelOppId = proList[0].AcctSeed__Opportunity__c;
                folderName = proList[0].AcctSeed__Opportunity__r.Name;
                objName = 'Opportunity';
            }
            isDODAProj = proList[0].AcctSeed__Account__r.Name == 'DODA';            
            isFCSProj = proList[0].AcctSeed__Account__r.Name == 'USDoC-FCS';
        }
        
        List<box__FRUP__c> frup = [SELECT Id,Name,box__Record_ID__c,box__Folder_ID__c FROM box__FRUP__c WHERE box__Record_ID__c IN :recordIds];        
        
        if(frup.size() > 0 || skipFRUPFolderCheckOrAllowBoxFolderCreation){

            if(frup.size() > 0)
                GenericUrlLaunch_Ctrl.updateOppProjects(projectId, 'AcctSeed__Project__c');

            wrapObj.contactAssignmentList = new List<contactAssignment>();
            wrapObj.contactAssignments = new List<Contact_Assignments__c>();
            Id ltsId;            
            List<Contact_Assignments__c> clientCA = new List<Contact_Assignments__c>();

            for(Contact_Assignments__c ca : [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Certificate_Generated_Date__c, Assignment_Position__c,
                                            Project__r.Language__r.Name, RecordType.DeveloperName, Certificate_Generation_URL__c 
                                            FROM Contact_Assignments__c 
                                            WHERE Project__c = :projectId AND RecordType.DeveloperName IN ('Client_Partner','Student','Staff')  
                                            AND Status__c NOT IN ('Canceled','Transferred')]){
                
                if(ca.RecordType.DeveloperName == 'Student'){ 
                    String candidateName = String.isNotBlank(ca.Certificate_Generation_URL__c) && ca.Certificate_Generation_URL__c.contains(ca.Candidate_Name__c)  ? ca.Candidate_Name__r.Name + ' (SENT) ' : ca.Candidate_Name__r.Name;
                    contactAssignment conAssign = new contactAssignment(ca, new Map<String, Contact_Assignments__c>{candidateName => ca}, new List<String>{candidateName}, new List<String>{candidateName});                    
                    wrapObj.contactAssignmentList.add(conAssign);
                    wrapObj.contactAssignments.add(ca);
                }
                //Modified by Dhinesh - 06/09/2023 - W-007871 - Add Training Officer in to address for FCS Projects
                //Modified by Dhinesh - 26/6/2023 - W-007817 - Add LTS as BCC for testing projects
                else if(ca.RecordType.DeveloperName == 'Staff' || (ca.RecordType.DeveloperName == 'Client_Partner' && (!isFCSProj || (isFCSProj && ca.Assignment_Position__c == 'Training Officer')))){ 
                    clientCA.add(ca);
                }

                if(ca.Assignment_Position__c == 'Project Manager' || ca.Assignment_Position__c == 'Manager'){                    
                    ltsId = ca.Candidate_Name__c;
                }
            }

            for(Contact_Assignments__c client : clientCA){
                
                for(contactAssignment conAssignment: wrapObj.contactAssignmentList){
                    Contact_Assignments__c ca = conAssignment.ca;
                    String candidateName = String.isNotBlank(ca.Certificate_Generation_URL__c) && ca.Certificate_Generation_URL__c.contains(client.Candidate_Name__c)  ? client.Candidate_Name__r.Name + ' (SENT) ' : client.Candidate_Name__r.Name;
                    conAssignment.sendToNames.add(candidateName);
                    conAssignment.sendToNameWithCAMap.put(candidateName, client);
                }
            }
            
            String congaTemplate = 'Generate Certificate Template';
            String congaEmailTemplate = 'Generate Certificate';
            
            Id ptId;
            for(Acctseed__Project_Task__c pt : [SELECT Id FROM Acctseed__Project_Task__c WHERE AcctSeed__Project__c = :projectId AND RecordType.DeveloperName = 'Language_Training' AND Project_Task_Type__c = 'Language Training' AND (NOT Name LIKE '%Additional%')]){
                ptId = pt.Id;
            }
            
            Map<Id, Id>  caIdWithExaminerId = new Map<Id, Id>();
            Map<Id, Id>  caIdWithLangTestingId = new Map<Id, Id>();

            wrapObj.showSendTo = proList[0].RecordType.DeveloperName == 'Testing_Projects';
            
            if(proList[0].RecordType.DeveloperName == 'Testing_Projects'){//Modified By Dhinesh - 27/6/2023 - W-007824 - Separate templates for Translation Testing projects
                congaTemplate =  proList[0].Test_Type__c.contains('Translation') ? 'Translation Testing Certificate Template' : 'Language Testing Certificate Template';
                congaEmailTemplate = proList[0].Test_Type__c.contains('Translation') ? 'Translation Language Testing Certificate' : 'Language Testing Certificate';
                for(Language_Testing__c langTesting : [SELECT Id, Examiner__c, Testee__c FROM Language_Testing__c WHERE Project__c = :projectId]){
                    caIdWithExaminerId.put(langTesting.Testee__c, langTesting.Examiner__c);
                    caIdWithLangTestingId.put(langTesting.Testee__c, langTesting.Id);
                }
                
                if(wrapObj.contactAssignments.size() != caIdWithLangTestingId.size()){
                    wrapObj.errorMsg = 'Please create Testing Record for the Student';  
                    return wrapObj;
                }
            }                        
            
            //Modified By Dhinesh - 24/08/2023 - W-007848 - Remove Support DLS email as from for all reports
            //String fromEmailId = [SELECT Id, Address FROM OrgWideEmailAddress WHERE  Address = 'support@dlsdc.com' LIMIT 1].Id;           
            
            Map<String, Object> congaSessionMap = new Map<String, Object>();
            if(!Test.isRunningTest()){
                congaSessionMap = (Map<String, Object>) JSON.deserializeUntyped(CongaButtonsController.getServerUrlSessionId());
            }
            Id congaTemplateId;
            for(APXTConga4__Conga_Template__c ct : [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = :congaTemplate]) {
                congaTemplateId = ct.Id;
            }
            Id emailTemplateId;
            for(APXTConga4__Conga_Email_Template__c et: [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = :congaEmailTemplate]){
                emailTemplateId = et.Id;
            }            
            
            String congaBaseUrl = 'https://composer.congamerge.com?sessionId='+(String)congaSessionMap.get('sessionId') + 
                                                  '&serverUrl='+(String)congaSessionMap.get('serverUrl');
            
            if(proList[0].RecordType.DeveloperName == 'Testing_Projects'){
                congaBaseUrl += '&id=&templateId=' + congaTemplateId+'&DefaultPDF=1&queryId=[PROJ]'+ CongaTranslator.getCongaQuery('Project Query for Job Summary Report') + '?pv0='+projectId+
                    ',[EXAMINER]'+ CongaTranslator.getCongaQuery('Contact Query - Generate Certificate') + '?pv0=';
                wrapObj.caIdWithLangTestingId = caIdWithLangTestingId;
                wrapObj.caIdWithExaminerId = caIdWithExaminerId;
            }else{
                congaBaseUrl += '&id='+projectId+'&templateId=' + congaTemplateId+'&DefaultPDF=1'+                    
                    '&queryId=[LTS]'+ CongaTranslator.getCongaQuery('Contact Query - Generate Certificate') + '?pv0='+ltsId+
                    ',[PT]'+ CongaTranslator.getCongaQuery('Project Task Query - Generate Certificate') + '?pv0='+ptId+                
                    ',[CA]'+ CongaTranslator.getCongaQuery('Contact Assignment Query - Generate Certificate') + '?pv0=';
            }
            wrapObj.congaBaseUrl = congaBaseUrl;
            //Modified By Dhinesh - 24/08/2023 - W-007848 - Remove Support DLS email as from for all reports
            wrapObj.emailParams = '&EmailReplyToId='+UserInfo.getUserId() +'&qmode=SendEmail&emailbcc='+Label.Generate_Certificate_Conga_Sign+
                    (isDODAProj && proList[0].RecordType.DeveloperName != 'Testing_Projects' ? ',' + Label.DODA_Generate_Certificate_Conga_Sign : '') + 
                    (isFCSProj ? ',' + Label.FCS_Generate_Certificate_Conga_Sign : '') + 
                    (proList[0].RecordType.DeveloperName == 'Testing_Projects' ? ',' + testingProjBccAdditionalEmailAdd : '') + '&CongaEmailTemplateId='+emailTemplateId;
            
        }else{
            if(String.isNotBlank(folderName)){
                folderName = folderName.replace('/','_'); //.replace('.','')
            }
            
            GenericUrlLaunch_Ctrl.calloutToCreateBoxRecs(projectRelOppId ,folderName ,'Opportunities',objName);
            wrapObj.errorMsg = 'No Box Record';  
        }
        System.debug('wrapObj:::'+wrapObj);       
        return wrapObj;
    }
    
    public class GenerateCertificateWrap{
        @auraEnabled public List<Contact_Assignments__c> contactAssignments;        
        @auraEnabled public String congaBaseUrl;
        @auraEnabled public String errorMsg;
        @auraEnabled public String emailParams;
        @auraEnabled public Map<Id, Id>  caIdWithLangTestingId;
        @auraEnabled public Map<Id, Id>  caIdWithExaminerId;

        @auraEnabled public Boolean showSendTo;
        @auraEnabled public List<ContactAssignment> contactAssignmentList;
    }
    
    public class ContactAssignment{
        @auraEnabled public Contact_Assignments__c ca;
        @auraEnabled public List<String> selectedSendTo;        
        @auraEnabled public Map<String, Contact_Assignments__c> sendToNameWithCAMap;
        @auraEnabled public List<String> sendToNames;

        public contactAssignment(Contact_Assignments__c ca, Map<String, Contact_Assignments__c> sendToNameWithCAMap, List<String> sendToNames, List<String> selectedSendTo){
            this.ca = ca;            
            this.sendToNameWithCAMap = sendToNameWithCAMap;
            this.sendToNames = sendToNames;
            this.selectedSendTo = selectedSendTo;
        }
    }
    
    @AuraEnabled 
    public static void createBoxFRUPRecs(String frupJSON) {
        GenericUrlLaunch_Ctrl.createBoxFRUPRecs(frupJSON);
    }
    
    @AuraEnabled
    public static string updateContactRecords(String conAssignmentStr){
        String result = 'success';
        
        try{
            List<Contact_Assignments__c> conAssignments = (List<Contact_Assignments__c>) JSON.deserialize(conAssignmentStr, List<Contact_Assignments__c>.class);
            update conAssignments;            
        }catch(exception ex){
            result = ex.getMessage();
        }
        return result;
    }

    public static Boolean getIsSandbox() {
        System.Domain domain = System.DomainParser.parse(URL.getOrgDomainUrl());
        return domain.getSandboxName() != null;
    }
    
}