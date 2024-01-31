@isTest
private class TestUpdateContAssignmentStatus{
    
    @testSetup static void setup(){
        
        List<AcctSeed__Accounting_Variable__c> acVar = TestClassUtil.createAccountingVariable();
        Test.StartTest();
            List<Contact_Assignments__c> conAssignlist = TestClassUtil.createTestContactAssignment();
            List<Product2> products = TestClassUtil.createTestProduct();
            TestClassUtil.createTestProjectTaskGLVariableMapping();    
            List<MTT_Location__c> locations = TestClassUtil.createTestLocations();
        Test.stopTest();
        List<AcctSeed__Time_Card_Day__c>  tcd = TestClassUtil.createTestTimeCardDay();
    }
    
    public static testMethod void testMtd1(){
        
        List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
        
        AcctSeed__Project_Task__c pT = [ SELECT Id,Name, Total_Hours__c, Total_Qty_Invoiced__c,AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Status__c FROM AcctSeed__Project_Task__c  limit 1];
        List<Contact_Assignments__c> cAs = [SELECT Id,Project_Task__c,Project__c FROM Contact_Assignments__c WHERE Project__c = :pT.AcctSeed__Project__c];
                
        pT.Total_Hours__c = 8;
        pT.Total_Qty_Invoiced__c = 8;
        
        Test.StartTest();
            if(pT != null){
            
                for(Contact_Assignments__c ca : cAs){
                
                    ca.Project__c = pT.AcctSeed__Project__c;
                    ca.Project_Task__c = pT.Id;
                    ca.End_Date__c = Date.Today().addDays(-2);
                    updateCAs.add(ca);
                }
                if(updateCAs != null){
                    update updateCAs;
                }
                
                try {
                    AcctSeed__Project__c proj = [SELECT Id, Name,AcctSeed__Status__c FROM AcctSeed__Project__c WHERE ID =:pT.AcctSeed__Project__c];
                    proj.AcctSeed__Status__c = 'Ended';
                    update proj;
                }catch(Exception e) {
                    system.debug('::::::exception::::'+e.getMessage());
                }
            }
            update pT;
        Test.StopTest();
    }   
    
    private static testMethod void testMtd2(){
        
        List<AcctSeed__GL_Account__c> glAcc = [SELECT Id FROM AcctSeed__GL_Account__c];
        
        List<Product2> products = [SELECT Id, AcctSeed__Revenue_GL_Account__c, AcctSeed__Inventory_GL_Account__c FROM Product2];
        products[0].AcctSeed__Revenue_GL_Account__c = glAcc[0].Id;
        products[0].AcctSeed__Inventory_GL_Account__c = glAcc[1].Id;
        update products[0];
        
        List<Contact> conList = [SELECT Id,Name FROM Contact LIMIT 2];
        
        List<AcctSeed__Project_Task__c> projTask1 = [SELECT Id,AcctSeed__Labor_GL_Account__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 1];
        
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
            new AcctSeed__Project_Task__c(Name = 'Bonus Leave Earned',Product__c = products[0].Id,AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = projTask1[0].AcctSeed__Project__c,Project_Task_Type__c = 'Language Training',Rate__c = 41,AcctSeed__Labor_GL_Account__c = projTask1[0].AcctSeed__Labor_GL_Account__c)
        };
        
        insert projTask;
        
        List<AcctSeed__Project_Task__c> prjTask = [SELECT Id, Revenue_GL_Account__c, Inventory_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Id = :projTask[0].Id];
        System.assertEquals(glAcc[0].Id, prjTask[0].Revenue_GL_Account__c);
    }
    
    // Populate PC_Job_Code__c field value in Project Task records
    private static testMethod void testMtd3() {
                
        List<AcctSeed__Project__c> proList = [SELECT Id, Contract__c FROM AcctSeed__Project__c LIMIT 1];
        List<Product2> products = [SELECT Id, AcctSeed__Revenue_GL_Account__c, AcctSeed__Inventory_GL_Account__c FROM Product2];
        List<Contact> conList = [SELECT Id,Name FROM Contact LIMIT 2];
        
        proList[0].Name = 'My Test Recent Project';
        update proList[0];
                
        List<AcctSeed__Project__c> projs = [SELECT Id, Name, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proList[0].Id];
        
        List<AcctSeed__Project_Task__c> projTask1 = [SELECT Id,AcctSeed__Labor_GL_Account__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 1];
        
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
            new AcctSeed__Project_Task__c(Name = 'Test Project Task',Product__c = products[0].Id,AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = projs[0].Id,Project_Task_Type__c = 'Language Training',Rate__c = 41, AcctSeed__Labor_GL_Account__c = projTask1[0].AcctSeed__Labor_GL_Account__c)
        };
        
        Test.startTest();
        
        insert projTask;
        
        List<AcctSeed__Project_Task__c> projTasks = [SELECT Id, Name, PC_Job_Code__c FROM AcctSeed__Project_Task__c WHERE Id IN :projTask];
        
        String pcJobCode = projs[0].DLS_Class__c+'-'+projTasks[0].Id;
        System.assertEquals(pcJobCode, projTasks[0].PC_Job_Code__c);
        
        Test.stopTest();
    }
    
    // Populate PC_Job_Code__c field value in Project Task records
    private static testMethod void testMtd3a() {
        
        Id dliWLTRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> proList = [SELECT Id, Contract__c FROM AcctSeed__Project__c LIMIT 1];
        List<Product2> products = [SELECT Id, AcctSeed__Revenue_GL_Account__c, AcctSeed__Inventory_GL_Account__c FROM Product2];
        List<Contact> conList = [SELECT Id,Name FROM Contact LIMIT 2];
        
        proList[0].Name = 'My DLI W LT Project';
        proList[0].RecordTypeId = dliWLTRT;
        update proList[0];
                
        List<AcctSeed__Project__c> projs = [SELECT Id, Name, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proList[0].Id];
        
        List<AcctSeed__Project_Task__c> projTask1 = [SELECT Id,AcctSeed__Labor_GL_Account__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 1];
        
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
            new AcctSeed__Project_Task__c(Name = 'Test Project Task',Product__c = products[0].Id,AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = projs[0].Id,Project_Task_Type__c = 'Language Training',Rate__c = 41, AcctSeed__Labor_GL_Account__c = projTask1[0].AcctSeed__Labor_GL_Account__c)
        };
        
        Test.startTest();
        
        insert projTask;
        
        List<AcctSeed__Project_Task__c> projTasks = [SELECT Id, Name, PC_Job_Code__c FROM AcctSeed__Project_Task__c WHERE Id IN :projTask];
        
        String pcJobCode = projs[0].DLS_Class__c+'-DLI-'+projTasks[0].Id;
        System.assertEquals(pcJobCode, projTasks[0].PC_Job_Code__c);
        
        Test.stopTest();
    }
    
    //Method to cover population of GL Variable 1 field based on the related Project's QB_Classification__c field
    private static testMethod void testMtd4() {
    
        List<AcctSeed__Accounting_Variable__c> acVar = [SELECT Id,AcctSeed__Active__c, Name FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c = 'GL Account Variable 1' LIMIT 1];
        acVar[0].AcctSeed__Active__c = TRUE;
        update acVar[0];
        
        List<Contact> conList = [SELECT Id,Name FROM Contact LIMIT 2];
        List<MTT_Location__c> loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Project_Task__c> tasks = [SELECT Id, AcctSeed__GL_Account_Variable_1__c, AcctSeed__Project__c, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 1];
        
        List<AcctSeed__Project__c> projs = [SELECT Id, QB_Classification__c,Training_Location__c FROM AcctSeed__Project__c WHERE Id = :tasks[0].AcctSeed__Project__c];
        projs[0].QB_Classification__c = acVar[0].Name;
        projs[0].Training_Location__c = loc[0].Id;
        update projs[0];
        
        List<AcctSeed__Project__c> pro = [SELECT Id, QB_Classification__c FROM AcctSeed__Project__c WHERE Id = :projs[0].Id];
        
        Test.startTest();
        
        List<Product2> products = [SELECT Id, Name FROM Product2];
        String ptName = products[0].Name;
        
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
            new AcctSeed__Project_Task__c(Name = ptName,Product__c = products[0].Id,AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = pro[0].Id,Project_Task_Type__c = 'Language Training',Rate__c = 41, AcctSeed__Labor_GL_Account__c = tasks[0].AcctSeed__Labor_GL_Account__c)
        };
        insert projTask;
        
        List<AcctSeed__Project_Task__c> taskRecs = [SELECT Id, AcctSeed__GL_Account_Variable_1__c FROM AcctSeed__Project_Task__c WHERE Id = :projTask[0].Id];
        System.assertEquals(acVar[0].Id, taskRecs[0].AcctSeed__GL_Account_Variable_1__c);
        
        Test.stopTest();
    }
    
    private static testMethod void testMtd5() {
    
        Test.startTest();
        
            List<AcctSeed__Project_Task__c> tasks = [SELECT Id, Total_Hours_Used_For_Language_Training__c FROM AcctSeed__Project_Task__c LIMIT 1];
            tasks[0].Total_Hours_Used_For_Language_Training__c = 8;
            update tasks[0];
            
        Test.stopTest();
    }
    
    private static testMethod void testMtd6() {
    
        Id langTrainRTId = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();  
        
        Account a = new Account(Name = 'PVT');
        insert a;
        
        List<AcctSeed__Project_Task__c> tasks = [SELECT Id, RecordTypeId, AcctSeed__Project__c, Total_Qty_Planned__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c='Language Training' LIMIT 1];
        tasks[0].RecordTypeId = langTrainRTId;
        tasks[0].Total_Qty_Planned__c = 250;
        update tasks[0];
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :tasks[0].AcctSeed__Project__c];
            projs[0].AcctSeed__Account__c = a.Id;
            update projs[0];
            
            Date reportDate = Date.Today()+7;
            
            List<Contact> conList = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
            
            List<Assessment_Report__c> reports = new List<Assessment_Report__c>{
                new Assessment_Report__c(Name = 'My Test Report1', Report_Date__c = reportDate, Project__c=projs[0].Id, Instructor__c = conList[0].Id, Status__c = 'Scheduled',Language__c = 'Tamil'),
                new Assessment_Report__c(Name = 'My Test Report2', Report_Date__c = reportDate, Project__c=projs[0].Id, Instructor__c = conList[0].Id, Status__c = 'Scheduled',Language__c = 'English')
            };
            insert reports;
            
            List<AcctSeed__Project_Task__c> updateProjTasks = [SELECT Id, Total_Qty_Planned__c FROM AcctSeed__Project_Task__c WHERE Id = :tasks[0].Id];
            updateProjTasks[0].Total_Qty_Planned__c = 350;
            update updateProjTasks[0];
            
        Test.stopTest();        
    }
    
    private static testMethod void testMtd6a() {
    
        Id langTrainRTId = Schema.SObjectType.AcctSeed__Project_Task__c.getRecordTypeInfosByDeveloperName().get('Language_Training').getRecordTypeId();  
        
        Account a = new Account(Name = 'FAS');
        insert a;
        
        List<AcctSeed__Project_Task__c> tasks = [SELECT Id, RecordTypeId, AcctSeed__Project__c, Total_Qty_Planned__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c='Language Training' LIMIT 1];
        tasks[0].RecordTypeId = langTrainRTId;
        tasks[0].Total_Qty_Planned__c = 250;
        update tasks[0];
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :tasks[0].AcctSeed__Project__c];
            projs[0].AcctSeed__Account__c = a.Id;
            update projs[0];
            
            Date reportDate = Date.Today()+7;
            
            List<Contact> conList = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
            
            List<Assessment_Report__c> reports = new List<Assessment_Report__c>{
                new Assessment_Report__c(Name = 'My Test Report1', Report_Date__c = reportDate, Project__c=projs[0].Id, Instructor__c = conList[0].Id, Status__c = 'Scheduled',Language__c = 'Tamil'),
                new Assessment_Report__c(Name = 'My Test Report2', Report_Date__c = reportDate, Project__c=projs[0].Id, Instructor__c = conList[0].Id, Status__c = 'Scheduled',Language__c = 'English')
            };
            insert reports;
            
            List<AcctSeed__Project_Task__c> updateProjTasks = [SELECT Id, Total_Qty_Planned__c FROM AcctSeed__Project_Task__c WHERE Id = :tasks[0].Id];
            updateProjTasks[0].Total_Qty_Planned__c = 350;
            update updateProjTasks[0];
        
            List<Assessment_Report__c> reportRecs = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Id IN :reports];
            //System.assertEquals('Canceled', reportRecs[0].Status__c);
        
        Test.stopTest();              
    }
    
    private static testMethod void myTest1(){
        Account a = new Account(Name = 'PVT');
        insert a;
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 2];
        
        List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c, QB_Contract_Type__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName='Language_Training_Projects'];
        projRecs[0].AcctSeed__Account__c = a.Id;
        projRecs[0].QB_Contract_Type__c = 'COMM:INDV';
        update projRecs[0];
        
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
            new AcctSeed__Project_Task__c(Name = 'Test Task-Tamil',AcctSeed__Project__c=projRecs[0].Id,Project_Task_Type__c='Language Training',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=41),
                new AcctSeed__Project_Task__c(Name = 'Test Task-English',AcctSeed__Project__c=projRecs[0].Id,Project_Task_Type__c='Language Testing',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=40)
                };
                    insert projTask;
        
        AcctSeed__Project_Task__c projTas = [SELECT Id, AcctSeed__GL_Account_Variable_2__r.Name FROM AcctSeed__Project_Task__c WHERE ID = :projTask[0].Id LIMIT 1];
        System.assertEquals('LT - PVT', projTas.AcctSeed__GL_Account_Variable_2__r.Name);
    }
    
    private static testMethod void myTest2(){
        List<Account> a = new List<Account>{
            new Account(Name = 'DLI-W - CD'),
            new Account(Name = 'PVT')
        };
        insert a;
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 2];
        
        List<MTT_Location__c> loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c, QB_Classification__c,Training_Location__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName='Language_Training_Projects'];        
        projRecs[0].AcctSeed__Account__c = a[1].Id;
        projRecs[0].RecordTypeId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('CD_Projects').getRecordTypeId();
        update projRecs[0];
        
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
            new AcctSeed__Project_Task__c(Name = 'Test Task-Tamil',AcctSeed__Project__c=projRecs[0].Id,Project_Task_Type__c='Language Training',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=41),
                new AcctSeed__Project_Task__c(Name = 'Test Task-English',AcctSeed__Project__c=projRecs[0].Id,Project_Task_Type__c='Language Testing',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=40)
                };
                    insert projTask;
        
        AcctSeed__Project_Task__c projTas = [SELECT Id, AcctSeed__GL_Account_Variable_2__r.Name FROM AcctSeed__Project_Task__c WHERE ID = :projTask[0].Id LIMIT 1];
        System.assertEquals('CD', projTas.AcctSeed__GL_Account_Variable_2__r.Name);
                    
        projRecs[0].AcctSeed__Account__c = a[0].Id;
        projRecs[0].QB_Classification__c = 'CD0DLI';  
        projRecs[0].Training_Location__c = loc[0].Id;      
        update projRecs[0];
        
        projTas = [SELECT Id, AcctSeed__GL_Account_Variable_2__r.Name FROM AcctSeed__Project_Task__c WHERE ID = :projTask[0].Id LIMIT 1];
        System.assertEquals('CD - DLI-W', projTas.AcctSeed__GL_Account_Variable_2__r.Name);
        
        
        
        
    }
    
    private static testMethod void myTest3(){
        Account a = new Account(Name = 'DLI-W');
        insert a;
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 2];
        
        List<MTT_Location__c> loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c, QB_Classification__c, Training_Location__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName='Language_Training_Projects'];
        projRecs[0].AcctSeed__Account__c = a.Id;
        projRecs[0].QB_Classification__c = 'CD0DLI';
        projRecs[0].Training_Location__c = loc[0].Id;
        projRecs[0].RecordTypeId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('CD_Projects').getRecordTypeId();
        update projRecs[0];
        
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
            new AcctSeed__Project_Task__c(Name = 'Test Task-Tamil',AcctSeed__Project__c=projRecs[0].Id,Project_Task_Type__c='Language Training',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=41),
            new AcctSeed__Project_Task__c(Name = 'Test Task-English',AcctSeed__Project__c=projRecs[0].Id,Project_Task_Type__c='Language Testing',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=40)
        };
        insert projTask;
        
        AcctSeed__Project_Task__c projTas = [SELECT Id, AcctSeed__GL_Account_Variable_2__r.Name FROM AcctSeed__Project_Task__c WHERE ID = :projTask[0].Id LIMIT 1];
        System.assertEquals('CD', projTas.AcctSeed__GL_Account_Variable_2__r.Name);
    }
    
    private static testMethod void myTest4(){
        Account a = new Account(Name = 'DODA');
        insert a;
        
        List<MTT_Location__c> loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 2];
        
        List<AcctSeed__Project__c> projRecs = [SELECT Id, AcctSeed__Account__c, QB_Classification__c, Training_Location__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName='Language_Training_Projects'];
        projRecs[0].AcctSeed__Account__c = a.Id;
        projRecs[0].QB_Classification__c = 'CD0DLI';
        projRecs[0].Training_Location__c = loc[0].Id;
        projRecs[0].RecordTypeId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
        update projRecs[0];
        
        List<AcctSeed__Project_Task__c> projTask = new List<AcctSeed__Project_Task__c> {
            new AcctSeed__Project_Task__c(Name = 'Test Task-Tamil',AcctSeed__Project__c=projRecs[0].Id,Project_Task_Type__c='Language Training',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=41),
            new AcctSeed__Project_Task__c(Name = 'Test Task-English',AcctSeed__Project__c=projRecs[0].Id,Project_Task_Type__c='Language Testing',AcctSeed__Labor_GL_Account__c=glAccList[0].Id,Rate__c=40)
        };
        insert projTask;
        
        AcctSeed__Project_Task__c projTas = [SELECT Id, AcctSeed__GL_Account_Variable_2__c, AcctSeed__GL_Account_Variable_2__r.Name FROM AcctSeed__Project_Task__c WHERE ID = :projTask[0].Id LIMIT 1];
        System.assertEquals('LT - DODA', projTas.AcctSeed__GL_Account_Variable_2__r.Name);
        
        AcctSeed__Project__c projRec = [SELECT Id, GL_Variable_2__c FROM AcctSeed__Project__c WHERE Id = :projRecs[0].Id];
        System.assertEquals(projTas.AcctSeed__GL_Account_Variable_2__c, projRec.GL_Variable_2__c);
        
        AcctSeed__Accounting_Variable__c glv2 = [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE Name != :projTas.AcctSeed__GL_Account_Variable_2__c AND AcctSeed__Type__c = 'GL Account Variable 2' AND AcctSeed__Active__c = TRUE LIMIT 1];
        projTas.AcctSeed__GL_Account_Variable_2__c = glv2.Id;
        update projTas;
        
        projRec = [SELECT Id, GL_Variable_2__c FROM AcctSeed__Project__c WHERE Id = :projRecs[0].Id];
        //System.assertEquals(glv2.Id, projRec.GL_Variable_2__c);
    }
    
    private static testMethod void lTWith_withoutPrepEmailAlert_Test1(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED, Default_Cost_Rate_Rate_Type__c = 'LT without Prep');
        insert proj;
        
        Test.startTest();
         
            AcctSeed__Project_Task__c projTask1 = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask1;
        
            AcctSeed__Project_Task__c projTask2 = new AcctSeed__Project_Task__c(Name = 'Language Training- Preparation', Parent_Project_Task__c = projTask1.Id, AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Preparation time', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask2;
        Test.StopTest();
    }
    
    private static testMethod void lTWith_withoutPrepEmailAlert_Test2(){
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED, Default_Cost_Rate_Rate_Type__c = 'LT with Prep');
        insert proj;
        
        Test.startTest();
         
            AcctSeed__Project_Task__c projTask1 = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask1;
        
            AcctSeed__Project_Task__c projTask2 = new AcctSeed__Project_Task__c(Name = 'Language Training- Preparation', Parent_Project_Task__c = projTask1.Id, AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Preparation time', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask2;
            
            delete projTask2;
        Test.StopTest();
    }
    
    private static testMethod void populateGLAV2InTCDs_Test(){
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];

        Test.startTest();
        
            List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
            
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
            update timeCard;
                
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
           
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
            
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
            insert day;
        
            AcctSeed__Accounting_Variable__c glv2 = [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c = 'GL Account Variable 2' AND AcctSeed__Active__c = TRUE LIMIT 1];
            task[0].AcctSeed__GL_Account_Variable_2__c = glv2.Id;
            update task[0];
            
        Test.stopTest();
        
        List<AcctSeed__Time_Card_Day__c> dayRec = [SELECT Id, GL_Variable_2__c FROM AcctSeed__Time_Card_Day__c WHERE Id = :day.Id];
        Assert.areEqual(dayRec[0].GL_Variable_2__c, glv2.Id);
    }
}