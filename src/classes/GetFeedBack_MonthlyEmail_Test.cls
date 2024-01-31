@isTest
private class GetFeedBack_MonthlyEmail_Test {
        
    @testSetup static void setup() {
        List<Holiday> holiList = TestClassUtil.createTestHoliday();      
    }

    static testmethod void test1() {
        
        Test.startTest();
            
            List<RecordType> conAssRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact_Assignments__c' AND DeveloperName = 'Student'];
            List<RecordType> proRT = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'AcctSeed__Project__c'];
            List<Holiday> holiList = [SELECT Id, Name, ActivityDate FROM Holiday WHERE ActivityDate != :System.Today() LIMIT 2];
            List<Contact> con = new List<Contact> {
                                    new Contact(LastName = 'TestContact')
                                };
            insert con;
            
            List<AcctSeed__Project__c> pro = new List<AcctSeed__Project__c> {//RecordTypeId = proRT[0].Id,
                                                 new AcctSeed__Project__c(Name = 'Test Project 1',AcctSeed__Status__c = 'Active', Start_Date__c = System.today(), End_Date__c = System.today().addMonths(1))
                                             };
            insert pro;
            
            List<Contact_Assignments__c> conAss = new List<Contact_Assignments__c> {
                                                      new Contact_Assignments__c(Project__c=pro[0].Id,RecordTypeId = conAssRT[0].Id,Weekly_Getfeedback_sent__c = system.today().addDays(-30),Candidate_Name__c=con[0].Id,Start_Date__c=System.today(),End_Date__c=System.today()+30,Status__c = 'Active')
                                                  };
            insert conAss;
            
            Datetime dt = Datetime.now().addMinutes(1);
            String sch = dt.format('s m H d M \'?\' yyyy');
            String jobID = system.schedule('Test Schedule', sch, new GetFeedBack_MonthlyEmail());

        Test.stopTest();
    }  
    
    static testmethod void test2() {
        
        Test.startTest();
 
            List<RecordType> proRT = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'AcctSeed__Project__c'];
            List<Holiday> holiList = [SELECT Id, Name, ActivityDate FROM Holiday WHERE ActivityDate != :System.Today() LIMIT 2];
                       
            List<AcctSeed__Project__c> pro = new List<AcctSeed__Project__c> {//RecordTypeId = proRT[0].Id,
                                                 new AcctSeed__Project__c(Name = 'Test Project 1',AcctSeed__Status__c = 'Active', Start_Date__c = System.today(), End_Date__c = System.today().addDays(40))
                                             };
            insert pro;
            
           
            System_Values__c sv = new System_Values__c(name = 'Send FeedBack Monthly', Value__c = String.ValueOf(System.today().addDays(-40)));
            Insert sv;

            Datetime dt = Datetime.now().addMinutes(2);
            String sch = dt.format('s m H d M \'?\' yyyy');
            String jobID = system.schedule('Test Schedule 1', sch, new GetFeedBack_MonthlyEmail());
                        
         //   System.assertEquals(String.ValueOf(system.Today()), sv.Value__c); 
            
        Test.stopTest();
    } 
    
    static testmethod void test3() {
            
            List<RecordType> conAssRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Student' AND SobjectType = 'Contact_Assignments__c'];
            List<RecordType> proRT = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'AcctSeed__Project__c'];
            List<Holiday> holiList = [SELECT Id, Name, ActivityDate FROM Holiday WHERE ActivityDate != :System.Today() LIMIT 2];
            
            List<Contact> con = new List<Contact> {
                                    new Contact(LastName = 'TestContact')
                                };
            insert con;
            
            List<AcctSeed__Project__c> pro = new List<AcctSeed__Project__c> {//RecordTypeId = proRT[0].Id,
                                                 new AcctSeed__Project__c(Name = 'Test Project 1',AcctSeed__Status__c = 'Active',Start_Date__c = System.today(), End_Date__c = System.today().addDays(40))
                                             };
            insert pro;
            
            List<Contact_Assignments__c> conAss = new List<Contact_Assignments__c> {
                                                      new Contact_Assignments__c(Project__c = pro[0].Id,RecordTypeId = conAssRT[0].Id,Weekly_Getfeedback_sent__c = system.today().addDays(-30),Candidate_Name__c=con[0].Id,Start_Date__c=System.today(),End_Date__c=System.today()+30,Status__c = 'Active')
                                                  };
            insert conAss;

            System_Values__c sv = new System_Values__c(name = 'Send FeedBack Monthly', Value__c = String.ValueOf(System.today().addDays(1)));
            Insert sv;
            
            Datetime dt = Datetime.now().addMinutes(1);
            String sch = dt.format('s m H d M \'?\' yyyy');
            String jobID = system.schedule('Test Schedule', sch, new GetFeedBack_MonthlyEmail());  
            
            System_Values__c svList = [SELECT Id, Value__c FROM System_Values__c WHERE Id = :sv.Id];
         //   System.assertEquals(String.ValueOf(system.Today()), svList.Value__c);          
        
    }   
}