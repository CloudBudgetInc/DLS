@isTest
public class ContactInsStatusUpdateScheduler_Test {
    @testSetup static void setup(){
        List<Account> acclist =  TestClassUtil.createTestAccounts();
    }
    public static testmethod void mytest() {         
        
        List<System_Values__c> sysVal =  new List<System_Values__c>{
            new System_Values__c(Name ='Cont\'s Inst status Chang Notify User', Value__c = 'kmarden@dlsdc.com,amurphy@dlsdc.com')
        };
        insert sysVal;
        system.debug(':::::sysVal'+sysVal);       
       
        List<Account> getAccList = [Select Id,Name From Account Limit 2];
        Id RTId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Candidate'].Id; 

        List<Contact> contList = new List<Contact> {
            new Contact(LastName='Test Contact1',account=getAccList[0],Email='test1@test.com',MailingPostalCode = '60012',AccountId=getAccList[0].Id, Geo_Code_Status__c = 'Processed',Instructor_status__c = 'Available',RecordTypeId = RTId ),
            new Contact(LastName='Test Contact2',account=getAccList[0],Email='test2@test.com',MailingPostalCode = '60013',AccountId=getAccList[1].Id, Geo_Code_Status__c = 'Processed',Instructor_status__c = 'Available', RecordTypeId = RTId )
        };
        insert contList;
        
        contList[0].Last_Availability_Update__c = system.today().addYears(-5);
        update contList; 
               
        ContactInsStatusUpdateScheduler sch = new ContactInsStatusUpdateScheduler();
        sch.execute(null);
        
        //List<Contact> contacts = [SELECT Id,Name,Last_Availability_Update__c,Instructor_status__c FROM Contact WHERE Id =: contList[0].Id];
        //if(contacts != null && contacts.size() > 0)
            //System.assertEquals('InActive', contacts[0].Instructor_status__c); 
            // Batch will update the Status of the Instructor which is 3 years before and status not equal to "Inactive"
    }
        
}