/*Developed by Siva Prasanth K.T on 06 sep 2019*/
@isTest
public class OnBoardingController_Test {
    
    @testsetup static void setup() {
    
       List<Events__c> eve = TestClassUtil.createTestEvent();
       Test.startTest();
           List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
       Test.stopTest();
    }
    
    // if login as Instructor Community User
    private static testMethod void testMethod1() {
    
        List<Contact> conLst = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1'];
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Instructor Community'];
        
        if(profileLst.size() > 0 && conLst.size() > 0){
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country='United States',IsActive =true,
                                 ContactId = conLst[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            List<Task> taskRecords;
            taskRecords = new List<Task> {
                new Task(Type = 'To Do' ,To_Do_Type__c = '10 - Watch Timekeeping Training Video',Status = 'In Progress',whoId = conLst[0].Id,subject = 'Watch Timekeeping Training Video'),
                new Task(Type = 'To Do' ,To_Do_Type__c = '20 - Review and complete your Profile',Status = 'In Progress',whoId = conLst[0].Id,subject = 'Review and complete your Profile')
            };
            insert taskRecords;
            
            system.runas(user){
                String taskJson = OnBoardingController.getToDoItems();
                List<Task> taskList = (List<Task>) JSON.deserialize(taskJson,List<Task>.class);
                
                if(taskList.size() > 0) {
                    System.AssertEquals(taskList[0].Status,'In Progress');
                    System.AssertEquals(taskList[0].whoId,conLst[0].Id);
                    
                    // to update status of task as 'Completed'
                    List<Task> taskLst = (List<Task>) JSON.deserialize(OnBoardingController.updateToDoItem(taskList[0].Id),List<Task>.class);
                    if(taskLst.size() > 0) {
                    System.AssertEquals(taskList.size()-1,taskLst.size());
                    }
                    
                    //cover catch try block code
                    try{
                        OnBoardingController.updateToDoItem('12346788');
                    }catch(Exception ex){
                        System.assertEquals(ex.getMessage(),'Script-thrown exception');
                    }
                }
            }
        }
    }
      // if login as Student Community User
    private static testMethod void testMethod2() {
    
        List<Contact> conLst = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1'];
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Student Community'];
        
        if(profileLst.size() > 0 && conLst.size() > 0){
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country='United States',IsActive =true,
                                 ContactId = conLst[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            List<Task> taskRecords;
            taskRecords = new List<Task> {
                new Task(Type = 'To Do' ,To_Do_Type__c = '30 - Watch Timekeeping Approval Training Video',Status = 'In Progress',whoId = conLst[0].Id,subject = 'Watch Timekeeping Approval Training Video'),
                new Task(Type = 'To Do' ,To_Do_Type__c = '40 - Student Policies & Procedures',Status = 'In Progress',whoId = conLst[0].Id,subject = 'Confirm your Contact Information'),
                new Task(Type = 'To Do' ,To_Do_Type__c = '50 - Confirm your Contact Information',Status = 'In Progress',whoId = conLst[0].Id,subject = 'Confirm your Contact Information')
            };
            insert taskRecords;
            
            system.runas(user){
                String taskJson = OnBoardingController.getToDoItems();
                List<Task> taskList = (List<Task>) JSON.deserialize(taskJson,List<Task>.class);
                
                if(taskList.size() > 0) {
                    System.AssertEquals(taskList[0].Status,'In Progress');
                    System.AssertEquals(taskList[0].whoId,conLst[0].Id);
                    
                    // to update status of task as 'Completed'
                    List<Task> taskLst = (List<Task>) JSON.deserialize(OnBoardingController.updateToDoItem(taskList[0].Id),List<Task>.class);
                    if(taskLst.size() > 0) {
                        System.AssertEquals(taskList.size()-1,taskLst.size());
                    }             
                    OnBoardingController.updateToDoItem(null);
                }
            }
        }
    }
    
    // to get Open and Completed ToDo Items for Instructor
    private static testMethod void testMethod3() {
    
        List<Contact> conLst = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1'];
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Instructor Community'];
        
        if(profileLst.size() > 0 && conLst.size() > 0){
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country='United States',IsActive =true,
                                 ContactId = conLst[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            List<Task> taskRecords;
            taskRecords = new List<Task> {
                new Task(Type = 'To Do' ,To_Do_Type__c = '10 - Watch Timekeeping Training Video',Status = 'In Progress',whoId = conLst[0].Id,subject = 'Watch Timekeeping Training Video'),
                new Task(Type = 'To Do' ,To_Do_Type__c = '20 - Review and complete your Profile',Status = 'In Progress',whoId = conLst[0].Id,subject = 'Review and complete your Profile')
            };
            insert taskRecords;
            
            List<Task> updateTaskRecords = [SELECT Id,To_Do_Type__c,Status FROM Task WHERE To_Do_Type__c = '20 - Review and complete your Profile' AND whoId = :conLst[0].Id];
          
            if(updateTaskRecords.size() > 0){
                updateTaskRecords[0].Status = 'Completed';
                update updateTaskRecords;
            }
            
            system.runas(user){
                OnBoardingController.toDoItems todo = OnBoardingController.getOpenCompletedToDoItems();
                
                if(todo != null) {
                    if(todo.completedToDoItems.size() > 0){
                        System.AssertEquals(todo.completedToDoItems[0].Status,'Completed');
                    }
                    if(todo.openToDoItems.size() > 0){
                        System.AssertEquals(todo.openToDoItems[0].Status,'In Progress');
                    }
                }
            }
        }
    }
    
    // to get Open and Completed ToDo Items for Student
    private static testMethod void testMethod4() {
    
        List<Contact> conLst = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1'];
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Student Community'];
        
        if(profileLst.size() > 0 && conLst.size() > 0){
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country='United States',IsActive =true,
                                 ContactId = conLst[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            List<Task> taskRecords;
            taskRecords = new List<Task> {
                new Task(Type = 'To Do' ,To_Do_Type__c = '30 - Watch Timekeeping Approval Training Video',Status = 'In Progress',whoId = conLst[0].Id,subject = 'Watch Timekeeping Approval Training Video'),
                new Task(Type = 'To Do' ,To_Do_Type__c = '40 - Student Policies & Procedures',Status = 'In Progress',whoId = conLst[0].Id,subject = 'Confirm your Contact Information'),
                new Task(Type = 'To Do' ,To_Do_Type__c = '50 - Confirm your Contact Information',Status = 'In Progress',whoId = conLst[0].Id,subject = 'Confirm your Contact Information')
                    
           };
            insert taskRecords;
            
            List<Task> updateTaskRecords = [SELECT Id,To_Do_Type__c,Status FROM Task WHERE To_Do_Type__c = '50 - Confirm your Contact Information' AND whoId = :conLst[0].Id];
          
            if(updateTaskRecords.size() > 0){
                updateTaskRecords[0].Status = 'Completed';
                update updateTaskRecords;
            }
            
            system.runas(user){
                OnBoardingController.toDoItems todo = OnBoardingController.getOpenCompletedToDoItems();
                
                if(todo != null) {
                    if(todo.completedToDoItems.size() > 0){
                        System.AssertEquals(todo.completedToDoItems[0].Status,'Completed');
                    }
                    if(todo.openToDoItems.size() > 0){
                        System.AssertEquals(todo.openToDoItems[0].Status,'In Progress');
                    }
                }
            }
        }
    }
    
    // Cover getSummaryDLIAttendanceInfo() method
    private static testMethod void testMethod5() {
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];

        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Id dliWLT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
    
        List<AcctSeed__Project_Task__c> pt = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training' LIMIT 1];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, RecordTypeId FROM AcctSeed__Project__c WHERE Id = :pt[0].AcctSeed__Project__c];
        projects[0].RecordTypeId = dliWLT;
        update projects[0];
        
        List<AcctSeed__Project__c> projects1 = [SELECT Id FROM AcctSeed__Project__c WHERE Id != :projects[0].Id];
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAss = [SELECT Id,Candidate_Name__c,Status__c,Project__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Assignment_Position__c IN ('Class Leader','Student') AND Status__c = 'Active'];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Project__c = projects[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Time_Approval_Preference__c ='Daily';
            update conAss[0];
                               
            List<Events__c> events = [SELECT Id,Date__c,Instructor__c,Project__c FROM Events__c WHERE Status__c = 'Scheduled'];
            events[0].Date__c = System.Today();
            events[0].Project__c = projects[0].Id;
            events[0].Instructor__c = conList[0].Id;
            update events[0];       
                        
            List<DLI_Attendance__c> attenRecs = new List<DLI_Attendance__c>{
                
                new DLI_Attendance__c(Project__c = projects1[0].Id, Class_Leader__c = conList[0].Id, Date__c = System.Today())
            };
            insert attenRecs;
            
            System.runAs(user){
            
                OnBoardingController.getSummaryDLIAttendanceInfo();
            }
        Test.stopTest();
    }
    
    // Cover getDLIAttendanceInfo() method
    private static testMethod void testMethod6() {
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];

        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Id dliWLT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
    
        List<AcctSeed__Project_Task__c> pt = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training' LIMIT 1];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, RecordTypeId FROM AcctSeed__Project__c WHERE Id = :pt[0].AcctSeed__Project__c];
        projects[0].RecordTypeId = dliWLT;
        update projects[0];
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projects1 = [SELECT Id FROM AcctSeed__Project__c WHERE Id != :projects[0].Id];
            
            List<Contact_Assignments__c> conAss = [SELECT Id,Candidate_Name__c,Status__c,Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Assignment_Position__c IN ('Class Leader','Student') AND Status__c = 'Active'];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Project__c = projects[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            update conAss[0];
                
            List<Events__c> events = [SELECT Id,Date__c,Instructor__c,Project__c FROM Events__c WHERE Status__c = 'Scheduled'];
            events[0].Date__c = System.Today();
            events[0].Project__c = projects[0].Id;
            events[0].Instructor__c = conList[0].Id;
            update events[0];       
                 
            System.runAs(user){
            
                OnBoardingController.getDLIAttendanceInfo(projects[0].Id, conList[0].Id);
            }
        Test.stopTest();
    }
    
    // Cover createDLIAttendance() method
    private static testMethod void testMethod7() {
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];

        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
                   
            OnBoardingController.summaryAttendanceDetail sumDet = new OnBoardingController.summaryAttendanceDetail();
            
            System.runAs(user){
            
                try{
                    OnBoardingController.createDLIAttendance(JSON.serialize(sumDet));
                }catch(Exception e){
                    System.debug('::::::'+e.getMessage());
                }
            }
        Test.stopTest();
    }
    
    // Cover createDLIAttendance() method
    private static testMethod void testMethod8() {
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];

        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, Student_Access__c = TRUE, Instructor_Access__c = TRUE,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
            
            List<AcctSeed__Project__c> projects = [SELECT Id, RecordTypeId FROM AcctSeed__Project__c LIMIT 1];
            
            List<Events__c> events = [SELECT Id,Date__c,Instructor__c,Project__c FROM Events__c WHERE Status__c = 'Scheduled' LIMIT 2];
                                        
            List<Contact_Assignments__c> conAss = [SELECT Id,Candidate_Name__c,Status__c,Project__c FROM Contact_Assignments__c LIMIT 1];
                                                
            OnBoardingController.AttendanceInfo atnd = new OnBoardingController.AttendanceInfo();
            atnd.studentPresent = 'no';
            atnd.attendanceComment = 'My comm';
            atnd.classLeaderId = conList[0].Id;
            atnd.classLeaderCAId = conList[0].Id;
            atnd.eventId = events[0].Id;
            atnd.projectId = events[0].Id;
            atnd.studentId = events[0].Id;
            atnd.studentCAId = conAss[0].Id;
            
            List<OnBoardingController.AttendanceInfo> atnList = new List<OnBoardingController.AttendanceInfo>();
            atnList.add(atnd);
            
            OnBoardingController.summaryAttendanceDetail sumDet = new OnBoardingController.summaryAttendanceDetail();
            sumDet.academicIssue = true;
            sumDet.academicIssueComment = 'Test comm';
            sumDet.technicalIssue = true;
            sumDet.technicalIssueComment = 'Test cm';
            sumDet.allStudentDetails = atnList;
            
            System.runAs(user){
            
                try{
                    OnBoardingController.createDLIAttendance(JSON.serialize(sumDet));
                }catch(Exception e){
                    System.debug('::::::'+e.getMessage());
                }
            }
        Test.stopTest();
    }
}