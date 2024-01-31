public without sharing class ContactAssignmentLightningCtrl {
    
    //For sending Cost Rate records for approval process
    public static Boolean isFromCA = false;
        
    /**********************************************************************
        Created by SivaPrasanth on Nov 16 2018: This method return list of ContactAssignment records based on parentId,ObjectName.
        @recId -Id of (Opportunity || project ||contract) 
        @sobjectName - (Opportunity || project ||contract)
        return - list of ContactAssignment records
     ***********************************************************************/ 
    @AuraEnabled
    public static ContactAssignmentDomain.WrapperContactAssign getTabRecs(String recId,string sobjectName) {
        if(String.isBlank(sObjectName)){
            sObjectName = String.valueOf(Id.valueOf(recId).getSObjectType());
        }
        boolean isDisplayAction = false; 
        boolean adminrecordType = false;
        boolean contractType = false;
        boolean mTTRecordType = false;
        boolean dLIWTOFSIrecordType = false;
        boolean TIRecordType = false;
        boolean isDisplayStudentTab = true;
        String activeTab;
        List<String> tabNames = new  List<String>();
        List<string> statusList = new List<String>();
        List<string> defaultStatusSet = new List<String>{'All','Active', 'Planned', 'On Hold', 'Ended', 'Canceled'};
        String instructorLabel = 'Instructor';
        String supervisorLabel = 'Supervisor/LTS';
        string recordTypeName;
        string projectId;
        string defaultCostRate;
        Set<Id> cRIdSet = new Set<Id>();
        Set<Id> conIdSet = new Set<Id>();
        Map<String,Integer> cALCRChildCount = new Map<String,Integer>();
        Map<Id,Integer> insIdWithSumTotalEventMap = new Map<Id,Integer>();
        
        List<ContactAssignmentDomain.ContactAssignmentWrapper> caWrapList = new List<ContactAssignmentDomain.ContactAssignmentWrapper>();
        List<Contact_Assignments__c>  activeContactAssignRecs = new List<Contact_Assignments__c>();
        
        List<RecordType> recordTypes = [SELECT RecordType.Name , RecordType.Id FROM RecordType WHERE SobjectType = 'Contact_Assignments__c'];
        system.debug('record types are '+recordTypes);
        if(sobjectName == 'Opportunity'){
            List<AcctSeed__Project__c> projectRec = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__r.Id =:recId];
            if(projectRec.size() <= 0){ 
                isDisplayAction = true;
            }
            else{
                projectId = projectRec[0].Id;
            }
            List<Opportunity> oppList = [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity WHERE Id = :recId];
            if(oppList != null && oppList.size() > 0){
                recordTypeName = oppList[0].RecordType.DeveloperName;
            }                    
            if(oppList.size() > 0){
                if(oppList[0].RecordType.DeveloperName == 'CD_Opportunities' || oppList[0].RecordType.DeveloperName == 'Translation_Opportunities' || oppList[0].RecordType.DeveloperName ==  'Linguist_Support' || oppList[0].RecordType.DeveloperName == 'Interpretation_Opportunities') {
                    instructorLabel = 'Direct Labor';
                    supervisorLabel = 'Overhead';
                    isDisplayStudentTab = false;
                } else if(oppList[0].RecordType.DeveloperName == 'Admin_Opportunities') { // Added for Internal Cost Job Opp
                    supervisorLabel = 'Staff';
                    adminrecordType = true;
                } else if(oppList[0].RecordType.DeveloperName == 'MTT_Opportunities')   {
                    mTTRecordType = true;
                }else if(oppList[0].RecordType.DeveloperName == 'DLI_W_TO_Opportunities' || oppList[0].RecordType.DeveloperName == 'FSI_Opportunities'){
                    dLIWTOFSIrecordType = true;
                }
                if(oppList[0].RecordType.DeveloperName == 'Translation_Opportunities' || oppList[0].RecordType.DeveloperName == 'Interpretation_Opportunities'){
                    TIRecordType = true;
                }
            }
        }
        if(sobjectName == 'AcctSeed__Project__c'){
            List<AcctSeed__Project__c> projectList = [SELECT  RecordType.Id,RecordType.DeveloperName,Default_Cost_Rate_Rate_Type__c FROM AcctSeed__Project__c WHERE Id =:recId];
            if(projectList != null && projectList.size() > 0){
                recordTypeName = projectList[0].RecordType.DeveloperName;
                defaultCostRate = projectList[0].Default_Cost_Rate_Rate_Type__c;
                               
                if(projectList[0].RecordType.DeveloperName == 'CD_Projects' || projectList[0].RecordType.DeveloperName == 'Translation_Projects' ||  projectList[0].RecordType.DeveloperName == 'Linguist_Support_Projects' ||  projectList[0].RecordType.DeveloperName == 'Interpretation_Projects') {
                    instructorLabel = 'Direct Labor';
                    supervisorLabel = 'Overhead';
                    isDisplayStudentTab = false;
                } else if(projectList[0].RecordType.DeveloperName == 'Admin_Projects') { // Added for Internal Cost Job Opp
                    supervisorLabel = 'Staff';
                    adminrecordType = true;
                }else if ( projectList[0].RecordType.DeveloperName == 'MTT_Projects' ) {
                    mTTRecordType = true;
                }
                if(projectList[0].RecordType.DeveloperName == 'Translation_Projects' || projectList[0].RecordType.DeveloperName == 'Interpretation_Projects'){
                    TIRecordType = true;
                }
            }
        }
        if(sobjectName == 'Contract'){
            contractType = True;
            List <Contract>  contrtList = SObjectQueryService.SObjectQuery('Contract',new Set<Id>{recId},',RecordType.DeveloperName');
            if(contrtList != null && contrtList.size() > 0){
                recordTypeName = contrtList[0].RecordType.DeveloperName;
                supervisorLabel = 'DLS Staff';
            }
            
        }
        Map<Id,String> oPLIMap = new Map<Id,String>();
        if(sobjectName == 'Opportunity'){
            for(OpportunityLineItem opl : [SELECT Id,Name,OpportunityId,Product2.Name FROM OpportunityLineItem WHERE OpportunityId = :recId]) {
                String pdName = opl.Product2.Name;
                oPLIMap.put(opl.Id,pdName);
            }
        }
     
        if(isDisplayStudentTab &&  !adminrecordType && !contractType ){
             tabNames.add('Student');
        }

        if(adminrecordType || contractType){
            activeTab = supervisorLabel;
        }else{
            activeTab = instructorLabel;
            tabNames.add(instructorLabel);
        }
        tabNames.add(supervisorLabel);
        tabNames.add('Client/Partner');
        
        if(adminrecordType && !contractType){
            tabNames.add('Consultant');
        }
        system.debug('tabs are'+tabNames);
        ContactAssignmentDomain.WrapperContactAssign wrapConAssign = new ContactAssignmentDomain.WrapperContactAssign();
        wrapConAssign.wrapTabNames = tabNames;
        wrapConAssign.wrapActiveTab = activeTab;
        wrapConAssign.parentRecordType = recordTypeName;
        wrapConAssign.defaultCostRate = defaultCostRate; 
        wrapConAssign.opliMap = oPLIMap;
        wrapConAssign.payRateModifyPermissionAccess = FeatureManagement.checkPermission('Pay_Rate_Modification_Access');
        system.debug('wrapper'+wrapConAssign);
        List<Contact_Assignments__c> contactAssignRecs;
        
        if(activeTab == 'Staff' || activeTab == 'Supervisor/LTS' || activeTab == 'Overhead' || activeTab =='DLS Staff'){
            activeTab = 'Staff';
        }else if(activeTab == 'Instructor' || activeTab == 'Direct Labor'){
            activeTab = 'Instructor';
        }
        
        if(sobjectName == 'Opportunity'){
            contactAssignRecs  = [SELECT id,Opportunity_Name__c,Opportunity_Name__r.Name,Candidate_Name__c,Candidate_Name__r.Supervisor_Name__c,Opportunity_Product_Id__c,Candidate_Name__r.Name,Mobile__c, Rate_Card_Rate__c,Rate_Card_Rate__r.Cost_Rate_Name__c,Start_Date__c,End_Date__c,Email__c,recordType.Name,Status__c,Drafted_Labor_Cost_Rate__r.Cost_Rate_Name__c,Drafted_Labor_Cost_Rate__c,
                                  Sequence__c,Assignment_Position__c,Total_Qty_Planned__c,Project_Task__r.Name,Project_Task__c,Drafted_Labor_Cost_Rate__r.Status__c,Oral_Exam_Date_Time__c,Rate_Card_Rate__r.Status__c,Drafted_Labor_Cost_Rate__r.Rate_Type__c,Rate_Card_Rate__r.Rate_Type__c  FROM Contact_Assignments__c WHERE recordType.DeveloperName=:activeTab AND Opportunity_Name__c = :recId];  
        }else if(sobjectName == 'AcctSeed__Project__c'){
            contactAssignRecs = [SELECT id,Opportunity_Name__c,Opportunity_Name__r.Name,Candidate_Name__c,Candidate_Name__r.Supervisor_Name__c,Candidate_Name__r.Name,Opportunity_Product_Id__c,Mobile__c, Start_Date__c,Rate_Card_Rate__c,Rate_Card_Rate__r.Cost_Rate_Name__c,End_Date__c,Email__c,recordType.Name,Status__c,Drafted_Labor_Cost_Rate__r.Cost_Rate_Name__c,Drafted_Labor_Cost_Rate__c,     
                                 Sequence__c,Assignment_Position__c,Total_Qty_Planned__c,Project_Task__r.Name,Project_Task__c,Drafted_Labor_Cost_Rate__r.Status__c,Oral_Exam_Date_Time__c,Rate_Card_Rate__r.Status__c,Drafted_Labor_Cost_Rate__r.Rate_Type__c,Rate_Card_Rate__r.Rate_Type__c,Total_of_Days_Eligible__c,Daily_Travel_Reimbursement_Amount__c,Bonus_Amount__c,
                                 Additional_Compensation_Type__c FROM Contact_Assignments__c WHERE recordType.DeveloperName = :activeTab AND Project__c = :recId];  
        }else if(sobjectName == 'Contract') {
            contactAssignRecs = [SELECT Id,Candidate_Name__c,Candidate_Name__r.Name,Candidate_Name__r.Supervisor_Name__c,recordType.Name,Status__c,Assignment_Position__c,Sequence__c,Oral_Exam_Date_Time__c,Start_Date__c,End_Date__c,Rate_Card_Rate__c,Rate_Card_Rate__r.Cost_Rate_Name__c,Project_Task__c,Drafted_Labor_Cost_Rate__r.Status__c,Rate_Card_Rate__r.Status__c,
                                Drafted_Labor_Cost_Rate__r.Rate_Type__c,Rate_Card_Rate__r.Rate_Type__c FROM Contact_Assignments__c  WHERE recordType.DeveloperName = :activeTab AND Contract__c = :recId];
        }
        
        /* To fix the OralDateTime TimeZone issue*/
        if(contactAssignRecs.size() > 0){
            for(Contact_Assignments__c ca : contactAssignRecs){
                ContactAssignmentDomain.ContactAssignmentWrapper caWrap = new ContactAssignmentDomain.ContactAssignmentWrapper();
                caWrap.oralExamDateTime = null;
                
                if(ca.Oral_Exam_Date_Time__c != null){
                    Datetime oralDateTime = ca.Oral_Exam_Date_Time__c;
                    caWrap.oralExamDateTime = oralDateTime.format('MM/dd/yyyy hh:mm a');
                }
                caWrap.caRecs = ca;
                caWrapList.add(caWrap);
            }
        }
        wrapConAssign.wrapConAssignList = caWrapList;
        
        if(activeTab == 'Instructor') {
            if(contactAssignRecs.size() > 0){
                for(Contact_Assignments__c ca : contactAssignRecs){
                    if(ca.Rate_Card_Rate__c != null){
                        cRIdSet.add(ca.Rate_Card_Rate__c);
                    }else if(ca.Drafted_Labor_Cost_Rate__c != null){
                        cRIdSet.add(ca.Drafted_Labor_Cost_Rate__c);
                    }
                    conIdSet.add(ca.Candidate_Name__c);
                }
            }
            
            List<AcctSeed__Cost_Rates__c> crList =  [Select Id,Contact__c,(SELECT Id FROM Cost_Rates__r)FROM AcctSeed__Cost_Rates__c WHERE Id IN :cRIdSet Order By Effective_Date__c DESC];
            
            for(AcctSeed__Cost_Rates__c cr : crList){
                cALCRChildCount.put(cr.Contact__c+'-'+cr.Id,cr.Cost_Rates__r.size());
            }
            if(cALCRChildCount != null){
                wrapConAssign.cACostRAteChildCountMap = cALCRChildCount;
            }
        }
           /*Work - W-001862
         Hiring Process: Additional Compensation (End of Training Bonuses, Client Site Travel Reimbursement, etc.)
         get sum of TotalnumbersofEvent to Instructor from Schedule record*/
        if(activeTab == 'Instructor' && sobjectName == 'AcctSeed__Project__c') {
            
            for(AggregateResult aCS :[SELECT SUM(Total_Events__c) totEvent, Instructor__c ins FROM Schedule__c WHERE Project__c = :recId AND Instructor__c = :conIdSet GROUP BY Instructor__c]){
               insIdWithSumTotalEventMap.put((Id)aCS.get('ins'), (Integer)(aCS.get('totEvent') == null ? 0 : Integer.valueOf(aCS.get('totEvent'))));
            }
            wrapConAssign.insIdWithSumTotalEventMap = insIdWithSumTotalEventMap;
        }
        if(TIRecordType){
            statusList.add('Planned & Active');
            statusList.addAll(defaultStatusSet);
        }else if(mTTRecordType){
            statusList.addAll(defaultStatusSet);
            statusList.add('Proposed');
        }else if(dLIWTOFSIrecordType){ //W-007837 - Create new FSI Labor Cost Rate Rate Type & Offer Letter (SEP-1-2023)
            List<string> dLIWTOFSIrecordTypeStatusSet = new List<String>{'All', 'Proposed', 'Awarded', 'Canceled'};
                statusList.addAll(dLIWTOFSIrecordTypeStatusSet);
        }else{
            statusList.addAll(defaultStatusSet);
        }
        
        
        wrapConAssign.wrapStatuspickList = statusList;
        wrapConAssign.wrapIsDisplayAction = isDisplayAction;
        wrapConAssign.wrapProjectId = projectId;
        return wrapConAssign;
    }
    /**********************************************************************
        Created by Sivaprasanth on Nov 18 2018: This method return list of Contact Assignments  Records basedon RecordType,ParentId,ObjectName After Tab Change.
        @ recordtypeName - pass the RecordTypeDeveloperName of(Project || Opportunity || Contract)
        @ parentId - pass the Id of(Project || Opportunity || Contract) 
        @ objectName - pass the ObjectName  of(Project || Opportunity || Contract) 
        return - list of Contact_Assignments__c records 
     ***********************************************************************/
    @AuraEnabled
    public static ContactAssignmentDomain.WrapperContactAssign getContactAssignRecs(String recordtypeName,string parentId,string objectName) {
        List<Contact_Assignments__c> contactAssignRecs;
        if(String.isBlank(objectName)){
            objectName = String.valueOf(Id.valueOf(parentId).getSObjectType());
        }
        system.debug('tab name is::::: '+recordtypeName);
        system.debug('tab name is::::: '+objectName);
        system.debug('tab name is::::: '+parentId);
        Set<Id> cRIdSet = new Set<Id>();
        Map<String,Integer> cALCRChildCount = new  Map<String,Integer>();
        
        List<ContactAssignmentDomain.ContactAssignmentWrapper> caWrapList = new List<ContactAssignmentDomain.ContactAssignmentWrapper>();
        ContactAssignmentDomain.WrapperContactAssign wrapConAssign = new ContactAssignmentDomain.WrapperContactAssign();
        
        if(objectName == 'Opportunity'){
            contactAssignRecs  = [SELECT Id,Opportunity_Name__c,Opportunity_Name__r.Name,Candidate_Name__c,Candidate_Name__r.Supervisor_Name__c,Opportunity_Product_Id__c,Oral_Exam_Date_Time__c,
                                  Candidate_Name__r.Name,Mobile__c, Start_Date__c,End_Date__c,Email__c,recordType.Name,Status__c,
                                  Drafted_Labor_Cost_Rate__r.Cost_Rate_Name__c,Drafted_Labor_Cost_Rate__c,
                                  Sequence__c,Assignment_Position__c,Project_Task__r.Name,Project_Task__c,Rate_Card_Rate__c,
                                  Rate_Card_Rate__r.Cost_Rate_Name__c,Total_Qty_Planned__c,Drafted_Labor_Cost_Rate__r.Status__c,Rate_Card_Rate__r.Status__c  
                                 ,Drafted_Labor_Cost_Rate__r.Rate_Type__c,Rate_Card_Rate__r.Rate_Type__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = :recordtypeName AND Opportunity_Name__c = :parentId];  
        }else if(objectName == 'AcctSeed__Project__c'){
            contactAssignRecs = [SELECT Id,Candidate_Name__c,Candidate_Name__r.Name,Mobile__c, Start_Date__c,Candidate_Name__r.Supervisor_Name__c,Opportunity_Product_Id__c,Opportunity_Name__c,Oral_Exam_Date_Time__c, 
                                 End_Date__c,Email__c,recordType.Name,Status__c,Drafted_Labor_Cost_Rate__r.Cost_Rate_Name__c,Drafted_Labor_Cost_Rate__c,
                                 Sequence__c,Assignment_Position__c,Project_Task__r.Name,Project_Task__c,Total_Qty_Planned__c,Rate_Card_Rate__c,Rate_Card_Rate__r.Cost_Rate_Name__c,
                                 Total_of_Days_Eligible__c,Daily_Travel_Reimbursement_Amount__c,Bonus_Amount__c,Additional_Compensation_Type__c,
                                 Drafted_Labor_Cost_Rate__r.Status__c,Rate_Card_Rate__r.Status__c,Drafted_Labor_Cost_Rate__r.Rate_Type__c,Rate_Card_Rate__r.Rate_Type__c
                                 FROM Contact_Assignments__c WHERE RecordType.DeveloperName = :recordtypeName AND Project__c = :parentId];  
        }else if(objectName == 'Contract') {
            contactAssignRecs = [SELECT Id,Candidate_Name__c,Candidate_Name__r.Name,recordType.Name,Status__c,Candidate_Name__r.Supervisor_Name__c,Opportunity_Product_Id__c,
                                Assignment_Position__c,Oral_Exam_Date_Time__c,Sequence__c,Total_Qty_Planned__c,Start_Date__c,End_Date__c,Rate_Card_Rate__c,
                                Rate_Card_Rate__r.Cost_Rate_Name__c,Project_Task__c,Drafted_Labor_Cost_Rate__r.Status__c,Rate_Card_Rate__r.Status__c,Drafted_Labor_Cost_Rate__r.Rate_Type__c,
                                Rate_Card_Rate__r.Rate_Type__c  FROM Contact_Assignments__c  WHERE RecordType.DeveloperName = :recordtypeName AND Contract__c = :parentId];
        }
        system.debug(' records are '+contactAssignRecs);
        
        
        if(recordtypeName == 'Instructor') {
            if(contactAssignRecs.size() > 0){
                for(Contact_Assignments__c ca : contactAssignRecs){
                    if(ca.Rate_Card_Rate__c != null){
                        cRIdSet.add(ca.Rate_Card_Rate__c);
                    }else if(ca.Drafted_Labor_Cost_Rate__c != null){
                        cRIdSet.add(ca.Drafted_Labor_Cost_Rate__c);
                    }
                }
            }
            
            List<AcctSeed__Cost_Rates__c> crList =  [Select Id,Contact__c,(SELECT Id FROM Cost_Rates__r)FROM AcctSeed__Cost_Rates__c WHERE Id IN :cRIdSet Order By Effective_Date__c DESC];
            
            for(AcctSeed__Cost_Rates__c cr : crList){
                cALCRChildCount.put(cr.Contact__c+'-'+cr.Id,cr.Cost_Rates__r.size());
            }
            if(cALCRChildCount != null){
                wrapConAssign.cACostRAteChildCountMap = cALCRChildCount;
            }
        }
        
        /* To fix the OralDateTime TimeZone issue*/
        if(contactAssignRecs.size() > 0){
            for(Contact_Assignments__c ca : contactAssignRecs){
                ContactAssignmentDomain.ContactAssignmentWrapper caWrap = new ContactAssignmentDomain.ContactAssignmentWrapper();
                caWrap.oralExamDateTime = null;
                
                if(ca.Oral_Exam_Date_Time__c != null){
                    Datetime oralDateTime = ca.Oral_Exam_Date_Time__c;
                    caWrap.oralExamDateTime = oralDateTime.format('MM/dd/yyyy hh:mm a');
                }
                caWrap.caRecs = ca;
                caWrapList.add(caWrap);
            }
        }
        wrapConAssign.wrapConAssignList = caWrapList;
        
        Map<Id,String> oPLIMap = new Map<Id,String>();
        List<string> statusList = new List<String>();
        if( objectName == 'Opportunity'){
            for(OpportunityLineItem opl : [SELECT Id,Name,OpportunityId,Product2.Name FROM OpportunityLineItem WHERE OpportunityId = :parentId]) {
                String pdName = opl.Product2.Name;
                oPLIMap.put(opl.Id,pdName);
            }
            Boolean dLIWTOrecordType = false;
            List<Opportunity> oppList = [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity WHERE Id = :parentId];
            
            if(oppList.size() > 0){
                if(oppList[0].RecordType.DeveloperName == 'DLI_W_TO_Opportunities'){
                    dLIWTOrecordType = true;
                }
                if(dLIWTOrecordType){
                    if(recordtypeName == 'Instructor'){
                        List<string> dLIWTOrecordTypeStatusSet = new List<String>{'All', 'Proposed', 'Awarded', 'Canceled'};
                            statusList.addAll(dLIWTOrecordTypeStatusSet);
                    }else{
                        List<string> dLIWTOrecordTypeStatusSet = new List<String>{'All','Planned', 'On Hold', 'Ended', 'Canceled'};
                            statusList.addAll(dLIWTOrecordTypeStatusSet);   
                    }
                }
            }
        }
        wrapConAssign.wrapStatuspickList = statusList;   
        wrapConAssign.opliMap = oPLIMap;
        return wrapConAssign;
    }
    /**********************************************************************
        Created by Sivaprasanth on Nov 15 2018: This method to send the Email Attached with RecordDetails of selected row CARecord by User Click on Student Tab
        @ conId - pass the ContactId related to ContactAssignments
        @ oppId -pass the OpportunityId related to ContactAssignments 
     ***********************************************************************/
    @AuraEnabled 
    public static void cAStudentMailsend(String conId,String oppId) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        try{
            Id userId = UserInfo.getUserId();  
            if( conId != null && oppId != null && userId != null) {
                List<Contact>  conList = [SELECT Id,FirstName,LastName,Email FROM Contact Where Id = :conId];
                List<Opportunity> oppList = [SELECT Id,End_Date__c,Name,Start_Date__c,ILR_Final_Date__c,ILR_Midterm_Date__c,DLS_Ref__c FROM Opportunity WHERE Id = :oppId];
                List<User> userList = [SELECT Id,FirstName,LastName,Title,Phone,Email FROM User WHERE Id = :userId];
                if( conList != null && conList.size() > 0 && oppList != null && oppList.size() > 0  && userList != null && userList.size() > 0 ) {
                    
                    String dlsNo = oppList[0].DLS_Ref__c != null ? oppList[0].DLS_Ref__c : '';
                    String stDAte = oppList[0].Start_Date__c != null ? String.ValueOf(oppList[0].Start_Date__c) : '';
                    String ilrMidDate = oppList[0].ILR_Midterm_Date__c != null ? String.ValueOf(oppList[0].ILR_Midterm_Date__c) : '';
                    String endDate = oppList[0].End_Date__c != null ? String.ValueOf(oppList[0].End_Date__c): '';
                    String ilrFinalDate = oppList[0].ILR_Final_Date__c != null ? String.ValueOf(oppList[0].ILR_Final_Date__c) : '';
                    String fName = conList[0].FirstName != null ? conList[0].FirstName: '';
                    String lName = conList[0].LastName != null ? conList[0].LastName : '';
                    String usrFName = userList[0].FirstName != null ? userList[0].FirstName : '';
                    String usrLName = userList[0].LastName != null ? userList[0].LastName : '';
                    
                    mail.setToAddresses(new List<String>{conList[0].Email});
                    mail.setSubject('Student Timeline');
                    
                    String mailBody = 'Dear ' + fName + ' ' + lName +',<br/>';
                    mailBody += '<br/><div><span>Please see below and attached for the timeline of your experience at DLS</span></div>';
                    mailBody += '<br/><div>DLS Class #: '+ dlsNo +'</div>';
                    mailBody += '<div>Training Start Date: '+ stDAte +'</div>';
                    mailBody += '<div>Testing Mid-Term Date: '+ ilrMidDate +'</div>';
                    mailBody += '<div>Training End Date: '+endDate+'</div>';
                    mailBody += '<div>Testing Final Date: '+ilrFinalDate+'</div>';
                    mailBody += '<br/><div>Thank you,</div>';
                    mailBody += '<div>'+ usrFName + ' ' + usrLName +'</div>';
                    
                    if(userList[0].Title != null){
                        mailBody += '<div>'+userList[0].Title+'</div>';
                    }
                    if(userList[0].Phone != null){
                        mailBody += '<div>'+userList[0].Phone+'</div>';
                    }
                    if(userList[0].Email != null){
                        mailBody += '<div>'+userList[0].Email+'</div>';
                    }
                    
                    mail.setHtmlBody(mailBody);
                    List<Attachment> attach = [SELECT Id,Name,Body,ParentId FROM Attachment WHERE ParentId =: oppId AND Name LIKE '%TimeLine%' Order by CreatedDate DESC];
                    List<Messaging.Emailfileattachment> emailAttacList = new List<Messaging.Emailfileattachment>();
                    if( attach != null && attach.Size() > 0 ) {
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        efa.setFileName(attach[0].Name);
                        efa.setBody(attach[0].Body);
                        emailAttacList.add(efa);
                        mail.setFileAttachments(emailAttacList);
                    }
                    
                    if(!Test.isRunningTest()){
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    }
                }
                System.debug('mail :::'+mail );
            }        
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**********************************************************************
        Created by Sivaprasanth on Nov 30 2018: This method to get conqueryId from CongaqueryName which is called by congaButton method
        @ queryName - pass the CongaqueryName
     ***********************************************************************/
    @AuraEnabled
    public static Id getCongaQuery(String queryName) {
        return CongaTranslator.getCongaQuery(queryName);
    }
    @AuraEnabled
    public static String genPaymentFormCongaDocument(String caId,String docFor,String parentId){
        String congaTempId;
        String urlForConga;
        
        List<Contact_Assignments__c> ca = [SELECT Id,Candidate_Name__c,Rate_Card_rate__c,Candidate_Name__r.Supervisor_Name__c,Candidate_Name__r.Name,Candidate_Name__r.Supervisor_Name_Formula__c FROM Contact_Assignments__c WHERE Id = :caId];
       
        if(ca.size() > 0){
            
            String getServerUrlSessionId;
            if(!test.isRunningTest()){
                getServerUrlSessionId = CongaButtonsController.getServerUrlSessionId();
            }else{  
                Map<String,String> getServerUrlSessIdMap =  new Map<String,String> {
                    'sessionId' =>  'sessionId','serverUrl' =>  'serverUrl' };
                        getServerUrlSessionId = JSON.serialize(getServerUrlSessIdMap);   
            }
            Map<String, String> ServerUrlSessionIdMap = (Map<String, String>) System.JSON.deserialize(getServerUrlSessionId,Map<String, String>.class);
            
            if(docFor == 'Tester Payment Form' || docFor == 'send Tester Payment Form') {
                congaTempId = CongaTranslator.getCongaTemplate('Tester Payment Form');
                urlForConga = 'https://composer.congamerge.com?sessionId='+ServerUrlSessionIdMap.get('sessionId')+'&serverUrl='+ServerUrlSessionIdMap.get('serverUrl')+'&Id='+ca[0].Candidate_Name__c+'&templateId='+congaTempId+'&queryId=[Pro]'+CongaTranslator.getCongaQuery('Project Query for Job Summary Report')+'?pv0=' + parentId + ',[CR]'+CongaTranslator.getCongaQuery('ICA Agreement Cost Rate Query')+'?pv0='+ca[0].Rate_Card_rate__c; 
                if(docFor == 'send Tester Payment Form') {
                    urlForConga += '&qmode=DocuSign&DocuSignVisible=1&DocuSignR1ID='+ca[0].Candidate_Name__r.Supervisor_Name__c+'&DocuSignR1SignNow=0&DocusignR1SIPName='+ca[0].Candidate_Name__r.Supervisor_Name_Formula__c+'&DocuSignR1RoutingOrder=1&DocuSignR1Type=Signer&DocuSignR1Role=Signer 1'+
                        '&DocuSignR2ID='+ca[0].Candidate_Name__c+'&DocuSignR2SignNow=0&DocusignR2SIPName='+ca[0].Candidate_Name__r.Name +'&DocuSignR2RoutingOrder=2&DocuSignR1Type=Signer&DocuSignR2Role=Signer 2&DocuSignEndpoint=Demo';
                }
            }
        }
        return urlForConga;
    }
    /**********************************************************************
        Created by Sivaprasanth on Dec 2 2018: This method to get GenerateOfferLetter UrlLink by user click on Staff Tab 
        based on Templates and CongaQueryName
        @ Template1 - pass the template1 name
        @ Template2 - pass the template1 name
        @ Conquery - pass the CongaqueryName
        return  WrapperClass which is based on selected row CArecord Field details following case 
         1- All condition satifised Conga Document Generation Url 
         2- Any one of the Required field missing User requested to update that required fields.
     ***********************************************************************/
    @AuraEnabled  
    public static ContactAssignmentDomain.GenOfferLetterWrapper congaButton(String Template1,String Template2,String caId,String Conquery) {
        
        String queryName =Conquery;
        String temp;
        List<String> fieldsEmpty = new List<String>();
        List<Contact_Assignments__c> ca = [SELECT Id,Candidate_Name__r.Department__c ,Candidate_Name__r.Original_Hire_Date__c,
                                          Candidate_Name__r.Supervisor_Name__r.Name,Quantity_Unit__c,Candidate_Name__r.Supervisor_Name__c,
                                          Rate_Card_Rate__r.Annual_Salary_Cost__c,
                                          Rate_Card_Rate__r.Exempt_Status__c ,Rate_Card_Rate__r.AcctSeed__Hourly_Cost__c,Candidate_Name__r.DOL_Status__c,
                                          Rate_Card_Rate__c,Rate_Card_Rate__r.Semi_Monthly_Salary_Cost__c,
                                          Candidate_Name__r.First_Performance_Review_Date__c,Assignment_Position__c FROM Contact_Assignments__c WHERE Id=:caId];
        
        ContactAssignmentDomain.GenOfferLetterWrapper  GenOfferWrap = new  ContactAssignmentDomain.GenOfferLetterWrapper();
        GenOfferWrap.contactAssigns = ca[0];
        
        if(ca.size() > 0) {
            if(ca[0].Assignment_Position__c == null){
                temp =  Schema.Contact_Assignments__c.fields.Assignment_Position__c.getDescribe().getLabel();
                fieldsEmpty.add(temp);
            }
            if(ca[0].Quantity_Unit__c == null){
                temp =  Schema.Contact_Assignments__c.fields.Quantity_Unit__c.getDescribe().getLabel();
                fieldsEmpty.add(temp);
            }
            if(ca[0].Candidate_Name__r.Department__c == null){
                temp = 'Candidate Name - '+Schema.Contact.fields.Department__c.getDescribe().getLabel(); 
                fieldsEmpty.add(temp);
            }
            if(ca[0].Candidate_Name__r.Original_Hire_Date__c == null){
                temp = 'Candidate Name - '+Schema.Contact.fields.Original_Hire_Date__c.getDescribe().getLabel(); 
                fieldsEmpty.add(temp);
            }
            if(ca[0].Candidate_Name__r.Supervisor_Name__c == null){
                temp = 'Candidate Name - '+Schema.Contact.fields.Supervisor_Name__c.getDescribe().getLabel(); 
                fieldsEmpty.add(temp);
            }
            if(ca[0].Rate_Card_Rate__c != null){
                if(ca[0].Rate_Card_Rate__r.Exempt_Status__c == 'Exempt'){
                    if(ca[0].Rate_Card_Rate__r.Semi_Monthly_Salary_Cost__c == null){
                        temp = 'Rate Card: Rate - '+Schema.AcctSeed__Cost_Rates__c.fields.Semi_Monthly_Salary_Cost__c.getDescribe().getLabel(); 
                        fieldsEmpty.add(temp);
                    }
                    if(ca[0].Rate_Card_Rate__r.Annual_Salary_Cost__c == null){
                        temp = 'Rate Card: Rate - '+Schema.AcctSeed__Cost_Rates__c.fields.Annual_Salary_Cost__c.getDescribe().getLabel(); 
                        fieldsEmpty.add(temp);
                    }
                    if(ca[0].Candidate_Name__r.First_Performance_Review_Date__c == null){
                        temp = 'Candidate Name - '+Schema.Contact.fields.First_Performance_Review_Date__c.getDescribe().getLabel(); 
                        fieldsEmpty.add(temp);
                    }
                    if(ca[0].Assignment_Position__c != null && ca[0].Candidate_Name__r.Department__c != null && 
                       ca[0].Candidate_Name__r.Original_Hire_Date__c != null && ca[0].Candidate_Name__r.Supervisor_Name__r.Name != null && 
                       ca[0].Rate_Card_Rate__r.Semi_Monthly_Salary_Cost__c != null && ca[0].Rate_Card_Rate__r.Annual_Salary_Cost__c != null && 
                       ca[0].Candidate_Name__r.First_Performance_Review_Date__c != null)
                    {
                        APXTConga4__Conga_Template__c tem = [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = :Template1 LIMIT 1];
                        GenOfferWrap.OffLetterTemId = tem.Id;
                    }
                } else if(ca[0].Rate_Card_Rate__r.Exempt_Status__c == 'Non-Exempt'){
                    if(ca[0].Rate_Card_Rate__r.AcctSeed__Hourly_Cost__c == null){
                        temp = 'Rate Card: Rate - '+Schema.AcctSeed__Cost_Rates__c.fields.AcctSeed__Hourly_Cost__c.getDescribe().getLabel(); 
                        fieldsEmpty.add(temp);
                    }
                    if(ca[0].Rate_Card_Rate__r.Annual_Salary_Cost__c == null){
                        temp = 'Rate Card: Rate - '+Schema.AcctSeed__Cost_Rates__c.fields.Annual_Salary_Cost__c.getDescribe().getLabel(); 
                        fieldsEmpty.add(temp);
                    }
                    if(ca[0].Candidate_Name__r.DOL_Status__c == null){
                        temp = 'Candidate Name - '+Schema.Contact.fields.DOL_Status__c.getDescribe().getLabel(); 
                        fieldsEmpty.add(temp);
                    }
                    if(ca[0].Assignment_Position__c != null && ca[0].Candidate_Name__r.Department__c != null && ca[0].Candidate_Name__r.Original_Hire_Date__c != null && ca[0].Candidate_Name__r.Supervisor_Name__r.Name != null && ca[0].Rate_Card_Rate__r.Annual_Salary_Cost__c != null && ca[0].Rate_Card_Rate__r.AcctSeed__Hourly_Cost__c != null && ca[0].Candidate_Name__r.DOL_Status__c != null){
                        APXTConga4__Conga_Template__c tem = [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = :Template2 LIMIT 1];
                        GenOfferWrap.OffLetterTemId = tem.Id;
                        system.debug(':OffLetterTemId'+GenOfferWrap.OffLetterTemId);
                    }
                } else {
                    GenOfferWrap.ConditionFailed = 'You can generate Offer Letter only for Staff with "Exempt Status" as "Exempt" or "Non-Exempt".';
                }
            } else {
                GenOfferWrap.ConditionFailed = 'You can generate Offer Letter only for Staff with "Exempt Status". So Please select Cost Rate with "Exempt Status".';
            }
        } 
        
        GenOfferWrap.fieldsEmpty = fieldsEmpty;   
        String urlId ='';
        PageReference ref = Page.Conga_SessionIdServerUrl;
        if(!test.isRunningTest()){
            urlId = ref.getContent().toString();
        } else {
            urlId = ' Start_Of_Session_Id test End_Of_Session_Id';
        }
        Integer startIndex = urlId.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),endIndex = urlId.indexOf('End_Of_Session_Id');
        GenOfferWrap.getServerUrlSessionId = urlId.substring(startIndex, endIndex);
        
        Map<String, Id> qryNameIdMap = new Map<String, Id>();   
        for(String qryName : queryName.split(',')) {
            if(!qryNameIdMap.containsKey(qryName)) {
                qryNameIdMap.put(qryName, getCongaQuery(qryName));
            }
        }
        GenOfferWrap.getQryMap = qryNameIdMap;
        return GenOfferWrap;
        
    }
    /**********************************************************************
        Created by NS on Dec 5 2018: This method to get ContactAssignment Records based on RecordId,ParentId,RecordTypeNmaeObjectName on Add/Edit CARecord
        @ caRecordId - pass the ContactAssignmnets RecordId on Edit CARecord 
        @ caRTName - pass the RecordTypeName of (Opportunity || Project || Contract)
        @ parentType - pass the ObjectName of (Opportunity || Project || Contract)
        @ parentId -  pass the ParentId of (Opportunity || Project || Contract)
     ***********************************************************************/
    @AuraEnabled
    public static ContactAssignmentDomain.CADetails getCARelatedInformation(String caRecordId,String caRTName,String parentType,String parentId){
        ContactAssignmentDomain.CADetails caDetail = new ContactAssignmentDomain.CADetails();
        ContactAssignmentDomain.PicklistValues pValues = new ContactAssignmentDomain.PicklistValues();
        Map<Id,String> oPLIMap = new Map<Id,String>();
        Set<Id> insConId = new Set<Id>();
        Set<Id> staffConId = new Set<Id>();
        Map<String,List<Contact_Assignments__c>> caRTWithCAs = new Map<String,List<Contact_Assignments__c>>();   
        Set<String> crRateTypeForStaff = new Set<String> {'PT Hourly (OH & G&A)', 'FT Hourly & Benefits', 'FT Salary & Benefits'};       
        List<Contact_Assignments__c> caList = new List<Contact_Assignments__c>();
        
        // Prevent Labor Cost Rate(Rate Card Rate field) to edit on Active Contact Assignments if Contact Assignment Instructor has Time Card Entry Record.
        if(String.isNotBlank(caRecordId)){
            caList = SObjectQueryService.SObjectQuery('Contact_Assignments__c',new Set<Id>{caRecordId},',RecordType.DeveloperName,Drafted_Labor_Cost_Rate__r.Cost_Rate_Name__c,Rate_Card_Rate__r.Cost_Rate_Name__c,Project_Task__r.Default_Cost_Rate_Rate_Type__c');
            
            if((caList[0].Rate_Card_Rate__c != null || (caList[0].Drafted_Labor_Cost_Rate__c != null) && caList[0].RecordType.DeveloperName == 'Instructor')){
                
                if(caList[0].Rate_Card_Rate__c != null)   {        
                    caDetail.cRId = caList[0].Rate_Card_Rate__c;
                }else{
                    caDetail.cRId = caList[0].Drafted_Labor_Cost_Rate__c;   
                }
                if(caList[0].Project_Task__c != null && caList[0].project__c != null){
                    /*List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id,AcctSeed__Date__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c WHERE  
                       AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :caList[0].Project__c AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = :caList[0].Candidate_Name__c AND Status__c != 'Unposted' AND 
                     AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c = :caList[0].project__c AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c = :caList[0].Project_Task__c]; */
                    
                    List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id FROM  AcctSeed__Time_Card_Line__c WHERE AcctSeed__Project_Task__r.AcctSeed__Project__c = :caList[0].project__c AND AcctSeed__Project_Task__c = :caList[0].Project_Task__c  AND AcctSeed__Time_Card__r.Intructor__c = :caList[0].candidate_Name__c AND Contact_Assignment__c = :caRecordId AND (of_Pending_Time_Logs__c > 0 OR of_Submitted_Hours__c > 0 OR of_Approved_Hours__c > 0)];
                    
                    if(tclList.size() > 0){
                        caDetail.isCostRateTClTCD = true;
                    }else{
                        caDetail.isCostRateTClTCD = false;
                    }
                }
            }
        }
        pValues.timeApprovalPreferences = InstructorMyProfileController.objPickListFormation('Time_Approval_Preference__c','Contact_Assignments__c');
        caDetail.displayCRPicklist =  FeatureManagement.checkPermission('Access_CA_CR_Picklist');
        caDetail.showSchObservation = false;
        Id profileId = userinfo.getProfileId();
        if(profileId != null) {
            List<Profile> profileList = [Select Id,Name from Profile where Id=:profileId];
            caDetail.profileName = profileList[0].Name;
        }
        //Qry parent record
        String parentRTName = '';
        Id oppId;
        Id projectId;
        Id contractId;
        String defaultCostRate = '';
        Date stDate;
        Date endDate;
        Id trainingLocation;
        String oppStagName;
        Datetime  oralDateTime;
        String projectLocation = '';
        
        if(parentType == 'Opportunity'){
            
            List<Opportunity> oppList = SObjectQueryService.SObjectQuery('Opportunity',new Set<Id>{parentId},',RecordType.DeveloperName');
            parentRTName = oppList[0].RecordType.DeveloperName;
            oppId = parentId;
            defaultCostRate = oppList[0].Default_Cost_Rate_Rate_Type__c;
            stDate = oppList[0].Start_Date__c;
            endDate = oppList[0].End_Date__c;
            trainingLocation = oppList[0].Location__c;
            oppStagName = oppList[0].StageName;
            caDetail.parentStDate = oppList[0].Start_Date__c;
            caDetail.parentEdDate = oppList[0].End_Date__c;
            caDetail.dliProjectType = oppList[0].DLI_Project_Type__c; 
                
            if(parentRTName == 'New_Classes_Opportunities' || parentRTName == 'ODNI_CLP_Opportunities'){
                caDetail.showSchObservation = true;
            }
            
        }else if(parentType == 'AcctSeed__Project__c'){
            List<AcctSeed__Project__c> proList = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',new Set<Id>{parentId},',RecordType.DeveloperName,Training_Location__r.Name,AcctSeed__Account__r.Name');
            
            parentRTName = proList[0].RecordType.DeveloperName;
            projectId = parentId;
            projectLocation = proList[0].Training_Location__r.Name;
            oppId = proList[0].AcctSeed__Opportunity__c;
            defaultCostRate = proList[0].Default_Cost_Rate_Rate_Type__c;
            stDate = proList[0].Start_Date__c;
            endDate = proList[0].End_Date__c;
            trainingLocation = proList[0].Training_Location__c;
            oralDateTime = proList[0].Oral_Exam_Date_Time__c;
            caDetail.parentStDate = proList[0].Start_Date__c;
            caDetail.parentEdDate = proList[0].End_Date__c;
            caDetail.dliProjectType = proList[0].DLI_Project_Type__c; 
            caDetail.requestedHrWeek = proList[0].Hours_Week__c;
            
            
            if((caDetail.caRecord.Assignment_Position__c != 'Substitute Instructor' && caDetail.caRecord.Assignment_Position__c != 'Tester') &&
               (parentRTName == 'DODA_Projects' ||  parentRTName == 'EFL_Projects' ||  parentRTName == 'Language_Training_Projects' ||  parentRTName == 'MTT_Projects')
                && (!(proList[0].AcctSeed__Account__c != null && (proList[0].AcctSeed__Account__r.Name == 'PVT' || proList[0].AcctSeed__Account__r.Name.contains('PVT') || proList[0].AcctSeed__Account__r.Name.contains('DODA')) && proList[0].QB_Classification__c == 'OF0MTT0PS'))){  
                   caDetail.showSchObservation = true;
             }
            
        }else if(parentType == 'Contract'){
            
            List<Contract> contrats = SObjectQueryService.SObjectQuery('Contract',new Set<Id>{parentId},',RecordType.DeveloperName');
            parentRTName = contrats[0].RecordType.DeveloperName;
            contractId = parentId;
            stDate = contrats[0].Start_Date__c;
            endDate = contrats[0].End_Date__c;   
        }
        
        if(caRTName == 'Client_Partner'){
            pValues.positionValues = new List<String>{'Training Officer','Client','Coordinator','Billing Contact'};
        }else if(caRTName == 'Instructor'){
            pValues.positionValues = new List<String>{'Instructor','EI','Substitute Instructor','Tester'};            
        }else if(caRTName == 'Staff'){
            pValues.positionValues = new List<String>{'Project Manager','Project Support','Manager','Supervisor'};      
        }else if(caRTName == 'Consultant'){
            pValues.positionValues = new List<String>{'Consultant'};    
        }else if(caRTName == 'Student'){    
            pValues.positionValues = new List<String>{'Student','Class Leader'};  
        }
        
        // Status values related conditions
        if(parentType == 'Opportunity') {
            if(parentRTName == 'MTT_Opportunities'){
                pValues.statusValues = new List<String>{'Active','Planned','Proposed', 'On Hold', 'Ended', 'Canceled'};
            }else if(parentRTName == 'DLI_W_TO_Opportunities' || parentRTName == 'FSI_Opportunities'){
                 if(caRTName == 'Instructor'){
                     pValues.statusValues = new List<String>{'Proposed','Awarded', 'Canceled'};
                 }else{
                     pValues.statusValues = new List<String>{'Active','Planned','On Hold', 'Ended', 'Canceled'};
                 }
            }else{
                pValues.statusValues = new List<String>{'Active' ,'Planned','On Hold', 'Ended', 'Canceled'};

            }
        }else if(parentType == 'AcctSeed__Project__c'){
            pValues.statusValues = new List<String>{'Active','Planned','On Hold', 'Ended', 'Canceled'};
                if(parentRTName != 'MTT_Projects') {
                    //Added by NS on May 17 2022 from skype request
                    if(caRTName == 'Student' && (parentRTName == 'Language_Training_Projects' 
                        || parentRTName == 'DLI_W_LT_Projects' || parentRTName == 'DODA_Projects')){
                        pValues.statusValues.add('Transferred');
                    }
                }else if(parentRTName == 'MTT_Projects'){
                    pValues.statusValues.add('Proposed');
                }
            // Withdrawn picklist added for Student CA only
            if(caRTName == 'Student'){
                pValues.statusValues.add('Withdrawn');
            }
        }else if(parentType == 'Contract'){
            pValues.statusValues = new List<String>{'Active','Planned', 'On Hold', 'Ended', 'Canceled'};
        }
        
        //Position related conditions
        if(parentType == 'Opportunity'){
            if(parentRTName == 'DLI_W_TO_Opportunities'){
                if(caRTName == 'Instructor') {
                    pValues.positionValues.addAll(new List<String>{'Partner School Instructor','Partner School EI'});  
                }
            }
            
            if(parentRTName == 'CD_Opportunities'){
                if(caRTName == 'Instructor') {
                    pValues.positionValues = new List<String>{'Developer','Editor','Coordinator'};
                }
                if(caRTName == 'Staff'){
                    pValues.positionValues = new List<String>{'Manager','Assistant'};
                }
            }
            
            if(parentRTName == 'Translation_Opportunities'){
                if(caRTName == 'Instructor') {
                    pValues.positionValues = new List<String>{'Translator','Editor','DTP / Formatting'};
                }
                if(caRTName == 'Staff'){
                    pValues.positionValues = new List<String>{'Manager','Assistant'};
                }
            }
            
            if(parentRTName  == 'Interpretation_Opportunities'){
                if(caRTName == 'Instructor') {
                    pValues.positionValues = new List<String>{'Interpreter'};
                }
            }
        
            if(parentRTName == 'Admin_Opportunities'){
                if(caRTName == 'Staff'){
                    pValues.positionValues = new List<String>{'Staff','Manager'};
                }
            }
            
            if(parentRTName == 'New_Classes_Opportunities'){
                if(caRTName == 'Staff'){
                    pValues.positionValues = new List<String>{'Project Manager','Project Support','Supervisor'};      
                }
            }
            
            if(parentRTName == 'Testing_Opportunities'){
                if(caRTName == 'Instructor'){
                    pValues.positionValues.add('Examiner');
                }
            }
            
        }else if(parentType == 'AcctSeed__Project__c'){
            
            if(parentRTName == 'Admin_Projects'){
                if(caRTName == 'Staff'){
                    pValues.positionValues = new List<String>{'Staff','Manager'};
                }
            }
            
            if(parentRTName == 'DLI_W_LT_Projects'){
                if(caRTName == 'Client_Partner'){
                    pValues.positionValues.addAll(new List<String>{'Academic Adviser','COR'});
                }
                
                if(caRTName == 'Instructor') {
                    pValues.positionValues.addAll(new List<String>{'Partner School Instructor','Partner School EI'});  
                }
            }
            
            if(parentRTName == 'Language_Training_Projects'){
                if(caRTName == 'Client_Partner'){
                    pValues.positionValues.add('COR');
                }
                if(caRTName == 'Staff'){
                    pValues.positionValues = new List<String>{'Project Manager','Project Support','Supervisor'};      
                }
            }
            
            if(parentRTName == 'CD_Projects'){
                if(caRTName == 'Instructor') {
                    pValues.positionValues = new List<String>{'Developer','Editor','Coordinator'};
                }
                if(caRTName == 'Staff'){
                    pValues.positionValues = new List<String>{'Manager','Assistant'};
                }
            }
            
            if(parentRTName  == 'Interpretation_Projects'){
                if(caRTName == 'Instructor') {
                    pValues.positionValues = new List<String>{'Interpreter'};
                }
            }
            
            if(parentRTName == 'Translation_Projects'){
                if(caRTName == 'Instructor') {
                    pValues.positionValues = new List<String>{'Translator','Editor','DTP / Formatting'};
                }
                if(caRTName == 'Staff'){
                    pValues.positionValues = new List<String>{'Manager','Assistant'};
                }
            }
            
            if(parentRTName == 'Testing_Projects'){
                if(caRTName == 'Staff'){
                    pValues.positionValues = new List<String>{'Project Manager','Project Support','Manager','Supervisor','Examiner'};
                }
                if(caRTName == 'Instructor'){
                     pValues.positionValues.add('Examiner');
                }
            }
        }else if(parentType == 'Contract'){
            if(caRTName == 'Staff'){
                pValues.positionValues = new List<String>{'Contracting POC','Technical POC'};
            }
            if(caRTName == 'Client_Partner'){
                pValues.positionValues = new List<String>{'Contracting POC','Technical POC'};
            }
        }
        
        //Score values
        List<String> scores = new List<String>();
        List<Schema.PicklistEntry> scorePickList = Contact_Assignments__c.S_Score_Final__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : scorePickList) {
            scores.add(entry.getValue());
        }
        pValues.scoreValues = scores;
        
        //Project Task formation
        if(parentType == 'AcctSeed__Project__c'){
            List<AcctSeed__Project_Task__c> taskList = new List<AcctSeed__Project_Task__c>();
            if(parentRTName != 'Linguist_Support_Projects'){
                taskList = [SELECT Id,Name,Project_Task_Type__c 
                            FROM AcctSeed__Project_Task__c 
                            WHERE AcctSeed__Project__c = :parentId AND Parent_Project_Task__c = null 
                             AND RecordType.DeveloperName != 'Material_Budget' 
                             AND Product__r.Name != 'Registration Fee - On-Site'];
            }else if(parentRTName == 'Linguist_Support_Projects'){
                taskList = [SELECT Id,Name,Project_Task_Type__c 
                            FROM AcctSeed__Project_Task__c 
                            WHERE AcctSeed__Project__c = :parentId 
                            AND Project_Task_Type__c IN ('Linguist Support','Linguist Support Services','ADMINISTRATIVE','Curriculum Development') 
                            AND Parent_Project_Task__c = null 
                            AND RecordType.DeveloperName != 'Material_Budget'  
                            AND Product__r.Name != 'Registration Fee - On-Site'];    
            }
            
            pValues.taskRecords = taskList;
        }else if(parentType == 'Opportunity'){
            
            Map<String,Decimal> prodNameCountMap = new Map<String, Decimal>();
            pValues.opliRecords = new List<ContactAssignmentDomain.OPLIDetail>();
            for(OpportunityLineItem opl : [SELECT Id,Name,OpportunityId,Product2.Name FROM OpportunityLineItem WHERE OpportunityId = :parentId AND Product2.Name NOT IN ('Registration Fee - On-Site','Language Materials')]) {
                String pdName = opl.Product2.Name;
                if(prodNameCountMap.containskey(opl.Product2.Name)) {
                    prodNameCountMap.put(opl.Product2.Name, prodNameCountMap.get(opl.Product2.Name) + 1);
                    pdName = pdName + ' ' + prodNameCountMap.get(opl.Product2.Name); 
                } else {
                    prodNameCountMap.put(opl.Product2.Name, 1);
                }
                ContactAssignmentDomain.OPLIDetail opliRec = new ContactAssignmentDomain.OPLIDetail();
                opliRec.id = opl.Id;
                opliRec.name = pdName;
                pValues.opliRecords.add(opliRec);
                oPLIMap.put(opl.Id,pdName);
            }  
        }
        //Quantity Units
        List<String> qUnites = new List<String>();
        List<Schema.PicklistEntry> qtyPickList = Contact_Assignments__c.Quantity_Unit__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : qtyPickList) {
            qUnites.add(entry.getValue());
        }
        pValues.quantityUnits = qUnites;
        
        if(caList.size() > 0){
            caDetail.caRecord = caList[0];  
            
            pValues.costRateLst = new List<ContactAssignmentDomain.RateCostRate>();
            caDetail.isNew = false;
            
            pValues.noOfLaptopIssues = new List<Integer>{0,1,2,3,4,5};
                for(Contact_Assignments__c cA : caList) {
                    if(!caRTWithCAs.containskey(ca.RecordType.DeveloperName)) {
                        caRTWithCAs.put(ca.RecordType.DeveloperName, new List<Contact_Assignments__c>());
                    } 
                    caRTWithCAs.get(ca.RecordType.DeveloperName).add(cA); 
                    if(cA.RecordType.DeveloperName == 'Instructor') {
                        insConId.add(cA.Candidate_Name__c);
                    } else if(cA.RecordType.DeveloperName == 'Staff') {
                        staffConId.add(cA.Candidate_Name__c);
                    }
                    
                } 
            if(caList[0].Status__c == 'Awarded'){
                caDetail.existingAwarded = true;
            }else{
                caDetail.existingAwarded = false;  
            }
            
            if(caList[0].Project_Task__c != null || caList[0].Opportunity_Product_Id__c != null ){
                caDetail.isOPLIPT = true;
            }else{
                caDetail.isOPLIPT = false;
            }
            
            if(caList[0].Candidate_Name__c != null){
                String conId = '';
                List<AcctSeed__Cost_Rates__c> lstcostRate =  new  List<AcctSeed__Cost_Rates__c>();
                if(parentRTName  == 'Interpretation_Projects' || parentRTName == 'Translation_Projects'){
                    if(caList[0].Project_Task__r.Default_Cost_Rate_Rate_Type__c == 'Non-SCA Translation (Per Word)'){
                        //**lstcostRate = [SELECT Id,Name,Rate_Type__c,Cost_Rate_Name__c,Contact__r.RecordType.DeveloperName,Contact__c,Status__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c != null AND Contact__c =: caList[0].Candidate_Name__c AND Status__c IN ('Approved','Draft','Submitted for Approval') AND Rate_Type__c IN ('Non-SCA Translation W/O Editing (Per Word)','Non-SCA Translation Editing Only (Per Word)','Non-SCA Translation + Editing (Per Word)','FT Salary & Benefits') Order By Effective_Date__c Desc];
                        conId = caList[0].Candidate_Name__c;
                        lstcostRate = CostRateService.getCostrateRec(' WHERE Rate_Type__c != NULL AND Contact__c = \''+ conId + '\' AND Status__c IN (\'Approved\',\'Draft\',\'Submitted for Approval\') AND Rate_Type__c IN (\'Non-SCA Translation W/O Editing (Per Word)\',\'Non-SCA Translation Editing Only (Per Word)\',\'Non-SCA Translation + Editing (Per Word)\',\'FT Salary & Benefits\') Order By Effective_Date__c Desc', 'Contact__r.RecordType.DeveloperName');
                    }else if(caList[0].Project_Task__r.Default_Cost_Rate_Rate_Type__c == 'Non-SCA Translation (Per Hour)' || caList[0].Project_Task__r.Default_Cost_Rate_Rate_Type__c == 'Non-SCA Interpretation (Per Hour)' || caList[0].Project_Task__r.Default_Cost_Rate_Rate_Type__c == 'Non-SCA Translation (FFP)'){
                        String costRATEcR = caList[0].Project_Task__r.Default_Cost_Rate_Rate_Type__c;
                        conId = caList[0].Candidate_Name__c;
                        //**lstcostRate = [SELECT Id,Name,Rate_Type__c,Cost_Rate_Name__c,Contact__r.RecordType.DeveloperName,Contact__c,Status__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c != null AND Contact__c =: caList[0].Candidate_Name__c AND Status__c IN ('Approved','Draft','Submitted for Approval') AND (Rate_Type__c = : costRATEcR OR Rate_Type__c = 'FT Salary & Benefits') Order By Effective_Date__c Desc];
                        lstcostRate = CostRateService.getCostrateRec(' WHERE Rate_Type__c != NULL AND Contact__c = \''+ conId + '\' AND Status__c IN (\'Approved\',\'Draft\',\'Submitted for Approval\') AND (Rate_Type__c = \'' + costRATEcR + '\' OR Rate_Type__c = \'FT Salary & Benefits\') Order By Effective_Date__c Desc', 'Contact__r.RecordType.DeveloperName');
                    }                 

                }   //W-006039 -  Process change when DLI projects are sub-contracted
                else if(caRTName == 'Instructor' && (parentType == 'AcctSeed__Project__c' || parentType == 'Opportunity') && caDetail.dliProjectType == 'Partner School' 
                        && defaultCostRate == 'SubK-LT' && (parentRTName == 'DLI_W_LT_Projects' || parentRTName == 'DLI_W_TO_Opportunities')){
                    
                     lstcostRate = CostRateService.getCostrateRec(' WHERE Rate_Type__c != NULL AND Account__c = \''+ caList[0].Account__c + '\' AND Status__c IN (\'Approved\',\'Draft\',\'Submitted for Approval\') Order By Effective_Date__c Desc', 'Contact__r.RecordType.DeveloperName');
                }else {
                    //**lstcostRate = [SELECT Id,Name,Rate_Type__c,Cost_Rate_Name__c,Contact__r.RecordType.DeveloperName,Contact__c,Status__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c != null AND Contact__c =: caList[0].Candidate_Name__c AND Status__c IN ('Approved','Draft','Submitted for Approval') Order By Effective_Date__c Desc];
                    conId = caList[0].Candidate_Name__c; 
                    lstcostRate = CostRateService.getCostrateRec(' WHERE Rate_Type__c != NULL AND Contact__c = \''+ conId + '\' AND Status__c IN (\'Approved\',\'Draft\',\'Submitted for Approval\') Order By Effective_Date__c Desc', 'Contact__r.RecordType.DeveloperName');
                }
                
                for(AcctSeed__Cost_Rates__c lstCR :lstcostRate){
                    ContactAssignmentDomain.RateCostRate rateCR = new ContactAssignmentDomain.RateCostRate();
                    String Nme = lstCR.Cost_Rate_Name__c;
                    if(lstCR.Status__c != 'Approved') {
                        Nme = lstCR.Cost_Rate_Name__c+' ('+lstCR.Status__c+')'; 
                    }
                    rateCR.cRID = lstCR.Id;
                    rateCR.costName = Nme;
                    
                    //W-006039 -  Process change when DLI projects are sub-contracted
                    if(caRTName == 'Instructor' && (parentType == 'AcctSeed__Project__c' ||  parentType == 'Opportunity')&& caDetail.dliProjectType == 'Partner School' 
                       && defaultCostRate == 'SubK-LT' && (parentRTName == 'DLI_W_LT_Projects' || parentRTName == 'DLI_W_TO_Opportunities')){
                           if(lstCR.Rate_Type__c == 'SubK-LT'){
                               pValues.costRateLst.add(rateCR);
                           }
                    }else if(parentRTName  == 'Interpretation_Projects' || parentRTName == 'Translation_Projects'){
                        if(caList[0].Project_Task__r.Default_Cost_Rate_Rate_Type__c == 'Non-SCA Translation (Per Word)'){
                            if(insConId.contains(lstCR.Contact__c) || staffConId.contains(lstCR.Contact__c)) {
                                pValues.costRateLst.add(rateCR);
                            } 
                        }else if(caList[0].Project_Task__r.Default_Cost_Rate_Rate_Type__c == 'Non-SCA Translation (Per Hour)' || caList[0].Project_Task__r.Default_Cost_Rate_Rate_Type__c == 'Non-SCA Interpretation (Per Hour)' || caList[0].Project_Task__r.Default_Cost_Rate_Rate_Type__c == 'Non-SCA Translation (FFP)' ){
                            if(insConId.contains(lstCR.Contact__c)  || staffConId.contains(lstCR.Contact__c)){
                                pValues.costRateLst.add(rateCR);
                            }             
                        }
                    }else {
                        if(insConId.contains(lstCR.Contact__c) && ( lstCR.Rate_Type__c == defaultCostRate || (lstCR.Contact__r.RecordType.DeveloperName == 'DLS_Employee' && lstCR.Rate_Type__c == 'FT Salary & Benefits'))) {
                            pValues.costRateLst.add(rateCR);
                        }else if((staffConId.contains(lstCR.Contact__c)  || parentType == 'Admin_Projects')  &&( crRateTypeForStaff.contains(lstCR.Rate_Type__c) || lstCR.Rate_Type__c == defaultCostRate)) {
                            pValues.costRateLst.add(rateCR);
                        }else if(insConId.contains(lstCR.Contact__c) && (defaultCostRate == 'DLI-16 SCA MTT' || defaultCostRate == 'DLI-20 SCA MTT') && (lstCR.Rate_Type__c == 'FT Salary & Benefits' || lstCR.Rate_Type__c == 'Non-SCA MTT (1099)')){
                            pValues.costRateLst.add(rateCR);
                        }else if(insConId.contains(lstCR.Contact__c) && (defaultCostRate == 'DLI-16 SCA CD' || defaultCostRate == 'DLI-20 SCA CD') && (lstCR.Rate_Type__c == 'FT Salary & Benefits' || (lstCR.Rate_Type__c == 'DLI-16 SCA CD (1099)' || lstCR.Rate_Type__c == 'DLI-20 SCA CD (1099)') ||  lstCR.Rate_Type__c == 'Non-SCA CD (1099)')){
                            pValues.costRateLst.add(rateCR);
                        }else if(insConId.contains(lstCR.Contact__c) && (defaultCostRate == 'DLI-16 SCA LT' || defaultCostRate == 'DLI-20 SCA LT') && (lstCR.Rate_Type__c == 'FT Salary & Benefits')){
                            pValues.costRateLst.add(rateCR);
                        }else if(insConId.contains(lstCR.Contact__c) && (defaultCostRate == 'LT with Prep' || defaultCostRate == 'LT without Prep') && (lstCR.Rate_Type__c == 'FT Salary & Benefits')){ // Non-SCA LT
                            pValues.costRateLst.add(rateCR);
                        }else if(insConId.contains(lstCR.Contact__c) && defaultCostRate == 'Non-SCA CD' && (lstCR.Rate_Type__c == 'FT Salary & Benefits')){
                            pValues.costRateLst.add(rateCR);
                        }
                    }
                } 
            }
        }else{
            caDetail.caRecord = new Contact_Assignments__c();
            caDetail.caRecord.RecordTypeId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get(caRTName).getRecordTypeId();
            caDetail.caRecord.Start_Date__c = stDate;
            caDetail.caRecord.End_Date__c = endDate;
            caDetail.caRecord.Location__c = trainingLocation;
            caDetail.caRecord.Status__c = 'Planned';
            caDetail.isOPLIPT = false;
            caDetail.existingAwarded = false;
            
            // Commented the below conditions as we are going to create Monthly Obs Report for DLI Projects
            // parentRTName == 'DLI_W_TO_Opportunities' ||  parentRTName == 'DLI_W_LT_Projects'
            if(parentRTName == 'New_Classes_Opportunities' || parentRTName == 'ODNI_CLP_Opportunities'
                || parentRTName == 'DODA_Projects' || parentRTName == 'MTT_Projects' || 
              parentRTName == 'EFL_Projects' || parentRTName == 'Language_Training_Projects'){
                caDetail.caRecord.Schedule_Observation__c = 'Yes';
            }
            
            caDetail.isNew = true;
            
            if(parentRTName == 'DLI_W_TO_Opportunities' || parentRTName == 'FSI_Opportunities'){
                if(caRTName == 'Instructor'){
                    caDetail.caRecord.Status__c = 'Proposed'; 
                }
            } 
            
            if(caRTName == 'Instructor'){
                if(parentRTName == 'Translation_Projects' || (parentRTName  == 'Translation_Opportunities')){
                    caDetail.caRecord.Assignment_Position__c = 'Translator';   
                }else if(parentRTName == 'Interpretation_Projects' || parentRTName  == 'Interpretation_Opportunities'){
                    caDetail.caRecord.Assignment_Position__c = 'Interpreter';  
                }else if (parentRTName =='CD_Projects' || parentRTName == 'CD_Opportunities'){
                    caDetail.caRecord.Assignment_Position__c = 'Developer';
                }else{
                    caDetail.caRecord.Assignment_Position__c = 'Instructor';
                }

            }else if( caRTName == 'Client_Partner' ) {
                caDetail.caRecord.Assignment_Position__c = 'Training Officer';
            }else if(caRTName == 'Staff' ){
                caDetail.caRecord.Assignment_Position__c = 'Project Manager';   
            }else if(caRTName == 'Consultant'){
                caDetail.caRecord.Assignment_Position__c = 'Consultant';
            }else if(caRTName == 'Student'){
                caDetail.caRecord.Assignment_Position__c = 'Student';
            }
            if(caRTName == 'Staff' && (parentRTName == 'Translation_Projects' || parentRTName  == 'Translation_Opportunities' || parentRTName =='CD_Projects' || parentRTName == 'CD_Opportunities')){
                caDetail.caRecord.Assignment_Position__c = 'Manager';
            }
            if(caRTName == 'Staff' &&  parentRTName == 'Admin_Projects'){
                caDetail.caRecord.Assignment_Position__c = 'Staff';
            }
            
            if(parentType == 'Contract'){
                if(caRTName == 'Staff'){
                    caDetail.caRecord.Assignment_Position__c = 'Technical POC';
                    
                }
                if(caRTName == 'Client_Partner'){
                    caDetail.caRecord.Assignment_Position__c = 'Contracting POC';       
                }
            }
            
            caDetail.caRecord.Opportunity_Name__c = oppId;
            caDetail.caRecord.Project__c = projectId;
            caDetail.caRecord.Contract__c = contractId;
            caDetail.caRecord.Oral_Exam_Date_Time__c = oralDateTime;
        }
        caDetail.oppId = oppId;
        caDetail.projectId = projectId;
        caDetail.defaultCostRate = defaultCostRate;
        caDetail.pickValues = pValues;
        caDetail.projectLocation = projectLocation;
        caDetail.opliMap = oPLIMap;
        caDetail.parentRecordType = parentRTName;
        caDetail.oppStageName = oppStagName;
      
        return CADetail;
    }
    /**********************************************************************
        Created by SivaPrasanth on Dec 8 2018: This method to save the ContactAssignment Record.
        @ conAssignJson - pass the ContactAssignmentRecord as JSON String 
        @cARecordType - ContactAssignment RecordType
        @parentRecordType - Project or Opportunity or Contract  RecordType
    ***********************************************************************/
    @AuraEnabled
    public static String saveContactAssignment(String sObjName,String conAssignJson, String parentRecordType, String cARecordType, String defaultCR, String actionPerform, String dliProjectType){
        isFromCA = true; // isFromCA is used for Additional Compensation Process
        String conName = '';
        String projectName = ''; 
        String effectiveDate;
        String hourlyCostRate = '';
        Date efDate;
        
        List<Contact_Assignments__c> caRecordsList = (List<Contact_Assignments__c>) System.JSON.deserialize(conAssignJson, List<Contact_Assignments__c>.class);
        try{
            if(caRecordsList != null && caRecordsList.size() > 0){
                if((parentRecordType == 'Interpretation_Projects' || parentRecordType == 'Translation_Projects') && cARecordType == 'Instructor' && caRecordsList[0].Status__c == 'Ended' && caRecordsList[0].Invoice_Date__c != null && caRecordsList[0].Quantity_Actual__c != null){
                    caRecordsList[0].Invoice_Received_Date__c = System.now(); // To update Invoice Received Date in CA.This update process moved from workflow to here.
                }
                upsert caRecordsList;
                
                
                /* Send CR Creation with CA Notification Email to Sub Contract type related Instructor Contact */
                if(sObjName == 'AcctSeed__Project__c' && parentRecordType == 'DLI_W_LT_Projects' && cARecordType == 'Instructor' 
                   && caRecordsList[0].Account__c != null  && actionPerform == 'Create' && ((dliProjectType == 'Partner School' && defaultCR == 'SubK-LT') || (caRecordsList[0].Assignment_Position__c == 'Partner School EI' || caRecordsList[0].Assignment_Position__c  == 'Partner School Instructor'))){
                    
                    List<Contact_Assignments__c> caRec = [SELECT Id,Candidate_Name__c,Start_Date__c,Drafted_Labor_Cost_Rate__c,Rate_Card_Rate__c,Candidate_Name__r.Email,Assignment_Position__c,
                                                            Candidate_Name__r.FirstName,Candidate_Name__r.LastName,Project__c,Project__r.Name,Drafted_Labor_Cost_Rate__r.Effective_Date__c,
                                                            Drafted_Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c,Rate_Card_Rate__r.AcctSeed__Hourly_Cost__c,Rate_Card_Rate__r.Effective_Date__c
                                                          FROM Contact_Assignments__c WHERE Id = :caRecordsList[0].Id];
                                                          
                    String subKLT = System.Label.SubK_LT_Cost_Rate_Notification_Email;
                    List<String> subKLTEmail = new List<String>();
                    if(subKLT != null && subKLT != '') {
                        subKLTEmail = subKLT.split(',');
                    }
                       
                    System.debug('subKLTEmail::::'+subKLTEmail);
                    if(caRec != null && caRec.size() > 0 && subKLTEmail != null && subKLTEmail.size() > 0){
                        
                        if(caRec[0].Candidate_Name__r.FirstName != null){
                            conName = caRec[0].Candidate_Name__r.FirstName+' ';
                        }
                        
                        if(caRec[0].Candidate_Name__r.LastName != null){
                            conName += caRec[0].Candidate_Name__r.LastName;
                        }
                        
                        if(caRec[0].Project__c != null && caRec[0].Project__r.Name != null){
                            projectName = caRec[0].Project__r.Name;
                        }
                        
                        if(caRec[0].Rate_Card_Rate__c != null){
                            
                            if(caRec[0].Rate_Card_Rate__r.AcctSeed__Hourly_Cost__c != null){
                                hourlyCostRate = String.valueOf((caRec[0].Rate_Card_Rate__r.AcctSeed__Hourly_Cost__c).setScale(2));
                            }
                            
                        }else if(caRec[0].Drafted_Labor_Cost_Rate__c != null){
                            
                            if(caRec[0].Drafted_Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null){
                                hourlyCostRate = String.valueOf((caRec[0].Drafted_Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c).setScale(2));
                            }
                        }
                        if(caRec[0].Start_Date__c != null){
                            efDate = caRec[0].Start_Date__c;
                            effectiveDate = String.valueOf(efDate).split('-')[1]+'/'+String.valueOf(efDate).split('-')[2]+'/'+String.valueOf(efDate).split('-')[0];
                        }
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(subKLTEmail);
                        mail.setSubject('Contact Assignment assigned with a SubK-LT Cost Rate.');
                        
                        String htmlBody = '';
                        htmlBody += 'Hi All,<br/><br/>';
                        htmlBody += 'A new Contact Assignment has been assigned to a Project with a SubK-LT Cost Rate.'+'<br/>';
                        htmlBody += '<table style="border-collapse: collapse;">';
                        htmlBody += '<tr><th style="padding:10px;border: 1px solid black;">Instructor</th>';
                        htmlBody += '<th style="padding:10px;border: 1px solid black;">Project</th>';
                        htmlBody += '<th style="padding:10px;border: 1px solid black;">Rate Type</th>';
                        htmlBody += '<th style="padding:10px;border: 1px solid black;">Hourly Rate</th>';
                        htmlBody += '<th style="padding:10px;border: 1px solid black;">Effective Date</th></tr><tr>';
                        htmlBody += '<td style="padding:10px;border: 1px solid black;"><a href="'+System.Label.Org_Prefix_Start_URL+'/lightning/r/'+caRec[0].Candidate_Name__c+'/view" target="_blank">' + conName + '</a></td>';
                        htmlBody += '<td style="padding:10px;border: 1px solid black;"><a href="'+System.Label.Org_Prefix_Start_URL+'/lightning/r/'+caRec[0].Project__c+'/view" target="_blank">' + projectName + '</a></td>';
                        htmlBody += '<td style="padding:10px;border: 1px solid black;">' + defaultCR + '</td>';
                        htmlBody += '<td style="padding:10px;border: 1px solid black;">' + hourlyCostRate + '</td>';
                        htmlBody += '<td style="padding:10px;border: 1px solid black;">'+ effectiveDate + '</td></tr>';
                        htmlBody += '</table>'; 
                        htmlBody += '<br/><br/>';
                        htmlBody += 'Thanks,<br/>';
                        htmlBody += 'DLS<br/>';
                        
                        mail.setHtmlBody(htmlBody);
                        
                        if(!Test.isRunningTest()){
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        }
                    }   
                }
                return caRecordsList[0].Id;
            }
            return 'SUCCESS';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**********************************************************************
        Created by SivaPrasanth on Dec 12 2018: This method to Authenticate the loginUser for Add/Edit/Delete Permission
        @ recordAccess - pass the Add/Edit/Delete imformation
        return true if Authenticated User
     ***********************************************************************/
    @AuraEnabled
    public static  Boolean cARecordAccess(String recordAccess){
        if(recordAccess == 'Edit'){
            return Schema.sObjectType.Contact_Assignments__c.isDeletable();
        }else if(recordAccess == 'Delete'){
            return Schema.sObjectType.Contact_Assignments__c.isUpdateable();
        }else if(recordAccess =='Create'){
            return Schema.sObjectType.Contact_Assignments__c.isCreateable();
        }
        return null;
    }
    /**********************************************************************
        Created by SivaPrasanth on Dec 13 2018: This method to delete ContactAssignment Record Basedon ContactAssignmentId
        @ cAId - pass the ContactAssignmentId
     ***********************************************************************/
    @AuraEnabled
    public static Contact_Assignments__c cADeleteRecord(String cAId){
        Contact_Assignments__c conAssign = new  Contact_Assignments__c (Id = cAId); 
        try{
            delete conAssign;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return conAssign;
    }
    /**********************************************************************
    Created by SivaPrasanth on Jul 26 2019: This method to get length of Staff ContactAssignment Active Status record
    @ parentId - pass the of ProjectId
    ***********************************************************************/
    @AuraEnabled
    public static Integer validateStaffActiveStatus(String parentId){
        
        List<Contact_Assignments__c> conAssignList =  [Select Id,Name,Status__c FROM Contact_Assignments__c WHERE Status__c = 'Active' AND recordType.Name = 'Staff' AND Project__c = :parentId];
        if(conAssignList.size() > 0) {
            
            return conAssignList.size();
        }
        return 0;
    }
    
    /**********************************************************************
        Created by SivaPrasanth on Dec 14 2018: This method to update the ContactAssignment Statusfield is Ended which is related to ProjectId.
        @ parentId - pass the of ProjectId
        @conAssignJson - pass the ContactAssignment  record
     ***********************************************************************/
    @AuraEnabled
    public static void staffStatusUpdate( String  parentId  ,String conAssignJson){
        List<Contact_Assignments__c> caRecordsList = (List<Contact_Assignments__c>) System.JSON.deserialize(conAssignJson, List<Contact_Assignments__c>.class);
        try{
            if(caRecordsList.size() > 0){
                upsert caRecordsList;  
                List<Contact_Assignments__c> conassign= [Select Id,Name,Status__c FROM Contact_Assignments__c WHERE Status__c = 'Active' AND recordType.Name = 'Staff' AND Project__c = :parentId AND Id= :caRecordsList[0].Id Order By createdDate DESC Limit 1 ];
                if(conassign.size() >0){
                    List<Contact_Assignments__c> updateCA =  [Select Id,Name,Status__c FROM Contact_Assignments__c WHERE Status__c = 'Active' AND recordType.Name = 'Staff' AND Project__c = :parentId AND Id != :caRecordsList[0].Id];
                    for(Contact_Assignments__c conAssignment: updateCA){
                        conAssignment.Status__c = 'Ended';  
                    }
                    update updateCA;
                }
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**********************************************************************
        Created by SivaPrasanth on Dec 15 2018: This method to end the Schedule When Contact have Schedule Record.
        @ contactId - pass the of ContactId
        @projectId - pass the projectId related to ContactAssignment
        return size of Schedule Record
      ***********************************************************************/
    @AuraEnabled
    public static Boolean validateInsEndStatusEditDelete(String contactId, String projectId, String caId){
        
        if(String.isNotBlank(contactId) && String.isNotBlank(projectId) && String.isNotBlank(caId)){
            List<Contact_Assignments__c> caList = [SELECT Id FROM Contact_Assignments__c WHERE Id != :caId AND Candidate_Name__c =: contactId AND Project__c =: projectId AND Status__c = 'Active'];
            List<Schedule__c>  schlst = [Select Id,Instructor__c FROM Schedule__c WHERE  Instructor__c =: contactId AND Project__c =: projectId AND Status__c NOT IN ('Canceled','Canceled','Completed')];   
        
            if(caList.size() == 0 && schlst.size() > 0){
                return true;
            }
        }
        return false;
    }
    
   /*********************************************************************
        Created by SivaPrasanth on Dec 14 2018: This method to update costrate to RateCardRate field when user select the Non-SCA Testing defaultCosRate
        @ContactId - pass the of Contact Id
        @defaultCR - pass DefaultCostRate of(Project || Opportunity Id)
    ***********************************************************************/
    @AuraEnabled
    public static ContactAssignmentDomain.CostRateDetails staffNonScaTestingmethod(String contactId,String defaultCR){
        Set<String> crRateTypeForStaff = new Set<String> {'PT Hourly (OH & G&A)', 'FT Hourly & Benefits', 'FT Salary & Benefits'};
        Map<String,AcctSeed__Cost_Rates__c> costRateMapForStaff = new  Map<String,AcctSeed__Cost_Rates__c>();
        ContactAssignmentDomain.CostRateDetails  costDetails = new ContactAssignmentDomain.CostRateDetails();
        CostDetails.isAlreadyCRExist = false;

        //**List<AcctSeed__Cost_Rates__c> crsForStaff = [SELECT Id,Name,Rate_Type__c,Contact__c,Status__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c IN: crRateTypeForStaff AND Status__c IN ('Submitted for Approval','Approved','Draft') AND Contact__c =: conAssign[0].Candidate_Name__c Order by Effective_Date__c Desc];
        
        List<AcctSeed__Cost_Rates__c> crsForStaff = CostRateService.getCostrateRec(' WHERE Rate_Type__c IN (\'PT Hourly (OH & G&A)\',\'FT Hourly & Benefits\',\'FT Salary & Benefits\') AND Status__c IN (\'Approved\',\'Draft\',\'Submitted for Approval\') AND Contact__c = \''+ contactId + '\' Order By Effective_Date__c Desc', '');
        if(defaultCR == 'Non-SCA Testing') {
            for(AcctSeed__Cost_Rates__c cRRecord : crsForStaff){
                if(!costRateMapForStaff.containskey(cRRecord.Contact__c+'-'+cRRecord.Rate_Type__c)) {
                    costRateMapForStaff.put(cRRecord.Contact__c+'-'+cRRecord.Rate_Type__c,cRRecord);
                }
            }
            
            if(costRateMapForStaff.size() > 0){
                costDetails.isAlreadyCRExist = true;
                
                AcctSeed__Cost_Rates__c crIdWithStatus = new AcctSeed__Cost_Rates__c();
                if(costRateMapForStaff.containskey(contactId+'-'+'FT Salary & Benefits')){
                    
                    crIdWithStatus = costRateMapForStaff.get(contactId+'-'+'FT Salary & Benefits');
                    costDetails.costLabel = crIdWithStatus.Status__c == 'Approved' ? 'RateCost' : 'LaborCost';
                    costDetails.rateCardRate = crIdWithStatus.Id;
                    costDetails.costRateMessage = 'The following Cost Rate will be assigned <a href="/'+crIdWithStatus.Id+'">'+crIdWithStatus.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                    
                }else if(costRateMapForStaff.containskey(contactId+'-'+'FT Hourly & Benefits')){
                    
                    crIdWithStatus = costRateMapForStaff.get(contactId+'-'+'FT Hourly & Benefits');
                    costDetails.costLabel = crIdWithStatus.Status__c == 'Approved' ? 'RateCost' : 'LaborCost';
                    costDetails.rateCardRate = crIdWithStatus.Id;
                    costDetails.costRateMessage = 'The following Cost Rate will be assigned <a href="/'+crIdWithStatus.Id+'">'+crIdWithStatus.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                    
                }else if(costRateMapForStaff.containskey(contactId+'-'+'PT Hourly (OH & G&A)')){
                    
                    crIdWithStatus = costRateMapForStaff.get(contactId+'-'+'PT Hourly (OH & G&A)');
                    costDetails.costLabel = crIdWithStatus.Status__c == 'Approved' ? 'RateCost' : 'LaborCost';
                    costDetails.rateCardRate = crIdWithStatus.Id;
                    costDetails.costRateMessage = 'The following Cost Rate will be assigned <a href="/'+crIdWithStatus.Id+'">'+crIdWithStatus.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                }
            }
        }
        return costDetails; 
    }
    
    /**********************************************************************
        Created by SivaPrasanth on Dec 11 2018: This method to get CA record related to Contact and Equipment Object.
        @conAssignId - pass the of conAssignId
        return  conAssignmentContact record
     ***********************************************************************/
     @AuraEnabled
    public static ContactAssignmentDomain.CAViewMoreWrapper contactAssignmentView(String conAssignId, String parentRecordType) {
        ContactAssignmentDomain.CAViewMoreWrapper caViewWrapper = new ContactAssignmentDomain.CAViewMoreWrapper();
        String proRecordType = null;
        List<Contact_Assignments__c> conAssignment = [SELECT Id,Candidate_Name__c,Oral_Exam_Date_Time__c,Candidate_Name__r.Name,Start_Date__c,  of_Per_Diem_Days__c,Location__c,Status__c,Mobile__c,Email__c,Candidate_Name__r.Phone,Candidate_Name__r.Personal_E_mail__c,Assignment_Position__c,End_Date__c,L_Score_Initial__c,L_Score_Final__c,R_Score_Final__c,R_Score_Initial__c,W_Score_Goal__c,S_Score_Final__c,
                                                     Account__r.Name,Schedule_Observation__c,S_Score_Initial__c,W_9_on_file__c,EE_Pay_Status__c,Labor_Pay_Rate__c,Payroll_Item__c,PC_EE_ID__c,Notes__c,Project_Task__c,Project_Task__r.Name,Contract_Uploaded_Word_and_PDF__c,ACH_set_up__c,Contract_Emailed_to_Instructor__c,
                                                     Per_diem_info_sent_to_Accounting__c,Signed_contract_received__c,CC_Auth_on_Hotel_Detail_Page__c,Code_of_Conduct_Received__c,Project__r.RecordTypeId,Base_Access_Letter_Requested__c,Trip_Details_Emailed_to_Instructor__c,Opportunity_Name__c,
                                                     Base_Access_Letter_Uploaded__c,Materials_Delivered_to_Instructor__c,Opportunity_Name__r.RecordTypeId,Flight_out_uploaded__c,Laptops_Issued__c,RecordType.DeveloperName,Project__r.DLI_Project_Type__c,Project__r.RecordType.DeveloperName,
                                                     Opportunity_Name__r.Default_Cost_Rate_Rate_Type__c,Project__r.Default_Cost_Rate_Rate_Type__c,Project__c,Opportunity_Name__r.RecordType.DeveloperName,Opportunity_Name__r.DLI_Project_Type__c,Project_Assignment_Description__c,Rental_Car_Confirmation_Uploaded__c,Candidate_Name__r.DLS_Candidate_Rating__c,Candidate_Name__r.MailingAddress,Candidate_Name__r.Active_Count_as_Instructor__c,Rate_Card_Rate__r.Cost_Rate_Name__c,Rate_Card_Rate__c,Drafted_Labor_Cost_Rate__c,Drafted_Labor_Cost_Rate__r.Cost_Rate_Name__c,Laptop_Returned__c,Return_Flight_Uploaded__c,Gas_Weekly_Allowance__c,Laptop_Serial_Numbers__c,Training_Location__c FROM Contact_Assignments__c WHERE Id=:conAssignId];
        
        
        List<Contact_Assignments__c> conAssignmentContact = [SELECT Id,Candidate_Name__r.Citizenship__c, Oral_Exam_Date_Time__c,Candidate_Name__r.Citizenship_VISA_expiration_date__c,Candidate_Name__r.City_and_Country_of_Birth__c,Candidate_Name__r.Other_names_used__c,Candidate_Name__r.Gender__c, Candidate_Name__r.Country_of_Birth__c,Candidate_Name__r.ID_Type__c , Candidate_Name__r.Non_US_Passport_Country__c  ,Drafted_Labor_Cost_Rate__c,
                                                             Candidate_Name__r.Driver_s_License__c,Candidate_Name__r.Preferred_Airport__c,Candidate_Name__r.Emergency_Contact__c,Candidate_Name__r.Emergency_Contact_Relationship__c, Candidate_Name__r.Emergency_Email__c, Candidate_Name__r.Emergency_Phone__c,Candidate_Name__r.Record_updated_from_security_info__c  FROM Contact_Assignments__c WHERE Id=:conAssignId];
        
        List<Equipment_Assignment__c> equipAssignment = [SELECT Id ,Name,Contact_Assignment__c,Contact__r.Name,Equipment__r.Name,Date_Requested__c,Date_Assigned__c,Date_Returned__c,Deposit_Amount__c,Equipment__c FROM Equipment_Assignment__c WHERE Contact_Assignment__c=:conAssignId];
        
        caViewWrapper.showAccountField = false;
        caViewWrapper.showObservationField = false; 

        if(conAssignment.size() > 0 && conAssignment[0].RecordType.DeveloperName == 'Instructor'){
           if(parentRecordType == 'AcctSeed__Project__c' && conAssignment[0].Project__c != null && conAssignment[0].Project__r.RecordTypeId != null){
                proRecordType = conAssignment[0].Project__r.RecordType.DeveloperName;
                
                // proRecordType == 'DLI_W_LT_Projects' commented since we are going to create Monthly Observation Report
                if( proRecordType == 'Language_Training_Projects' || proRecordType == 'DODA_Projects'
                   || proRecordType == 'MTT_Projects' || proRecordType == 'EFL_Projects'){
                    caViewWrapper.showObservationField = true;   
                }
                
                if(proRecordType == 'DLI_W_LT_Projects' && conAssignment[0].Project__r.DLI_Project_Type__c == 'Partner School' 
                   && conAssignment[0].Project__r.Default_Cost_Rate_Rate_Type__c == 'SubK-LT'){
                    caViewWrapper.showAccountField = true;
                }
            }else if(parentRecordType == 'Opportunity' && conAssignment[0].Opportunity_Name__c != null && conAssignment[0].Opportunity_Name__r.RecordTypeId != null){
               proRecordType = conAssignment[0].Opportunity_Name__r.RecordType.DeveloperName;
               // proRecordType == 'DLI_W_TO_Opportunities' commented since we are going to create Monthly Observation Report
               if( proRecordType == 'New_Classes_Opportunities' || proRecordType == 'ODNI_CLP_Opportunities'){
                   caViewWrapper.showObservationField = true;   
               }
                
                if(proRecordType == 'DLI_W_TO_Opportunities' && conAssignment[0].Opportunity_Name__r.DLI_Project_Type__c == 'Partner School'
                    && conAssignment[0].Opportunity_Name__r.Default_Cost_Rate_Rate_Type__c == 'SubK-LT'){
                    caViewWrapper.showAccountField = true;
                }
            }
        }
        caViewWrapper.lstConAssignContactCitizen = conAssignmentContact;
        caViewWrapper.lstConAssignment = conAssignment;
        caViewWrapper.lstEquiAssignment = equipAssignment;
        return caViewWrapper;
        
    } 
    /**********************************************************************
        Created by SivaPrasanth on Dec 20 2018: This method to save  equipAssignments Record related to CA.
        @conAssignId - pass the of ContactId
        return list of equipAssignments record
     ***********************************************************************/
    @AuraEnabled
    public static List<Equipment_Assignment__c> getEABasedonCA(string conAssignId) {
        
        List<Equipment_Assignment__c> equipAssignments = [SELECT Id ,Name,Contact_Assignment__c,Contact__r.Name,Equipment__r.Name,Date_Requested__c,Date_Assigned__c,Date_Returned__c,Deposit_Amount__c,Equipment__c FROM Equipment_Assignment__c WHERE Contact_Assignment__c=:conAssignId];
        return equipAssignments;
    } 

    @AuraEnabled
    public static String createPayRateModifyCostRate(AcctSeed__Cost_Rates__c crRecord,String parentId,Contact_Assignments__c caRecord,String defaultCR){
        isFromCA = true;
        Savepoint sp = Database.setSavepoint();
        
        try {
            crRecord.Status__c = 'Draft';
            crRecord.Contact__c = caRecord.Candidate_Name__c;
            crRecord.Rate_Type__c = defaultCR;
            insert crRecord;
            
            List<AcctSeed__Cost_Rates__c> newLCRlst = [SELECT Id,Status__c,Effective_Date__c,Prior_Version__c,Contact__c FROM AcctSeed__Cost_Rates__c WHERE Id = :crRecord.Id];
            
            if(newLCRlst.size() > 0){
                if(newLCRlst[0].Status__c != 'Approved') {
                    List<Contact_Assignments__c> caList = SObjectQueryService.SObjectQuery('Contact_Assignments__c',new Set<Id>{caRecord.Id},'');
                    
                    if(caList.size() > 0){             
                        List<Contact_Assignments__c> createAndUpdateCA = new List<Contact_Assignments__c>();
                        if(caRecord.End_Date__c != newLCRlst[0].Effective_Date__c 
                           && caRecord.End_Date__c > newLCRlst[0].Effective_Date__c
                           && caRecord.Start_Date__c < newLCRlst[0].Effective_Date__c){
                               
                               Contact_Assignments__c newCA = caList[0].clone(false,true,false,false);
                               newCA.Rate_Card_Rate__c = null;
                               newCA.Start_Date__c = newLCRlst[0].Effective_Date__c;
                               newCA.Drafted_Labor_Cost_Rate__c = null;
                               newCA.Moodle_Sync_Status__c = null;
                               
                               if(newLCRlst[0].Status__c == 'Draft' || newLCRlst[0].Status__c == 'Submitted for Approval'){
                                   newCA.Drafted_Labor_Cost_Rate__c = newLCRlst[0].Id;
                               }
                               caRecord.End_Date__c = newLCRlst[0].Effective_Date__c.addDays(-1);  
                               createAndUpdateCA.add(newCA);
                           }
                        
                        if(caRecord.Start_Date__c > newLCRlst[0].Effective_Date__c){
                            
                            if(newLCRlst[0].Status__c == 'Draft' || newLCRlst[0].Status__c == 'Submitted for Approval'){
                                caRecord.Drafted_Labor_Cost_Rate__c = newLCRlst[0].Id;
                            }
                        }else if(newLCRlst[0].Effective_Date__c <=  System.today()) {
                            caRecord.Status__c = 'Ended';
                        }
                        
                        System.debug('createAndUpdateCA::'+createAndUpdateCA);
                        createAndUpdateCA.add(caRecord);
                        if(createAndUpdateCA.size() > 0){
                            upsert createAndUpdateCA;
                        }
                    }
                }
            }
            return crRecord.Id;
        }catch(Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*W-002019 - User Story - DODA Projects - Instructor Contact Assignments, US Citizen
      On DODA Projects, when adding an Instructor Contact Assignment, upon save check the Contact page 
      if the Citizenship field has the "US Citizen" value. If the Contact does not have the "US Citizen" value, 
      throw warning message: "This Candidates Citizenship is not US Citizen. Please assign a Candidate with US Citizenship." 
      Do not allow the user to save. */
    @AuraEnabled
    public static Boolean isConCitizenshipisUSCitizen(Id conId){
        
        List<Contact> conLst = [SELECT Id,Citizenship__c FROM Contact WHERE Id = :conId AND Citizenship__c = 'U.S. Citizen'];
        if(conLst.size() > 0){
            return true;
        }
        return false;
    }
    
    /*W-007195 -) Add Validation Rules when LTS saves an Instructor Contact Assignment.- When the “Schedule Observation” is no
     - If the Project Requested Hours/Week <15 show a message“{Instructors Name}'s last Observation was on {Observation Due Date}
    and their next Observation is scheduled for {Observation Due Date} (or N/A if they do not have one Scheduled/Ready to Send/Sent to Instructor).*/
    
    @AuraEnabled
    public static String getObservationReportInsCAInfo(String conId){
        List<Assessment_Report__c> lastObservationReport = new List<Assessment_Report__c>();
        List<Assessment_Report__c> nextObservationReport = new List<Assessment_Report__c>();
        
        String observationRepMsg = null;
        String lastObsDate = null;
        String nextObsDate = null;
        String instructorName = null;
        
        if(conId != null){
            lastObservationReport = [SELECT Id,Report_Date__c,Instructor__c,Instructor__r.Name,Date_Completed__c FROM Assessment_Report__c WHERE Report_Date__c != null AND Instructor__c = :conId AND RecordType.DeveloperName = 'Observation_Report' AND Status__c = 'Completed'  Order By Date_Completed__c Desc LIMIT 1]; //Report_Date__c
            nextObservationReport = [SELECT Id,Report_Date__c,Instructor__c,Instructor__r.Name FROM Assessment_Report__c WHERE Report_Date__c != null AND Instructor__c = :conId AND RecordType.DeveloperName = 'Observation_Report' AND Status__c IN ('Scheduled','Ready to Send','Sent to Instructor') Order By Report_Date__c ASC LIMIT 1];
        
            if(lastObservationReport.size() == 0 && nextObservationReport.size() == 0){
                List<Contact> Ins = [SELECT Id,Name FROM Contact WHERE Id = :conId];
                instructorName = Ins[0].Name;
            }else{
                
                if(lastObservationReport.size() > 0){
                    String lastObsDateStr =  String.valueOf(lastObservationReport[0].Date_Completed__c); //Report_Date__c
                    instructorName = lastObservationReport[0].Instructor__r.Name;
                    
                    List<String> tempDate = lastObsDateStr != null ? lastObsDateStr.split('-') : new List<String>();
                    lastObsDate = (tempDate != null && tempDate.size() > 1) ? (tempDate[1]+'/'+tempDate[2]+'/'+tempDate[0]) : null;
                }
                
                if(nextObservationReport.size() > 0){
                    String nextObsDateStr =  String.valueOf(nextObservationReport[0].Report_Date__c);
                    if(String.isBlank(instructorName)){
                        instructorName = nextObservationReport[0].Instructor__r.Name;   
                    }
                    List<String> tempDate2 = nextObsDateStr != null ? nextObsDateStr.split('-') : new List<String>();
                    nextObsDate = (tempDate2 != null && tempDate2.size() > 1) ? (tempDate2[1]+'/'+tempDate2[2]+'/'+tempDate2[0]) : null;
                    
                }
            }
            
            if(instructorName != null){
                observationRepMsg = '<html><div>' + instructorName+'\'';
            }
            observationRepMsg += 's last Observation was on '+(lastObsDate != null ? String.valueOf(lastObsDate) : '<b>N/A</b>') +' and their next Observation is scheduled for '+ (nextObsDate != null ? String.valueOf(nextObsDate) : '<b>N/A</b>') + '.</div></html>';
            return observationRepMsg;
        }
        return null;
    }
    // To get lookup records
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    }
    
   /* W-007721 - Process to Transfer a Student from One Project to Another Project (MAR-15-2023)*/
    @AuraEnabled
    public static void transferStudentCAtoAnotherProject(String caId,Date oldCAEndDt,Date newCAStartDt,String newCAProjectId,String cAStudentCL){
        List<Contact_Assignments__c> studentCAList = new List<Contact_Assignments__c>();
        List<AcctSeed__Project__c> proRecs = new List<AcctSeed__Project__c>();
        List<Assessment_Report__c> trainingReports = new List<Assessment_Report__c>();
        List<Language_Testing__c> langTesting = new List<Language_Testing__c>();
        
        if(newCAProjectId != null){
          proRecs = [SELECT Id,End_Date__c FROM AcctSeed__Project__c WHERE Id = :newCAProjectId];    
        }
        
        /* Make selected Student Contact Assignment as Leader*/
        if(cAStudentCL != null){
            List<Contact_Assignments__c> conAssignment = [SELECT Id,Assignment_Position__c FROM Contact_Assignments__c WHERE Id = :cAStudentCL AND RecordType.DeveloperName='Student'];
            if(conAssignment.size() > 0){
                conAssignment[0].Assignment_Position__c = 'Class Leader'; 
                update conAssignment;
            }
        }
        
        if(caId != null){
             List<Contact_Assignments__c> conAssignment = [SELECT Id,Project__c,Candidate_Name__c,Assignment_Position__c,RecordTypeId,R_Score_Final__c,S_Score_Final__c,W_Score_Goal__c,L_Score_Final__c FROM Contact_Assignments__c WHERE Id = :caId AND RecordType.DeveloperName='Student'];
        
            if(conAssignment.size() > 0 && proRecs.size() > 0){
                conAssignment[0].End_Date__c = oldCAEndDt;
                conAssignment[0].Status__c = 'Transferred';
                if( conAssignment[0].Assignment_Position__c == 'Class Leader'){
                    conAssignment[0].Assignment_Position__c = 'Student';
                }
                studentCAList.add(conAssignment[0]);
                
                Contact_Assignments__c newStudentCA = new Contact_Assignments__c();
                newStudentCA.R_Score_Final__c = conAssignment[0].R_Score_Final__c;
                newStudentCA.S_Score_Final__c = conAssignment[0].S_Score_Final__c;
                newStudentCA.W_Score_Goal__c = conAssignment[0].W_Score_Goal__c;
                newStudentCA.L_Score_Final__c = conAssignment[0].L_Score_Final__c;
                newStudentCA.Assignment_Position__c = 'Student';
                newStudentCA.Project__c = proRecs[0].Id;
                newStudentCA.Start_Date__c = newCAStartDt;
                newStudentCA.Candidate_Name__c = conAssignment[0].Candidate_Name__c;
                newStudentCA.End_Date__c = proRecs[0].End_Date__c;        
                newStudentCA.Status__c = 'Active';
                newStudentCA.RecordTypeId = conAssignment[0].RecordTypeId;
                studentCAList.add(newStudentCA);
                
                if(studentCAList.size() > 0){
                    upsert studentCAList;
                }
                
                // to update the Training report records.
                trainingReports = [SELECT Id,Project__c FROM Assessment_Report__c WHERE Project__c = :conAssignment[0].Project__c AND Student__c = :conAssignment[0].Candidate_Name__c AND Status__c IN ('Draft','Scheduled') AND (Report_Date__c >= :newCAStartDt AND Report_Date__c <= :newStudentCA.End_Date__c)];
                
                if(trainingReports.size() > 0){
                    for(Assessment_Report__c ap : trainingReports){
                        ap.Project__c = proRecs[0].Id;
                    } 
                    update trainingReports;
                }
                
                // to update the Language Testing records.
                langTesting = [SELECT Id,Testee__c,Project__c,Contact_Assignment__c FROM Language_Testing__c WHERE Project__c = :conAssignment[0].Project__c AND Testee__c = :conAssignment[0].Candidate_Name__c AND Contact_Assignment__c = :conAssignment[0].Id];

                if(langTesting.size() > 0){
                    for(Language_Testing__c lt : langTesting){
                        lt.Project__c = proRecs[0].Id;
                        lt.Contact_Assignment__c = studentCAList[1].Id;
                    } 
                    update langTesting;
                }
            }
            
        }
    }
    @AuraEnabled
    public static String getStudentCAsForClassLeader(String currentCAProjectId,String oldCAPosition){ 
        List<Contact_Assignments__c> studentCANameList = new List<Contact_Assignments__c>();
        if(oldCAPosition == 'Class Leader'){
            studentCANameList = [SELECT Id,Candidate_Name__r.Name FROM Contact_Assignments__c WHERE Assignment_Position__c != 'Class Leader' AND RecordType.DeveloperName='Student' AND Project__c = :currentCAProjectId AND Status__c IN ('Active','Planned')];
        }
        return JSON.serialize(studentCANameList);
    }
    /* W-007721 - Process to Transfer a Student from One Project to Another Project (MAR-15-2023)*/
    @AuraEnabled
    public static String transferStudentCAValidationCheck(Date newCAStartDt,String newCAProjectId,String stuConId){ 
        // This method to check the new Project Enddate validation and already existing student contact validation*/
        
        List<Contact_Assignments__c> studentCAList = new List<Contact_Assignments__c>();
        List<AcctSeed__Project__c> proRecs = new List<AcctSeed__Project__c>();
        String validationMsg = '<html>';
        Boolean isValid = true;   
        
        if(newCAProjectId != null){
            proRecs = [SELECT Id,Name,Start_Date__c,End_Date__c FROM AcctSeed__Project__c WHERE Id = :newCAProjectId];    
        }   
        
        if(proRecs.size() > 0){
            if(stuConId != null){ 
                studentCAList = [SELECT Id,Project__c,Assignment_Position__c,Candidate_Name__r.Name FROM Contact_Assignments__c WHERE Candidate_Name__c = :stuConId AND RecordType.DeveloperName='Student' AND Project__c = :proRecs[0].Id];
            }
            
            if(studentCAList.size() > 0){
                validationMsg += '<div>Please delete the existing Student Contact Assignment of <b>'+studentCAList[0].Candidate_Name__r.Name +'</b> on this project<b> '+proRecs[0].Name+'</b> before going to transfer this Student contact</div><br/>';
                isValid = false;
            }
            if(proRecs[0].Start_Date__c > newCAStartDt || proRecs[0].End_Date__c < newCAStartDt) {
                
                List<String> stTempDate = proRecs[0].Start_Date__c != null ? (String.valueOf(proRecs[0].Start_Date__c)).split('-') : new List<String>();
                List<String> edTempDate = proRecs[0].End_Date__c != null ? (String.valueOf(proRecs[0].End_Date__c)).split('-') : new List<String>();
                
                String stDt = (stTempDate != null && stTempDate.size() > 1) ? stTempDate[2]+'/'+stTempDate[1]+'/'+stTempDate[0] : null;
                String edDt = (edTempDate != null && edTempDate.size() > 1) ? edTempDate[2]+'/'+edTempDate[1]+'/'+edTempDate[0] : null;
                
                validationMsg += '<div> Please fill the valid new Student Contact Assignment Start Date for selected project <b>'+ proRecs[0].Name+'</b> within the date range from '+stDt +' to '+edDt+' .</div>';
                isValid = false;
            }
            
        }
        validationMsg += '</Html>'; 
        
        if(isValid == true){
            validationMsg = '';
        }
        return validationMsg; 
    }
}