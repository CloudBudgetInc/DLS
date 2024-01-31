@isTest
public Class ProjectTaskCreationContr_Test{
    @testSetup static void setup(){
       List<AcctSeed__Project_Task__c> accprotask = TestClassUtil.createTestProjectTask();
       List<Opportunity> opps = TestClassUtil.createTestOpportunities();
    }
    
    public static testMethod void myTest(){
        List<Project_Task_Master__c> projmaster = new List<Project_Task_Master__c>{
            
            new Project_Task_Master__c(Name = 'Test 1',Project_Type__c = 'Internal Cost Jobs',Unit__c = 'Hrs',Project_Task_Type__c = 'FMLA',Payroll_Item__c = 'S', Project_Task_Record_Type__c = 'Cost',Project_Record_Type__c = 'Admin_Projects'),
            new Project_Task_Master__c(Name = 'Test 2',Project_Type__c = 'Internal Cost Jobs',Unit__c = 'Hrs',Project_Task_Type__c = 'Fringe',Payroll_Item__c = 'JUR', Project_Task_Record_Type__c = 'Cost', Project_Record_Type__c = 'Admin_Projects'),
            new Project_Task_Master__c(Name = 'Test 3',Project_Type__c = 'DLS-Site Language Training; Client Site Language Training; FBI WO',Unit__c = 'Hrs',Project_Task_Type__c = 'Fringe',Payroll_Item__c = 'JUR', Project_Task_Record_Type__c = 'Cost', Project_Record_Type__c = 'Language_Training_Projects')
        };
        insert projmaster;                              
        List<AcctSeed__Project_Task__c> accprotask = [Select Id, Name, AcctSeed__Project__c,AcctSeed__Project__r.RecordType.DeveloperName, Project_Task_Type__c, Total_Qty_Planned__c, Rate__c, Unit__c From AcctSeed__Project_Task__c Where AcctSeed__Project__r.RecordType.DeveloperName =: 'Admin_Projects' Limit 5];
        system.debug('::::accprotask'+accprotask);
        
        List<AcctSeed__Project_Task__c> accprotask1 = new List<AcctSeed__Project_Task__c>{
            new AcctSeed__Project_Task__c(Name = 'Test1')
        };
        
        List<AcctSeed__GL_Account__c> laborList = [Select Id,Name From AcctSeed__GL_Account__c Limit 3];
        List<Id> laborid = new List<Id>();
        
        for(AcctSeed__GL_Account__c at : laborList){
            laborid.add(at.Id);
        }
        
        String laborjson = JSON.serialize(laborid);
        system.debug(':::laborjson'+laborjson);
        
        Id usrId = UserInfo.getUserId();
        List<Opportunity> opps = [SELECT Id FROM Opportunity LIMIT 1];
        Id recordTypeId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Translation_Projects').getRecordTypeId();
        AcctSeed__Project__c transInterProject = new AcctSeed__Project__c(Name = 'Test Project',AcctSeed__Status__c = 'Active',RecordTypeId = recordTypeId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opps[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert transInterProject ;

        
        Test.startTest();
        ProjectTaskCreationContr.projecttask(accprotask[0].AcctSeed__Project__c);
        ProjectTaskCreationContr.picklistvalues('AcctSeed__Project_Task__c' , 'Unit__c');
        ProjectTaskCreationContr.createprojecttask(accprotask);
        ProjectTaskCreationContr.createprojecttask(accprotask1);
        ProjectTaskCreationContr.laborrec(laborjson);
        ProjectTaskCreationContr.getRecordType();
        ProjectTaskCreationContr.getLookupRecords('AcctSeed__Project_Task__c','M','');
        ProjectTaskCreationContr.checkRecordTypeName(transInterProject.Id);
        ProjectTaskCreationContr.checkRecordTypeName(accprotask[0].AcctSeed__Project__c);
        
        // To increase coverage for "TimeCardDayTranslator"
        TimeCardDayTranslator.payrollItemFormation(projmaster);
        Test.stopTest();
    }
}