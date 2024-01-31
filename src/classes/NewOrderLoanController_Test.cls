@isTest
public class NewOrderLoanController_Test {
    
    @testsetup static void setup() {
        Test.startTest();
        List<Contact_Assignments__c> cAList = TestClassUtil.createTestContactAssignment();
        List<Materials__c> matList = TestClassUtil.createTestmaterials();
        List<AcctSeed__Project_Task__c> pjtTaskReqList = TestClassUtil.createTestProjectTask();
        Test.stopTest();
        List<MTT_Location__c> locations = TestClassUtil.createTestLocations();
    }
    
    
    // getting project record based on contactId
    private static testMethod void testMethod1(){
        List<Contact> conLst = [Select Id From Contact LIMIT 1];
        List<AcctSeed__Project__c> pjtLst = NewOrderLoanController.contactRelatedProjects(conLst[0].Id);
        
        NewOrderLoanController.getLookupRecords('Testing','Contact','Name','',new List<Id>());
        if(pjtLst.size() > 0){
            List<AcctSeed__Project__c> protList =  [SELECT Id From AcctSeed__Project__c Where Id =: pjtLst[0].Id];
            System.assertEquals(protList.size() > 0 ,true);
            List<Contact> students = NewOrderLoanController.getStudentCAInfo(protList[0].Id);            
        }
    }
    //creating Loan based Material Request Record
    private static testMethod void testMethod2(){
        List<Materials__c>  MaterialsList = [SELECT Id FROM Materials__c];
        //List<Contact> contactList = [SELECT Id,Name,AccountId,MailingCountry, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact LIMIT 1];
        Contact con = new Contact();
        con.LastName = 'My test con';
        con.MailingCountry =  'India';
        con.MailingStreet = 'MGR Street';
        con.MailingCity = 'Chennai';
        con.MailingState = 'TamilNadu';
        con.MailingPostalCode = '60041';
        insert con;
        
        Test.startTest();
        
            List<Materials_Request__c> materialReqList = new List<Materials_Request__c>();
            
            materialReqList = new List<Materials_Request__c> {
                new Materials_Request__c( Contact__c = con.Id, Materials_Name__c = MaterialsList[0].Id,Date_Ordered__c = system.today().addDays(3),Due_Date__c = system.today().addDays(20),Qty__c = 1,Date_Delivered__c = system.today().addDays(10),Request_Status__c = 'Loaned Out')
                };
            
            NewOrderLoanController.materialsRequestCreation('Loan', JSON.serialize(materialReqList), new List<String>{con.Id});
            List<Materials_Request__c> materialReqLst =  [SELECT Id FROM Materials_Request__c];
            System.assertEquals(materialReqLst.size() ,1);
        Test.stopTest();
    }
    //creating Order based Material Request Record
    private static testMethod void testMethod3(){
        List<Materials__c>  MaterialsList = [SELECT Id FROM Materials__c Materials__c];
        //List<Contact> contactList = [SELECT Id,Name,AccountId,MailingCountry, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact LIMIT 1];
        Contact con = new Contact();
        con.LastName = 'My test con';
        con.MailingCountry =  'India';
        con.MailingStreet = 'MGR Street';
        con.MailingCity = 'Chennai';
        con.MailingState = 'TamilNadu';
        con.MailingPostalCode = '60041';
        insert con;
        
        List<Account> accLst = [SELECT Id FROM Account LIMIT 1];
        List<Materials_Request__c> materialReqList = new List<Materials_Request__c>();
        
        Test.startTest();
        
            if(accLst.size() > 0){
                accLst[0].Name = 'Stock';
                update accLst;
            }
            materialReqList = new List<Materials_Request__c> {
                new Materials_Request__c(Contact__c = con.Id, Materials_Name__c = MaterialsList[0].Id,Date_Ordered__c = system.today().addDays(3),Due_Date__c = system.today().addDays(20),Qty__c = 1,Date_Delivered__c = system.today().addDays(10),Request_Status__c = 'Requested by LTS',Materials_Source__c = 'DLS Stock')
            };
                        
            NewOrderLoanController.materialsRequestCreation('Order', JSON.serialize(materialReqList), new List<String>{con.Id});
            List<Materials_Request__c> materialReqLst = [SELECT Id FROM Materials_Request__c];
            System.assertEquals(materialReqLst.size() ,1);
        Test.stopTest();
    }
    
    //creating Order based Material Request Record
    private static testMethod void testMethod3a(){
        List<Materials__c>  MaterialsList = [SELECT Id FROM Materials__c Materials__c];
        //List<Contact> contactList = [SELECT Id,Name,AccountId,MailingCountry, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact LIMIT 1];
        Contact con = new Contact();
        con.LastName = 'My test con';
        con.MailingCountry =  'India';
        con.MailingStreet = 'MGR Street';
        con.MailingCity = 'Chennai';
        con.MailingState = 'TamilNadu';
        con.MailingPostalCode = '60041';
        insert con;
        
        List<Account> accLst = [SELECT Id FROM Account LIMIT 1];
        List<Materials_Request__c> materialReqList = new List<Materials_Request__c>();
        
        Test.startTest();
        
            if(accLst.size() > 0){
                accLst[0].Name = 'Stock';
                update accLst;
            }
            
            List<MTT_Location__c> loc = [SELECT Id, Street__c, City_and_State__c, State__c, Zip_Code__c, Country__c FROM MTT_Location__c WHERE Name IN ('DLS - Rosslyn','DLS - Herndon','DLS - Elkridge')];
            loc[0].Street__c = 'Test Street';
            loc[0].City_and_State__c = 'Test city and State';
            loc[0].Zip_Code__c = 'Test zip';
            loc[0].Country__c = 'Test Country';
            update loc[0];
            
            materialReqList = new List<Materials_Request__c> {
                new Materials_Request__c(Location__c = loc[0].Id, Contact__c = con.Id, Materials_Name__c = MaterialsList[0].Id,Date_Ordered__c = system.today().addDays(3),Due_Date__c = system.today().addDays(20),Qty__c = 1,Date_Delivered__c = system.today().addDays(10),Request_Status__c = 'Requested by LTS',Materials_Source__c = 'DLS Stock')
            };
                        
            NewOrderLoanController.materialsRequestCreation('Order', JSON.serialize(materialReqList), new List<String>());
            List<Materials_Request__c> materialReqLst = [SELECT Id FROM Materials_Request__c];
            System.assertEquals(materialReqLst.size() ,1);
        Test.stopTest();
    }
    
    //creating Order based Material Request Record - try- catch
    private static testMethod void testMethod3b(){
        List<Materials__c>  MaterialsList = [SELECT Id FROM Materials__c Materials__c];
        //List<Contact> contactList = [SELECT Id,Name,AccountId,MailingCountry, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact LIMIT 1];
        Contact con = new Contact();
        con.LastName = 'My test con';
        con.MailingCountry =  'India';
        con.MailingStreet = 'MGR Street';
        con.MailingCity = 'Chennai';
        con.MailingState = 'TamilNadu';
        con.MailingPostalCode = '60041';
        insert con;
        
        List<Account> accLst = [SELECT Id FROM Account LIMIT 1];
        List<Materials_Request__c> materialReqList = new List<Materials_Request__c>();
        
        Test.startTest();
        
            if(accLst.size() > 0){
                accLst[0].Name = 'Stock';
                update accLst;
            }
            
            List<MTT_Location__c> loc = [SELECT Id, Street__c, City_and_State__c, State__c, Zip_Code__c, Country__c FROM MTT_Location__c WHERE Name IN ('DLS - Rosslyn','DLS - Herndon','DLS - Elkridge')];
            loc[0].Street__c = 'Test Street';
            loc[0].City_and_State__c = 'Test city and State';
            loc[0].Zip_Code__c = 'Test zip';
            loc[0].Country__c = 'Test Country';
            update loc[0];
            
            materialReqList = new List<Materials_Request__c> {
                new Materials_Request__c(Location__c = loc[0].Id, Contact__c = con.Id, Materials_Name__c = MaterialsList[0].Id,Date_Ordered__c = system.today().addDays(3),Due_Date__c = system.today().addDays(20),Qty__c = 1,Date_Delivered__c = system.today().addDays(10),Request_Status__c = 'Requested by LTS',Materials_Source__c = 'DLS Stock')
            };
            
            try{    
                NewOrderLoanController.materialsRequestCreation('Order', JSON.serialize(loc), new List<String>());
            }catch(Exception e){
                System.debug(':::::::'+e);
            }
        Test.stopTest();
    }
    
    // getting Project Record Based on ProjectId
    private static testMethod void testMethod4(){
        List<AcctSeed__Project__c> protList =  [SELECT Id From AcctSeed__Project__c LIMIT 1];
        
        if(protList.size() > 0){
            List<AcctSeed__Project__c> proLst = NewOrderLoanController.getProjectInfo(protList[0].Id);
            System.assertEquals(proLst.size(), 1);
        }
    }
    // getting Material Record Based on MaterialId
    private static testMethod void testMethod5(){
        List<Materials__c> matList = [SELECT Id FROM Materials__c LIMIT 1];
        
        if(matList.size() > 0){
            List<Materials__c> matLst = NewOrderLoanController.getMaterialInfo(matList[0].Id);
            System.assertEquals(matLst.size(), 1);
        }
    }
    // getting Project Record Based on ProjectId
    private static testMethod void testMethod6(){
        List<AcctSeed__Project__c> protList =  [SELECT Id From AcctSeed__Project__c LIMIT 1];
        String pTRecId = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Material_Budget').getRecordTypeId();
        List<AcctSeed__Project_Task__c>  projTaskLst = [SELECT Id ,RecordTypeId FROM AcctSeed__Project_Task__c];
        
        if(protList.size() > 0 && projTaskLst.size() > 0){
            projTaskLst[0].RecordTypeId = pTRecId;
            update projTaskLst;
            List<AcctSeed__Project_Task__c> proTaskLst = NewOrderLoanController.getTaskInfomation(protList[0].Id);
            System.assertEquals(proTaskLst.size(), 1);
        }
    }
}