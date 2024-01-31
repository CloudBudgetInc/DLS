@isTest
private  class ContactAssignmentLightningCtrl_Test { 
    
  @testsetup static void setup() {
        Test.StartTest();
        List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
        Test.Stoptest();  
        List<AcctSeed__Cost_Rates__c>  costrateList = TestClassUtil.createTestCostRates();
        List<APXTConga4__Conga_Template__c> congatmpLst =  TestClassUtil.createCongaTemplate();
        List<Labor_Cost_Rate_Master__c> CostRateMasterLists  =  TestClassUtil.createTestCostRatesMaster();
        List<Schedule__c> schlst =  TestClassUtil.createTestSchedule();
        //List<AcctSeed__Project_Task__c> projTask =  TestClassUtil.createTestProjectTask();
    } 
     
    //getting ContactAssignment Record Related to Project 
    private static testMethod void testMethod1() {
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Schedule__c> schlst = [SELECT Id,Project__c,Instructor__c FROM Schedule__c LIMIT 2];
        String insRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        List<Contact_Assignments__c>  conList = [SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__c LIMIT 1];
        
        if(projList.size() > 0 && schlst.size() > 0 && conList.size() > 0) {
            
            for(Contact_Assignments__c ca : conList){
                ca.Project__c = projList[0].Id;
            }
            update conList;
            for(Schedule__c sh : schlst){
                sh.Instructor__c = conList[0].Candidate_Name__c;
                sh.Project__c = projList[0].Id;
            }
            update schlst;
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getTabRecs(projList[0].Id ,'AcctSeed__Project__c');
            System.assertEquals(returnConAssign.wrapTabNames.contains(returnConAssign.wrapActiveTab),true);              
        }
    }
    //getting ContactAssignment Record Related to Opportunity
    private static testMethod void testMethod2() { 
        
        List<AcctSeed__Project__c> opplist = proOppContract('Opportunity'); 
        
        if(opplist.size() > 0 ) {
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            
            Test.startTest();
            returnConAssign = ContactAssignmentLightningCtrl.getTabRecs(opplist[0].AcctSeed__Opportunity__r.Id  ,'Opportunity');
            System.assertEquals(returnConAssign.wrapStatuspickList.contains('Planned'),true);
            System.assertEquals(returnConAssign.wrapTabNames.contains('Client/Partner'),true);
            Test.stopTest();
        }
    }
    //getting ContactAssignment Record Related to Contract
    private static testMethod void testMethod3() {
        
        List<Contract> contractlist = proOppContract('Contract'); 
        
        if(contractlist.size() > 0 ) {
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getTabRecs(contractlist[0].Id ,'Contract');
            System.assertEquals(returnConAssign.wrapStatuspickList.contains('Planned'),true);
            System.assertEquals(returnConAssign.wrapTabNames.contains(returnConAssign.wrapActiveTab),true);
        }
    }
    //getting ContactAssignment Record Related to Project after tab Change
    private static testMethod void testMethod4() {
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        
        if(projList.size() > 0) {
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getContactAssignRecs('Student',projList[0].Id ,'AcctSeed__Project__c');
            if(returnConAssign.wrapConAssignList.size() > 0){
                System.assertEquals(returnConAssign.wrapConAssignList[0].caRecs.Assignment_Position__c,'Student');
            }
        }
        
    }
    //getting ContactAssignment Record Related to Opportunity after tab Change
    private static testMethod void testMethod5() { 
        
        List<AcctSeed__Project__c> opplist = proOppContract('Opportunity'); 
        
        if(opplist.size() > 0) {
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getContactAssignRecs('Instructor',opplist[0].AcctSeed__Opportunity__r.Id  ,'Opportunity');
            if(returnConAssign.wrapConAssignList.size() > 0){
                System.assertEquals(returnConAssign.wrapConAssignList[0].caRecs.Assignment_Position__c,'Instructor');
            }
        }
    }
    //Dli opporunites  for Instructor  after tab Change
    private static testMethod void testMethod6() { 
        
        List<Opportunity> oppList = [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity LIMIT 4];
        
        if( oppList.size() >= 0) {
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getContactAssignRecs('Instructor',oppList[3].Id ,'Opportunity');
            if(returnConAssign.wrapConAssignList.size() > 0){
                System.assertEquals(returnConAssign.wrapConAssignList[0].caRecs.Assignment_Position__c,'Instructor');
            }
        }
    }
    //Dli opporunites  for staff/consultant/ClientPartner after tab Change
    private static testMethod void testMethod7() { 
        
        List<Opportunity> oppList = [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity LIMIT 4];
        
        if(  oppList.size() >= 0) {
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getContactAssignRecs('Staff',oppList[3].Id ,'Opportunity');
            if(returnConAssign.wrapConAssignList.size() > 0){
                System.assertEquals(returnConAssign.wrapConAssignList[0].caRecs.Assignment_Position__c,'Staff');
            }
        }
    }
    //getting CA records based on ContractId  after tab Change
    private static testMethod void testMethod8() {
        
        List<Contract> contractlist = proOppContract('Contract'); 
        
        if(contractlist.size() > 0) {
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getContactAssignRecs('Staff',contractlist[1].Id  ,'Contract');
            if(returnConAssign.wrapConAssignList.size() > 0){
                System.assertEquals(returnConAssign.wrapConAssignList[0].caRecs.Assignment_Position__c,'Staff');
            }
        }
    }
    //opportunity without project recordType DLI Opportunites 
    private static testMethod void testMethod9() {
        
        List<Opportunity> oppList= [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity  WHERE RecordType.DeveloperName ='DLI_W_TO_Opportunities'];
        
        if(oppList.size() > 0){
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getTabRecs(oppList[0].Id ,'Opportunity');
            System.assertEquals(returnConAssign.wrapActiveTab,'Instructor');
        }
        
    }
    //opportunity with recordType Admin Opportunites
    private static testMethod void testMethod10() { 
        
        String oppRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Admin_Opportunities').getRecordTypeId();
        List<Opportunity> oppList = [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity LIMIT 1];
        
        if(oppList.size() > 0) {
            oppList[0].RecordTypeId = oppRt;
            oppList[0].Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA MTT';
            update oppList[0];
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getTabRecs(oppList[0].Id ,'Opportunity');
            System.assertEquals(returnConAssign.wrapActiveTab,'Staff');
        }
    }
    //opportunity with recordType MTT_Opportunities
    private static testMethod void testMethod11() { 
        
        String oppRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MTT_Opportunities').getRecordTypeId();
        String TransRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Translation_Opportunities').getRecordTypeId();

        List<Opportunity> oppList = [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity LIMIT 1];
        
        if(oppList.size() > 0) {
            oppList[0].RecordTypeId = TransRt;
            update oppList;
            ContactAssignmentLightningCtrl.getTabRecs(oppList[0].Id ,'Opportunity');
            oppList[0].RecordTypeId = oppRt;
            oppList[0].Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA MTT';
            update oppList;
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getTabRecs(oppList[0].Id ,'Opportunity');
            System.assertEquals(returnConAssign.wrapActiveTab,'Instructor');      
        }
    }
    //opportunity with recordType CD_Opportunities
    private static testMethod void testMethod12() { 
        
        String oppRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CD_Opportunities').getRecordTypeId();
        List<Opportunity> oppList = [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity];
        
        if(oppList.size() > 0) {
            oppList[0].RecordTypeId = oppRt;
            oppList[0].Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA MTT';
            update oppList[0];
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getTabRecs(oppList[0].Id ,'Opportunity');
            System.assertEquals(returnConAssign.wrapActiveTab,'Direct Labor');
        }
    }
    //project with recordType CD_Projects
    private static testMethod void testMethod13() { 
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        String proRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('CD_Projects').getRecordTypeId();
        
        if(projList.size() > 0 ) {
            projList[0].RecordTypeId = proRt;  
            update projList;
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getTabRecs( projList[0].Id ,'AcctSeed__Project__c');
            System.assertEquals(returnConAssign.wrapStatuspickList.contains('Planned'),true);
            System.assertEquals(returnConAssign.wrapTabNames.contains('Client/Partner'),true);
        }
    }
    //project with recordType Admin_Projects
    private static testMethod void testMethod14() { 
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        String proRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Admin_Projects').getRecordTypeId();
        
        if(projList.size() > 0 ) {
            projList[0].RecordTypeId = proRt;  
            update projList;
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getTabRecs( projList[0].Id ,'AcctSeed__Project__c');
            System.assertEquals(returnConAssign.wrapStatuspickList.contains('Planned'),true);
            System.assertEquals(returnConAssign.wrapTabNames.contains('Client/Partner'),true);
        }
    }
    //project with recordType MTT_Projects and Translation projects
    private static testMethod void testMethod15() { 
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        String proRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('MTT_Projects').getRecordTypeId();
        String TransRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Translation_Projects').getRecordTypeId();
        
        if(projList.size() > 0 ) {
            projList[0].RecordTypeId = TransRt; 
            update projList;
            ContactAssignmentLightningCtrl.getTabRecs( projList[0].Id ,'AcctSeed__Project__c');
            projList[0].RecordTypeId = proRt; 
            projList[0].Project_Type__c = 'MTT'; 
            projList[0].TO__c = 'Test';
            update projList;
            ContactAssignmentDomain.WrapperContactAssign returnConAssign = new ContactAssignmentDomain.WrapperContactAssign();
            returnConAssign = ContactAssignmentLightningCtrl.getTabRecs( projList[0].Id ,'AcctSeed__Project__c');
            System.assertEquals(returnConAssign.wrapStatuspickList.contains('Planned'),true);
            System.assertEquals(returnConAssign.wrapTabNames.contains('Client/Partner'),true);
        }
    }
    // getting Ca record based CA Id
    private static testMethod void testMethod16() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Contract__c,Project__c,Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Project__c != null  LIMIT 1];
        String proDliRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();

        if( conAssList.size() > 0) {
            AcctSeed__Project__c pro = new AcctSeed__Project__c();
            pro.Id = conAssList[0].Project__c;
            pro.Default_Cost_Rate_Rate_Type__c = 'SubK-LT';
            pro.DLI_Project_Type__c = 'Partner School';
            pro.RecordTypeId = proDliRt;
            update pro;
            
            ContactAssignmentDomain.CAViewMoreWrapper returnConAssign = new ContactAssignmentDomain.CAViewMoreWrapper();
            returnConAssign = ContactAssignmentLightningCtrl.contactAssignmentView(conAssList[0].Id,'AcctSeed__Project__c');
            System.assertEquals(returnConAssign.lstConAssignment[0].Id,conAssList[0].Id);
        }
    }
     // getting Ca record based CA Id
    private static testMethod void testMethod16A() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Contract__c,Opportunity_Name__c,Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor'  LIMIT 1];
        List<Opportunity> oppRec = [SELECT Id FROM Opportunity LIMIT 1];
        String oppDliRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DLI_W_TO_Opportunities').getRecordTypeId();

        if( conAssList.size() > 0) {
            Opportunity opp = new Opportunity();
            opp.Id = oppRec[0].Id;
            opp.Default_Cost_Rate_Rate_Type__c = 'SubK-LT';
            opp.DLI_Project_Type__c = 'Partner School';
            opp.RecordTypeId = oppDliRt;
            update opp;
            
            Test.startTest();
            
            conAssList[0].Opportunity_Name__c = oppRec[0].Id;
            update conAssList;
            
            ContactAssignmentDomain.CAViewMoreWrapper returnConAssign = new ContactAssignmentDomain.CAViewMoreWrapper();
            returnConAssign = ContactAssignmentLightningCtrl.contactAssignmentView(conAssList[0].Id,'Opportunity');
            System.assertEquals(returnConAssign.lstConAssignment[0].Id,conAssList[0].Id);
            
            Test.stopTest();
        }
    }
    private static testMethod void testMethod17() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Contract__c, Candidate_Name__c FROM Contact_Assignments__c LIMIT 1];
        List<Equipment_Assignment__c> equiList = TestClassUtil.createTestEquipmentAssignment();
        
        if( conAssList.size() > 0 && equiList.size() > 0) {
            for(Equipment_Assignment__c eqiList : equiList){
                eqiList.Contact_Assignment__c = conAssList[0].Id;
            }
            update equiList;
            List<Equipment_Assignment__c> saveEqui = ContactAssignmentLightningCtrl.getEABasedonCA(conAssList[0].Id);
            System.assertEquals(saveEqui[0].Contact_Assignment__c,conAssList[0].Id);
            
        }
    }
   // delete CA records
    private static testMethod void testMethod19() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Contract__c, Candidate_Name__c FROM Contact_Assignments__c LIMIT 2];
        
        if( conAssList.size() > 0) {
            ContactAssignmentLightningCtrl.cADeleteRecord(conAssList[0].Id);
            List<Contact_Assignments__c> conAssListAfterDel = [SELECT Id, Name, Contract__c, Candidate_Name__c FROM Contact_Assignments__c  WHERE Id =: conAssList[0].Id];
            System.assertEquals(conAssListAfterDel.size(),0);
        }
    }
    //check permission to access CA records
    private static testMethod void testMethod20() {
        
        Boolean Edit = ContactAssignmentLightningCtrl.cARecordAccess('Edit');
        Boolean Create = ContactAssignmentLightningCtrl.cARecordAccess('Create');
        Boolean Deletes =  ContactAssignmentLightningCtrl.cARecordAccess('Delete');
        System.assertEquals( Edit ,true);
        System.assertEquals(Create,true);
        System.assertEquals(Deletes,true);
        
    }
    //validateInsEndStatusEditDelete
    private static testMethod void testMethod21() {
        
        List<Schedule__c>schList = [SELECT Id,Name,Instructor__c ,Project__c FROM Schedule__c LIMIT 1];
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, Candidate_Name__c FROM Contact_Assignments__c  WHERE Candidate_Name__c != null LIMIT 1];

        if( conAssList.size() > 0 && schList.size() > 0) {
            schList[0].Instructor__c = conAssList[0].Candidate_Name__c;
            schList[0].Project__c = conAssList[0].Project__c;
            update schList;
            ContactAssignmentLightningCtrl.validateInsEndStatusEditDelete(conAssList[0].Candidate_Name__c ,conAssList[0].Project__c ,conAssList[0].Id);
        }
    }
    //save CA record
    private static testMethod void testMethod22() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c,Status__c,Quantity_Actual__c,Invoice_Date__c,Candidate_Name__c, End_Date__c FROM Contact_Assignments__c LIMIT 1];
        if( conAssList.size() > 0) {
            conAssList[0].Status__c = 'Ended';
            conAssList[0].Invoice_Date__c = System.today();
            conAssList[0].Quantity_Actual__c = 12;
            conAssList[0].End_Date__c = Date.Today().addDays(-2);
            ContactAssignmentLightningCtrl.saveContactAssignment('AcctSeed__Project__c',JSON.serialize(conAssList),'Translation_Projects','Instructor',null,'Create',null);
            List<Contact_Assignments__c> conAsList = [SELECT Id, Name, Project__c,Status__c,Candidate_Name__c FROM Contact_Assignments__c WHERE Id =: conAssList[0].Id];
            //System.assertEquals(conAsList[0].Status__c,'Ended'); 
        }
    }
    
    //save CA record
    private static testMethod void testMethod22A() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c,Status__c,Candidate_Name__c,Start_Date__c,End_Date__c FROM Contact_Assignments__c WHERE Project__c != null LIMIT 1];
        List<Account> accRecs = [SELECT Id FROM Account LIMIT 1]; 

        if( conAssList.size() > 0 && accRecs.size() > 0) {
            Test.startTest();
            conAssList[0].Account__c = accRecs[0].Id;
            
            ContactAssignmentLightningCtrl.saveContactAssignment('AcctSeed__Project__c',JSON.serialize(conAssList),'DLI_W_LT_Projects','Instructor','SubK-LT','Create','Partner School');
            Test.stopTest();
        }
    }
    
    //send Student timeline
    private static testMethod void testMethod23() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Opportunity_Name__c,Opportunity_Name__r.Id, Candidate_Name__c FROM Contact_Assignments__c WHERE Opportunity_Name__c != null LIMIT 2];
        
        if( conAssList.size() > 0) {
            List<Attachment> AttachmentList = new List<Attachment> {
                new Attachment (Name = 'testTimeline', Body = Blob.valueof('Test'), ParentId = conAssList[0].Opportunity_Name__r.Id),
                    new Attachment (Name = 'test1Timeline', Body = Blob.valueof('Test1'), ParentId = conAssList[0].Opportunity_Name__r.Id) 
                    };
                        insert AttachmentList; 
            
            List<User> usrList = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
            if(usrList.size() > 0) {
                usrList[0].Phone = '989374788';
                update usrList;
            }
            ContactAssignmentLightningCtrl.CAStudentMailsend(conAssList[0].Candidate_Name__c,conAssList[0].Opportunity_Name__c);
        }
    }                                                           
    
    //  exempt Status  with required field is empty
    private static testMethod void testMethod24() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, RecordTypeId,Candidate_Name__r.First_Performance_Review_Date__c, Project__c, Candidate_Name__c, Candidate_Name__r.Id FROM Contact_Assignments__c LIMIT 2];
        String conAssRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        String congaTmp1 = null;
        String congaTmp2 = null;
        String congaTmpId = null;
        if(conAssList.size() >= 0){
            List<APXTConga4__Conga_Template__c> conTemplst  = [SELECT Id ,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c IN ('Offer Letter - Staff - Exempt','Offer Letter - Staff - Non-Exempt') ];
            
            for(APXTConga4__Conga_Template__c congatTmp : conTemplst){
                if(congatTmp.APXTConga4__Name__c == 'Offer Letter - Staff - Exempt'){
                    congaTmp1 = congatTmp.APXTConga4__Name__c;
                    congaTmpId = congatTmp.Id;
                }else{
                    congaTmp2 = congatTmp.APXTConga4__Name__c;
                }
            }
        } 
        
        String conRt = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Rate_Type__c,Status__c,Contact__c,Exempt_Status__c,Annual_Salary_Cost__c,Semi_Monthly_Salary_Cost__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        if(costrateList.size() > 0){
            costrateList[0].Exempt_Status__c = 'Exempt';
            costrateList[0].Contact__c = conList[0].Id;
            update costrateList;
            
            if(costrateList[0].Status__c == 'Approved'){
                conAssList[0].Rate_Card_Rate__c = costrateList[0].Id;
            }else{
                conAssList[0].Drafted_Labor_Cost_Rate__c = costrateList[0].Id; 
            }
        }
        
        Test.StartTest();
        // Exempt Status for generate Offer Letter
        conList[0].Home_Dept__c = 'CD';
        conList[0].Original_Hire_Date__c = System.today();
        conList[0].Supervisor_Name__c = UserInfo.getUserId();
        conList[0].First_Performance_Review_Date__c = System.today();
        update conList;
        
        conAssList[0].Assignment_Position__c = 'Instructor';

        //update conAssList;
        
        if(costrateList.size() > 0){
            costrateList[0].Annual_Salary_Cost__c = 5500;
            costrateList[0].Semi_Monthly_Salary_Cost__c = 50;
            update costrateList;
        }
        
        ContactAssignmentDomain.GenOfferLetterWrapper  genOffer = new ContactAssignmentDomain.GenOfferLetterWrapper(); 
        genOffer = ContactAssignmentLightningCtrl.congaButton(congaTmp1,congaTmp2,conAssList[0].Id,'ICA Agreement Contact Assign Query,Contact Query for Supervisor in Offer Letter');
        Test.StopTest();
    }
     //  exempt Status  with required field is empty
    private static testMethod void testMethod24A() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, RecordTypeId,Candidate_Name__r.First_Performance_Review_Date__c, Project__c, Candidate_Name__c, Candidate_Name__r.Id FROM Contact_Assignments__c LIMIT 2];
        String conAssRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        String congaTmp1 = null;
        String congaTmp2 = null;
        String congaTmpId = null;
        if(conAssList.size() >= 0){
            List<APXTConga4__Conga_Template__c> conTemplst  = [SELECT Id ,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c IN ('Offer Letter - Staff - Exempt','Offer Letter - Staff - Non-Exempt') ];
            
            for(APXTConga4__Conga_Template__c congatTmp : conTemplst){
                if(congatTmp.APXTConga4__Name__c == 'Offer Letter - Staff - Exempt'){
                    congaTmp1 = congatTmp.APXTConga4__Name__c;
                    congaTmpId = congatTmp.Id;
                }else{
                    congaTmp2 = congatTmp.APXTConga4__Name__c;
                }
            }
        } 
        
        String conRt = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Rate_Type__c,Contact__c,Exempt_Status__c,Annual_Salary_Cost__c,Semi_Monthly_Salary_Cost__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        if(costrateList.size() > 0){
            costrateList[0].Exempt_Status__c = 'Exempt';
            costrateList[0].Contact__c = conList[0].Id;
            update costrateList;
            conAssList[0].Rate_Card_Rate__c = costrateList[0].Id;
        }
        
        Test.startTest();
        if(conList.size() > 0 && conRt != null) {  
            conList[0].RecordTypeId = conRt;
            conList[0].Home_Dept__c = null;
            conList[0].Department__c = null;
            conList[0].Original_Hire_Date__c = null;
            conList[0].Supervisor_Name__c = null;
            conList[0].First_Performance_Review_Date__c = null;
            conList[0].DOL_Status__c = 'FT';
            update conList;
        }
        
        conAssList[0].Assignment_Position__c = null;
        conAssList[0].Candidate_Name__c = conList[0].Id;
        conAssList[0].RecordTypeId = conAssRt;
        update conAssList;
        
        Test.stopTest();
        
        ContactAssignmentDomain.GenOfferLetterWrapper  genOffer = new ContactAssignmentDomain.GenOfferLetterWrapper(); 
        genOffer = ContactAssignmentLightningCtrl.congaButton(congaTmp1,congaTmp2,conAssList[0].Id,'ICA Agreement Contact Assign Query,Contact Query for Supervisor in Offer Letter');
        System.assertEquals(genOffer.OffLetterTemId,null);
    }
    
    //Generate OfferLetter with NON-Exempt 
    private static testMethod void testMethod25() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__r.First_Performance_Review_Date__c, Project__c, Candidate_Name__c, Candidate_Name__r.Id FROM Contact_Assignments__c LIMIT 2];
        String conAssRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        String congaTmp1 = null;
        String congaTmp2 = null;
        String congaTmpId = null;
        
        if(conAssList.size() >= 0){
            List<APXTConga4__Conga_Template__c> conTemplst  = [SELECT Id ,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c IN ('Offer Letter - Staff - Exempt','Offer Letter - Staff - Non-Exempt') ];
            
            for(APXTConga4__Conga_Template__c congatTmp : conTemplst){
                if(congatTmp.APXTConga4__Name__c == 'Offer Letter - Staff - Exempt'){
                    congaTmp1 = congatTmp.APXTConga4__Name__c;
                }else{
                    congaTmp2 = congatTmp.APXTConga4__Name__c;
                    congaTmpId = congatTmp.Id;
                }
            }
        } 
        String conRt = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Rate_Type__c,Contact__c,Exempt_Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        if(costrateList.size() > 0){
            costrateList[0].Exempt_Status__c = 'Non-Exempt';
            costrateList[0].AcctSeed__Hourly_Cost__c = 43;
            costrateList[0].Annual_Salary_Cost__c = 5000;
            costrateList[0].Status__c = 'Approved';
            costrateList[0].Contact__c = conList[0].Id;
            update costrateList;
            conAssList[0].Rate_Card_Rate__c = costrateList[0].Id;
        }
        
        Test.startTest();
        
        if(conList.size() > 0 && conRt != null) {  
            conList[0].RecordTypeId = conRt;
            conList[0].Home_Dept__c = 'CD';
            conList[0].Department__c = 'Curriculum Development';
            conList[0].Original_Hire_Date__c = System.today();
            conList[0].Supervisor_Name__c = UserInfo.getUserId();
            conList[0].First_Performance_Review_Date__c = System.today();
            conList[0].DOL_Status__c = 'FT';
        }
        update conList;
        
        conAssList[0].Assignment_Position__c = 'Instructor';
        conAssList[0].Candidate_Name__c = conList[0].Id;
        conAssList[0].RecordTypeId = conAssRt;
        
        update conAssList;
        
        ContactAssignmentDomain.GenOfferLetterWrapper  genOffer = new ContactAssignmentDomain.GenOfferLetterWrapper(); 
        genOffer = ContactAssignmentLightningCtrl.congaButton(congaTmp1,congaTmp2,conAssList[0].Id,'ICA Agreement Contact Assign Query,Contact Query for Supervisor in Offer Letter');
        System.assertEquals(congaTmpId, genOffer.OffLetterTemId);
        
        
        // show required field for NON-Exempt 
        if(costrateList.size() > 0){
            conList[0].DOL_Status__c = null;
            costrateList[0].AcctSeed__Hourly_Cost__c = null;
            costrateList[0].Annual_Salary_Cost__c = null;
            costrateList[0].AcctSeed__Overtime_Hourly_Cost__c = null;
            update costrateList;
        }
        update conList;
        genOffer = ContactAssignmentLightningCtrl.congaButton(congaTmp1,congaTmp2,conAssList[0].Id,'ICA Agreement Contact Assign Query,Contact Query for Supervisor in Offer Letter');
        System.assertEquals(genOffer.fieldsEmpty.contains('Quantity Unit'),true);
        Test.stopTest();
    }
    
    
    //'You can generate Offer Letter only for Staff with "Exempt Status". So Please select Cost Rate with "Exempt Status".
    private static testMethod void testMethod26() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__r.First_Performance_Review_Date__c, Project__c, Candidate_Name__c, Candidate_Name__r.Id FROM Contact_Assignments__c LIMIT 2];
        String conAssRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        String congaTmp1 = null;
        String congaTmp2 = null;
        String congaTmpId = null;
        
        if(conAssList.size() >= 0){
            List<APXTConga4__Conga_Template__c> conTemplst  = [SELECT Id ,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c IN ('Offer Letter - Staff - Exempt','Offer Letter - Staff - Non-Exempt') ];
            
            for(APXTConga4__Conga_Template__c congatTmp : conTemplst){
                if(congatTmp.APXTConga4__Name__c == 'Offer Letter - Staff - Exempt'){
                    congaTmp1 = congatTmp.APXTConga4__Name__c;
                    congaTmpId = congatTmp.Id;
                }else{
                    congaTmp2 = congatTmp.APXTConga4__Name__c;
                }
            }
        } 
        String conRt = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(conList.size() > 0 && conRt != null) {  
            conList[0].RecordTypeId = conRt;
            conList[0].Home_Dept__c = 'CD';
            conList[0].Department__c = 'Curriculum Development';
            conList[0].Original_Hire_Date__c = System.today();
            conList[0].Supervisor_Name__c = UserInfo.getUserId();
            conList[0].First_Performance_Review_Date__c = System.today();
            conList[0].DOL_Status__c = null;
        }
        update conList;
        Test.StartTest();
        
        conAssList[0].Assignment_Position__c = 'Instructor';
        conAssList[0].Candidate_Name__c = conList[0].Id;
        conAssList[0].RecordTypeId = conAssRt;
        conAssList[0].Rate_Card_Rate__c = null;
        update conAssList;
        
        ContactAssignmentDomain.GenOfferLetterWrapper  genOffer = new ContactAssignmentDomain.GenOfferLetterWrapper(); 
        genOffer = ContactAssignmentLightningCtrl.congaButton(congaTmp1,congaTmp2,conAssList[0].Id,'ICA Agreement Contact Assign Query,Contact Query for Supervisor in Offer Letter');
        System.assertEquals('You can generate Offer Letter only for Staff with "Exempt Status". So Please select Cost Rate with "Exempt Status".', genOffer.ConditionFailed);
       
        //You can generate Offer Letter only for Staff with "Exempt Status" as "Exempt" or "Non-Exempt"
        List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Rate_Type__c,Exempt_Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        if(costrateList.size() > 0){
            costrateList[0].Exempt_Status__c = null;
            update costrateList;
            conAssList[0].Rate_Card_Rate__c = costrateList[0].Id;
        }
        update conAssList;
        genOffer = ContactAssignmentLightningCtrl.congaButton(congaTmp1,congaTmp2,conAssList[0].Id,'ICA Agreement Contact Assign Query,Contact Query for Supervisor in Offer Letter');
        System.assertEquals('You can generate Offer Letter only for Staff with "Exempt Status" as "Exempt" or "Non-Exempt".', genOffer.ConditionFailed);
        Test.StopTest();
    }
    
    // getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod27() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, RecordTypeId ,Candidate_Name__c, Candidate_Name__r.Id,Project__r.AcctSeed__Account__c  FROM Contact_Assignments__c WHERE Project__c != null AND Project__r.AcctSeed__Account__c != null LIMIT 1];
        if( conAssList.size() > 0) {
            ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[0].Id,'Client_Partner','AcctSeed__Project__c',conAssList[0].Project__c );
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[0].Id,'Consultant','AcctSeed__Project__c',conAssList[0].Project__c );
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[0].Id,'Student','AcctSeed__Project__c',conAssList[0].Project__c );
            system.assertEquals(conAssList[0].Id, caDetails.caRecord.Id);
        }
        
    }
    // getCARelatedInformation method to populate CA inputfield Values
     private static testMethod void testMethod28() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Opportunity_Name__c, Candidate_Name__c FROM Contact_Assignments__c WHERE Project__c != null  LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,RecordTypeId FROM AcctSeed__Project__c LIMIT 1];
        String proRT= Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Translation_Projects').getRecordTypeId();
        String proTsk = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Translation').getRecordTypeId();
        List<AcctSeed__Project_Task__c>  proTaskLst = [SELECT Name,Project_Task_Type__c,RecordTypeId  FROM AcctSeed__Project_Task__c LIMIT 1];

        if(conAssList.size() > 0 && proList.size() > 0 && proTaskLst.size() > 0) {
             proList[0].RecordTypeId  = proRT;
             conAssList[0].Project__c = proList[0].Id;
             proTaskLst[0].RecordTypeId = proTsk;
             proTaskLst[0].Project_Task_Type__c  = 'Translation (per word)';
             proTaskLst[0].Default_Cost_Rate_Rate_Type__c = 'Non-SCA Translation (Per Word)';
             conAssList[0].Project_task__c = proTaskLst[0].Id;

             update proList;
             update proTaskLst;
             update conAssList;
        
            ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[0].Id,'Instructor','AcctSeed__Project__c',conAssList[0].Project__c);
            system.assertEquals(conAssList[0].Id, caDetails.caRecord.Id);
            
            Test.StartTest();
            
            proTaskLst[0].Project_Task_Type__c  = 'Translation (per hr)';
            proTaskLst[0].Default_Cost_Rate_Rate_Type__c = 'Non-SCA Translation (Per Hour)';
            update proTaskLst;
            
            ContactAssignmentDomain.CADetails caDetail = new ContactAssignmentDomain.CADetails();
            ContactAssignmentLightningCtrl.getCARelatedInformation( null,'Instructor','AcctSeed__Project__c',conAssList[0].Project__c);
            caDetail = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[0].Id,'Instructor','AcctSeed__Project__c',conAssList[0].Project__c);
            system.assertEquals(conAssList[0].Id, caDetail.caRecord.Id);
            
            Test.StopTest();
        }
    }
    // getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod29() {
        
        List<AcctSeed__Project__c> oplist = proOppContract('Opportunity'); 
        List<Opportunity> oppList= [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity  LIMIT 1];
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Opportunity_Name__c,Opportunity_Product_Id__c, Candidate_Name__c FROM Contact_Assignments__c  LIMIT 1];
        String oppcdRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CD_Opportunities').getRecordTypeId();
        
        if(opplist.size() > 0 && conAssList.size() > 0) {
            Test.StartTest();
            
            List<OpportunityLineItem> oppLineItems = [SELECT Id FROM OpportunityLineItem LIMIT 3];
            conAssList[0].Opportunity_Product_Id__c = oppLineItems[0].Id;
            conAssList[0].Status__c = 'Awarded';
            update conAssList;
            
            ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();
            
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation(conAssList[0].Id,'Staff','Opportunity',opplist[0].Id );
            opplist[0].RecordTypeId = oppcdRt;
            update opplist;
            
            Test.StopTest();
            system.assertEquals(conAssList[0].Id, caDetails.caRecord.Id);
           
        }
    }
// getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod29A1() {
        
        List<AcctSeed__Project__c> oplist = proOppContract('Opportunity'); 
        List<Opportunity> oppList= [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity  LIMIT 1];
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Opportunity_Name__c,Opportunity_Product_Id__c, Candidate_Name__c FROM Contact_Assignments__c  LIMIT 1];
        String oppcdRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CD_Opportunities').getRecordTypeId();
        
        if(opplist.size() > 0 && conAssList.size() > 0) {
            
            ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();
            opplist[0].RecordTypeId = oppcdRt;
            update opplist;
            
            Test.StartTest();
            
            List<OpportunityLineItem> oppLineItems = [SELECT Id FROM OpportunityLineItem LIMIT 3];
            conAssList[0].Opportunity_Product_Id__c = oppLineItems[0].Id;
            conAssList[0].Status__c = 'Awarded';
            update conAssList;
            
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation(conAssList[0].Id,'Instructor','Opportunity',opplist[0].Id );
            system.assertEquals(conAssList[0].Id, caDetails.caRecord.Id);
            Test.StopTest();
           
        }
    }
  
    // getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod29a() {
        
        List<AcctSeed__Project__c> oplist = proOppContract('Opportunity'); 
        List<Opportunity> oppList= [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity  LIMIT 1];
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Opportunity_Name__c,Opportunity_Product_Id__c, Candidate_Name__c FROM Contact_Assignments__c  LIMIT 1];
        String oppAdminRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Admin_Opportunities').getRecordTypeId();
        
        
        if(opplist.size() > 0 && conAssList.size() > 0) {
            ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();
            
            Test.startTest();
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation(conAssList[0].Id,'Instructor','Opportunity',opplist[0].Id);
            system.assertEquals(conAssList[0].Id, caDetails.caRecord.Id);
            Test.stoptest();
        }
    }
     // getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod29B() {
        
        List<AcctSeed__Project__c> oplist = proOppContract('Opportunity'); 
        List<Opportunity> oppList= [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity  LIMIT 1];
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Opportunity_Name__c,Opportunity_Product_Id__c, Candidate_Name__c FROM Contact_Assignments__c  LIMIT 1];
        String oppAdminRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Admin_Opportunities').getRecordTypeId();
        
        if(opplist.size() > 0 && conAssList.size() > 0) {
            ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();
            
            Test.startTest();
            opplist[0].RecordTypeId = oppAdminRt;
            update opplist;
            
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation(conAssList[0].Id,'Staff','Opportunity',opplist[0].Id );
            system.assertEquals(conAssList[0].Id, caDetails.caRecord.Id);
            Test.stoptest();
        }
    }
    // getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod29aa() {
        
        List<AcctSeed__Project__c> oplist = proOppContract('Opportunity'); 
        List<Opportunity> oppList= [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity  LIMIT 1];
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Opportunity_Name__c,Opportunity_Product_Id__c, Candidate_Name__c FROM Contact_Assignments__c  LIMIT 1];
        String oppMttRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MTT_Opportunities').getRecordTypeId();
        
        if(opplist.size() > 0 && conAssList.size() > 0) {
            ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();
            opplist[0].RecordTypeId = oppMttRt;
            update opplist;
            
            Test.startTest();
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation(conAssList[0].Id,'Instructor','Opportunity',opplist[0].Id );
            system.assertEquals(conAssList[0].Id, caDetails.caRecord.Id);
            Test.Stoptest();
        }
    }
    // getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod30() {
        
        List<AcctSeed__Project__c> oplist = proOppContract('Opportunity'); 
        List<Opportunity> oppList= [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity  LIMIT 1];
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Opportunity_Name__c,Opportunity_Product_Id__c, Candidate_Name__c FROM Contact_Assignments__c  LIMIT 1];
        String oppTransRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Translation_Opportunities').getRecordTypeId();
        String oppInterRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Interpretation_Opportunities').getRecordTypeId();
        
        List<OpportunityLineItem> oppLineItems = [SELECT Id FROM OpportunityLineItem LIMIT 3];
        conAssList[0].Opportunity_Product_Id__c = oppLineItems[0].Id;
        update conAssList;
        
        if(opplist.size() > 0 && conAssList.size() > 0) {
            
            Test.StartTest();
            opplist[0].RecordTypeId = oppTransRt;
            update opplist;
            ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();

            ContactAssignmentLightningCtrl.getCARelatedInformation(conAssList[0].Id,'Instructor','Opportunity',opplist[0].Id );
            ContactAssignmentLightningCtrl.getCARelatedInformation(null,'Staff','Opportunity',opplist[0].Id );
            opplist[0].RecordTypeId = oppInterRt;
            update opplist;
            
            ContactAssignmentLightningCtrl.getCARelatedInformation(null,'Instructor','Opportunity',opplist[0].Id );
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation(conAssList[0].Id,'Instructor','Opportunity',opplist[0].Id );
            system.assertEquals(conAssList[0].Id, caDetails.caRecord.Id);
            Test.Stoptest();
        }
    }
    // getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod31() {
        
        List<Contract> contractlist = proOppContract('Contract'); 
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Contract__c, Candidate_Name__c FROM Contact_Assignments__c WHERE  Contract__c != null LIMIT 2];
        
        if(contractlist.size() > 0 && conAssList.size() > 0) {
            ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[0].Id,'Staff','Contract',contractlist[0].Id );
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[0].Id,'Client_Partner','Contract',contractlist[0].Id );
            system.assertEquals(conAssList[0].Id, caDetails.caRecord.Id);
        }
        
    }
    // getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod32() {
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, RecordTypeId ,Candidate_Name__c, Candidate_Name__r.Id FROM Contact_Assignments__c  LIMIT 3];
        String proLSPRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Linguist_Support_Projects').getRecordTypeId();
        String proDliRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        List<AcctSeed__Project_Task__c> protask = [Select Id from AcctSeed__Project_Task__c  LIMIT 2];
        conAssList[0].Project_Task__c = protask[0].Id;
        conAssList[0].Status__c = 'Awarded';
        update conAssList;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(projList.size() > 0 && conAssList.size() > 0) {
            
            Test.startTest();
            
            List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Rate_Type__c,Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
            costrateList[0].Status__c = 'Draft';
            costrateList[0].Contact__c = conList[0].Id;
            update costrateList;
            
            projList[0].RecordTypeId = proLSPRt; 
            projList[0].Default_Cost_Rate_Rate_Type__c = costrateList[0].Rate_Type__c;
            update projList;
            
            ContactAssignmentDomain.CADetails caDetails =new  ContactAssignmentDomain.CADetails();
            
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[0].Id,'Instructor','AcctSeed__Project__c',projList[0].Id);
            Test.stopTest();

            projList[0].RecordTypeId = proDliRt; 
            update projList;
          
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[0].Id,'Client_Partner','AcctSeed__Project__c',projList[0].Id );
          
            system.assertEquals(conAssList[0].Id, caDetails.caRecord.Id);
        }
        
    }
    // getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod32A() {
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, RecordTypeId ,Candidate_Name__c, Candidate_Name__r.Id FROM Contact_Assignments__c WHERE Project__r.AcctSeed__Account__c != null LIMIT 3];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        String proMttRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('MTT_Projects').getRecordTypeId();

        
        List<AcctSeed__Project_Task__c> protask = [Select Id from AcctSeed__Project_Task__c LIMIT 2];
        conAssList[0].Project_Task__c = protask[0].Id;
        conAssList[0].Status__c = 'Awarded';
        update conAssList;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        
        if(projList.size() > 0 && conAssList.size() > 0) {
            ContactAssignmentDomain.CADetails caDetails =new  ContactAssignmentDomain.CADetails();
            
            Test.startTest();
            List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Rate_Type__c,Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
            costrateList[0].Status__c = 'Draft';
            costrateList[0].Contact__c = conList[0].Id;
            update costrateList;
            
            projList[0].RecordTypeId = proMttRt; 
            projList[0].Default_Cost_Rate_Rate_Type__c = costrateList[0].Rate_Type__c;
            projList[0].Project_Type__c = 'MTT'; 
            projList[0].TO__c = 'Test';
            projList[0].AcctSeed__Account__c = accList[0].Id;
            update projList;
            Test.stopTest();

            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[1].Id,'Instructor','AcctSeed__Project__c',projList[0].Id);
            system.assertEquals(conAssList[1].Id, caDetails.caRecord.Id);
        }
        
    }
     // getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod33() {
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, RecordTypeId ,Candidate_Name__c, Candidate_Name__r.Id FROM Contact_Assignments__c  LIMIT 3];
       
        String proCdRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('CD_Projects').getRecordTypeId();
        String TransRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Translation_Projects').getRecordTypeId();

        List<AcctSeed__Project_Task__c> protask = [Select Id from AcctSeed__Project_Task__c  LIMIT 2];
        conAssList[0].Project_Task__c = protask[0].Id;
        conAssList[0].Status__c = 'Awarded';
        update conAssList;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Rate_Type__c,Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        if(projList.size() > 0 && conAssList.size() > 0) {
            
            Test.startTest();
            
            costrateList[0].Status__c = 'Draft';
            costrateList[0].Contact__c = conList[0].Id;
            update costrateList;
            
            projList[0].Default_Cost_Rate_Rate_Type__c = costrateList[0].Rate_Type__c;
            projList[0].RecordTypeId = TransRt; 
            update projList;
            
            ContactAssignmentDomain.CADetails caDetails =new  ContactAssignmentDomain.CADetails();
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[2].Id,'Instructor','AcctSeed__Project__c',projList[0].Id);
            Test.stopTest();
            
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[2].Id,'Staff','AcctSeed__Project__c',projList[0].Id );
            system.assertEquals(conAssList[2].Id, caDetails.caRecord.Id);
           
        }
    }
      // getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod33A() {
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, RecordTypeId ,Candidate_Name__c, Candidate_Name__r.Id FROM Contact_Assignments__c  LIMIT 3];
       
        String proCdRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('CD_Projects').getRecordTypeId();

        List<AcctSeed__Project_Task__c> protask = [Select Id from AcctSeed__Project_Task__c  LIMIT 2];
        conAssList[0].Project_Task__c = protask[0].Id;
        conAssList[0].Status__c = 'Active';
        update conAssList;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Rate_Type__c,Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        if(projList.size() > 0 && conAssList.size() > 0) {
            
            Test.startTest();
            
            costrateList[0].Status__c = 'Draft';
            costrateList[0].Contact__c = conList[0].Id;
            update costrateList;
            
            projList[0].Default_Cost_Rate_Rate_Type__c = costrateList[0].Rate_Type__c;
            projList[0].RecordTypeId = proCdRt; 
            update projList;
            
            ContactAssignmentDomain.CADetails caDetails =new  ContactAssignmentDomain.CADetails();
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[1].Id,'Instructor','AcctSeed__Project__c',projList[0].Id);
            Test.stopTest();
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[1].Id,'Staff','AcctSeed__Project__c',projList[0].Id );
                      
        }
    }
    
     private static testMethod void testMethod34() {
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, RecordTypeId ,Candidate_Name__c, Candidate_Name__r.Id FROM Contact_Assignments__c  LIMIT 3];
        String InterPretRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Interpretation_Projects').getRecordTypeId();

         ContactAssignmentDomain.CADetails caDetails =new  ContactAssignmentDomain.CADetails();

         List<AcctSeed__Project_Task__c> protask = [Select Id from AcctSeed__Project_Task__c  LIMIT 2];
         conAssList[0].Project_Task__c = protask[0].Id;
         update conAssList;
         
         List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
         
         
         if(projList.size() > 0 && conAssList.size() > 0) {
             Test.startTest();
             
             List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Rate_Type__c,Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
             costrateList[0].Status__c = 'Draft';
             costrateList[0].Contact__c = conList[0].Id;
             update costrateList;
             
             projList[0].RecordTypeId = InterPretRT; 
             update projList;
             caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( null,'Staff','AcctSeed__Project__c',projList[0].Id );
             
             Test.stopTest();
             caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[0].Id,'Instructor','AcctSeed__Project__c',projList[0].Id );
             system.assertEquals(conAssList[0].Id, caDetails.caRecord.Id);
         }
     }
       private static testMethod void testMethod34A() {
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, RecordTypeId ,Candidate_Name__c, Candidate_Name__r.Id FROM Contact_Assignments__c  LIMIT 3];
        String TransRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Translation_Projects').getRecordTypeId();

         ContactAssignmentDomain.CADetails caDetails =new  ContactAssignmentDomain.CADetails();

         List<AcctSeed__Project_Task__c> protask = [Select Id from AcctSeed__Project_Task__c  LIMIT 2];
         conAssList[0].Project_Task__c = protask[0].Id;
         update conAssList;
         
         List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
         List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Rate_Type__c,Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
         
         
         if(projList.size() > 0 && conAssList.size() > 0) {
             Test.startTest();
             
             costrateList[0].Status__c = 'Draft';
             costrateList[0].Contact__c = conList[0].Id;
             update costrateList;
             
             projList[0].RecordTypeId = TransRt; 
             update projList;
             
             caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( null,'Staff','AcctSeed__Project__c',projList[0].Id);
             caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( conAssList[0].Id,'Instructor','AcctSeed__Project__c',projList[0].Id);

             system.assertEquals(conAssList[0].Id, caDetails.caRecord.Id);
             Test.stopTest();
         }
         
     }
    // for new ContactAssignment Creation (Project,Opportunity,Contract)
    private static testMethod void testMethod35() {
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contract> contractlist = proOppContract('Contract'); 
        List<Opportunity> oppList= [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity LIMIT 2];
        String oppDliRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DLI_W_TO_Opportunities').getRecordTypeId();
       
        Test.startTest();
        
        ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();
        oppList[0].RecordTypeId = oppDliRt; 
        update oppList;
        
        caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( null,'Instructor','Opportunity',oppList[0].Id);
        system.assertEquals(null, caDetails.caRecord.Id);
        
        Test.stopTest();
    }
      private static testMethod void testMethod35AA() {
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contract> contractlist = proOppContract('Contract'); 
        List<Opportunity> oppList= [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity LIMIT 2];
        String proAdminRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Admin_Projects').getRecordTypeId();
       
        ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();
       
        Test.startTest();

        projList[1].RecordTypeId = proAdminRt; 
        update projList;
        
        caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( null,'Staff','AcctSeed__Project__c',projList[1].Id);
        caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( null,'Staff','Contract',contractlist[0].Id);
        system.assertEquals(null, caDetails.caRecord.Id);
        
        Test.stopTest();
    }
     // for new ContactAssignment Creation (Project,Opportunity,Contract)
    private static testMethod void testMethod35B() {
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contract> contractlist = proOppContract('Contract'); 
        List<Opportunity> oppList= [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity LIMIT 2];
        String proAdminRt = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Admin_Projects').getRecordTypeId();
        String oppDliRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DLI_W_TO_Opportunities').getRecordTypeId();
       
        Test.startTest();
            
        ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();
        oppList[0].RecordTypeId = oppDliRt; 
        update oppList;
        
        caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( null,'Instructor','Opportunity',oppList[0].Id);
        
        Test.stopTest();
    }
     // for new ContactAssignment Creation (Project,Opportunity,Contract)
    private static testMethod void testMethod35BB() {
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contract> contractlist = proOppContract('Contract'); 
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];

        List<Opportunity> oppList= [SELECT  RecordType.Id,RecordType.DeveloperName FROM Opportunity LIMIT 2];
       
        ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();

        caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( null,'Client_Partner','Contract',contractlist[0].Id);
        Test.startTest();
        
        projList[0].AcctSeed__Account__c = accList[0].Id;
        update projList;
        
        caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( null,'Consultant','AcctSeed__Project__c',projList[0].Id);
        caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( null,'Student','AcctSeed__Project__c',projList[0].Id);
        system.assertEquals(projList[0].Id,caDetails.caRecord.Project__c);
        
        Test.stopTest();
    }
    
    //staffStatusUpdate apex   method related to update staff field based on condition (Status Ended)  
    private static testMethod void testMethod36() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name,Project__c,Contract__c,RecordTypeId, Status__c,recordType.Name,Candidate_Name__c,Opportunity_Name__c, End_Date__c FROM Contact_Assignments__c Where RecordType.DeveloperName = 'Staff' AND Project__c != null];
        List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
        
        if(conAssList.size() > 0){
        
            for(Contact_Assignments__c ca : conAssList){
            
                ca.Status__c = 'Active';
                ca.End_Date__c = Date.Today().addDays(-2);
                updateCAs.add(ca);
            }
            update updateCAs;
            
            ContactAssignmentLightningCtrl.staffStatusUpdate(conAssList[0].Project__c,JSON.serialize(conAssList));
            List<Contact_Assignments__c> conAsListStatusEnded = [SELECT Id, Name, Contract__c,RecordTypeId, Status__c,recordType.Name,Project__c,Candidate_Name__c,Opportunity_Name__c FROM Contact_Assignments__c Where RecordType.DeveloperName = 'Staff' AND Id != :conAssList[0].Id LIMIT 1];
            if(conAsListStatusEnded.size() > 0){
                //system.assertEquals(conAsListStatusEnded[0].Status__c,'Ended');
            }
        }
    }
   
    private static testMethod void testMethod37() {
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Rate_Card_Rate__c,Drafted_Labor_Cost_Rate__c,Candidate_Name__r.Id,Opportunity_Product_Id__c,Project_Task__c FROM Contact_Assignments__c LIMIT 2];
        List<AcctSeed__Project_Task__c> protask = [Select Id From AcctSeed__Project_Task__c LIMIT 2];
        
        if(projList.size() > 0 && conAssList.size() > 0) {
            projList[0].Default_Cost_Rate_Rate_Type__c = 'Non-SCA Testing';
            update projList;
            
            List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Contact__c,Status__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'FT Salary & Benefits'];
            costrateList[0].Contact__c = conAssList[0].Candidate_Name__c;
            costrateList[0].Status__c = 'Approved';
            update  costrateList;
            
            conAssList[0].Project_Task__c = protask[0].Id;
            update  conAssList;
            
            ContactAssignmentDomain.CostRateDetails  costDetails = ContactAssignmentLightningCtrl.staffNonScaTestingmethod(projList[0].Default_Cost_Rate_Rate_Type__c,conAssList[0].Candidate_Name__c); 
            System.assertEquals(conAssList[0].Rate_Card_Rate__c, costDetails.rateCardRate);
            
            Test.StartTest();
            costrateList[0].Rate_Type__c = 'FT Hourly & Benefits';
            update  costrateList;
            
            ContactAssignmentLightningCtrl.staffNonScaTestingmethod(projList[0].Default_Cost_Rate_Rate_Type__c,conAssList[0].Candidate_Name__c);
            costrateList[0].Rate_Type__c = 'PT Hourly (OH & G&A)';
            update  costrateList;
            
            ContactAssignmentLightningCtrl.staffNonScaTestingmethod(projList[0].Default_Cost_Rate_Rate_Type__c,conAssList[0].Candidate_Name__c);
           
            Test.StopTest();
        }
    }
     private static testMethod void testMethod38() {
        
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Rate_Card_Rate__c,Drafted_Labor_Cost_Rate__c,Candidate_Name__r.Id,Opportunity_Product_Id__c,Project_Task__c FROM Contact_Assignments__c LIMIT 2];
        List<AcctSeed__Project_Task__c> protask = [Select Id From AcctSeed__Project_Task__c LIMIT 2];
        
        if(projList.size() > 0 && conAssList.size() > 0) {
            
            projList[0].Default_Cost_Rate_Rate_Type__c = 'Non-SCA Testing';
            update projList;
            
            List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Contact__c,Status__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'FT Salary & Benefits'];
            costrateList[0].Contact__c = conAssList[0].Candidate_Name__c;
            costrateList[0].Rate_Type__c = 'FT Salary & Benefits';
            costrateList[0].Status__c = 'Approved';
            update  costrateList;
            
            conAssList[0].Project_Task__c = protask[0].Id;
            conAssList[0].Rate_Card_Rate__c = costrateList[0].Id;
            update  conAssList;
            
            ContactAssignmentDomain.CostRateDetails  costDetails = ContactAssignmentLightningCtrl.staffNonScaTestingmethod(conAssList[0].Candidate_Name__c,projList[0].Default_Cost_Rate_Rate_Type__c); 
            System.assertEquals(costrateList[0].Id, costDetails.rateCardRate);
            
            Test.StartTest();
            costrateList[0].Rate_Type__c = 'FT Hourly & Benefits';
            update  costrateList;
            
            ContactAssignmentLightningCtrl.staffNonScaTestingmethod(conAssList[0].Candidate_Name__c,projList[0].Default_Cost_Rate_Rate_Type__c);
            costrateList[0].Rate_Type__c = 'PT Hourly (OH & G&A)';
            update  costrateList;
            
            ContactAssignmentLightningCtrl.staffNonScaTestingmethod(conAssList[0].Candidate_Name__c,projList[0].Default_Cost_Rate_Rate_Type__c);
            Test.StopTest();
            
        }
    }
    private static testMethod void testMethod39(){
        List<AcctSeed__Project__c> projList = proOppContract('Project'); 
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__r.Name FROM Contact_Assignments__c LIMIT 1];
        List<APXTConga4__Conga_Template__c> conTemplst  = [SELECT Id ,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Name__c = 'send Tester Payment Form'];
        
        if(projList.size() > 0 && conAssList.size() > 0){
            conAssList[0].Project__c = projList[0].Id;
            update conAssList;
            projList[0].Default_Cost_Rate_Rate_Type__c = 'Non-SCA Testing';
            update projList;
            ContactAssignmentLightningCtrl.genPaymentFormCongaDocument(conAssList[0].Id,'send Tester Payment Form',projList[0].Id);
        }
    }
 
    // getCARelatedInformation method to populate CA inputfield Values
    private static testMethod void testMethod40() {
        
        String cAInsRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId(); 
        String proRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();  
        String proTaskRT = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        List<Contact_Assignments__c> caList = [SELECT Id,Name,Status__c,Candidate_Name__c,Candidate_Name__r.Name,Project__c FROM Contact_Assignments__c WHERE Project__r.AcctSeed__Account__c != null LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,Name,RecordTypeId,DLS_Class__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c>  proTask = [SELECT Name,Project_Task_Type__c FROM AcctSeed__Project_Task__c LIMIT 1];  
        
        AcctSeed__Project_Task__c ProTsk = new AcctSeed__Project_Task__c(RecordTypeId = proTaskRT,Id = proTask[0].Id,Name = 'Language Training Hindi',AcctSeed__Project__c = proList[0].Id,Project_Task_Type__c = 'Language Training');
        update ProTsk;
       
        
        
        if(proList.size() > 0 && caList.size() > 0 &&  proTask.size() > 0){
            prolist[0].RecordTypeId = proRT;
            update proList;
           
            
            List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Rate_Type__c,Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
            costrateList[0].Status__c = 'Approved';
            costrateList[0].Contact__c = caList[0].Candidate_Name__c;
            update costrateList;
             
            caList[0].RecordTypeId = cAInsRT;
            caList[0].Project_Task__c = proTask[0].Id;
            caList[0].Project__c = proList[0].Id;
            caList[0].Rate_Card_Rate__c = costrateList[0].Id;
            update caList;
            
            ContactAssignmentDomain.CADetails caDetails = new ContactAssignmentDomain.CADetails();
            caDetails = ContactAssignmentLightningCtrl.getCARelatedInformation( caList[0].Id,'Instructor','AcctSeed__Project__c',caList[0].Project__c );
            
            //Student_Approval_Status__c,
            List<AcctSeed__Time_Card_Day__c> tcdLst = [SELECT AcctSeed__Time_Card_Line__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Total_Hours_Before_Approved__c,AcctSeed__Hours__c,AcctSeed__Date__c,Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 3];        
            
            if(tcdLst.size() > 0){
                for(AcctSeed__Time_Card_Day__c tcd : tcdLst){
                    //tcd.Student_Approval_Status__c = 'Submitted';
                    tcd.Status__c = 'Submitted';
                }
                update tcdLst;
                List<AcctSeed__Time_Card__c> tcLst = [SELECT Id,Intructor__c FROM AcctSeed__Time_Card__c WHERE Id = :tcdLst[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c];
                tcLst[0].Intructor__c =  caList[0].Candidate_Name__c ;
                update tcLst;
                
                List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id,AcctSeed__Project__c,AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Line__c WHERE Id = :tcdLst[0].AcctSeed__Time_Card_Line__c];
                tclList[0].AcctSeed__Project_Task__c = ProTsk.Id;
                tclList[0].AcctSeed__Project__c = proList[0].Id;
                update tclList;
            }
            system.assertEquals(caList[0].Id, caDetails.caRecord.Id);
        }
        
    }
    // This method for payratemodify action in CA
    private static testMethod void testMethod41() {
        
        String cAInsRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId(); 
        String proRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();  
        String ProTsk = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        List<Contact_Assignments__c> caList = [SELECT Id,Name,Status__c,Candidate_Name__c,Candidate_Name__r.Name,Project__c,Project_Task__c,Rate_Card_Rate__c,RecordTypeId FROM Contact_Assignments__c LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,Name,RecordTypeId,DLS_Class__c,Default_Cost_Rate_Rate_Type__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c>  proTask = [SELECT Name,Project_Task_Type__c FROM AcctSeed__Project_Task__c LIMIT 1];
        List<AcctSeed__Cost_Rates__c>  costrateList = [SELECT Id,Rate_Type__c,Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        try{
            if(proList.size() > 0 && caList.size() > 0 && proTask.size() > 0 && costrateList.size() > 0){
                prolist[0].RecordTypeId = proRT;
                prolist[0].Default_Cost_Rate_Rate_Type__c = 'LT with Prep';
                update proList;
                
                Test.startTest();
                caList[0].RecordTypeId = cAInsRT;
                caList[0].End_Date__c = system.today().addDays(5);
                caList[0].Project_Task__c = proTask[0].Id;
                caList[0].Project__c = proList[0].Id;
                caList[0].Rate_Card_Rate__c = costrateList[0].Id;
                update caList;
                
                AcctSeed__Cost_Rates__c cr = new AcctSeed__Cost_Rates__c();
                cr.Prior_Version__c = costrateList[0].Id;
                cr.Effective_Date__c = system.today();
                cr.Notes_Reasons_for_Change__c = 'Test';
                cr.AcctSeed__Hourly_Cost__c = 23;
                cr.Status__c = 'Draft';
                
                // logged as LTS User 
                Profile p = [SELECT Id FROM Profile WHERE Name='LTS'];
                User usr = new User(Alias = 'standt', email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    LocaleSidKey='en_US', ProfileId = p.id,timezonesidkey='america/los_angeles',username='ltstest@testorg.com');
                insert usr; 
                
                System.runAs(usr) {
                    ContactAssignmentLightningCtrl.createPayRateModifyCostRate(cr, proList[0].Id,caList[0],'LT with Prep');
                }
            }
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }
        Test.stopTest();
    }// to check contact citizenship as 'US Citizen'
     private static testMethod void testMethod42() {
         List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];
         if(conList.size() > 0){
             
             conList[0].Citizenship__c = 'U.S. Citizen';
             update conList;
             
             Boolean isUsCitizen =  ContactAssignmentLightningCtrl.isConCitizenshipisUSCitizen(conList[0].Id);
             system.assertEquals(true, isUsCitizen);
         }
         
    }
    private static testMethod void testMethod43() {
        List<Contact_Assignments__c> caList = [SELECT Id,Project__c FROM Contact_Assignments__c WHERE Project__c != null LIMIT 1];
        
        if(caList.size() > 0){
            ContactAssignmentLightningCtrl.validateStaffActiveStatus(caList[0].Project__c);
        }
        
    }
    /* W-007721 - Process to Transfer a Student from One Project to Another Project (MAR-15-2023)*/
    private static testMethod void testMethod44() { 
        List<Contact_Assignments__c> caList = [SELECT Id,Project__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Student' LIMIT 1];
        
        if(caList.size() > 0){
            String caJSON =  ContactAssignmentLightningCtrl.getStudentCAsForClassLeader(caList[0].Project__c,'Class Leader');
            
            List<Contact_Assignments__c> caStuList = (List<Contact_Assignments__c>) JSON.deserialize(caJSON, List<Contact_Assignments__c>.class);
            
            System.assertEquals(true, caStuList.size() > 0);
        }
    }  
    /* W-007721 - Process to Transfer a Student from One Project to Another Project (MAR-15-2023)*/
    private static testMethod void testMethod44a() { 
        List<Contact_Assignments__c> caList = [SELECT Id,Project__c,Candidate_Name__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Student' LIMIT 1];
        
        if(caList.size() > 0){
            String caValidationJSON = ContactAssignmentLightningCtrl.transferStudentCAValidationCheck(System.today()-25,caList[0].Project__c,caList[0].Candidate_Name__c);  
            System.assertEquals(true, caValidationJSON.contains('Please fill the valid new Student Contact Assignment Start Date for selected project '));
        }
    }
    /* W-007721 - Process to Transfer a Student from One Project to Another Project (MAR-15-2023)*/
    private static testMethod void testMethod44b() { 
        List<Contact_Assignments__c> caList = [SELECT Id,Project__c,Candidate_Name__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Student' LIMIT 1];
        
        if(caList.size() > 0){
            
            Test.startTest();
            caList[0].Assignment_Position__c = 'Class Leader';
            update caList;
            Test.stopTest();
            
            ContactAssignmentLightningCtrl.transferStudentCAtoAnotherProject(caList[0].Id,System.today(),System.today()+10,caList[0].Project__c,caList[0].Candidate_Name__c);
            
            List<Contact_Assignments__c> caResult = [SELECT Id,Project__c,Status__c FROM Contact_Assignments__c WHERE Id = :caList[0].Id];
            System.assertEquals(true, caResult.size() > 0);

        }      

    }//* This method to get lookup value
    private static testMethod void testMethod44C() { 
        ContactAssignmentLightningCtrl.getLookupRecords('', 'AcctSeed__Project__c', '', '', new List<String>{});
    }
    // Based on the parameter records will be Queried   
    private static List<Sobject> proOppContract(String obj) { 
        
        List<Contact> conList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId != null LIMIT 2];

        if(obj != 'Contract') {
            List<AcctSeed__Project__c> proList = [SELECT Id, Name, AcctSeed__Opportunity__r.Id,Default_Cost_Rate_Rate_Type__c,AcctSeed__Account__c FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c != null LIMIT 2];
            List<Opportunity> oppListUp = new List<Opportunity>();
            List<AcctSeed__Project__c> proListUp =  new List<AcctSeed__Project__c>();
            
            List<MTT_Location__c> locList = new List<MTT_Location__c> {
                new MTT_Location__c(Name='Test Loc 1',State__c = 'Test State 1'),
                new MTT_Location__c(Name='Test Loc 2',State__c = 'Test State 2', Street__c = 'Test Street 2', Zip_Code__c = '123',
                                    Country__c = 'Test Country', City_and_State__c = 'Test City_and_State__c')
            };
            insert locList;
            
            if(proList.size() > 0) {
                                
                if(obj == 'Project') {
                    for(AcctSeed__Project__c pro : proList) {
                        pro.Travel_In_Date__c = system.today();
                        pro.Travel_Out_Date__c = system.today().addDays(10);
                        pro.Oral_Exam_Date_Time__c = system.today().addDays(5);
                        pro.Training_Location__c = locList[0].Id;
                        if(pro.AcctSeed__Account__c == null ){
                            pro.AcctSeed__Account__c = conList[0].AccountId;
                        }
                        proListUp.add(pro);
                    }
                    update proListUp;
                
                    List<AcctSeed__GL_Account__c> glAccList = new List<AcctSeed__GL_Account__c> {
                        new AcctSeed__GL_Account__c(Name = 'Test GL1',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Expense'),
                        new AcctSeed__GL_Account__c(Name = 'Test GL2',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Expense')
                    };
                    insert glAccList;
                 
                } else if(obj == 'Opportunity') {
                    Set<Id> oppIdSet = new Set<Id>();
                    oppIdSet.add(proList[0].AcctSeed__Opportunity__r.Id);
                    oppIdSet.add(proList[1].AcctSeed__Opportunity__r.Id);
                    
                    if(oppIdSet.size() > 0) {
                        List<Opportunity> oppList = [SELECT Id, Name,Travel_In_Date__c, Travel_Out_Date__c, Oral_Exam__c, Location__c FROM Opportunity WHERE Id IN :oppIdSet];
                        if(oppList.size() > 0) {
                            for(Opportunity opp : oppList) {
                                opp.Travel_In_Date__c = system.today();
                                opp.Travel_Out_Date__c = system.today().addDays(10);
                                opp.Oral_Exam__c = system.today().addDays(5);
                                opp.Location__c = locList[0].Id;
                                oppListUp.add(opp);
                            }
                            update oppListUp;
                        }
                    }
                    
                    List<Product2> prodList = new List<Product2> {
                        new Product2(Name = 'Test Product', Description = 'Test Desc', productCode = 'Test Code', isActive = TRUE,Family='Language Training'),
                        new Product2(Name = 'Test Product2', Description = 'Test Desc2', productCode = 'Test Code2', isActive = TRUE,Family='Language Training')
                    };
                    insert prodList;
        
                    String stdPriceBookId = Test.getStandardPricebookId();
                     
                    List<PricebookEntry> pbeList = new List<PricebookEntry>{
                        new PricebookEntry(IsActive = TRUE, UnitPrice = 100,Pricebook2Id = stdPriceBookId, Product2Id = prodList[0].Id),
                        new PricebookEntry(IsActive = TRUE, UnitPrice = 100, Pricebook2Id = stdPriceBookId, Product2Id = prodList[1].Id)
                    };
                    insert pbeList;
                    
                    List<Language__c> langList = new List<Language__c> {
                        new Language__c(Name = 'English'),
                        new Language__c(Name = 'Tamil')
                    };
                    insert langList;
                    
                    List<OpportunityLineItem> opliList = new List<OpportunityLineItem> {
                        new OpportunityLineItem(OpportunityId = proList[0].AcctSeed__Opportunity__r.Id, PricebookEntryId = pbeList[0].Id,Quantity = 2, UnitPrice = 200, Language__c = langList[0].Id),
                        new OpportunityLineItem(OpportunityId = proList[0].AcctSeed__Opportunity__r.Id, PricebookEntryId = pbeList[0].Id,Quantity = 1, UnitPrice = 300, Language__c = langList[1].Id)
                    };
                    insert opliList;
                }
               
            }
            return proList;
        } else {
            
            List<Contract> contractList = new List<Contract>();
            List<RecordType> contractRt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Contract' LIMIT 2];
            if(contractRt.size() >0) {
                contractList = new List<Contract> {
                    new Contract(RecordTypeId = contractRt[0].Id, AccountId = conList[0].AccountId, Status = 'Completed Draft', StartDate = system.today(), EndDate = system.today().addDays(5), Primary_POC__c = conList[0].Id),
                    new Contract(RecordTypeId = contractRt[1].Id, AccountId = conList[1].AccountId, Status = 'Completed Draft', StartDate = system.today(), EndDate = system.today().addDays(6), Primary_POC__c = conList[1].Id)
                };
                insert contractList;
            }
            return contractList;
        }
    } 
    
    private static testMethod void insDetailsMethod_Test(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Project_Task__c, Status__c, Opportunity_Product_Id__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        Map<Id, List<SelectOption>> conIdCRMap = new Map<Id, List<SelectOption>>();
        conIdCRMap.put(conAss[0].Candidate_Name__c, new List<SelectOption>());
        
        contactAssignmentTranslator.insDetailsMethod(conAss, conIdCRMap);
    }
    
    private static testMethod void getCAListView_Test(){
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Record_Type_Developer_Name__c, 
            Candidate_Name__r.firstname, Candidate_Name__r.lastname, Candidate_Name__r.name, Start_Date__c, End_Date__c,
            Status__c, Assignment_Position__c, RecordTypeId, RecordType.DeveloperName
             FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        
        contactAssignmentTranslator.getCAListView(conAss, conAss[0].Project__c, 'instructor', conAss[0].Candidate_Name__c);
    } 
}