@isTest
private class SuspendMoodleUser_Scheduler_Test{

    @testSetup static void setupMethod(){
        
        List<Contact> contacs = TestClassUtil.createTestContacts();
        List<System_Values__c> sysValuesList = TestClassUtil.createSystemValues();
    }
    
    private static testMethod void myTest(){
        
        List<Contact> contacts = [SELECT Id, Name, Moodle_User_Id__c, Moodle_User_Status__c FROM Contact WHERE RecordType.DeveloperName IN ('Candidate','Student') LIMIT 1];
        List<Contact> updateContacts = new List<Contact>();
        
        Integer i = 1;
        for(Contact c : contacts){
            c.Moodle_User_Id__c = 'Test Id - '+i;
            c.Moodle_User_Status__c = 'Active';
            i = i+1;
            updateContacts.add(c);
        }
        
        if(updateContacts.size() > 0){
            update updateContacts;
        }
        List<System_Values__c> sysValuesList = [SELECT Id, Name, Value__c FROM System_Values__c WHERE Name = 'Suspend Moodle User Batch Size'];
        
        Test.startTest();            
            String CRON_EXP = '0 0 1 * * ?';
            SuspendMoodleUser_Scheduler sch = new SuspendMoodleUser_Scheduler();
            system.schedule('Suspend Moodle User', CRON_EXP, sch);
        Test.stopTest();
    }
}