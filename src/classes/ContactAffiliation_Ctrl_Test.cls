@isTest
public class ContactAffiliation_Ctrl_Test {
    @testsetup static void setup() {
        List<Contract> contractList = TestClassUtil.createTestContracts();
    }
    
    // This method to get Client/Partner tab related Contact Affilation records in Account page
    private static testMethod void testMethod1() {
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Contact_Affiliation__c> conAffilList = new List<Contact_Affiliation__c>();
        
        if(conList.size() > 0 && accList.size() > 0){
            Id clientPartnerRTId = Schema.SObjectType.Contact_Affiliation__c.getRecordTypeInfosByDeveloperName().get('Client_Partner').getRecordTypeId();     
            
            List<Contact_Affiliation__c> conAfilList = new List<Contact_Affiliation__c> {
                new Contact_Affiliation__c(Contact__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c = System.today()+30,Account__c = accList[0].Id,Status__c = 'Active',RecordTypeId = clientPartnerRTId,Position__c = 'Client'),
                new Contact_Affiliation__c(Contact__c = conList[1].Id,Start_Date__c = System.today()+1,End_Date__c = System.today()+20,Account__c = accList[0].Id,Status__c = 'Active',RecordTypeId = clientPartnerRTId,Position__c = 'Client')
           };
                        
            insert conAfilList;
            
            ContactAffiliation_Ctrl.ContactAffilationTabInfo conAfilTabInfo = ContactAffiliation_Ctrl.getTabInfo(accList[0].Id,'Account');
            System.assertEquals(conAfilList.size(),conAfilTabInfo.contactAffilationRecs.size());
        }
    }

     // This method to get DLS Staff tab related Contact Affilation records in Contract page
    private static testMethod void testMethod2() {
        List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        
        Id clientPartnerRTId = Schema.SObjectType.Contact_Affiliation__c.getRecordTypeInfosByDeveloperName().get('Client_Partner').getRecordTypeId();     
        
        if(conList.size() > 0 && contractList.size() > 0){
            
            List<Contact_Affiliation__c> conAffilList = new List<Contact_Affiliation__c> {
                new Contact_Affiliation__c(Contact__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c = System.today()+30,Contract__c = contractList[0].Id,Status__c = 'Active',RecordTypeId = clientPartnerRTId,Position__c = 'Client'),
                new Contact_Affiliation__c(Contact__c = conList[1].Id,Start_Date__c = System.today()+1,End_Date__c = System.today()+20,Contract__c = contractList[0].Id,Status__c = 'Planned',RecordTypeId = clientPartnerRTId,Position__c = 'Client')
           };

            insert conAffilList;
            
            ContactAffiliation_Ctrl.ContactAffilationTabInfo conAfilTabInfo = ContactAffiliation_Ctrl.getTabInfo(contractList[0].Id,'Contract');
            System.assertEquals(conAffilList.size(),conAfilTabInfo.contactAffilationRecs.size());
        }
    }
    
    // This method to get Student tab related Contact Affilation records in Account page
    private static testMethod void testMethod3() {
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 2];
        List<Contact_Affiliation__c> conAffilList = new List<Contact_Affiliation__c>();
        
        Id studentRTId = Schema.SObjectType.Contact_Affiliation__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();     
        
        if(conList.size() > 0 && accList.size() > 0){
            Contact_Affiliation__c conAfil = new Contact_Affiliation__c();
            
            conAfil.Contact__c = conList[0].Id;
            conAfil.Start_Date__c = System.today();
            conAfil.End_Date__c = System.today()+30;
            conAfil.Account__c = accList[0].Id;
            conAfil.RecordTypeId = studentRTId;
            conAfil.Position__c = 'Student';
            conAfil.Status__c = 'Planned';
            conAffilList.add(conAfil);
            
            insert conAffilList;
            
            ContactAffiliation_Ctrl.ContactAffilationTabInfo conAfilTabInfo = ContactAffiliation_Ctrl.getContactAffiliationRecs(accList[0].Id,'Account','Student'); 
            System.assertEquals(conAffilList.size(),conAfilTabInfo.contactAffilationRecs.size());
        }
    }
    
    // This method to get DLS Staff tab related Contact Affilation records in Account page
    private static testMethod void testMethod4() {
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];
        List<Contact_Affiliation__c> conAffilList = new List<Contact_Affiliation__c>();
        
        Id staffRTId = Schema.SObjectType.Contact_Affiliation__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();     
        
        if(conList.size() > 0 && accList.size() > 0){
            Contact_Affiliation__c conAfil = new Contact_Affiliation__c();
            
            conAfil.Contact__c = conList[0].Id;
            conAfil.Start_Date__c = System.today();
            conAfil.End_Date__c = System.today()+30;
            conAfil.Account__c = accList[0].Id;
            conAfil.RecordTypeId = staffRTId;
            conAfil.Position__c = 'Staff';
            conAfil.Status__c = 'Planned';
            conAffilList.add(conAfil);
            
            insert conAffilList;
            
            ContactAffiliation_Ctrl.ContactAffilationTabInfo conAfilTabInfo = ContactAffiliation_Ctrl.getContactAffiliationRecs(accList[0].Id,'Account','Staff');
            System.assertEquals(conAffilList.size(),conAfilTabInfo.contactAffilationRecs.size());
        }
    }
    // This method to get Instructor tab related Contact Affilation records in Account page
    private static testMethod void testMethod5() {
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];
        List<Contact_Affiliation__c> conAffilList = new List<Contact_Affiliation__c>();
        
        Id insRTId = Schema.SObjectType.Contact_Affiliation__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();     
        
        if(conList.size() > 0 && accList.size() > 0){
            Contact_Affiliation__c conAfil = new Contact_Affiliation__c();
            
            conAfil.Contact__c = conList[0].Id;
            conAfil.Start_Date__c = System.today();
            conAfil.End_Date__c = System.today()+30;
            conAfil.Account__c = accList[0].Id;
            conAfil.RecordTypeId = insRTId;
            conAfil.Position__c = 'Instructor';
            conAfil.Status__c = 'Planned';
            conAffilList.add(conAfil);
            
            insert conAffilList;
            
            ContactAffiliation_Ctrl.ContactAffilationTabInfo conAfilTabInfo = ContactAffiliation_Ctrl.getContactAffiliationRecs(accList[0].Id,'Account','Instructor');
            System.assertEquals(conAffilList.size(),conAfilTabInfo.contactAffilationRecs.size());
        }
    }
    
    // This test  method to check permission to perform DML operation.
    private static testMethod void testMethod6() {
        Boolean edit = ContactAffiliation_Ctrl.contactAffilationRecAccess('Edit');
        Boolean del = ContactAffiliation_Ctrl.contactAffilationRecAccess('Delete');
        Boolean create = ContactAffiliation_Ctrl.contactAffilationRecAccess('Create');
        
        System.assertEquals(edit,true);
        System.assertEquals(create,true);
        System.assertEquals(del,true);
    }
    
    // This test method to update and delete the Contact Affilation Record
    private static testMethod void testMethod7() {
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];
        List<Contact_Affiliation__c> conAffilList = new List<Contact_Affiliation__c>();
        
        Id studentRTId = Schema.SObjectType.Contact_Affiliation__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();     
        
        if(conList.size() > 0 && accList.size() > 0){
            Contact_Affiliation__c conAfil = new Contact_Affiliation__c();
            
            conAfil.Contact__c = conList[0].Id;
            conAfil.Start_Date__c = System.today();
            conAfil.End_Date__c = System.today()+30;
            conAfil.Account__c = accList[0].Id;
            conAfil.RecordTypeId = studentRTId;
            conAfil.Status__c = 'Planned';
            conAfil.Position__c = 'Student';
            conAffilList.add(conAfil);
            
            insert conAffilList;
            
            if(conAffilList.size() > 0){
                conAffilList[0].Status__c = 'Active';
                update conAffilList;
                
                ContactAffiliation_Ctrl.upsertCARecord(JSON.serialize(conAffilList));
                
                List<Contact_Affiliation__c> conAffiLst = [Select Id,Status__c FROM Contact_Affiliation__c WHERE Id = :conAffilList[0].Id];
                System.assertEquals('Active', conAffiLst[0].Status__c);
                
                Test.startTest();
                ContactAffiliation_Ctrl.deleteConAffilationRec(conAffilList[0].Id);
                List<Contact_Affiliation__c> conAffiList = [Select Id FROM Contact_Affiliation__c WHERE Id = :conAffilList[0].Id];
                System.assertEquals(0, conAffiList.size());
                Test.stopTest();
            }
        }
    }
    
    // This test method to get Editing information for Contact Affilation Record in Account Page
    private static testMethod void testMethod8() {
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];
        List<Contact_Affiliation__c> conAffilList = new List<Contact_Affiliation__c>();
        
        Id studentRTId = Schema.SObjectType.Contact_Affiliation__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();     
        
        if(conList.size() > 0 && accList.size() > 0){
            Contact_Affiliation__c conAfil = new Contact_Affiliation__c();
            
            conAfil.Contact__c = conList[0].Id;
            conAfil.Start_Date__c = System.today();
            conAfil.End_Date__c = System.today()+30;
            conAfil.Account__c = accList[0].Id;
            conAfil.RecordTypeId = studentRTId;
            conAffilList.add(conAfil);
            
            insert conAffilList;
            
            contactAffiliation_Ctrl.ContactAffilationDetail  conAffilInfo =  ContactAffiliation_Ctrl.getConAffilAddEditInformation(conAffilList[0].Id,'Student','Account',accList[0].Id);
            System.assertEquals(conAffilList[0].Id,conAffilInfo.cARecord.Id);
        }
    }
    
    // This test method to get Editing information for Contact Affilation Record in contract page.
    private static testMethod void testMethod9() {
        List<Contract> contractList  = [SELECT Id FROM Contract LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<Contact_Affiliation__c> conAffilList = new List<Contact_Affiliation__c>();
        
        Id staffRTId = Schema.SObjectType.Contact_Affiliation__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();     
        
        if(conList.size() > 0 && contractList.size() > 0){
            
            Contact_Affiliation__c conAfil = new Contact_Affiliation__c();
            
            conAfil.Contact__c = conList[0].Id;
            conAfil.Start_Date__c = System.today();
            conAfil.End_Date__c = System.today()+30;
            conAfil.Contract__c = contractList[0].Id;
            conAfil.RecordTypeId = staffRTId;
            conAfil.Position__c = 'Staff';
            conAffilList.add(conAfil);
            
            insert conAffilList;
            
            ContactAffiliation_Ctrl.ContactAffilationDetail  conAffilInfo =  ContactAffiliation_Ctrl.getConAffilAddEditInformation(conAffilList[0].Id,'Staff','Contract',contractList[0].Id);
            System.assertEquals(conAffilList[0].Id,conAffilInfo.cARecord.Id);
        }
    }
    
    // This method to get creating Contact Affilation record information.
    private static testMethod void testMethod10() {
        List<Contract> contractList  = [SELECT Id FROM Contract LIMIT 1];
        List<Account> accList  = [SELECT Id FROM Account LIMIT 1];
        
        if(contractList.size() > 0){
            ContactAffiliation_Ctrl.getConAffilAddEditInformation('','Client_Partner','Contract',contractList[0].Id);
            
            ContactAffiliation_Ctrl.ContactAffilationDetail  conAffilInfo = ContactAffiliation_Ctrl.getConAffilAddEditInformation('','Staff','Contract',contractList[0].Id);
            Id recordTypeId = Schema.SObjectType.Contact_Affiliation__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
            System.assertEquals(recordTypeId,conAffilInfo.cARecord.RecordTypeId);
        }
        
        Test.startTest();
        if(accList.size() > 0){
            ContactAffiliation_Ctrl.getConAffilAddEditInformation('','Instructor','Account',accList[0].Id);
            
            ContactAffiliation_Ctrl.ContactAffilationDetail  conAffilInfo = ContactAffiliation_Ctrl.getConAffilAddEditInformation('','Student','Account',accList[0].Id);
            Id recordTypeId = Schema.SObjectType.Contact_Affiliation__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            System.assertEquals(recordTypeId,conAffilInfo.cARecord.RecordTypeId);
        }       
        Test.stopTest();
    }
}