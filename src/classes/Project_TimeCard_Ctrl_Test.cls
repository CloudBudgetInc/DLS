@isTest
public class Project_TimeCard_Ctrl_Test { 
    @testSetup static void setup(){
        List<AcctSeed__Time_Card_Day__c> timeCardDays =  TestClassUtil.createTestTimeCardDay();
    }
    public static testMethod void myTest() {
        
        Test.startTest();
        
        List<AcctSeed__Time_Card_Line__c> timecardlinelist = [Select Id,Name,AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name From AcctSeed__Time_Card_Line__c limit 3];       
        system.debug(':::::timecardlinelist'+timecardlinelist);
        system.debug(':::::timecardlinelist'+timecardlinelist[0].AcctSeed__Project_Task__r.AcctSeed__Project__c);
           
        PageReference pageRef = Page.ProjectTimeCard_Page;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(timecardlinelist[0].AcctSeed__Project_Task__r.AcctSeed__Project__c));             
        //ApexPages.StandardController sc = new ApexPages.StandardController(timecardlinelist[0]);       
        
        Project_TimeCard_Ctrl testAccPlan = new Project_TimeCard_Ctrl();
              
        Project_TimeCard_Ctrl.getInitialValues(timecardlinelist[0].AcctSeed__Time_Card__r.Intructor__c, 'contact');
        Project_TimeCard_Ctrl.getInitialValues(timecardlinelist[0].AcctSeed__Project_Task__r.AcctSeed__Project__c, 'AcctSeed__Project__c');
        Project_TimeCard_Ctrl.getInstructorFilterValues(timecardlinelist[0].AcctSeed__Time_Card__r.Intructor__c, 'contact');
        Project_TimeCard_Ctrl.getInstructorFilterValues(timecardlinelist[0].AcctSeed__Project_Task__r.AcctSeed__Project__c, 'AcctSeed__Project__c');
        Project_TimeCard_Ctrl.getDaysByInstructor('All', timecardlinelist[0].AcctSeed__Time_Card__r.Intructor__c, String.valueOf(Date.Today()), String.valueOf(Date.Today()), 'All');
        Project_TimeCard_Ctrl.getDaysByInstructor(timecardlinelist[0].AcctSeed__Time_Card__r.Intructor__c, timecardlinelist[0].AcctSeed__Project_Task__r.AcctSeed__Project__c, String.valueOf(Date.Today()), String.valueOf(Date.Today()), timecardlinelist[0].AcctSeed__Project_Task__c);
        Project_TimeCard_Ctrl.getTCDCount('All', timecardlinelist[0].AcctSeed__Project_Task__r.AcctSeed__Project__c, String.valueOf(Date.Today()), String.valueOf(Date.Today()), 'All');
        
        Test.stopTest();
    }
     
    public static testMethod void myTest1() {
        
        List<AcctSeed__Time_Card_Line__c> timecardlinelist = [Select Id,Name,AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card__r.Intructor__r.Name From AcctSeed__Time_Card_Line__c limit 3];       
        
        PageReference pageRef = Page.ProjectTimeCard_Page;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(timecardlinelist[0].AcctSeed__Project_Task__r.AcctSeed__Project__c)); 
        
        Project_TimeCard_Ctrl.getTCDCount(timecardlinelist[0].AcctSeed__Time_Card__r.Intructor__c, timecardlinelist[0].AcctSeed__Project_Task__r.AcctSeed__Project__c, String.valueOf(Date.Today()), String.valueOf(Date.Today()), 'All');
        
        Project_TimeCard_Ctrl.getTCDForDownload('All', timecardlinelist[0].AcctSeed__Project_Task__r.AcctSeed__Project__c,1, String.valueOf(Date.Today()), String.valueOf(Date.Today()), 'All');
        Project_TimeCard_Ctrl.getTCDForDownload(timecardlinelist[0].AcctSeed__Time_Card__r.Intructor__c, timecardlinelist[0].AcctSeed__Project_Task__r.AcctSeed__Project__c,2, String.valueOf(Date.Today()), String.valueOf(Date.Today()),'All');
    
        Project_TimeCard_Ctrl.getTCDTotalHours('All', timecardlinelist[0].AcctSeed__Project_Task__r.AcctSeed__Project__c, 'AcctSeed__Project__c','All');
        Project_TimeCard_Ctrl.getTCDTotalHours(timecardlinelist[0].AcctSeed__Time_Card__r.Intructor__c, timecardlinelist[0].AcctSeed__Project_Task__r.AcctSeed__Project__c, 'AcctSeed__Project__c','All');
    }
}