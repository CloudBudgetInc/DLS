@isTest
private class Mobile_SupervisorTimeApproval_Ctrl_Test {
    
    @testsetup static void setup() {
        Test.startTest();
            TestClassUtil.createTestTimeCardDay();
        Test.stopTest();
        TestClassUtil.createTestContactAssignment(); 
    }
    
    // For getting the pending weeks details, Contact list based on the logged in user
    private static testMethod void testMethod1() {
                
        Test.startTest();
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 2];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :conAssList[0].Candidate_Name__c];
        List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id, Name, Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 3];
        List<RecordType> rType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Candidate'];
        
        if(conList.size() > 0 && conAssList.size() > 0 && tcdList.size() > 0 && rType.size() > 0) {
            
            objectInsert(conList, conAssList[0].Project__c);

            for(AcctSeed__Time_Card_Day__c tcd : tcdList) {
                tcd.Status__c = 'Submitted';
            }
            update tcdList;
            
            List<User> userList = [SELECT Id, Name FROM User WHERE IsActive = True LIMIT 1]; // WHERE Email = 'testing@gmail.com'
            
            if(userList.size() > 0) {
                System.runAs(userList[0]) {
                    String returnJson = Mobile_SupervisorTimeApproval_Ctrl.getWholeWeekInformation(userList[0].Id); 
                    if(returnJson != null && returnJson != '')
                        System.assert(returnJson.contains(userList[0].Id));
                }
            }
            
            conList[0].LastName = userInfo.getLastName();
            conList[0].RecordTypeId = rType[0].Id;
            conList[0].Supervisor_Name__c = userInfo.getUserId();
            update conList;
            
            Mobile_SupervisorTimeApproval_Ctrl.getWholeWeekInformation('--None--');
        }
        Test.stopTest();
    } 
    
    // For getting specific week start date & End Date based entries result display
    private static testMethod void testMethod2() {
                
        Test.startTest();     
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 2];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :conAssList[0].Candidate_Name__c];
        List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id, Name, Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 3];
        List<RecordType> rType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Candidate'];
        
        if(conList.size() > 0 && conAssList.size() > 0 && tcdList.size() > 0 && rType.size() > 0) {
            objectInsert(conList, conAssList[0].Project__c);
            
            for(AcctSeed__Time_Card_Day__c tcd : tcdList) {
                tcd.Status__c = 'Submitted';
            }
            update tcdList;

            List<User> userList = [SELECT Id, Name FROM User WHERE IsActive = True LIMIT 1];
           
            if(userList.size() > 0) {
                System.runAs(userList[0]) {
                    String returnJson = Mobile_SupervisorTimeApproval_Ctrl.getSpecificWeekDetails(userList[0].Id, 'Date', String.valueOf(System.today().addDays(-10)), String.valueOf(System.today().addDays(5))); 
                    if(returnJson != null && returnJson != '')
                       System.assert(returnJson.contains('weekDates')); 
                }
            }
            
            conList[0].LastName = userInfo.getLastName();
            conList[0].RecordTypeId = rType[0].Id;
            conList[0].Supervisor_Name__c = userInfo.getUserId();
            update conList;
            
            Mobile_SupervisorTimeApproval_Ctrl.getSpecificWeekDetails('--None--', '', String.valueOf(System.today().addDays(-5)), String.valueOf(System.today().addDays(5)));
        } 
        Test.stopTest();
    } 
    
    // For getting Delegated Approver information for approval
    private static testMethod void testMethod3() {
        
        Test.startTest();
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 2];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :conAssList[0].Candidate_Name__c];
        
        if(conList.size() > 0 && conAssList.size() > 0) {
            objectInsert(conList, conAssList[0].Project__c);
            String userListString = Mobile_SupervisorTimeApproval_Ctrl.getDelegatedApproverRelatedUsrs();
            //if(userListString != null && userListString != '')
                //System.assert(userListString.contains('Testing'));
        }
        Test.stopTest();
    } 
    
    // For updating TCD records status based on the supervisor approval
    private static testMethod void testMethod4() {
        
        Test.startTest();
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 2];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :conAssList[0].Candidate_Name__c];
        
        if(conList.size() > 0 && conAssList.size() > 0) {
            objectInsert(conList, conAssList[0].Project__c);
            List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id, Name FROM AcctSeed__Time_Card_Day__c LIMIT 2];
        
            if(tcdList.size() > 0) {
                String result = Mobile_SupervisorTimeApproval_Ctrl.updateTCDStatus(JSON.serialize(tcdList), 'ApproveAll', 'ApproveAll');
                System.assertEquals('SUCCESS', result);
            }
        }
        Test.stopTest();
    } 
    
    private static testMethod void testMethod5() {
        
        Test.startTest();
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 2];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :conAssList[0].Candidate_Name__c];
        
        if(conList.size() > 0 && conAssList.size() > 0) {
            objectInsert(conList, conAssList[0].Project__c);
            String returnJSON = Mobile_SupervisorTimeApproval_Ctrl.getSemiMontlyWeeks();
            
            System.assert(returnJSON.contains('currentWeek'));
        }
        Test.stopTest();
    } 
    
    // For Semi monthly summary information related method - used in mobile approval page semi monthly summary
    private static testMethod void testMethod6() {
        
        Test.startTest();
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 2];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :conAssList[0].Candidate_Name__c];
        
        if(conList.size() > 0 && conAssList.size() > 0) {
            objectInsert(conList, conAssList[0].Project__c);
            
            String stDate = string.valueOf(System.today().toStartOfMonth());
            String enDate = string.valueOf(System.today().addMonths(1).toStartOfMonth().addDays(-1));
            
            List<User> userList = [SELECT Id, Name FROM User WHERE Email = 'testing@gmail.com'];
           
            if(userList.size() > 0) {
                System.runAs(userList[0]) {
                    String returnJSON = Mobile_SupervisorTimeApproval_Ctrl.SemiMonthlyInformation(stDate, enDate);
                    if(returnJSON != null && returnJSON != '')
                        System.assert(returnJSON.contains(conList[0].Id));
                } 
            }
        }
        Test.stopTest();
    }
    
    // For Semi monthly summary information related method - used in mobile approval page semi monthly summary
    private static testMethod void testMethod6a() {
        
        Test.startTest();
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Project__c != null AND RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 2];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :conAssList[0].Candidate_Name__c];
        
        if(conList.size() > 0 && conAssList.size() > 0) {
            objectInsert(conList, conAssList[0].Project__c);
            
            String stDate = string.valueOf(System.today().toStartOfMonth());
            String enDate = string.valueOf(System.today().addMonths(1).toStartOfMonth().addDays(-1));

            conList[0].LastName = userInfo.getLastName();
            update conList;
            
            List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id, Name, Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];
                
            if(tcdList.size() > 0) {
                tcdList[0].Status__c = 'Unposted';
                tcdList[1].Status__c = 'Unposted';
                update tcdList;
                
                String returnJSON = Mobile_SupervisorTimeApproval_Ctrl.SemiMonthlyInformation(stDate, enDate);
                if(returnJSON != null && returnJSON != '')
                    System.assert(returnJSON.contains('weekRanges'));
            }
            
        }
        Test.stopTest();
    } 
    
    // Common Method to insert plannnedDaysOff record
    private static void objectInsert(List<Contact> conList, Id proId) {
        
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Contact', 'Planned_Days_Off__c') AND DeveloperName IN ('Candidate', 'Staff_Planned_Days_Off')];
        List<AcctSeed__Project__c> proList = [SELECT Id, Name FROM AcctSeed__Project__c WHERE Id = :proId];
        List<User> userList = [SELECT Id,Name,FirstName,LastName FROM User WHERE Email = 'testing@gmail.com'];
        
        if(conList.size() > 0 && rType.size() > 0) {
            
            String conRt, pdoRt;
            
            for(recordType rt : rType) {
                if(rt.DeveloperName == 'Candidate')
                    conRt = rt.Id;
                else if(rt.DeveloperName == 'Staff_Planned_Days_Off')
                    pdoRt = rt.Id;
            }
            
            List<Planned_Days_Off__c> pdoList = new List<Planned_Days_Off__c> {
                new Planned_Days_Off__c(Contact__c = conList[0].Id,Date__c=System.today(),Description__c='Test',Requested_Reschedule_Date__c=System.today().addDays(-1),RecordTypeId=pdoRt),
                new Planned_Days_Off__c(Contact__c = conList[0].Id,Date__c=System.today(),Description__c='Test',Requested_Reschedule_Date__c=System.today().addDays(-1),RecordTypeId=pdoRt)
            };
            insert pdoList;
        }
    }
}