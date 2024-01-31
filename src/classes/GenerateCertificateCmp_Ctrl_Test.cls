@isTest
public class GenerateCertificateCmp_Ctrl_Test {
    @TestSetup
    static void setupMethod(){
        List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment();          
        box__FRUP__c frup = new box__FRUP__c(box__Folder_ID__c = 'testfolderid', box__Object_Name__c= 'Opportunity', box__Record_ID__c= contactAssignList[0].Project__c,box__Permission__c = 'Read/Write');
        insert frup; 
        insert new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Generate Certificate Template');
        insert new APXTConga4__Conga_Email_Template__c(APXTConga4__Name__c = 'Generate Certificate');
        
        List<Language_Testing__c> langTestingrecs = TestClassUtil.createTestLanguageTesting();
    }
    
    private static testMethod void testGetStudentListAndCongaSessionId(){
        box__FRUP__c frup = [SELECT Id,box__Record_ID__c FROM box__FRUP__c LIMIT 1];
        Test.startTest();
            GenerateCertificateCmp_Ctrl.GenerateCertificateWrap wrapObj = GenerateCertificateCmp_Ctrl.getStudentListAndCongaSessionId(frup.box__Record_ID__c);
            System.assertEquals(null, wrapObj.errorMsg);
            List<Contact_Assignments__c> caToUpdate = new List<Contact_Assignments__c>();
            for(Contact_Assignments__c ca : wrapObj.contactAssignments){
                ca.Certificate_Generation_URL__c = wrapObj.congaBaseUrl;
                ca.Certificate_Generated_Date__c = System.today();
                caToUpdate.add(ca);
            }         
            GenerateCertificateCmp_Ctrl.updateContactRecords(JSON.serialize(caToUpdate));
        Test.stopTest();
    }
    
    private static testMethod void testcreateBoxFRUPRecs(){
        box__FRUP__c frup = [SELECT Id,box__Record_ID__c FROM box__FRUP__c LIMIT 1];
        List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c WHERE Id != :frup.box__Record_ID__c];
        GenerateCertificateCmp_Ctrl.GenerateCertificateWrap wrapObj = GenerateCertificateCmp_Ctrl.getStudentListAndCongaSessionId(proj[0].Id);
        //System.assertEquals('No Box Record', wrapObj.errorMsg); 
        Test.startTest();
            box__FRUP__c frupToInsert = new box__FRUP__c(box__Folder_ID__c = 'testfolderid1', box__Object_Name__c= 'AcctSeed__Project__c', box__Record_ID__c= proj[0].Id,box__Permission__c = 'Read/Write');
            GenerateCertificateCmp_Ctrl.createBoxFRUPRecs(JSON.serialize(frupToInsert));
        Test.stopTest();
    }    
    
    private static testMethod void getStudentListAndCongaSessionId_Test1(){
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        proj[0].RecordTypeId = testProjRTId;
        proj[0].Test_Type__c = 'Translation Billable';
        update proj[0];
        
        GenerateCertificateCmp_Ctrl.GenerateCertificateWrap wrapObj = GenerateCertificateCmp_Ctrl.getStudentListAndCongaSessionId(proj[0].Id);
        Test.startTest();
            box__FRUP__c frupToInsert = new box__FRUP__c(box__Folder_ID__c = 'testfolderid1', box__Object_Name__c= 'AcctSeed__Project__c', box__Record_ID__c= proj[0].Id,box__Permission__c = 'Read/Write');
            GenerateCertificateCmp_Ctrl.createBoxFRUPRecs(JSON.serialize(frupToInsert));
        Test.stopTest();
    }  
    
    private static testMethod void getStudentListAndCongaSessionId_Test2(){
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        proj[0].RecordTypeId = testProjRTId;
        proj[0].Test_Type__c = 'Translation Billable';
        update proj[0];
        
        List<Language_Testing__c> ltRec = [SELECT Id, Examiner__c, Testee__c FROM Language_Testing__c LIMIT 1];
        ltRec[0].Project__c = proj[0].Id;
        update ltRec[0];
        
        GenerateCertificateCmp_Ctrl.GenerateCertificateWrap wrapObj = GenerateCertificateCmp_Ctrl.getStudentListAndCongaSessionId(proj[0].Id);
        Test.startTest();
            box__FRUP__c frupToInsert = new box__FRUP__c(box__Folder_ID__c = 'testfolderid1', box__Object_Name__c= 'AcctSeed__Project__c', box__Record_ID__c= proj[0].Id,box__Permission__c = 'Read/Write');
            GenerateCertificateCmp_Ctrl.createBoxFRUPRecs(JSON.serialize(frupToInsert));
        Test.stopTest();
    }  
    
    private static testMethod void getStudentListAndCongaSessionId_Test3(){
        Id ltPTRTId = Schema.SObjectType.Acctseed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();
        List<Acctseed__Project_Task__c> ptRecs = [SELECT Id, AcctSeed__Project__c FROM Acctseed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training'];
        ptRecs[0].RecordTypeId = ltPTRTId;
        update ptRecs[0];
        
        List<Contact_Assignments__c> caRecs = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff'];
        caRecs[0].Project__c = ptRecs[0].AcctSeed__Project__c;
        caRecs[0].Assignment_Position__c = 'Project Manager';
        update caRecs[0];
        
        Account a = new Account(Name = 'DODA');
        insert a;
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = ptRecs[0].AcctSeed__Project__c;
        proj.AcctSeed__Account__c = a.Id;
        update proj;
        
        Test.startTest();
        
            GenerateCertificateCmp_Ctrl.GenerateCertificateWrap wrapObj = GenerateCertificateCmp_Ctrl.getStudentListAndCongaSessionId(ptRecs[0].AcctSeed__Project__c);
        
            box__FRUP__c frupToInsert = new box__FRUP__c(box__Folder_ID__c = 'testfolderid1', box__Object_Name__c= 'AcctSeed__Project__c', box__Record_ID__c= ptRecs[0].AcctSeed__Project__c,box__Permission__c = 'Read/Write');
            GenerateCertificateCmp_Ctrl.createBoxFRUPRecs(JSON.serialize(frupToInsert));
        Test.stopTest();
        
    }
    
    private static testMethod void getStudentListAndCongaSessionId_Test4(){        
        List<Contact_Assignments__c> caRecs = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' LIMIT 1];
        
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        List<AcctSeed__Project__c> proj = [SELECT Id FROM AcctSeed__Project__c WHERE Id != :caRecs[0].Project__c LIMIT 1];
        proj[0].RecordTypeId = testProjRTId;
        proj[0].Test_Type__c = 'Translation Billable';
        update proj[0];
        
        caRecs[0].Project__c = proj[0].Id;
        caRecs[0].Assignment_Position__c = 'Project Manager';
        update caRecs[0];
        
        Test.startTest();
            GenerateCertificateCmp_Ctrl.GenerateCertificateWrap wrapObj = GenerateCertificateCmp_Ctrl.getStudentListAndCongaSessionId(proj[0].Id);
        
            box__FRUP__c frupToInsert = new box__FRUP__c(box__Folder_ID__c = 'testfolderid1', box__Object_Name__c= 'AcctSeed__Project__c', box__Record_ID__c= proj[0].Id,box__Permission__c = 'Read/Write');
            GenerateCertificateCmp_Ctrl.createBoxFRUPRecs(JSON.serialize(frupToInsert));
        Test.stopTest();
    }  
    
    private static testMethod void getStudentListAndCongaSessionId_Test5(){        
        
        List<Acctseed__Project_Task__c> ptRecs = [SELECT Id, AcctSeed__Project__c FROM Acctseed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training'];
        
        Test.startTest();
            GenerateCertificateCmp_Ctrl.updateContactRecords(JSON.serialize(ptRecs));
        Test.stopTest();
    }  
}