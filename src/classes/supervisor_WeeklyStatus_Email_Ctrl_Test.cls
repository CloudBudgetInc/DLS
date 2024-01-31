@isTest
public class supervisor_WeeklyStatus_Email_Ctrl_Test {

    @testSetup static void setup(){
    
        List<AcctSeed__Time_Card_Day__c> timecardList = TestClassUtil.createTestTimeCardDay();
        Test.startTest();
            List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
        Test.stopTest();
    }
    
    public static testMethod void myTest() {
    
        Date myDate = date.today();
        Date weekstdate = myDate.toStartofWeek()+1;
        Date weekenddate = myDate.toStartofWeek()+7;
        
        Date Laststdate = weekstdate.addDays(-7);
        Date Lastenddate = weekenddate.addDays(-7);
        
        system.debug('::::Laststdate:::'+Laststdate);
        system.debug(':::Lastenddate::::'+Lastenddate);
        
        if(Laststdate.toStartofMonth() != weekstdate.toStartofMonth()) {
            String month;
            if(Laststdate.month() < 10){
                month = '0'+Laststdate.month();
            }else {
                month = String.valueOf(Laststdate.month());
            }
            
            AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c();
            accPeriod.name = Laststdate.year()+'-'+month;
            accPeriod.AcctSeed__Start_Date__c = Laststdate.toStartofMonth();
            accPeriod.AcctSeed__End_Date__c = Laststdate.addMonths(1).toStartofMonth().addDays(-1);
            Insert accPeriod;
        }
                
        List<AcctSeed__Time_Card_Period__c> timeCardPeriod = new List<AcctSeed__Time_Card_Period__c> {
            new AcctSeed__Time_Card_Period__c(Name = myDate.year()+'-'+myDate.Month(),AcctSeed__End_Date__c = Lastenddate,AcctSeed__Start_Date__c = Laststdate)
        };
        insert timeCardPeriod;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' LIMIT 1];
        
        List<AcctSeed__Ledger__c> ledgerList = [SELECT Id, Name, AcctSeed__Type__c FROM AcctSeed__Ledger__c WHERE AcctSeed__Type__c = 'Transactional' LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = new List<AcctSeed__Time_Card__c> {
            new AcctSeed__Time_Card__c(AcctSeed__Employee__c=UserInfo.getUserId(),Intructor__c=conList[0].Id,AcctSeed__Time_Card_Period__c=timeCardPeriod[0].Id, AcctSeed__Ledger__c = ledgerList[0].Id, Submitted_Date__c = Date.Today())
        };
        
        insert timeCard;
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' LIMIT 1];
        System.debug('task ====='+task);
        
        List<Contact_Assignments__c> insConAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        System.debug('insConAss====='+insConAss);
        insConAss[0].Candidate_Name__c = conList[0].Id;
        insConAss[0].Project__c = task[0].AcctSeed__Project__c;
        update insConAss;
        
        Test.startTest();
        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = insConAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            List<AcctSeed__Time_Card_Day__c> timeCardDays = new List<AcctSeed__Time_Card_Day__c> {
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Laststdate,Status__c = 'Submitted'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = Laststdate.addDays(1),Status__c = 'Submitted'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = Laststdate.addDays(2),Status__c = 'Submitted')
            };
            insert timeCardDays; 
            
            List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, Status__c FROM AcctSeed__Time_Card_Day__c WHERE Id IN : timeCardDays];
            days[0].Status__c = 'Approved';
            days[1].Status__c = 'Rejected';
            update days;
            
            supervisor_WeeklyStatus_Email_Controller weekstatus1 = new supervisor_WeeklyStatus_Email_Controller();
            weekstatus1.setactualContactId(conList[0].Id);
            weekstatus1.getactualContactId();
            
            supervisor_WeeklyStatus_Email_Controller weekstatus2 = new supervisor_WeeklyStatus_Email_Controller();
            weekstatus2.setcontactId(conList[0].Id);
            weekstatus2.getcontactId();
        Test.stopTest();
    }
}