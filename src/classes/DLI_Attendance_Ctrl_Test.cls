@isTest
public class DLI_Attendance_Ctrl_Test {
    @testSetup static void setup() {
        //List<Account> accList = TestClassUtil.createTestAccounts();
        List<schedule__c> schList = TestClassUtil.createTestSchedule();
        List<Room__c> roomList = TestClassUtil.createTestRoom();
        List<Floor_Suite__c> floorList = TestClassUtil.createTestSuite();
        Test.StartTest();
        List<Contact_Assignments__c> conAssList = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
    }     
    
    public static testMethod void DLIAttendanceMethod() {
        
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Floor_Suite__c flo = [SELECT Id, Floor__c FROM Floor_Suite__c LIMIT 1];
        flo.Floor__c = '1st FL';
        update flo;
        system.debug('::::flo:::::'+flo);
        Room__c ro = [SELECT Id, Name, Floor_Suite__c, Floor_Suite__r.Floor__c FROM Room__c LIMIT 1];
        update ro;
        system.debug(':::ro::::'+ro);
        Date today = system.today();
        String dt = String.valueOf(today);
    
        List<Schedule__c> sch = [SELECT Id, Name, Project__c, Project_Task__c, Status__c,Room__r.Floor_Suite__r.Floor__c,
                                 Total_Hours__c, End_Date__c, Start_Date__c, Project__r.AcctSeed__Account__c, Room__c, 
                                 Room__r.Name, Room__r.Floor_Suite__c FROM Schedule__c LIMIT 2];
        
        for(Integer i = 0; i < sch.size(); i++) {
            //sch[i].Project__r.AcctSeed__Account__c = acc.Id;       
            sch[i].Status__c = 'Active';
            sch[i].Room__c = ro.Id;          
        }
        update sch;
        
        AcctSeed__Project__c pro = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :sch[0].Project__c LIMIT 1];
        pro.AcctSeed__Account__c = acc.Id;
        update pro; 
               
        system.debug('::schedule__c::floor:1:'+sch[0].Room__r.Floor_Suite__r.Floor__c);
        system.debug(':::ro:::floor:::'+ro.Floor_Suite__r.Floor__c);
        system.debug('::schedule__c::room:::'+sch[0].Room__c); 
        
        Test.startTest();
        
        List<Contact_Assignments__c> conAss = [SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Name, Project__c,
                                               Project__r.Language__c,Project__r.Language__r.Name,Project__r.Name 
                                               FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' LIMIT 2];
        
        for(Integer i = 0; i < conAss.size(); i++) {
            conAss[i].Project__c = sch[0].Project__c;
        }
        update conAss;
       
        ApexPages.StandardController sc1 = new ApexPages.standardController(acc);
        DLI_Attendance_Ctrl dliAtt = new DLI_Attendance_Ctrl(sc1);
        DLI_Attendance_Ctrl.getStudentsBasedonFloors(acc.Id, flo.Floor__c, dt);
        DLI_Attendance_Ctrl.picklistvalues('Floor_Suite__c', 'Floor__c');
        Test.stopTest();
    }  
}