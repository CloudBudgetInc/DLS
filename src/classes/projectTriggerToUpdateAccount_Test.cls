@isTest
private Class projectTriggerToUpdateAccount_Test{

    @testsetup static void setup() {
    
        List<AcctSeed__Project_Task__c> projTasks = TestClassUtil.createTestProjectTask();
        List<Contract> contracts = TestClassUtil.createTestContracts();
        List<AcctSeed__Accounting_Variable__c> accVar = TestClassUtil.createAccountingVariable();
        
        Test.startTest();
            List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'FALSE')};
            insert sysVal;
            List<MTT_Location__c> locations = TestClassUtil.createTestLocations();
        Test.stopTest();
    }
     
    // For Delivery & End User account updation
    private static testMethod void testMethod1() {
    
        List<Account> acc = [SELECT Id, Name FROM Account LIMIT 2];
        List<AcctSeed__Project__c> proList = [SELECT Id, Name, RecordTypeId, AcctSeed__Account__c, Delivery_Account__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName = 'Language_Training_Projects' LIMIT 3];
        
        if(proList != null && proList.size() > 0){
            for(AcctSeed__Project__c pro : proList) {
                pro.AcctSeed__Account__c = acc[0].Id;
            }
            update proList;
        }
        List<AcctSeed__Project__c> updatedList = [SELECT Id,Name,Delivery_Account__c FROM AcctSeed__Project__c WHERE Id = :proList[0].Id];
        
        if(updatedList.size() > 0)
        System.assertEquals(acc[0].Id, updatedList[0].Delivery_Account__c);
    }
     
    // For ICJ Project related account updation
    private static testMethod void testMethod2() {
         
        List<Account> acc = [SELECT Id, Name FROM Account LIMIT 2];
        List<System_Values__c> sysVal = new List<System_Values__c>{
             new System_Values__c(Name = 'DLS Account',Value__c = acc[0].Id)
        };
         
        insert sysVal;
        
        List<AcctSeed__Project__c> proList = [SELECT Id, Name,AcctSeed__Account__c,End_Date__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName = 'Admin_Projects' LIMIT 2];
        if(proList != null && proList.size() > 0){
            for(AcctSeed__Project__c pro : proList) {
                pro.End_Date__c = system.today().addDays(20);
            }
            update proList;
        }
         
        List<AcctSeed__Project__c> updatedList = [SELECT Id,Name,AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :proList[0].Id];
        if(updatedList.size() > 0)
            System.assertEquals(sysVal[0].Value__c, updatedList[0].AcctSeed__Account__c);
    }
     
    // End date updation from Oram exam date for Testing Projects
     private static testMethod void testMethod3() {
         
         List<Account> acc = [SELECT Id, Name FROM Account LIMIT 2];
         
         List<Opportunity> oppList = [SELECT Id,Name FROM Opportunity WHERE RecordType.DeveloperName = 'Testing_Opportunities' LIMIT 1];
         
         List<AcctSeed__Project__c> newProList = new List<AcctSeed__Project__c>();
         
         List<AcctSeed__Project__c> proList = [SELECT Id, Name,AcctSeed__Account__c,End_Date__c,Oral_Exam_Date_Time__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName = 'Testing_Projects' LIMIT 2];
         if(proList != null && proList.size() > 0){
             for(AcctSeed__Project__c pro : proList) {
                 pro.Oral_Exam_Date_Time__c = system.now().addDays(-6);
             }
             update proList;
         }else {
             
             List<RecordType> proRTList = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'AcctSeed__Project__c' AND DeveloperName = 'Testing_Projects'];
             
             newProList = new List<AcctSeed__Project__c>{
                 new AcctSeed__Project__c(Name = 'Testing Project 1',AcctSeed__Status__c = 'Order',RecordTypeId = proRTList[0].Id, AcctSeed__Opportunity__c = oppList[0].Id, Oral_Exam_Date_Time__c = System.now().addDays(-15)),
                 new AcctSeed__Project__c(Name = 'Testing Project 2',AcctSeed__Status__c = 'Active',RecordTypeId = proRTList[0].Id, AcctSeed__Opportunity__c = oppList[0].Id, Oral_Exam_Date_Time__c = System.now().addDays(20))
             };
             
             insert newProList;
         }
         
         if(proList.size() > 0) {
             List<AcctSeed__Project__c> updatedList = [SELECT Id,Name,End_Date__c,Oral_Exam_Date_Time__c FROM AcctSeed__Project__c WHERE Id = :proList[0].Id LIMIT 1];
             if(updatedList.size() > 0)
                 System.assertEquals(Date.ValueOf(System.today().addDays(-6)), updatedList[0].End_Date__c);
         }else {
             List<AcctSeed__Project__c> newlyUpdated = [SELECT Id,Name,End_Date__c,Oral_Exam_Date_Time__c FROM AcctSeed__Project__c WHERE Id = :newProList[0].Id LIMIT 1];
             DateTime dT = System.now().addDays(-15);
             Date etDate = date.newinstance(dT.year(), dT.month(), dT.day());
             System.assertEquals(etDate, newlyUpdated[0].End_Date__c);
         }
         
     }
     
    // Planned days off creation for direct project creation without opportunity values
    private static testMethod void testMethod4() {
         
        List<Account> acc = [SELECT Id, Name FROM Account LIMIT 2];
         
        List<RecordType> rtPlanDaysOff = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Planned_Days_Off__c' AND DeveloperName = 'DLI_W_LT_Training_Holidays'];
        Id pdortId;
        
        if(rtPlanDaysOff != Null && rtPlanDaysOff.size() > 0) {
            pdortId = rtPlanDaysOff[0].Id;
        }
        
        List<Planned_Days_Off__c> pdoList = new List<Planned_Days_Off__c> {
                                            new Planned_Days_Off__c(Date__c = System.today().addDays(-1),Description__c = 'Test',RecordTypeId = pdortId),
                                            new Planned_Days_Off__c(Date__c = System.today().addDays(-1),Description__c = 'Test',RecordTypeId = pdortId)
                                        };
        insert pdoList;
        
        List<RecordType> proRTList = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'AcctSeed__Project__c' AND DeveloperName = 'DLI_W_LT_Projects'];
        
        List<Opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 1];
        
        List<AcctSeed__Project__c> newProList = new List<AcctSeed__Project__c>{
                 new AcctSeed__Project__c(Name = 'Test DLI-W Project 1',AcctSeed__Status__c = 'Order',RecordTypeId = proRTList[0].Id, Start_Date__c = System.today().addDays(-15),End_Date__c = System.today().addDays(50)),
                 new AcctSeed__Project__c(Name = 'Test DLI-W Project 2',AcctSeed__Status__c = 'Active',RecordTypeId = proRTList[0].Id, Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(30))
             };
             
        insert newProList;
         
        List<Planned_Days_Off__c> planDayOffList = [SELECT Id FROM Planned_Days_Off__c WHERE RecordType.DeveloperName = 'Project_Planned_Days_Off' AND Project__c = :newProList[0].Id];
        System.assert(planDayOffList.size() > 0);
    } 
    
    // Course Completion Feedback Email notification on Project status updation to Ended
    private static testMethod void testMethod5() {
         
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
        
        List<RecordType> conAssignRTList = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Contact_Assignments__c' AND DeveloperName = 'Student'];
        
        List<AcctSeed__Project__c> projList = [SELECT Id,Name,Start_Date__c,End_Date__c,AcctSeed__Status__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName = 'Language_Training_Projects' LIMIT 2];
        
        List<Contact> contactList = new List<Contact>{
            new Contact(LastName = 'Test Student 1', AccountId = accList[0].Id,Email = 'test1@gmail.com'),
            new Contact(LastName = 'Test Student 2', AccountId = accList[0].Id,Email = 'test2@gmail.com'),
            new Contact(LastName = 'Test Student 3', AccountId = accList[1].Id,Email = 'test3@gmail.com')
        };
        
        insert contactList;
        
        List<Contact_Assignments__c> conAssignList = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(Candidate_Name__c = contactList[0].Id,RecordTypeId = conAssignRTList[0].Id,Project__c = projList[0].Id,Status__c = 'Active',Start_Date__c = projList[0].Start_Date__c,End_Date__c = projList[0].End_Date__c),
            new Contact_Assignments__c(Candidate_Name__c = contactList[1].Id,RecordTypeId = conAssignRTList[0].Id,Project__c = projList[0].Id,Status__c = 'Planned',Start_Date__c = projList[0].Start_Date__c,End_Date__c = projList[0].End_Date__c),
            new Contact_Assignments__c(Candidate_Name__c = contactList[2].Id,RecordTypeId = conAssignRTList[0].Id,Project__c = projList[1].Id,Status__c = 'Active',Start_Date__c = projList[0].Start_Date__c,End_Date__c = projList[0].End_Date__c)
        };
        
        insert conAssignList;
        
        
        for(AcctSeed__Project__c pro : projList){
            pro.AcctSeed__Status__c = 'Ended';
            pro.End_Date__c = Date.Today().addDays(-2);
        }
        try {
            update projList; 
        } catch(Exception e) {
            System.debug(':::::exception::DML:::'+e.getMessage());
        }
    } 
    
    // Default Cost Rate Rate Type population related method
    private static testMethod void testMethod6() {
        
        List<Opportunity_Project_Mapping__c> oppMapping = new List<Opportunity_Project_Mapping__c>{
        
            new Opportunity_Project_Mapping__c(Name = 'DLI_W_LT_Projects' ,Default_CR_Rate_Type__c = 'DLI-16 SCA LT',Opportunity_Value__c = 'DLI_W_TO_Opportunities',Project_Value__c = 'DLI_W_LT_Projects',Value_Type__c = 'Rate Type'),
            new Opportunity_Project_Mapping__c(Name = 'DODA_Projects_Non-SCA LT' ,Default_CR_Rate_Type__c = 'Non-SCA LT',Opportunity_Value__c = 'ODNI_CLP_Opportunities,New_Classes_Opportunities,Partner_School',Project_Value__c = 'DODA_Projects,Language_Training_Projects,Partner_School_LT_Projects',Value_Type__c = 'Rate Type')
        };
        insert oppMapping;
       
        List<RecordType> proRTList = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'AcctSeed__Project__c' AND DeveloperName IN ('DODA_Projects','Language_Training_Projects')];
        
        if(proRTList.size() > 0) {
            List<AcctSeed__Project__c> newProList = new List<AcctSeed__Project__c>{
                new AcctSeed__Project__c(Name = 'Test DODA Project 1',AcctSeed__Status__c = 'Order',RecordTypeId = proRTList[0].Id, Start_Date__c = System.today().addDays(-15),End_Date__c = System.today().addDays(50)),
                new AcctSeed__Project__c(Name = 'Test LT Project 2',AcctSeed__Status__c = 'Active',RecordTypeId = proRTList[1].Id, Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(30))
            };
             
            insert newProList;
            
            newProList[0].RecordTypeId = proRTList[0].Id;
            
            update newProList;
            
            List<AcctSeed__Project__c> updatedList = [SELECT Id,Name,Default_Cost_Rate_Rate_Type__c FROM AcctSeed__Project__c WHERE Id = :newProList[0].Id];
            //System.assertEquals(oppMapping[1].Default_CR_Rate_Type__c, updatedList[0].Default_Cost_Rate_Rate_Type__c);
        }
    }
    
    // ILR R,S & L Goal Applicable related method
    private static testMethod void testMethod7() {
    
        List<RecordType> proRTList = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'AcctSeed__Project__c' AND DeveloperName IN ('DODA_Projects','Language_Training_Projects')];
        List<Opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 1];
        
        List<AcctSeed__Project__c> projectList = [SELECT Id,Name,ILR_L_Goal__c,ILR_R_Goal__c,ILR_S_Goal__c,L_Goal_Score_Applicable__c,R_Goal_Score_Applicable__c FROM AcctSeed__Project__c LIMIT 2];
        
        List<AcctSeed__Project__c> newProList = new List<AcctSeed__Project__c>{
            new AcctSeed__Project__c(Name = 'Test DODA Project 2',AcctSeed__Opportunity__c = oppList[0].Id,AcctSeed__Status__c = 'Order',RecordTypeId = proRTList[0].Id, Start_Date__c = System.today().addDays(-15),End_Date__c = System.today().addDays(50),ILR_L_Goal__c = '2+'),
            new AcctSeed__Project__c(Name = 'Test LT Project 3',AcctSeed__Opportunity__c = oppList[0].Id,AcctSeed__Status__c = 'Active',RecordTypeId = proRTList[1].Id, Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(30),ILR_R_Goal__c = '3',ILR_S_Goal__c = '1+')
        };
             
        insert newProList;
        
        projectList[0].ILR_L_Goal__c = '2+';
        projectList[1].ILR_R_Goal__c = '1+';
        update projectList;
        
        List<AcctSeed__Project__c> updatedList = [SELECT Id,Name,L_Goal_Score_Applicable__c FROM AcctSeed__Project__c WHERE Id = :projectList[0].Id];
        System.assertEquals(true, updatedList[0].L_Goal_Score_Applicable__c);
        
        delete newProList[0];
    } 
    
    // Update the Cost Rate type value based on the Contract provided
    private static testMethod void testMethod8() {
        
        List<RecordType> rtList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('AcctSeed__Project__c', 'Contract') AND DeveloperName IN ('DLI_W_LT_Projects', 'Commercial_Client', 'MTT_Projects', 'CD_Projects')];
        
        if(rtList.size() > 0) {
        
            Id proRt, contrRt, mttRt, cdRt;
            
            for(RecordType rt : rtList) {
                if(rt.DeveloperName == 'DLI_W_LT_Projects')
                    proRt = rt.Id;
                else if(rt.DeveloperName == 'Commercial_Client')
                    contrRt = rt.Id;
                else if(rt.DeveloperName == 'MTT_Projects')
                    mttRt = rt.Id;
                else if(rt.DeveloperName == 'CD_Projects')
                    cdRt = rt.Id;
            }
            
            List<Opportunity_Project_Mapping__c> oppMapping = new List<Opportunity_Project_Mapping__c>{
                new Opportunity_Project_Mapping__c(Name = 'DLI_W_LT_Projects' ,Default_CR_Rate_Type__c = 'DLI-16 SCA LT',Opportunity_Value__c = 'DLI_W_TO_Opportunities',Project_Value__c = 'DLI_W_LT_Projects',Value_Type__c = 'Rate Type')
            };
            insert oppMapping;
            
            List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
            
            List<Contract> contractList = new List<Contract> {
                
                new Contract(RecordTypeId = contrRt,AccountId = accList[0].Id, Status = 'Completed Draft',StartDate = system.today()), //,Billing_Contact__c = contactList[1].Id,Primary_POC__c = contactList[0].Id
                new Contract(RecordTypeId = contrRt,AccountId = accList[1].Id,Status = 'Completed Draft',StartDate = system.today())
            };
            
            insert contractList;
           
            List<AcctSeed__Project__c> newProList = new List<AcctSeed__Project__c>{
                new AcctSeed__Project__c(Name = 'Test DLI Project 1',AcctSeed__Status__c = 'Order',RecordTypeId = proRt, Start_Date__c = System.today().addDays(-15),End_Date__c = System.today().addDays(-10), Contract__c = contractList[0].Id),
                new AcctSeed__Project__c(Name = 'Test DLI Project 2',AcctSeed__Status__c = 'Active',RecordTypeId = proRt, Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(30), Contract__c = contractList[1].Id),
                new AcctSeed__Project__c(Name = 'Test MTT Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = mttRt, Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(30), Contract__c = contractList[1].Id, Project_Type__c = 'MTT', TO__c = '101'),
                new AcctSeed__Project__c(Name = 'Test CD Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = cdRt, Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(30))
            };
            insert newProList;           
        }
    }
    
    // Populate Contract field value in Project Task records from Project while populating contract value on project
    private static testMethod void testMethod9() {
    
        Id dlwRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        List<Contract> contracts = [SELECT Id FROM Contract LIMIT 1];
        
        List<AcctSeed__Project__c> proList = [SELECT Id, Contract__c FROM AcctSeed__Project__c LIMIT 2];
        
        List<AcctSeed__Project_Task__c> projTasks = [SELECT Id FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c =:proList[1].Id];
        
        proList[1].RecordTypeId = dlwRTId;
        proList[1].Contract__c = contracts[0].Id;
        update proList[1];
        
        List<AcctSeed__Project__c> proj = [SELECT Id, Contract__c FROM AcctSeed__Project__c WHERE Id = :proList[1].Id];
        System.assertEquals(contracts[0].Id, proj[0].Contract__c);
    }
    
    // Populate PC_Job_Code__c field value in Project Task records
    private static testMethod void testMethod10() {
                
        List<AcctSeed__Project__c> proList = [SELECT Id, Contract__c, DLS_Class__c FROM AcctSeed__Project__c LIMIT 1];
                
        proList[0].Name = 'My Test Recent Project';
        proList[0].DLS_Class__c = '00001';
        update proList[0];
                
        List<AcctSeed__Project__c> projs = [SELECT Id, Name, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proList[0].Id];
        
        List<AcctSeed__Project_Task__c> projTasks = [SELECT Id, PC_Job_Code__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c =:proList[0].Id];
        
        String pcJobCode = projs[0].DLS_Class__c+'-'+projTasks[0].Id;
        System.assertEquals(pcJobCode, projTasks[0].PC_Job_Code__c);
    }
    
    // Populate PC_Job_Code__c field value in Project Task records
    private static testMethod void testMethod10a() {
        
        List<MTT_Location__c> loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        Id dliRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> proList = [SELECT Id, Name, RecordTypeId, DLS_Class__c FROM AcctSeed__Project__c LIMIT 1];
                
        proList[0].Name = 'My Testing Project';
        proList[0].RecordTypeId = dliRTId;
        proList[0].DLS_Class__c = '00001';
        // To test the Project Task update process
        proList[0].QB_Classification__c = 'FSC0ARL';
        proList[0].Hourly_Rate__c = 50;
        proList[0].Training_Location__c = loc[0].Id;
        update proList[0];
                
        List<AcctSeed__Project__c> projs = [SELECT Id, Name, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proList[0].Id];
        
        List<AcctSeed__Project_Task__c> projTasks = [SELECT Id, Name, PC_Job_Code__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c =:proList[0].Id];
        
        String pcJobCode = projs[0].DLS_Class__c+'-DLI-'+projTasks[0].Id;
        System.assertEquals(pcJobCode, projTasks[0].PC_Job_Code__c);
    }
    
    // Populate DLS Class # field on Translation Projects, Language Testing Projects, and Interpretation Projects
    private static testMethod void testMethod11() {
        
        List<RecordType> rtList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('AcctSeed__Project__c') AND DeveloperName IN ('Testing_Projects','Translation_Projects','Interpretation_Projects', 'CD_Projects')];
        
        if(rtList.size() > 0) {
        
            Id testRT, transRT, interPreRT, cdRT;
            
            for(RecordType rt : rtList) {
                if(rt.DeveloperName == 'Testing_Projects')
                    testRT = rt.Id;
                else if(rt.DeveloperName == 'Translation_Projects')
                    transRT = rt.Id;
                else if(rt.DeveloperName == 'Interpretation_Projects')
                    interPreRT = rt.Id;
                else if(rt.DeveloperName == 'CD_Projects')
                    cdRT = rt.Id;
            }
            
            List<Opportunity_Project_Mapping__c> oppMapping = new List<Opportunity_Project_Mapping__c>{
                new Opportunity_Project_Mapping__c(Name = 'DLI_W_LT_Projects' ,Default_CR_Rate_Type__c = 'DLI-16 SCA LT',Opportunity_Value__c = 'DLI_W_TO_Opportunities',Project_Value__c = 'DLI_W_LT_Projects',Value_Type__c = 'Rate Type')
            };
            insert oppMapping;
            
            List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
           
            List<AcctSeed__Project__c> newProList = new List<AcctSeed__Project__c>{
                new AcctSeed__Project__c(Name = 'Test Testing Project 2',AcctSeed__Status__c = 'Order',RecordTypeId = testRT, Start_Date__c = System.today().addDays(-15),End_Date__c = System.today().addDays(-10)),
                new AcctSeed__Project__c(Name = 'Test Trans Project 2',AcctSeed__Status__c = 'Active',RecordTypeId = transRT, Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(30)),
                new AcctSeed__Project__c(Name = 'Test Inter Project 3',AcctSeed__Status__c = 'Active',RecordTypeId = interPreRT, Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(30)),
                new AcctSeed__Project__c(Name = 'Test CD Project 2',AcctSeed__Status__c = 'Active',RecordTypeId = cdRT, Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(30))
            };
            insert newProList;      
            
            List<AcctSeed__Project__c> projRec = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id IN : newProList AND RecordType.DeveloperName = 'Translation_Projects']; 
            Integer Year = Date.Today().Year();
            String str1 = String.valueof(Year).substring(2,4);
            String refValue = str1 + '0001';
            System.assertEquals('TR'+refValue, projRec[0].DLS_Class__c);
            
            Test.startTest();
            
                List<AcctSeed__Project__c> newProList1 = new List<AcctSeed__Project__c>{
                    new AcctSeed__Project__c(Name = 'Test Testing Project 11',AcctSeed__Status__c = 'Order',RecordTypeId = testRT, Start_Date__c = System.today().addDays(-15),End_Date__c = System.today().addDays(-10)),
                    new AcctSeed__Project__c(Name = 'Test Trans Project 12',AcctSeed__Status__c = 'Active',RecordTypeId = transRT, Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(30)),
                    new AcctSeed__Project__c(Name = 'Test Inter Project 13',AcctSeed__Status__c = 'Active',RecordTypeId = interPreRT, Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(30)),
                    new AcctSeed__Project__c(Name = 'Test CD Project 14',AcctSeed__Status__c = 'Active',RecordTypeId = cdRT, Start_Date__c = System.today().addDays(-10),End_Date__c = System.today().addDays(30))
                };
                insert newProList1;
            Test.stopTest();
        }
    }
    
    // To populate "Time_Approval_Preference__c" field for related Student Contact Assignment records based on "No_Student_Approval__c" field value
    private static testMethod void testMethod12() {
    
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'Test Project 101',AcctSeed__Status__c = 'Order', Start_Date__c = System.today().addDays(-15),End_Date__c = System.today().addDays(-10), No_Student_Approval__c = FALSE);
        insert proj;
        
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        contacts[0].Time_Approval_Preference__c = 'Daily';
        update contacts[0];
        
        Id stdRTId =Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact_Assignments__c> stdCAs = new List<Contact_Assignments__c> {
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = proj.Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = stdRTId),
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = proj.Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = stdRTId)
        };
        
        Test.startTest();
        
            insert stdCAs;
            
            List<AcctSeed__Project__c> projRec = [SELECT Id, No_Student_Approval__c FROM AcctSeed__Project__c WHERE Id =:proj.Id];
            projRec[0].No_Student_Approval__c = TRUE;
            update projRec;
            
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE Id IN : stdCAs];
            System.assertEquals('No Approval', conAssigns[0].Time_Approval_Preference__c);
            
        Test.stopTest();
    }
    
    // To populate "Time_Approval_Preference__c" field for related Student Contact Assignment records based on "No_Student_Approval__c" field value
    private static testMethod void testMethod13() {
    
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'Test Project 102',AcctSeed__Status__c = 'Order', Start_Date__c = System.today().addDays(-15),End_Date__c = System.today().addDays(-10), No_Student_Approval__c = TRUE);
        insert proj;
        
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        contacts[0].Time_Approval_Preference__c = 'Daily';
        update contacts[0];
        
        Id stdRTId =Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact_Assignments__c> stdCAs = new List<Contact_Assignments__c> {
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = proj.Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = stdRTId),
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = proj.Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = stdRTId)
        };
        
        Test.startTest();
        
            insert stdCAs;
            
            List<AcctSeed__Project__c> projRec = [SELECT Id, No_Student_Approval__c FROM AcctSeed__Project__c WHERE Id =:proj.Id];
            projRec[0].No_Student_Approval__c = FALSE;
            update projRec;
            
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE Id IN : stdCAs];
            System.assertEquals('Daily', conAssigns[0].Time_Approval_Preference__c);
            
        Test.stopTest();
    }
    
    private static testMethod void testMethod14() {
    
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'Test Project 103',AcctSeed__Status__c = 'Order', Start_Date__c = System.today().addDays(-15),End_Date__c = System.today().addDays(-10), Project_Manager__c = NULL);
        insert proj;
        
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        
        Id insRTId =Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> stdCAs = new List<Contact_Assignments__c> {
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = proj.Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = insRTId, Paper_Timesheet__c = FALSE),
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = proj.Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = insRTId, Paper_Timesheet__c = FALSE)
        };
        
        Test.startTest();
        
            insert stdCAs;
            
            List<AcctSeed__Project__c> projRec = [SELECT Id, Project_Manager__c FROM AcctSeed__Project__c WHERE Id =:proj.Id];
            projRec[0].Project_Manager__c = UserInfo.getUserId();
            update projRec;
            
        Test.stopTest();
    }
    
    private static testMethod void testMethod15(){
    
        Id testProjId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'Test Project 104',AcctSeed__Status__c = 'Order', Oral_Exam_Date_Time__c = System.today().addDays(10), Project_Manager__c = NULL, RecordTypeId = testProjId);
        insert proj;
        
        try{
        
            proj.Oral_Exam_Date_Time__c = System.Today().addDays(15);
            update proj;
            
        }catch(Exception e){
        
            Boolean isError = e.getMessage().contains('You can\'t edit this field, please update related event if you want to update the Oral Exam Date & Time') ? true : false;
            System.assertEquals(isError, True); 
        }
    }
    
    //Sending an email to accounting group
    private static testMethod void testMethod16() {
                
        List<MTT_Location__c> loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Project__c> proList = [SELECT Id, Training_Location__c FROM AcctSeed__Project__c LIMIT 1];
                
        proList[0].Training_Location__c = loc[0].Id;
        proList[0].QB_Classification__c = 'ON0LT0ARL';
        proList[0].Name = 'My New Project';
        update proList[0];
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projs = [SELECT Id, Name, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proList[0].Id];
            
            List<AcctSeed__Project_Task__c> projTasks = [SELECT Id, PC_Job_Code__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c =:proList[0].Id];
            
            String pcJobCode = projs[0].DLS_Class__c+'-'+projTasks[0].Id;
            System.assertEquals(pcJobCode, projTasks[0].PC_Job_Code__c);
            
        Test.stopTest();
    }
    
    //Sending an email to accounting group
    private static testMethod void testMethod17() {
                
        List<MTT_Location__c> loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 2];
        
        List<AcctSeed__Project__c> proList = [SELECT Id, Training_Location__c FROM AcctSeed__Project__c LIMIT 1];
                       
        proList[0].Name = 'My New Project';
        update proList[0];
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projs = [SELECT Id, Name, DLS_Class__c, Training_Location__c FROM AcctSeed__Project__c WHERE Id = :proList[0].Id];
            projs[0].Training_Location__c = loc[1].Id;
            projs[0].QB_Classification__c = 'ON0LT0ARL';
            update projs[0];
        Test.stopTest();
    }
    
    private static testMethod void testMethod18() {
    
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'Test Project 105',AcctSeed__Status__c = 'Order', Start_Date__c = System.Today(),End_Date__c = System.Today().addDays(15));
        insert proj;
        
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        
        Id insRTId =Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> insCAs = new List<Contact_Assignments__c> {
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = proj.Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = insRTId)
        };
        
        Test.startTest();
        
            insert insCAs;
            
            List<AcctSeed__Project__c> projRec = [SELECT Id, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE Id =:proj.Id];
            projRec[0].AcctSeed__Status__c = 'Order';
            update projRec;
            
        Test.stopTest();
    }
    
    private static testMethod void testMethod19() {
    
        List<MTT_Location__c> loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'Test Project 106',AcctSeed__Status__c = 'Order', Start_Date__c = System.today().addDays(-15),End_Date__c = System.today().addDays(-10));
        insert proj;
        
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        
        Id insRTId =Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        List<Contact_Assignments__c> insCAs = new List<Contact_Assignments__c> {
            new Contact_Assignments__c(Status__c = 'Draft', Candidate_Name__c = contacts[0].Id, Project__c = proj.Id, Start_Date__c = System.today().addDays(-15), End_Date__c = System.today().addDays(-10), RecordTypeId = insRTId)
        };
        
        Test.startTest();
        
            insert insCAs;
            
            List<AcctSeed__Project__c> projRec = [SELECT Id, Start_Date__c, End_Date__c, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE Id =:proj.Id];
            projRec[0].Start_Date__c = System.Today();
            projRec[0].End_Date__c = System.today().addDays(10);
            projRec[0].Training_Location__c = loc[0].Id;
            projRec[0].QB_Classification__c = 'ON0LT0ARL';
            update projRec;
            
        Test.stopTest();
    }
    
    private static testMethod void testMethod20() {
    
        List<MTT_Location__c> loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'Test Project 107',AcctSeed__Status__c = 'Order', Start_Date__c = System.today().addDays(-15),End_Date__c = System.today().addDays(-10));
        insert proj;
        
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        
        Id stdRTId =Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact_Assignments__c> insCAs = new List<Contact_Assignments__c> {
            new Contact_Assignments__c(Status__c = 'Draft', Candidate_Name__c = contacts[0].Id, Project__c = proj.Id, Start_Date__c =  System.today().addDays(-15), End_Date__c = System.today().addDays(-10), RecordTypeId = stdRTId)
        };
        
        Test.startTest();
        
            insert insCAs;
            
            List<AcctSeed__Project__c> projRec = [SELECT Id, Start_Date__c, End_Date__c, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE Id =:proj.Id];
            projRec[0].Start_Date__c = System.Today();
            projRec[0].End_Date__c = System.today().addDays(10);
            projRec[0].Training_Location__c = loc[0].Id;
            projRec[0].QB_Classification__c = 'ON0LT0ARL';
            update projRec;
            
        Test.stopTest();
    }
    
    private static testMethod void testMethod21() {
    
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'Test Project 108',AcctSeed__Status__c = 'Order', Start_Date__c = System.Today(),End_Date__c = System.Today().addDays(15));
        insert proj;
        
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        
        Id stdRTId =Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact_Assignments__c> insCAs = new List<Contact_Assignments__c> {
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = proj.Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = stdRTId)
        };
        
        Test.startTest();
        
            insert insCAs;
            
            List<AcctSeed__Project__c> projRec = [SELECT Id, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE Id =:proj.Id];
            projRec[0].AcctSeed__Status__c = 'Order';
            update projRec;
            
        Test.stopTest();
    }
    
    // Cover sendLateCancellationEmail process
    private static testMethod void testMethod22() {
    
        List<AcctSeed__Project__c> proList = [SELECT Id, Training_Location__c FROM AcctSeed__Project__c LIMIT 1];
              
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        
        Id staffRTId =Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        
        List<Contact_Assignments__c> staffCA = new List<Contact_Assignments__c> {
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = proList[0].Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = staffRTId, Assignment_Position__c = 'Project Support')
        };
        
        Test.startTest();
        
            insert staffCA;
            
            List<AcctSeed__Project__c> projRec = [SELECT Id, Late_Cancelation__c, Number_of_Hrs_Charge__c FROM AcctSeed__Project__c WHERE Id =:proList[0].Id];
            projRec[0].Late_Cancelation__c = 'Yes';
            projRec[0].Number_of_Hrs_Charge__c = 40;
            update projRec;
            
        Test.stopTest();
    }
    
    // Cover sendLateCancellationEmail process
    private static testMethod void testMethod22a() {
    
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'Test Project 109',AcctSeed__Status__c = 'Active', Start_Date__c = System.Today(),End_Date__c = System.Today().addDays(15), Late_Cancelation__c = 'Yes', Number_of_Hrs_Charge__c = 10);
        insert proj;
              
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        
        Id staffRTId =Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        
        List<Contact_Assignments__c> staffCA = new List<Contact_Assignments__c> {
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = contacts[0].Id, Project__c = proj.Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = staffRTId, Assignment_Position__c = 'Project Support')
        };
        
        Test.startTest();
        
            insert staffCA;
            
            List<AcctSeed__Project__c> projRec = [SELECT Id, Late_Cancelation__c, Number_of_Hrs_Charge__c FROM AcctSeed__Project__c WHERE Id =:proj.Id];
            projRec[0].Late_Cancelation__c = 'Yes';
            projRec[0].Number_of_Hrs_Charge__c = 40;
            update projRec;
            
        Test.stopTest();
    }
    
    // Cover sendProjectEndedMailToAccountingGroup process
    private static testMethod void sendProjectEndedMailToAccountingGroup_Test() {
    
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'Test Project 110',AcctSeed__Status__c = 'Active', Start_Date__c = System.Today(),End_Date__c = System.Today().addDays(15));
        insert proj;
              
        Contact c  = new Contact(LastName = 'My Test Contact', Email = 'hemalatha@softsquare.biz');
        insert c;
        
        Id staffRTId =Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        
        List<Contact_Assignments__c> staffCA = new List<Contact_Assignments__c> {
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c = c.Id, Project__c = proj.Id, Start_Date__c = system.today(), End_Date__c = System.today().addDays(10), RecordTypeId = staffRTId, Assignment_Position__c = 'Project Support')
        };
        
        Test.startTest();
        
            insert staffCA;
            
            List<Contact_Assignments__c> ca = [SELECT Id, Name, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE Project__c = :proj.Id];
            ca[0].Start_Date__c = Date.Today().addDays(-3);
            ca[0].End_Date__c = Date.Today().addDays(-2);
            update ca[0];
            
            List<AcctSeed__Project__c> projRec = [SELECT Id, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE Id =:proj.Id];
            projRec[0].AcctSeed__Status__c = 'Ended';
            update projRec;
            
        Test.stopTest();
    }
    
    private static testMethod void GLAV2_Population_Test() {
        
         List<AcctSeed__Accounting_Variable__c> glAccList = [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c = 'GL Account Variable 2' LIMIT 1];
                  
         List<AcctSeed__Project__c> projRecs = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 1];
         projRecs[0].GL_Variable_2__c = glAccList[0].Id;
         update projRecs[0];
         
         List<AcctSeed__Project_Task__c> projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = : projRecs[0].Id LIMIT 1];
     
    }
    
    private static testMethod void updateCongaSignTransaction_CTP_Test(){
    
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name, Email FROM Contact WHERE NAME LIKE '%Test%' LIMIT 1];
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student')
            };
                
            insert conAssignRecs;
                
            APXT_CongaSign__Transaction__c cst = new APXT_CongaSign__Transaction__c();
            cst.Parent_006__c = opp[0].Id;
            cst.APXT_CongaSign__Status__c = 'SENT';
            insert cst;
                    
            APXT_CongaSign__Recipient__c csr = new APXT_CongaSign__Recipient__c();
            csr.APXT_CongaSign__Transaction__c = cst.Id;
            csr.APXT_CongaSign__Email__c = stdCon[0].Email;
            insert csr;
            
            ConvertToProject.isFromConvertToProject = True;
            
            AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 111',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
        
        Test.stopTest();
    }
    
    private static testMethod void sendLowHoursBalanceEmail_Test1(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Scheduled_Hours_Week__c = 20, AcctSeed__Account__c = a.Id, Name = 'Test Project 112',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        System.debug('proj::::'+proj);
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Total_Qty_Paid__c = 18, Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];
            
            projTask.Total_Hours_Used_For_Language_Training__c = 15;
            update projTask;
        Test.stopTest();
    }
    
    private static testMethod void sendLowHoursBalanceEmail_Test2(){
        
        Account a = new Account(Name = 'DODA');
        insert a;
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
    
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), Project_Type__c = 'SLP-PT')
        };
        insert proItrList;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Program_Iteration__c = proItrList[0].Id, Scheduled_Hours_Week__c = 20, AcctSeed__Account__c = a.Id, Name = 'Test Project 113',AcctSeed__Status__c = 'Active',RecordTypeId = dodaRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Total_Qty_Paid__c = 18, Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
                
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
            insert conAssignRecs;
            
            List<Schedule__c> updateSchedule = [SELECT Id FROM Schedule__c WHERE Id IN : schList];
            updateSchedule[0].Status__c = 'Active';
            updateSchedule[0].Total_Hours__c = 4;
            update updateSchedule[0];
            
            projTask.Total_Hours_Used_For_Language_Training__c = 15;
            update projTask;
        Test.stopTest();
    }
}