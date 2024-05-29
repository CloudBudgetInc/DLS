@isTest
public class Cost_Rate_Trigger_Test {
    @testSetup static void setup(){
        
        List<Labor_Cost_Rate_Master__c> costrateMasterList = TestClassUtil.createTestCostRatesMaster();
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = TestClassUtil.createTestTimeCardDay();
        Test.startTest();
            List<Contact_Assignments__c> conAssList = TestClassUtil.createTestContactAssignment();
            List<AcctSeed__Cost_Rates__c> costrateList = TestClassUtil.createTestCostRates();    
        Test.stopTest();
    }
    // To Test the CR Name Population and some field values population from the Master Record.
    public static testMethod void myTestToUpdateCRName1() {
        
        List<Contact> conList = [Select Id, Alias__c From Contact Limit 5];
        List<AcctSeed__Cost_Rates__c> coratList = [Select Id,Cost_Rate_Name__c,Fully_Loaded_Rate__c, Exempt_Status__c,Rate_Type__c,Pay_Type__c,Contact__c,AcctSeed__Hourly_Cost__c,Status__c From AcctSeed__Cost_Rates__c WHERE Fully_Loaded_Rate__c != null LIMIT 10];
        List<APXTConga4__Conga_Template__c> conTemp = new List<APXTConga4__Conga_Template__c> {
                                                          new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Offer Letter - DLI-W New Contract - SCA'),
                                                          new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'APXTConga4 Name 2')
                                                      };

            insert conTemp; 
        
        
        // Cost Rate Name is Populated based on the Rate Type, Fully_Loaded_Rate__c and the Record Count (based on Rate type and Contact Alias Name)
        //System.assertEquals(coratList[0].Rate_Type__c+'-01-$'+coratList[0].Fully_Loaded_Rate__c, coratList[0].Cost_Rate_Name__c);  // since new Cost Rates have been inserted, this assert failed
        System.assertEquals(coratList[0].Rate_Type__c+'-01-$'+coratList[0].Fully_Loaded_Rate__c, coratList[0].Cost_Rate_Name__c); 
        
        // Field Exempt_Status__c,etc value are based on the Rate Type
        System.assertEquals('Non-Exempt', coratList[0].Exempt_Status__c); 
        
        // Cost Rate Name is null when the Rate Type is empty       
        // System.assertEquals(null, coratList[1].Cost_Rate_Name__c);       
       
        // Field Exempt_Status__c,etc value are based on the Rate Type
         //System.assertEquals(null, coratList[1].Exempt_Status__c); 
        
        // Cost Rate Name is Populated based on the Rate Type, Fully_Loaded_Rate__c and Record Count (based on Rate type and Contact Alias Name)
       // System.assertEquals(coratList[2].Rate_Type__c+'-01-$'+coratList[2].Fully_Loaded_Rate__c, coratList[2].Cost_Rate_Name__c);       
        
        // Field Exempt_Status__c,etc value are based on the Rate Type
        System.assertEquals('Exempt', coratList[2].Exempt_Status__c);
        
        
            // Updated Labor Cost Rate Rate Type from null to 'DLI-21 SCA CD' 
            coratList[1].Rate_Type__c = 'DLI-21 SCA CD';
            coratList[1].Contact__c = null; 
            coratList[1].Non_Billable_Payroll_Item__c = 'BLE';

            // Contact is updated to empty
            coratList[0].Rate_Type__c = 'DLI-21 SCA CD';
            coratList[0].Contact__c = null; 
            coratList[0].Non_Billable_Payroll_Item__c = 'BLE';

            
            Test.StartTest();
            update coratList; 
        
 
            List<AcctSeed__Cost_Rates__c> coratListUpdate = [Select Id,Cost_Rate_Name__c, Rate_Type__c, Fully_Loaded_Rate__c , Exempt_Status__c From AcctSeed__Cost_Rates__c WHERE Fully_Loaded_Rate__c != null AND (Id = :coratList[0].Id OR Id = :coratList[1].Id)];       
            
            if(coratListUpdate.size() > 0){
                // Cost Rate Name is Populated based on the Rate Type and Record Count (based on Rate type and Contact Alias Name)
                System.assertEquals(coratListUpdate[0].Rate_Type__c+'-01-$'+coratListUpdate[0].Fully_Loaded_Rate__c, coratListUpdate[0].Cost_Rate_Name__c);       
                
                // Cost Rate Name is Populated based on the Rate Type and Record Count when the value is assigned for empty Rate Type
                System.assertEquals(coratListUpdate[1].Rate_Type__c+'-01-$'+coratListUpdate[1].Fully_Loaded_Rate__c, coratListUpdate[1].Cost_Rate_Name__c);
                
                // When the Rate Type is changed, field Exempt_Status__c,etc value are changed
                System.assertEquals('Non-Exempt', coratListUpdate[1].Exempt_Status__c);  
            }
            
           Test.StopTest();
    }
    
    public static testMethod void myTestToUpdateCRName1A() {
        
        List<Contact> conList = [Select Id, Alias__c From Contact Limit 5];
        List<AcctSeed__Cost_Rates__c> coratList = [Select Id,Cost_Rate_Name__c,Fully_Loaded_Rate__c, Exempt_Status__c,Rate_Type__c,Pay_Type__c,Contact__c,AcctSeed__Hourly_Cost__c,Status__c From AcctSeed__Cost_Rates__c LIMIT 10];
        List<APXTConga4__Conga_Template__c> conTemp = new List<APXTConga4__Conga_Template__c> {
                                                          new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Offer Letter - DLI-W New Contract - SCA'),
                                                          new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'APXTConga4 Name 2')
                                                      };
                                                        
        Test.StartTest();
        
        insert conTemp; 
                
        
        // Rate Type is updated to empty
        coratList[0].Rate_Type__c = null;      
        coratList[0].Contact__c = conList[3].Id;
        coratList[0].Non_Billable_Payroll_Item__c = 'BLE';
        update coratList;
        
        
        List<AcctSeed__Cost_Rates__c> coratListUpdateList = [Select Id,Cost_Rate_Name__c, Fully_Loaded_Rate__c , Exempt_Status__c From AcctSeed__Cost_Rates__c WHERE Id = :coratList[0].Id];
        
        // Cost Rate Name is null when the Rate Type is empty
        System.assertEquals(null, coratListUpdateList[0].Cost_Rate_Name__c);
        
        // When the Rate Type is changed, field Exempt_Status__c,etc value are changed
        System.assertEquals(null, coratListUpdateList[0].Exempt_Status__c);
        
        coratList[0].Status__c = 'Draft';
        update coratList[0];
        Test.StopTest();


    }
    
    // For Rate Type "Non-SCA LT" Field values check
    public static testMethod void myTestToUpdateCRName2() {
        test.startTest();
        List<Contact> conList = [Select Id, Alias__c From Contact Limit 5];
        List<AcctSeed__Cost_Rates__c> coratList = [Select Id,Cost_Rate_Name__c,Fully_Loaded_Rate__c, Exempt_Status__c,Rate_Type__c,Pay_Type__c,Contact__c,AcctSeed__Hourly_Cost__c,Status__c From AcctSeed__Cost_Rates__c LIMIT 10];

        // Rate Type of Labor Cost Rate is changed
        coratList[0].Contact__c = conList[2].Id;
        coratList[0].Rate_Type__c = 'LT with Prep';
        coratList[0].AcctSeed__Hourly_Cost__c = 70;
        update coratList;
        
        List<AcctSeed__Cost_Rates__c>  cos = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 20 ,Payroll_Item__c='R', H_W_Rate__c = 2, HOL_Rate__c = 3, VAC_Rate__c = 4, Contact__c = conList[2].Id)
        };
        insert cos;
        
        List<AcctSeed__Cost_Rates__c> costRate = [Select Id,Cost_Rate_Name__c, Fully_Loaded_Rate__c, Exempt_Status__c, Gen_Email_Doc_Conga_Workflow_Template__c From AcctSeed__Cost_Rates__c WHERE Id = :cos[0].Id];       
        // To check whether the Gen_email_Doc_conga_Workflow__c field value is populated
        System.assertNotEquals(null,costRate[0].Gen_Email_Doc_Conga_Workflow_Template__c);
        
        test.stopTest();
        
        List<AcctSeed__Cost_Rates__c> coratListUp = [Select Id,Cost_Rate_Name__c, Rate_Type__c, Fully_Loaded_Rate__c, Exempt_Status__c From AcctSeed__Cost_Rates__c WHERE Id = :coratList[0].Id];
        
        // Cost Rate Name is Populated based on the Rate Type, Fully_Loaded_Rate__c and the Record Count (based on Rate type and Contact Alias Name)
        //System.assertEquals(coratListUp[0].Rate_Type__c+'-01-$'+coratListUp[0].Fully_Loaded_Rate__c, coratListUp[0].Cost_Rate_Name__c); 
       
        // When the Rate Type is changed, field Exempt_Status__c,etc value are changed 
        System.assertEquals('Non-Exempt', coratListUp[0].Exempt_Status__c);
    }
    
    // For Rate Type "DLI-21 SCA CD" Field values check
    public static testMethod void myTestToUpdateCRName3() {
        List<Contact> conList = [Select Id, Alias__c From Contact Limit 5];
        List<AcctSeed__Cost_Rates__c> coratList = [Select Id,Cost_Rate_Name__c,Fully_Loaded_Rate__c, Exempt_Status__c,Rate_Type__c,Pay_Type__c,Contact__c,AcctSeed__Hourly_Cost__c,Status__c From AcctSeed__Cost_Rates__c];
        
        Test.StartTest();
        List<APXTConga4__Conga_Template__c> conTemp = new List<APXTConga4__Conga_Template__c> {
                                                          new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Offer Letter - DLI-W New Contract - SCA'),
                                                          new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'APXTConga4 Name 2')
                                                      };
        insert conTemp;
        
        // Updated Labor Cost Rate Rate Type from null to 'DLI-21 SCA CD' 
        coratList[1].Rate_Type__c = 'DLI-21 SCA CD';
        coratList[1].Contact__c = null; 
        coratList[1].Non_Billable_Payroll_Item__c = 'BLE';
        // Contact is updated to empty
        coratList[0].Rate_Type__c = 'DLI-21 SCA CD';
        coratList[0].Contact__c = null; 
        coratList[0].Non_Billable_Payroll_Item__c = 'BLE';
        update coratList;  
        
        List<AcctSeed__Cost_Rates__c>  cos = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA CD',AcctSeed__Hourly_Cost__c = 40 ,Payroll_Item__c='R', H_W_Rate__c = 2, HOL_Rate__c = 3, VAC_Rate__c = 4)
        };
        insert cos;
        
        List<AcctSeed__Cost_Rates__c> costRate = [Select Id,Cost_Rate_Name__c, Fully_Loaded_Rate__c, Exempt_Status__c, Gen_Email_Doc_Conga_Workflow_Template__c From AcctSeed__Cost_Rates__c WHERE Id = :cos[0].Id AND Fully_Loaded_Rate__c != null];       
        // To check whether the Gen_email_Doc_conga_Workflow__c field value is populated
        System.assertNotEquals(null,costRate[0].Gen_Email_Doc_Conga_Workflow_Template__c);
                        
        List<AcctSeed__Cost_Rates__c> coratListUpdate = [Select Id,Cost_Rate_Name__c, Rate_Type__c, Fully_Loaded_Rate__c , Exempt_Status__c From AcctSeed__Cost_Rates__c WHERE Fully_Loaded_Rate__c != null AND (Id = :coratList[0].Id OR Id = :coratList[1].Id)];       
        
        Test.StopTest(); 
        if(coratListUpdate.size() > 0){
            // Cost Rate Name is Populated based on the Rate Type and Record Count (based on Rate type and Contact Alias Name)
            System.assertEquals(coratListUpdate[0].Rate_Type__c+'-01-$'+coratListUpdate[0].Fully_Loaded_Rate__c, coratListUpdate[0].Cost_Rate_Name__c);       
            
            // Cost Rate Name is Populated based on the Rate Type and Record Count when the value is assigned for empty Rate Type
            System.assertEquals(coratListUpdate[1].Rate_Type__c+'-01-$'+coratListUpdate[1].Fully_Loaded_Rate__c, coratListUpdate[0].Cost_Rate_Name__c);
            
            // When the Rate Type is changed, field Exempt_Status__c,etc value are changed
            System.assertEquals('Non-Exempt', coratListUpdate[1].Exempt_Status__c);  
        }
    }
    
    public static testMethod void myTestToUpdateCRName4() {
        List<Contact> conList = [Select Id, Alias__c From Contact Limit 5];
        List<AcctSeed__Cost_Rates__c> coratList = [Select Id,Cost_Rate_Name__c,Fully_Loaded_Rate__c, Exempt_Status__c,Rate_Type__c,Pay_Type__c,Contact__c,AcctSeed__Hourly_Cost__c,Status__c From AcctSeed__Cost_Rates__c];
        
        Test.StartTest();
        
        // Rate Type is updated to empty
        coratList[0].Rate_Type__c = null;      
        coratList[0].Contact__c = conList[3].Id;
        coratList[0].Non_Billable_Payroll_Item__c = 'BLE';
        update coratList;
        

        List<AcctSeed__Cost_Rates__c> coratListUpdateList = [Select Id,Cost_Rate_Name__c, Fully_Loaded_Rate__c , Exempt_Status__c From AcctSeed__Cost_Rates__c WHERE Id = :coratList[0].Id];
        
        // Cost Rate Name is null when the Rate Type is empty
        System.assertEquals(null, coratListUpdateList[0].Cost_Rate_Name__c);
        
        // When the Rate Type is changed, field Exempt_Status__c,etc value are changed
        System.assertEquals(null, coratListUpdateList[0].Exempt_Status__c);
        //When creating Cost Rate rec without status, status is updated as "Draft"
        List<AcctSeed__Cost_Rates__c>  cos = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA MTT',AcctSeed__Hourly_Cost__c = 40 ,Payroll_Item__c='R', H_W_Rate__c = 2, HOL_Rate__c = 3, VAC_Rate__c = 4)
        };
        insert cos;
        AcctSeed__Cost_Rates__c cosrate = [Select Id, Status__c From AcctSeed__Cost_Rates__c WHERE Id = :cos[0].Id];
        System.assertEquals(cosrate.Status__c,'Draft');
        Test.StopTest();
        
    }
    
    public static testmethod void myTestToApproveCR() {
        AcctSeed__Cost_Rates__c coratStatusList = [Select Id, Status__c From AcctSeed__Cost_Rates__c WHERE Status__c = 'Draft' LIMIT 1];
        
        if(coratStatusList != Null) {
            
            Contact_Assignments__c conAss = [SELECT Id, Name, Candidate_Name__c, Rate_Card_Rate__c, Drafted_Labor_Cost_Rate__c FROM Contact_Assignments__c WHERE Candidate_Name__c != Null LIMIT 1];
            if(conAss != Null) {
                Test.startTest();
                    conAss.Drafted_Labor_Cost_Rate__c = coratStatusList.Id;
                    update conAss;
                
                    coratStatusList.Status__c = 'Approved';
                    coratStatusList.Contact__c = conAss.Candidate_Name__c;
                    update coratStatusList; 
                
                
                Contact_Assignments__c conAssUp = [SELECT Id, Name, Rate_Card_Rate__c, Drafted_Labor_Cost_Rate__c FROM Contact_Assignments__c WHERE Id = :conAss.Id LIMIT 1];
                
                /* When the Labour cost Rate Status is Updated to Approved and it is linked with Contact Assignment Drafted_Labor_Cost_Rate__c field             
                   then the  Drafted_Labor_Cost_Rate__c of contact Assignment is Updated to Null */
                System.assertEquals(null,conAssUp.Drafted_Labor_Cost_Rate__c);
                
                /* When the Labour cost Rate Status is Updated to Approved and it is linked with Contact Assignment Drafted_Labor_Cost_Rate__c field             
                   then the Rate_Card_Rate__c of contact Assignment is Updated with Drafted_Labor_Cost_Rate__c value */
                System.assertEquals(conAss.Drafted_Labor_Cost_Rate__c,conAssUp.Rate_Card_Rate__c);
                Test.stopTest();
            }      
        } 
    } 
    
    // To update the cost rate status to approved
    public static testMethod void myTestToUpdateStatus() {
        
        List<AcctSeed__Cost_Rates__c> coratStatusList = [Select Id, Status__c, Rate_Type__c, Contact__c, Contact__r.Id From AcctSeed__Cost_Rates__c WHERE Status__c = 'Draft' LIMIT 1];
        
        if(coratStatusList.size() > 0) {
            
            CostRateCreation_Ctrl.isFromCR = true;
             
            Test.startTest();
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = coratStatusList[0].Contact__c, Pay_Type__c = 'Hourly', Rate_Type__c = 'Non-SCA Testing',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
            insert costrateList;
            Test.stopTest();
            
            List<AcctSeed__Cost_Rates__c> costRateReturn = [SELECT Id, Name, Status__c FROM AcctSeed__Cost_Rates__c WHERE Id = :costrateList[0].Id];
            if(costRateReturn.size() > 0) 
                System.assertEquals('Submitted for Approval', costRateReturn[0].Status__c);
        }
    }
    
    // Send mail for approval
    public static testMethod void myTestSendApporovalMail() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        List<Contact> conList = new List<Contact> {
            new Contact(LastName = 'Test Contact 1', AccountId = accList[0].Id)
        };
        
        Test.startTest();
        
        insert conList;
        
        CostRateCreation_Ctrl.isFromCR = TRUE;
        
        if(accList.size() > 0) {
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA CD',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
            
                insert costrateList;
            Test.stopTest();
        }
        
    }
        
    /********
        Added By HL 
        Only HR & Payroll users should have access to Labor Cost Rate records related to DLS Staff record type Contact records
    ********/
    public static testMethod void staffRTContactsLCRTestMethod(){
    
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        Id staffRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('DLS Staff').getRecordTypeId();
        List<Contact> staffContacts = [SELECT Id FROM Contact WHERE RecordTypeId = :staffRTId];
        
        if(accList.size() > 0) {
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
             Test.startTest(); 

            insert costrateList;
            
            costrateList[0].Exempt_Status__c = 'Exempt';
            costrateList[1].Exempt_Status__c = 'Exempt';
            try{
                update costrateList;
            }catch(Exception e){
                System.Assert(e.getMessage().contains('Only HR, Payroll and System Admin users should have access to Labor Cost Rate records related to DLS Staff record type Contact records'));            
            }
            Test.stopTest();
        }
    }
    
    public static testMethod void candidateRTContactsLCRTestMethod(){
    
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        List<Contact> candidateContacts = [SELECT Id FROM Contact WHERE RecordTypeId = :candidateRTId];
        
        if(accList.size() > 0) {
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = candidateContacts[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = candidateContacts[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
                
            Test.startTest(); 
            
            insert costrateList;
            
            costrateList[0].Exempt_Status__c = 'Exempt';
            costrateList[1].Exempt_Status__c = 'Exempt';
             
            update costrateList;
            System.assertEquals('Exempt', costrateList[0].Exempt_Status__c);
            Test.stopTest();
        }
    }
    
    public static testMethod void staffAndCandidateRTContactsLCRTestMethod(){
    
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        Id staffRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('DLS Staff').getRecordTypeId();
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
        List<Contact> contacts = [SELECT Id FROM Contact WHERE RecordTypeId = :staffRTId OR RecordTypeId = :candidateRTId];
        
        if(accList.size() > 0) {
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = contacts[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                new AcctSeed__Cost_Rates__c(Contact__c = contacts[1].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
            };
                Test.startTest(); 

            insert costrateList;
            
            costrateList[0].Exempt_Status__c = 'Exempt';
            costrateList[1].Exempt_Status__c = 'Exempt';
                try{
                update costrateList;
            }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Only HR, Payroll and System Admin users should have access to Labor Cost Rate records related to DLS Staff record type Contact records') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest();
        }
    }
    
    public static testMethod void hRUserToEditLCRTestMethod(){
    
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        Id staffRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('DLS Staff').getRecordTypeId();
        List<Contact> staffContacts = [SELECT Id FROM Contact WHERE RecordTypeId = :staffRTId];
        
        Test.startTest(); 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='HR'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName='hrTest@testorg.com'
        );
        insert u;
        
        
        //To prevent INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY 
        List<Group>  groups = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName = 'Staff_CR_Read_Write_Group']; 
        System.debug('groups========='+groups);
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = u.Id;
        grpMem1.GroupId = groups[0].Id;
        Insert grpMem1;
        
        System.runAs(u) {
            
            if(accList.size() > 0) {
                List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                    new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                    new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
                };
                    
                insert costrateList;
                
                costrateList[0].Exempt_Status__c = 'Exempt';
                costrateList[1].Exempt_Status__c = 'Exempt';
                    try{
                        update costrateList;
                    }catch(Exception e){
                    
                    }
                Test.stopTest();
            }
        }
    }
    
    public static testMethod void ltsUserToEditLCRTestMethod(){
    
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        Id staffRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('DLS Staff').getRecordTypeId();
        List<Contact> staffContacts = [SELECT Id FROM Contact WHERE RecordTypeId = :staffRTId];
        
        Test.startTest(); 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='LTS'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName='hrTest@testorg.com'
        );
        insert u;
        
        //To prevent INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY 
        List<Group>  groups = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName = 'Staff_CR_Read_Write_Group']; 
        System.debug('groups========='+groups);
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = u.Id;
        grpMem1.GroupId = groups[0].Id;
        Insert grpMem1;
        
        System.runAs(u) {
                        
            if(accList.size() > 0) {
                List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                    new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
                    new AcctSeed__Cost_Rates__c(Contact__c = staffContacts[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
                };
                                    
                insert costrateList;
                
                costrateList[0].Exempt_Status__c = 'Exempt';
                costrateList[1].Exempt_Status__c = 'Exempt';
                
                try{
                    update costrateList;
                }catch(Exception e){
                    System.assert(e.getMessage().contains('Only HR, Payroll and System Admin users should have access to Labor Cost Rate records related to DLS Staff record type Contact records'), e.getMessage());
                }
                Test.stopTest();
            }
        }
    }
    
    public static testMethod void myTestSendApporovalMailForPriorCR() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        List<Contact> conList = [SELECT Id, RecordTypeId FROM Contact LIMIT 1];
        
        Test.startTest(); 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='LTS'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName='ltsTest@testorg.com'
        );
        insert u; 
        
        CostRateCreation_Ctrl.isFromCR = TRUE;
        
        if(accList.size() > 0) {
        
            
            
            System.runAs(u) {
                List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                    new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Approved', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R')
                };
                                List<AcctSeed__Cost_Rates__c>  costrateList1 = new List<AcctSeed__Cost_Rates__c>{
                    new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Prior_Version__c = costrateList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Draft', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R')
                };
                
                 insert costrateList;
                //insert costrateList1;
                Test.stopTest();
            }
        }
        
    }
    
    public static testMethod void myTestSendApporovalMailForPriorCR1() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        List<Contact> conList = [SELECT Id, RecordTypeId FROM Contact LIMIT 1];
        System.debug('conList======='+conList+'conList SIZE========'+conList.size());
        
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='LTS'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName='ltsTest@testorg.com'
        );
                
        insert u; 
        
        CostRateCreation_Ctrl.isFromCR = TRUE;
        
        if(accList.size() > 0) {
            System.runAs(u) {
                List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                    new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Approved', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R')
                };
                
                    insert costrateList;
                
                    List<AcctSeed__Cost_Rates__c>  costrateList1 = new List<AcctSeed__Cost_Rates__c>{
                        new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Prior_Version__c = costrateList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Draft', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R')
                     };
                    insert costrateList1;
                Test.stopTest();
            }
        }
        
    }
    
    public static testMethod void myTestSendApporovalMailForPriorCR2() {
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        List<Contact> conList = [SELECT Id, RecordTypeId FROM Contact LIMIT 1];
        System.debug('conList======='+conList+'conList SIZE========'+conList.size());
        
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='LTS'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName='ltsTest@testorg.com'
        );
        insert u; 
        
        
        
        CostRateCreation_Ctrl.isFromCR = TRUE;
        
        if(accList.size() > 0) {
            System.runAs(u) {
                List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                    new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Approved', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R')
                };
                
                    insert costrateList;
                
                    List<AcctSeed__Cost_Rates__c>  costrateList1 = new List<AcctSeed__Cost_Rates__c>{
                        new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Prior_Version__c = costrateList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Draft', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 20,Payroll_Item__c='R')
                    };
                    insert costrateList1;
                Test.stopTest();
            }
        }
        
    }
    
    public static testMethod void priorCostRateTestMethod(){
    
        List<Contact> conList = [Select Id, Alias__c From Contact Limit 5];
        List<AcctSeed__Cost_Rates__c> coratList = [Select Id, Exempt_Status__c,Rate_Type__c,Pay_Type__c,Contact__c,Status__c From AcctSeed__Cost_Rates__c];
        
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Prior_Version__c = coratList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Prior_Version__c = coratList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
        };
          Test.startTest();

        insert costrateList;
        System.debug('costrateList777'+costrateList[0].Status__c );
            costrateList[0].Status__c = 'Approved';
            update costrateList[0];
            List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Status__c FROM AcctSeed__Cost_Rates__c WHERE Id IN :coratList];
            System.assertEquals('Inactive', costRates[0].Status__c);
        Test.stopTest();
    }
    public static testMethod void priorCostRateTestMethod1(){
    
        List<Contact> conList = [Select Id, Alias__c From Contact Limit 5];
        //List<AcctSeed__Cost_Rates__c> coratList = [Select Id, Exempt_Status__c,Rate_Type__c,Pay_Type__c,Contact__c,Status__c From AcctSeed__Cost_Rates__c];
        
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20),
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43,Payroll_Item__c='R',Per_Test_Cost__c = 20)
        };
         
        Test.startTest();
        
        insert costrateList;
        
        
        System.debug('costrateList777'+costrateList[0].Status__c );
            costrateList[0].Rate_Type__c = 'FT Salary & Benefits';
            costrateList[0].Annual_Salary_Cost__c = 90;
            costrateList[0].Salary_Cost_Per_Hour__c= 90;
            costrateList[0].Non_Billable_Payroll_Item__c = 'BLE';

            update costrateList[0];
            List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Status__c FROM AcctSeed__Cost_Rates__c WHERE Id IN :costrateList];
        Test.stopTest();
    }
    
    // To cover preventLCREdit method 
    public static testMethod void preventLCREditTest1(){
    
        List<AcctSeed__Cost_Rates__c> coratList = [SELECT Id, Annual_Salary_Cost__c, Fixed_Cost__c, H_W_Rate__c, HOL_Rate__c , Per_FFP_Cost__c , Per_Test_Cost__c , Per_Word_Cost__c , Salary_Cost_Per_Hour__c , Semi_Monthly_Salary_Cost__c , VAC_Rate__c , Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' LIMIT 1];
        System.debug('conList==='+conList);
        
        Test.startTest();
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c>();
        
        
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training' LIMIT 1];
        System.debug('task ====='+task);
        
        //Labor_Cost_Rate__c = coratList[0].Id, 
        timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
            new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c = timeCard[0].Id,AcctSeed__Project_Task__c = task[0].Id, AcctSeed__Project__c = task[0].AcctSeed__Project__c)    
        };
        
        insert timeCardLine;
        System.debug('timeCardLine====='+timeCardLine[0].AcctSeed__Project__r.RecordType.DeveloperName);
        
        //Labor_Cost_Rate__c = coratList[0].Id,  
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c= 'Draft');
        insert day;
        System.debug('day========='+day);
        
            try{
                coratList[0].Annual_Salary_Cost__c = 90;
                update coratList[0];
            }catch(Exception e){
                System.Assert(e.getMessage().contains('Currency and Rate Type of Labor Cost Rate records cannot be modified by any user'));
            }
        Test.stopTest();
    }
    
    // To cover preventLCREdit method 
    public static testMethod void preventLCREditTest2(){
    
        List<AcctSeed__Cost_Rates__c> coratList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Fixed_Cost__c, H_W_Rate__c, HOL_Rate__c , Per_FFP_Cost__c , Per_Test_Cost__c , Per_Word_Cost__c , Salary_Cost_Per_Hour__c , Semi_Monthly_Salary_Cost__c , VAC_Rate__c , Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' LIMIT 1];
        System.debug('conList==='+conList);
                
        Test.startTest();
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c>();
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training' LIMIT 1];
        System.debug('task ====='+task);
                
        timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
            new AcctSeed__Time_Card_Line__c(Labor_Cost_Rate__c = coratList[0].Id, AcctSeed__Time_Card__c = timeCard[0].Id,AcctSeed__Project_Task__c = task[0].Id, AcctSeed__Project__c = task[0].AcctSeed__Project__c)    
        };

        insert timeCardLine;
        System.debug('timeCardLine====='+timeCardLine[0].AcctSeed__Project__r.RecordType.DeveloperName);
            
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c= 'Draft');
        insert day;
        System.debug('day========='+day);
        
        
            try{
                coratList[0].Annual_Salary_Cost__c = 90;
                coratList[0].VAC_Rate__c = 20;
                coratList[0].Rate_Type__c = 'DLI-21 SCA CD';
                update coratList[0];
            }catch(Exception e){
                System.Assert(e.getMessage().contains('Currency and Rate Type of Labor Cost Rate records cannot be modified by any user'));
            }
        Test.stopTest();
    }
    
    public static testMethod void preventLCREditTest3(){
    
        List<AcctSeed__Cost_Rates__c> coratList = [SELECT Id, AcctSeed__Hourly_Cost__c, Annual_Salary_Cost__c, Fixed_Cost__c, H_W_Rate__c, HOL_Rate__c , Per_FFP_Cost__c , Per_Test_Cost__c , Per_Word_Cost__c , Salary_Cost_Per_Hour__c , Semi_Monthly_Salary_Cost__c , VAC_Rate__c , Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' LIMIT 1];
        System.debug('conList==='+conList);
                
        Test.startTest();
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
                
        List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c>();
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training' LIMIT 1];
        System.debug('task ====='+task);
                
        timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
            new AcctSeed__Time_Card_Line__c(Labor_Cost_Rate__c = coratList[0].Id, AcctSeed__Time_Card__c = timeCard[0].Id,AcctSeed__Project_Task__c = task[0].Id, AcctSeed__Project__c = task[0].AcctSeed__Project__c)    
        };

        insert timeCardLine;
        System.debug('timeCardLine====='+timeCardLine[0].AcctSeed__Project__r.RecordType.DeveloperName);
            
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c= 'Draft');
        insert day;
        System.debug('day========='+day);
        
        
            try{
                coratList[0].VAC_Rate__c = 20;
                coratList[0].Rate_Type__c = 'DLI-21 SCA CD';
                update coratList[0];
            }catch(Exception e){
                System.Assert(e.getMessage().contains('Currency and Rate Type of Labor Cost Rate records cannot be modified by any user'));
            }
        Test.stopTest();
    }
    
    // To cover preventLCREdit method 
    public static testMethod void preventLCREditTest4(){
    
        List<AcctSeed__Cost_Rates__c> coratList = [SELECT Id, Annual_Salary_Cost__c, Fixed_Cost__c, H_W_Rate__c, HOL_Rate__c , Per_FFP_Cost__c , Per_Test_Cost__c , Per_Word_Cost__c , Salary_Cost_Per_Hour__c , Semi_Monthly_Salary_Cost__c , VAC_Rate__c , Rate_Type__c , Status__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' LIMIT 1];
        System.debug('conList==='+conList);
        Test.startTest();
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
                
        List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c>();
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training' LIMIT 1];
        System.debug('task ====='+task);
                
        timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
            new AcctSeed__Time_Card_Line__c(Labor_Cost_Rate__c = coratList[0].Id, AcctSeed__Time_Card__c = timeCard[0].Id,AcctSeed__Project_Task__c = task[0].Id, AcctSeed__Project__c = task[0].AcctSeed__Project__c)    
        };

        insert timeCardLine;
        System.debug('timeCardLine====='+timeCardLine[0].AcctSeed__Project__r.RecordType.DeveloperName);
            
        //Labor_Cost_Rate__c = coratList[0].Id,
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c= 'Draft');
        insert day;
        System.debug('day========='+day);
        
        
            try{
                coratList[0].VAC_Rate__c = 20;
                coratList[0].Rate_Type__c = 'DLI-21 SCA CD';
                update coratList[0];
            }catch(Exception e){
                System.Assert(e.getMessage().contains('Currency and Rate Type of Labor Cost Rate records cannot be modified by any user'));
            }
        Test.stopTest();
    }
    
    // To cover updateMeritIncreaseCRMaster
    public static testMethod void updateCRMasterTest1(){
    
        List<Labor_Cost_Rate_Master__c> crMaster = [SELECT Id, Name, Rate_Type__c, YTD_Merit_Increases__c FROM Labor_Cost_Rate_Master__c WHERE Rate_Type__c = 'LT with Prep'];
        System.debug('crMaster==================='+crMaster);
        
        Pay_Rate_Modification_Handler.isFromCRModify = TRUE;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 20,Payroll_Item__c='R',Per_Test_Cost__c = 20),
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 30,Payroll_Item__c='R',Per_Test_Cost__c = 20)
        };
        Test.startTest();
        insert costrateList;
        
        List<AcctSeed__Cost_Rates__c>  priorCostRate = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Prior_Version__c = costrateList[1].Id, Pay_Type__c = 'Hourly', Status__c = 'Draft', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
        };
        insert priorCostRate;
        Test.stopTest();
    }
    
    // To cover updateMeritIncreaseCRMaster
    public static testMethod void updateCRMasterTest2(){
    
        List<Labor_Cost_Rate_Master__c> crMaster = [SELECT Id, Name, Rate_Type__c, YTD_Merit_Increases__c FROM Labor_Cost_Rate_Master__c WHERE Rate_Type__c = 'LT with Prep'];
        System.debug('crMaster==================='+crMaster);
        crMaster[0].YTD_Merit_Increases__c = 3;
        update crMaster[0];
        
        Date d1 = Date.today();
        Date effDate = Date.newInstance(d1.year(), 1, 1);
        System.debug('effDate ='+effDate);
                                                
        Pay_Rate_Modification_Handler.isFromCRModify = TRUE;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 20,Payroll_Item__c='R',Per_Test_Cost__c = 20),
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 30,Payroll_Item__c='R',Per_Test_Cost__c = 20)
        };
        Test.startTest();
        insert costrateList;
        
        List<AcctSeed__Cost_Rates__c>  priorCostRate = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Effective_Date__c = effDate, Prior_Version__c = costrateList[1].Id, Pay_Type__c = 'Hourly', Status__c = 'Draft', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R'),
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Effective_Date__c = d1, Prior_Version__c = costrateList[1].Id, Pay_Type__c = 'Hourly', Status__c = 'Draft', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
        };
        insert priorCostRate;
        Test.stopTest();
    }
    
    // To cover updateMeritIncreaseCRMaster
    public static testMethod void updateCRMasterTest3(){
    
        List<Labor_Cost_Rate_Master__c> crMaster = [SELECT Id, Name, Rate_Type__c, YTD_Merit_Increases__c FROM Labor_Cost_Rate_Master__c WHERE Rate_Type__c = 'LT with Prep'];
        System.debug('crMaster==================='+crMaster);
        crMaster[0].YTD_Merit_Increases__c = 3;
        update crMaster[0];
        
        Date d1 = Date.today();
        Date effDate = Date.newInstance(d1.year(), 1, 1);
        System.debug('effDate ='+effDate);
        
        // System.ListException: List index out of bounds: 0
        //List<User> user = [SELECT ID, name FROM USer WHERE Profile.Name = 'PayRoll' AND ISActive = TRUE];
        //System.debug('user =============='+user);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Payroll'];
        
        User user = new User(Alias = 'standt', email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.id,timezonesidkey='america/los_angeles',username='ltstest@testorg.com'
        );
        
        Test.startTest();
        
        insert user ;
                                                
        Pay_Rate_Modification_Handler.isFromCRModify = TRUE;
                
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 20,Payroll_Item__c='R',Per_Test_Cost__c = 20),
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 30,Payroll_Item__c='R',Per_Test_Cost__c = 20)
        };
        
        System.runAs(user){
            insert costrateList;
            
            List<AcctSeed__Cost_Rates__c>  priorCostRate = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Effective_Date__c = effDate, Prior_Version__c = costrateList[1].Id, Pay_Type__c = 'Hourly', Status__c = 'Draft', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R'),
                new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Effective_Date__c = d1, Prior_Version__c = costrateList[1].Id, Pay_Type__c = 'Hourly', Status__c = 'Draft', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
            };
            insert priorCostRate;            
        }
        Test.stopTest();
    }
    
    // To cover updateMeritIncreaseCRMaster
    public static testMethod void updateCRMasterTest4(){
    
        List<Labor_Cost_Rate_Master__c> crMaster = [SELECT Id, Name, Rate_Type__c, YTD_Merit_Increases__c FROM Labor_Cost_Rate_Master__c WHERE Rate_Type__c = 'LT without Prep'];
        System.debug('crMaster==================='+crMaster);
        crMaster[0].YTD_Merit_Increases__c = 3;
        update crMaster[0];
        
        Date d1 = Date.today();
        Date effDate = Date.newInstance(d1.year(), 1, 1);
        System.debug('effDate ='+effDate);
                                
        Pay_Rate_Modification_Handler.isFromCRModify = TRUE;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Draft', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT without Prep',AcctSeed__Hourly_Cost__c = 20)
        };
        Test.startTest();
            insert costrateList;
            
            List<AcctSeed__Cost_Rates__c>  priorCostRate = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Effective_Date__c = effDate, Prior_Version__c = costrateList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Draft', Rate_Type__c = 'LT without Prep',AcctSeed__Hourly_Cost__c = 80)
            };
            insert priorCostRate;
            
            List<AcctSeed__Cost_Rates__c> costRates1 = [SELECT Id, Name,Status__c FROM AcctSeed__Cost_Rates__c WHERE Id IN :priorCostRate];
            costRates1[0].Status__c = 'Approved';
            update costRates1[0];
            
        Test.stopTest();
    }
      // To cover PayRateModificationProcess
    public static testMethod void TestMethodPayRateModification1(){
                                
        Pay_Rate_Modification_Handler.isFromCRModify = TRUE;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        List<Contact_Assignments__c> conAssList = [SELECT Id FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
        System.debug('conList==='+conList);
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Approved', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 20,Payroll_Item__c='R',Per_Test_Cost__c = 20)
        };
               
        Test.startTest();
        insert costrateList;  
        
        conAssList[0].Rate_Card_Rate__c = costrateList[0].Id;
        conAssList[0].Candidate_name__c = conList[0].Id;
        conAssList[0].Start_Date__c = system.today().addDays(2);
        update conAssList;
        
        List<AcctSeed__Cost_Rates__c>  priorCostRate = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Effective_Date__c = system.today().addDays(1), Prior_Version__c = costrateList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Draft', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
         };
        insert priorCostRate;
        
        List<Contact_Assignments__c> newConAssList = [SELECT Id FROM Contact_Assignments__c WHERE (Rate_Card_Rate__c = :priorCostRate[0].Id OR Drafted_Labor_Cost_Rate__c = :priorCostRate[0].Id)];
        System.assertEquals(1,newConAssList.size());
        Test.stopTest();
    }
      // To cover PayRateModificationProcess
    public static testMethod void TestMethodPayRateModification2(){
                                
        Pay_Rate_Modification_Handler.isFromCRModify = TRUE;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        List<Contact_Assignments__c> conAssList = [SELECT Id FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
        System.debug('conList==='+conList);
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Approved', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 20,Payroll_Item__c='R',Per_Test_Cost__c = 20)
        };
               
        Test.startTest();
        insert costrateList;  
        
        conAssList[0].Rate_Card_Rate__c = costrateList[0].Id;
        conAssList[0].Candidate_name__c = conList[0].Id;
        update conAssList;
            
        List<AcctSeed__Cost_Rates__c>  priorCostRate = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Effective_Date__c = system.today().addDays(2), Prior_Version__c = costrateList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Draft', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
        };
        insert priorCostRate;
            
        List<Contact_Assignments__c> newConAssList = [SELECT Id FROM Contact_Assignments__c WHERE (Rate_Card_Rate__c = :priorCostRate[0].Id OR Drafted_Labor_Cost_Rate__c = :priorCostRate[0].Id)];
        System.assertEquals(1,newConAssList.size());
        Test.stopTest();
    }
      // To cover PayRateModificationProcess
    public static testMethod void TestMethodPayRateModification2A(){
                                
        Pay_Rate_Modification_Handler.isFromCRModify = TRUE;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee'];
        List<Contact_Assignments__c> conAssList = [SELECT Id FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
        System.debug('conList==='+conList);
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Approved', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 20,Payroll_Item__c='R',Per_Test_Cost__c = 20)
        };
               
        Test.startTest();
        insert costrateList;  
        
        conAssList[0].Rate_Card_Rate__c = costrateList[0].Id;
        conAssList[0].Candidate_name__c = conList[0].Id;
        update conAssList;
            
        List<AcctSeed__Cost_Rates__c>  priorCostRate = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id,Annual_Salary_Cost__c = 20 ,New_Department_Name__c = 'OF0QAT',Salary_Cost_Per_Hour__c=20,Effective_Date__c = system.today().addDays(-1), Prior_Version__c = costrateList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Draft', Rate_Type__c = 'FT Salary & Benefits',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
        };
        insert priorCostRate;
            
        List<Contact_Assignments__c> newConAssList = [SELECT Id FROM Contact_Assignments__c WHERE (Rate_Card_Rate__c = :priorCostRate[0].Id OR Drafted_Labor_Cost_Rate__c = :priorCostRate[0].Id)];
        System.assertEquals(1,newConAssList.size());
        Test.stopTest();
    }
    

    
      // To cover PayRateModificationProcess
    public static testMethod void TestMethodPayRateModification3(){
                                
        Pay_Rate_Modification_Handler.isFromCRModify = TRUE;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        List<Contact_Assignments__c> conAssList = [SELECT Id FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' LIMIT 1];
        System.debug('conList==='+conList);
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Status__c = 'Approved', Contact__c = conList[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 20,Payroll_Item__c='R',Per_Test_Cost__c = 20)
        };
               
        Test.startTest();
        insert costrateList;  
        
        conAssList[0].Rate_Card_Rate__c = costrateList[0].Id;
        conAssList[0].Candidate_name__c = conList[0].Id;
        update conAssList;
            
        List<AcctSeed__Cost_Rates__c>  priorCostRate = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = conList[0].Id, Effective_Date__c = system.today().addDays(-2), Prior_Version__c = costrateList[0].Id, Pay_Type__c = 'Hourly', Status__c = 'Submitted for Approval', Rate_Type__c = 'LT with Prep',AcctSeed__Hourly_Cost__c = 80,Payroll_Item__c='R')
         };
         insert priorCostRate;
            
        List<Contact_Assignments__c> newConAssList = [SELECT Id FROM Contact_Assignments__c WHERE (Rate_Card_Rate__c = :priorCostRate[0].Id OR Drafted_Labor_Cost_Rate__c = :priorCostRate[0].Id)];
        System.assertEquals(1,newConAssList.size());
        Test.stopTest();
    } 
    // To cover getProjClassiMap
    public static testMethod void TestMethodProjClassiMap(){
        Cost_Rate_Trigger_Handler.getProjClassiMap();
    }
}