global class Language_Testing_CreatePge_Ctrl {
    
     global class InnerClass {
        
        public Opportunity opp;
        public List<Contact_Assignments__c> assignments;
        public List<Contact_Assignments__c> testerAssignments;
        public List<Contact_Assignments__c> examinerAssignments;
        //public List<Language__c> langaugeList;
        
        public Language_Testing__c langTesting;
        public AttachmentInfo attachment = new AttachmentInfo();
        public AttachmentInfo ExaminerAttachment = new AttachmentInfo();
    }
    
    public class AttachmentInfo {
        public String Bodycontent;
        public String contentType;
        public Id attachemntId;
        public String name;
        public Id parentId;
    }
    
    global Class getPickListValues {
        
        public List<String> scoreList;
        public List<String> formatList;
        public List<String> typeList;
        public List<String> goalVsScore;
        public List<String> stageList;
        public List<String> sourceList;
        public List<Language__c> languageList;
    }
    
    public Id OpportunityId {get; set;}
    public Id LanguageTestId {get; set;}
    
    public Language_Testing_CreatePge_Ctrl(ApexPages.StandardController stdcontroller){
        
        Language_Testing__c langTest = (Language_Testing__c)stdController.getRecord();
        
        system.debug(':::::langTest:::::::'+langTest);
        
        if(langTest.Id != null) {
            LanguageTestId = langTest.Id;
        }else {
            OpportunityId = langTest.Opportunity__c;
        }
       
    }
    
    @RemoteAction
    public static InnerClass getRelatedInfomation(String OppId) {
       
       Opportunity oppRec = [SELECT Id,Name,AccountId,Account.Name,L_Goal_Score_Applicable__c,
                                   R_Goal_Score_Applicable__c,S_Goal_Score_Applicable__c,
                                   W_Goal_Score_Applicable__c,Language__c,ILR_L_Goal__c,ILR_R_Goal__c,ILR_S_Goal__c
                            FROM Opportunity 
                            WHERE Id = :OppId];
       
       // Qry Contact Assignment with Opp Id
        
        List<Contact_Assignments__c> conAssignments = [SELECT Id,Name,Opportunity_Name__c,Candidate_Name__c,Candidate_Name__r.Name,
                                                                Status__c,Assignment_Position__c,Project__c,End_Date__c,Start_Date__c
                                                        FROM Contact_Assignments__c WHERE Opportunity_Name__c = :OppId AND RecordType.DeveloperName = 'Student'];
         system.debug('::::::conAssignments::;;;;;'+conAssignments);
         
         List<Contact_Assignments__c> InstructorAssign = [SELECT Id,Name,Opportunity_Name__c,Candidate_Name__c,Candidate_Name__r.Name,
                                                                Status__c,Assignment_Position__c,Project__c,End_Date__c,Start_Date__c
                                                        FROM Contact_Assignments__c WHERE Opportunity_Name__c = :OppId AND RecordType.DeveloperName = 'Instructor' LIMIT 1];
         system.debug('::::::InstructorAssign::;;;;;'+InstructorAssign);
         
         List<Contact_Assignments__c> examiners = [SELECT Id,Name,Opportunity_Name__c,Candidate_Name__c,Candidate_Name__r.Name,
                                                                Status__c,Assignment_Position__c,Project__c,End_Date__c,Start_Date__c
                                                        FROM Contact_Assignments__c WHERE Opportunity_Name__c = :OppId AND RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
         system.debug('::::::examiners::;;;;;'+examiners);
         
         //Query instructor attachment for signature
         String parent = '';
         
         if(InstructorAssign.size() > 0)
             parent = InstructorAssign[0].Candidate_Name__c;
         
         List<Attachment> atta = [SELECT Id,Name,OwnerId,ParentId,Body,ContentType FROM Attachment WHERE ParentId = :parent AND Name LIKE '%Signature%' ORDER BY createdDate DESC LIMIT 1];
         
         // Query Examiner - LTS attachment for Signature
         
         String parentIdForExaminer = '';
         
         if(examiners.size() > 0)
             parentIdForExaminer = examiners[0].Candidate_Name__c;
         
         List<Attachment> examinerAttach = [SELECT Id,Name,OwnerId,ParentId,Body,ContentType FROM Attachment WHERE ParentId = :parentIdForExaminer AND Name LIKE '%Signature%' ORDER BY createdDate DESC LIMIT 1];
         
         
        InnerClass inr = new InnerClass();
        
        inr.opp = oppRec;
        inr.assignments = conAssignments;
        inr.testerAssignments = InstructorAssign;
        inr.examinerAssignments = examiners;
        
        if(atta != null && atta.size() > 0) {
            inr.attachment.Bodycontent = EncodingUtil.base64Encode(atta[0].Body);
            inr.attachment.contentType = atta[0].ContentType;
            inr.attachment.attachemntId = atta[0].Id;
            inr.attachment.name = atta[0].Name;
            inr.attachment.parentId = atta[0].ParentId;
        }
        
        if(examinerAttach != null && examinerAttach.size() > 0) {
            
            inr.ExaminerAttachment.Bodycontent = EncodingUtil.base64Encode(examinerAttach[0].Body);
            inr.ExaminerAttachment.contentType = examinerAttach[0].ContentType;
            inr.ExaminerAttachment.attachemntId = examinerAttach[0].Id;
            inr.ExaminerAttachment.name = examinerAttach[0].Name;
            inr.ExaminerAttachment.parentId = examinerAttach[0].ParentId;
        }
        
        system.debug('::::::::::inr:::::::::'+inr);
       return inr;
    }  
    
    @RemoteAction
    public static InnerClass getExistingLanguageTesting(String langTestId) {
       
       Language_Testing__c lang = [SELECT Id,Name,Account_Name__c,Account_Name__r.Name,Date_Time_Scheduled__c,L_Goal__c,L_Score__c,L_Score_vs_Goal__c,Opportunity__c,Opportunity__r.L_Goal_Score_Applicable__c,
                                           Opportunity__r.R_Goal_Score_Applicable__c,Opportunity__r.S_Goal_Score_Applicable__c,Opportunity__r.W_Goal_Score_Applicable__c,
                                           Overall_Score_vs_Goal__c,Project_Task__c,R_Goal__c,R_Score__c,R_Score_vs_Goal__c,Target_Language_LU__c,Target_Language_LU__r.Name,
                                           S_Goal__c,Source__c,S_Score__c,S_Score_vs_Goal__c,Stage__c,Target_Language__c,Billable__c,Total_Hours_Used__c,
                                           Testee__c,Testee__r.Name,Tester__c,Tester__r.Name,Test_Format__c,Test_Type__c,W_Goal__c,W_Score__c,W_Score_vs_Goal__c,Examiner__c,Examiner__r.Name
                                   FROM Language_Testing__c WHERE Id = :langTestId];
                                   
       String OppId = lang.Opportunity__c;
       String examierId = '';
       
       if(lang.Examiner__c != null)
           examierId = lang.Examiner__c;
       
       Opportunity oppRec = [SELECT Id,Name,AccountId,Account.Name,L_Goal_Score_Applicable__c,
                                   R_Goal_Score_Applicable__c,S_Goal_Score_Applicable__c,
                                   W_Goal_Score_Applicable__c 
                            FROM Opportunity 
                            WHERE Id = :OppId];
       
       // Qry Contact Assignment with Opp Id
        
        List<Contact_Assignments__c> conAssignments = [SELECT Id,Name,Opportunity_Name__c,Candidate_Name__c,Candidate_Name__r.Name,
                                                                Status__c,Assignment_Position__c,Project__c,End_Date__c,Start_Date__c
                                                        FROM Contact_Assignments__c WHERE Opportunity_Name__c = :OppId AND RecordType.DeveloperName = 'Student'];
         system.debug('::::::conAssignments::;;;;;'+conAssignments);
         
         List<Contact_Assignments__c> InstructorAssign = [SELECT Id,Name,Opportunity_Name__c,Candidate_Name__c,Candidate_Name__r.Name,
                                                                Status__c,Assignment_Position__c,Project__c,End_Date__c,Start_Date__c
                                                        FROM Contact_Assignments__c WHERE Opportunity_Name__c = :OppId AND RecordType.DeveloperName = 'Instructor' LIMIT 1];
         system.debug('::::::InstructorAssign::;;;;;'+InstructorAssign);
         System.debug('examierId:::'+examierId);
         List<Contact_Assignments__c> examiners = [SELECT Id,Name,Opportunity_Name__c,Candidate_Name__c,Candidate_Name__r.Name,
                                                                Status__c,Assignment_Position__c,Project__c,End_Date__c,Start_Date__c
                                                        FROM Contact_Assignments__c WHERE Candidate_Name__c = :examierId AND RecordType.DeveloperName = 'Staff' LIMIT 1];
         system.debug('::::::examiners::;;;;;'+examiners);
         
         
         //Query instructor attachment for signature
         
         String parent = '';
         
         if(InstructorAssign.size() > 0)
             parent = InstructorAssign[0].Candidate_Name__c;
         
         List<Attachment> atta = [SELECT Id,Name,OwnerId,ParentId,Body,ContentType FROM Attachment WHERE ParentId = :parent AND Name LIKE '%Signature%' ORDER BY createdDate DESC LIMIT 1];
         
         system.debug('::::::atta::::::'+atta);
         
         // Query Examiner - LTS attachment for Signature
         
         String parentIdForExaminer = '';
         
         System.debug('examiners:::Size:'+examiners.size());
         
         if(examiners.size() > 0)
             parentIdForExaminer = examiners[0].Candidate_Name__c;
         
         List<Attachment> examinerAttach = [SELECT Id,Name,OwnerId,ParentId,Body,ContentType FROM Attachment WHERE ParentId = :parentIdForExaminer AND Name LIKE '%Signature%' ORDER BY createdDate DESC LIMIT 1];
         
        InnerClass inr = new InnerClass();
        
        inr.opp = oppRec;
        inr.assignments = conAssignments;
        inr.testerAssignments = InstructorAssign;
       
        inr.langTesting = lang;
        inr.examinerAssignments = examiners;
        
        if(atta != null && atta.size() > 0) {
            inr.attachment.Bodycontent = EncodingUtil.base64Encode(atta[0].Body);
            inr.attachment.contentType = atta[0].ContentType;
            inr.attachment.attachemntId = atta[0].Id;
            inr.attachment.name = atta[0].Name;
            inr.attachment.parentId = atta[0].ParentId;
        }
        
        if(examinerAttach != null && examinerAttach.size() > 0) {
            
            inr.ExaminerAttachment.Bodycontent = EncodingUtil.base64Encode(examinerAttach[0].Body);
            inr.ExaminerAttachment.contentType = examinerAttach[0].ContentType;
            inr.ExaminerAttachment.attachemntId = examinerAttach[0].Id;
            inr.ExaminerAttachment.name = examinerAttach[0].Name;
            inr.ExaminerAttachment.parentId = examinerAttach[0].ParentId;
        }
        
        system.debug('::::::::::inr:::::::::'+inr);
       return inr;
    }
    
    
    @RemoteAction
    public static Language_Testing__c LanguageTestCreateOrUpdate(String languageString){
       
       List<Language_Testing__c> LanguageTestingList = (List<Language_Testing__c>) System.JSON.deserialize(languageString, List<Language_Testing__c>.class);
       system.debug('::::::::LanguageTestingList:::::::'+LanguageTestingList);
       
       if(LanguageTestingList.size() > 0 && LanguageTestingList[0].Id != null)
           update LanguageTestingList;
       else if(LanguageTestingList.size() > 0)
           insert LanguageTestingList;
           
       
       return LanguageTestingList[0];
    }
    
     // Added by sukanya on October 26 2016 for look up Search
        
    // This method is modified for Contact Assignment Supervisor/LTS Contact Search
    
    @RemoteAction
    global static List<sObject> getLookupRecords(String objectName, String searchString, String condition) {
        List<sObject> lookupRecords = new List<sObject>();
        String query = 'SELECT Id, Name FROM ' + objectName;
        if(searchString != null && searchString != '') {
            query += ' WHERE Name LIKE \'%' + searchString + '%\'';
        }
        if(condition != null && condition != '') {
            if(searchString != null && searchString != '') {
                query += ' AND ' + condition;
            } else {
                query += ' WHERE ' + condition;
            }
        }
        query += ' LIMIT 10';
        System.debug('query log:::::::::::: ' + query);
        lookupRecords = Database.query(query);
        system.debug(':::::::::lookupRecords:::::::'+lookupRecords);
        return lookupRecords;
    }
    
   /* @RemoteAction
    global static Contact getSpecificLookupRec(String contactId) {
        Contact conRec = [SELECT Id,Name FROM Contact WHERE Id = :contactId];
        system.debug(':::::conRec::::::'+conRec);
        return conRec;
    }
    */
    // Added by Sukanya on October 27 2016 for getting Pick list values from single method
    
    @RemoteAction
    global static getPickListValues getSelectOptionValues() {
        
        getPickListValues getValue = new getPickListValues();
        
        getValue.scoreList = StudentTestResult_ReportPage_Controller.PicklistValues('Language_Testing__c','L_Score__c');
        getValue.formatList = StudentTestResult_ReportPage_Controller.PicklistValues('Language_Testing__c','Test_Format__c');
        getValue.typeList = StudentTestResult_ReportPage_Controller.PicklistValues('Language_Testing__c','Test_Type__c');
        getValue.goalVsScore = StudentTestResult_ReportPage_Controller.PicklistValues('Language_Testing__c','R_Score_vs_Goal__c');
        getValue.stageList = StudentTestResult_ReportPage_Controller.PicklistValues('Language_Testing__c','Stage__c');
        getValue.sourceList = StudentTestResult_ReportPage_Controller.PicklistValues('Language_Testing__c','Source__c');
        getValue.languageList = [SELECT Id,Name FROM Language__c];
        
        return getValue;
    }
    
    // To get the opp related testee details from contact assignemnt
    
    @RemoteAction
    global static List<Contact_Assignments__c> getTesteeDetails(String OppId) {
        List<Contact_Assignments__c> contactAssign = [SELECT Id,Name,Opportunity_Name__c,Candidate_Name__c,Candidate_Name__r.Name FROM Contact_Assignments__c WHERE Opportunity_Name__c = :OppId AND RecordType.DeveloperName = 'Student'];
        system.debug(':::::conRec::::::'+contactAssign);
        return contactAssign;
    }
    

}