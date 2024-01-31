/*
Cannot use test Class util since it refers the Accounting Setting Value's
*/
 
@isTest(SeeAllData=True)

Public Class ConvertToProject_Test{
    
    // For returning back to the Opportunity
    private static testMethod void testMethod1() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity'});
        Test.StopTest();  
      
        if(oppList.size() > 0) {
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
            
            ConvertToProject cTP = new ConvertToProject(sc);
            
            pageReference pgRef = cTP.toOpportunity();
            
            if(pgRef != null) {
                String pageRef = String.valueOf(pgRef);
                String oppId = oppList[0].Id; 
                System.assert(pageRef.contains(oppId.substring(0,oppId.length()-3)));
            }
        }       
    } 
    
    private static testMethod void testMethod1a() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity'});
        Test.StopTest();  
      
        if(oppList.size() > 0) {
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[2]);
            
            ConvertToProject cTP = new ConvertToProject(sc);
            
            pageReference pgRef = cTP.toOpportunity();
            
            if(pgRef != null) {
                String pageRef = String.valueOf(pgRef);
                String oppId = oppList[2].Id; 
                System.assert(pageRef.contains(oppId.substring(0,oppId.length()-3)));
            }
        }       
    }
    
    // Opportunity to Project Conversion with product
    private static testMethod void testMethod2() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Contact Assignment'});
        Test.StopTest();  
        
        if(oppList.size() > 0) {
            
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
            
            ConvertToProject cTP = new ConvertToProject(sc);
                                               
            for(integer i=0;i<cTP.scheduleList.size();i++){
                cTP.scheduleList[i].productNameAsProjectTask = 'Language Training- Afrikaans';
            }
            
            for(integer i=0;i<cTP.projectTaskInnserClassList.size();i++){
                cTP.projectTaskInnserClassList[i].projTask.Project_Task_Type__c = 'Language Training';
            }        
            
            cTP.projectExist = true;
            cTP.oldProjectId = '';  
            
            cTP.createProjectAndProjectTask(); 
            
            List<AcctSeed__Project__c> proUp = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppList[0].Id];
            if(proUp.size() > 0)
                System.assertEquals(1, proUp.size());  
       }     
    } 
    
    private static testMethod void testMethodForProduct() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Contact Assignment'});
        Test.StopTest();  
        
        if(oppList.size() > 0) {
            
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
            
            ConvertToProject cTP = new ConvertToProject(sc);
                                               
            for(integer i=0;i<cTP.scheduleList.size();i++){
                cTP.scheduleList[i].productNameAsProjectTask = 'Language Training- Afrikaans';
            }
            
            for(integer i=0;i<cTP.projectTaskInnserClassList.size();i++){
                cTP.projectTaskInnserClassList[i].projTask.Project_Task_Type__c = 'ELC Language Training';
            }        
            
            cTP.projectExist = true;
            cTP.oldProjectId = '';  
            
            cTP.createProjectAndProjectTask(); 
            
            List<AcctSeed__Project__c> proUp = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppList[0].Id];
            if(proUp.size() > 0)
                System.assertEquals(1, proUp.size());  
       }     
    }
    
    // Opportunity to Project Conversion with product
    private static testMethod void testMethod2a() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Contact Assignment'}); 
        Test.StopTest();  

        List<Product2> prodList = [SELECT Id, Name FROM Product2 WHERE Name = 'Language Training- Preparation'];
        

        if(oppList.size() > 0 && prodList.size() > 0) {
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
            
            ConvertToProject cTP = new ConvertToProject(sc);
            
            for(integer i=0;i<cTP.instructorCAList.size();i++){
                cTP.instructorCAList[i].productNameAsProjectTask = 'Interpretation (per hr)';
            }
           
            for(integer i=0;i<cTP.projectTaskInnserClassList.size();i++){
                cTP.projectTaskInnserClassList[i].projTask.Project_Task_Type__c = 'Interpretation (per hr)';
                cTP.projectTaskInnserClassList[i].productNameAsProjectTask = 'Test';
            }  
            
            List<Schedule__c> sch = [SELECT Id, Name FROM Schedule__c LIMIT 1];
            if(sch.size() > 0) {
                ConvertToProject.ScheduleUpdateInnerClass schCls = new ConvertToProject.ScheduleUpdateInnerClass(sch[0], prodList[0].Name);
                
                cTP.createProjectAndProjectTask();
                List<AcctSeed__Project__c> proUp = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppList[0].Id];
                if(proUp.size() > 0)
                    System.assertEquals(1, proUp.size());
            }
        }   
    } 
    
    // Opportunity to Project Conversion with product
    private static testMethod void testMethod2b() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Contact Assignment'}); //'Contact Assignment', 
        Test.StopTest();  
        
        if(oppList.size() > 0) {
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
            
            ConvertToProject cTP = new ConvertToProject(sc);
            
            for(integer i=0;i<cTP.PaymentLineList.size();i++){
                cTP.PaymentLineList[i].productNameAsProjectTask = 'RT';
            }
            
            for(integer i=0;i<cTP.projectTaskInnserClassList.size();i++){
                cTP.projectTaskInnserClassList[i].projTask.Project_Task_Type__c = 'Accommodations';
            }  
               
            cTP.createProjectAndProjectTask();
            List<AcctSeed__Project__c> proUp = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppList[0].Id];
            if(proUp.size() > 0)
                System.assertEquals(1, proUp.size());
        }  
    } 
    
    // Opportunity to Project Conversion with product
    private static testMethod void testMethod2c() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Contact Assignment'}); //'Contact Assignment', 
        Test.StopTest();  

        List<RecordType> rTypeList = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'MTT_Opportunities'];
        
        if(oppList.size() > 0 && rTypeList.size() > 0) {
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
            
            List<Events__c> eveList = [SELECT Id, Name FROM Events__c WHERE Schedule__r.Opportunity__c = :oppList[0].Id];
            if(eveList.size() > 0) {
                delete eveList;
            }
            
            oppList[0].RecordTypeId = rTypeList[0].Id;
            oppList[0].Project_Type__c = 'MTT';
            oppList[0].To__c = '101';
            update oppList;
            
            ConvertToProject cTP = new ConvertToProject(sc);
            
            for(integer i=0;i<cTP.projectTaskInnserClassList.size();i++){
                cTP.projectTaskInnserClassList[i].projTask.Project_Task_Type__c = 'ADMINISTRATIVE';
            }  
            cTP.newProject.To__c = '102';
            
            cTP.createProjectAndProjectTask();
            List<AcctSeed__Project__c> proUp = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppList[0].Id];
            if(proUp.size() > 0)
                System.assertEquals(1, proUp.size());
        }
    }
    
    // DODA LMS Creation
    private static testMethod void testMethod2cc() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Contact Assignment'}); //'Contact Assignment', 
        Test.StopTest();  

        List<RecordType> rTypeList = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'ODNI_CLP_Opportunities'];
        
        if(oppList.size() > 0 && rTypeList.size() > 0) {
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
            
            oppList[0].RecordTypeId = rTypeList[0].Id;
            oppList[0].Project_Type__c = 'SLP-FT';
            update oppList;
            
            ConvertToProject cTP = new ConvertToProject(sc);
            
            for(integer i=0;i<cTP.projectTaskInnserClassList.size();i++){
                cTP.projectTaskInnserClassList[i].projTask.Project_Task_Type__c = 'ADMINISTRATIVE';
            }  
            cTP.newProject.To__c = '102';
            
            cTP.createProjectAndProjectTask();
            List<AcctSeed__Project__c> proUp = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppList[0].Id];
            if(proUp.size() > 0)
                System.assertEquals(1, proUp.size());
        }
    }
    
    //To get instructor Conflict
    private static testMethod void testMethod2d() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Contact Assignment'}); //'Contact Assignment',
        Test.StopTest();  
        
        List<System_Values__c> sv = [SELECT Id,Name, Value__c FROM System_Values__c WHERE Name = 'MR - Account Id Set'];
        if(sv.size() > 0) {
            sv[0].Value__c = oppList[0].accountId;
            update sv;
        }
            
        if(oppList.size() > 0) {
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
            ConvertToProject cTP = new ConvertToProject(sc);
                        
            List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Name = 'Test Contact - 1'];
            List<Schedule__c> schList = [SELECT Id, Name FROM Schedule__c WHERE Opportunity__r.Name = 'Test Opp - 1']; 
            
            if(schList.size() > 0 && conList.size() > 0) {
                List<ConvertToProject.InstructorConflicts> Insconflict = ConvertToProject.getInstructorConflicts(conList[0].Id,schList[0].Id);
                if(Insconflict.size() > 0) {
                    String conflictIns = string.valueOf(Insconflict);
                    System.assert(conflictIns.contains('Planned Day Off'));
                }
            }
        }
    } 
    
    // Opportunity to Project Conversion with product
    private static testMethod void testMethod3() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Material Request'}); //'Contact Assignment', 
        Test.StopTest();  
        
        if(oppList.size() > 0) {
            
            List<System_Values__c> sv = [SELECT Id,Name, Value__c FROM System_Values__c WHERE Name = 'MR - Account Id Set'];
            if(sv.size() > 0) {
                sv[0].Value__c = oppList[0].accountId;
                update sv;
            }
         
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
            
            ConvertToProject cTP = new ConvertToProject(sc);
             
            cTP.createProjectAndProjectTask();
            List<AcctSeed__Project__c> proUp = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppList[0].Id];
            if(proUp.size() > 0)
                System.assertEquals(1, proUp.size());
        }   
    } 
    
    // Opportunity to Project Conversion with product
    private static testMethod void testMethod4() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Language Testing'}); //'Contact Assignment', 
        Test.StopTest();  
        
        if(oppList.size() > 0) {
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
            
            ConvertToProject cTP = new ConvertToProject(sc);
              
            cTP.createProjectAndProjectTask();
            List<AcctSeed__Project__c> proUp = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppList[0].Id];
            if(proUp.size() > 0)
                System.assertEquals(1, proUp.size());
        }  
    } 
    
    // Opportunity to Project Conversion with product
    private static testMethod void testMethod5() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Get Feedback', 'Payment'}); //'Contact Assignment', 
        Test.StopTest();  
        
        if(oppList.size() > 0) {
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
            
            ConvertToProject cTP = new ConvertToProject(sc);
             
            cTP.createProjectAndProjectTask();
            List<AcctSeed__Project__c> proUp = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppList[0].Id];
            if(proUp.size() > 0)
                System.assertEquals(1, proUp.size());
        }
    } 
    
    // Opportunity to Project Conversion with product
    private static testMethod void testMethod6() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        List<RecordType> rType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'DLI_W_TO_Opportunities'];
        List<Product2> prodList = [SELECT Id, Name FROM Product2 WHERE Name = 'Language Training- Preparation'];
        Test.StopTest();  
        
        if(oppList.size() > 0 && rType.size() > 0 && prodList.size() > 0) {
            
            oppList[0].RecordTypeId = rType[0].Id;
            oppList[0].Project_Type__c = 'HUB';
            update oppList;
            
            prodList[0].Name = 'Test Pro2';
            update prodList;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
            ConvertToProject cTP = new ConvertToProject(sc);
              
            cTP.createProjectAndProjectTask();            
            List<AcctSeed__Project__c> proUp = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppList[0].Id];
            if(proUp.size() > 0)
                System.assertEquals(1, proUp.size());
        }
    } 
    
    // Opportunity is already converted as Project
    private static testMethod void testMethod7() {
        
        String proRt, oppRt;
        for(RecordType rt : [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType IN ('Opportunity', 'AcctSeed__Project__c') AND DeveloperName IN ('New_Classes_Opportunities', 'DLI_W_LT_Projects')]) {
            if(rt.SobjectType == 'Opportunity')
                oppRt = rt.Id;
            else
                proRt = rt.Id;
        }
        
        if(oppRt != null && oppRt != '' && proRt != null && proRt != '') {
            
            List<Account> accList = new List<Account> {
                new Account(Name = 'TestAccount')
            };
            insert accList;
            
            List<Opportunity> oppList = new List<Opportunity> { 
                new Opportunity(AccountId=accList[0].Id, Name='Test Opp', Language__c='Malaysian', CloseDate=System.Today(), StageName='Active', Start_Date__c = System.today().addDays(-2),End_Date__c = System.today().addDays(10), RecordTypeId = oppRt)
            };
            Insert oppList;  
            
            List<AcctSeed__Project__c> proList = new List<AcctSeed__Project__c> {
                new AcctSeed__Project__c(Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = proRt, AcctSeed__Opportunity__c = OppList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10))
            };
            insert proList;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
        
            ConvertToProject ctp = new ConvertToProject(sc);
            System.assertEquals(true, ctp.projectExist);
        }     
    }
    
    // Opportunity to Project Conversion without product, Contract and Order
    private static testMethod void testMethod8() {
        
        List<RecordType> oppRt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'DLI_W_TO_Opportunities'];
        
        if(oppRt.size() > 0) {
            
            List<Account> accList = new List<Account> {
                new Account(Name = 'TestAccount')
            };
            insert accList;
            
            List<Opportunity> oppList = new List<Opportunity> { 
                new Opportunity(AccountId=accList[0].Id, Name='Test Opp', QB_Contract_Type__c = 'FED:GSA', Language__c='Malaysian', CloseDate=System.Today(), StageName='Active', Start_Date__c = System.today().addDays(-2),End_Date__c = System.today().addDays(10), RecordTypeId = oppRt[0].Id)
            };
            Insert oppList;  
            
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
        
            ConvertToProject ctp = new ConvertToProject(sc);
            if(ctp != null)
                System.assert(ctp.MsgForProductNotExist.contains('QB Contract type, Order #'));
        }  
    } 
    
    // Opportunity to Project Conversion without product
    private static testMethod void testMethod9() {
        
        String oppRt;
        String contrRt;
        String contrModiRt;
      
        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Contract', 'Contract_Modification__c') AND DeveloperName IN ('New_Classes_Opportunities', 'Federal_Client', 'Task_Order')]) {
            if(rt.DeveloperName == 'New_Classes_Opportunities') oppRt = rt.Id;
            if(rt.DeveloperName == 'Federal_Client') contrRt = rt.Id;
            if(rt.DeveloperName == 'Task_Order') contrModiRt = rt.Id;
        }
        
        if(oppRt != null && oppRt != '' &&contrRt != null && contrRt != '' && contrModiRt != null && contrModiRt != '') {
            
            List<Account> accList = new List<Account> {
                new Account(Name = 'TestAccount')
            };
            insert accList;
            
            List<Contract> contractList = new List<Contract> {    
                new Contract(RecordTypeId = contrRt,AccountId = accList[0].Id, Status = 'Completed Draft',StartDate = system.today()) //,Primary_POC__c = contactList[0].Id
            };
            Insert contractList;
            
            List<Opportunity> oppList = new List<Opportunity> { 
                new Opportunity(AccountId=accList[0].Id, Name='Test Opp', Language__c='Malaysian', CloseDate=System.Today(), StageName='Active', Start_Date__c = System.today().addDays(-2),End_Date__c = System.today().addDays(10), RecordTypeId = oppRt, Order__c = 'Test Order', ContractId = contractList[0].Id)
            };
            Insert oppList;  
            
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
        
            ConvertToProject ctp = new ConvertToProject(sc);
            if(ctp != null)
                System.assert(ctp.MsgForProductNotExist.contains('Product'));
        }    
    } 
    
    // Opportunity to Project Conversion without product and Contract
    private static testMethod void testMethod10() {
        
        List<RecordType> oppRt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'DLI_W_TO_Opportunities'];
        
        if(oppRt.size() > 0) {
            
            List<Account> accList = new List<Account> {
                new Account(Name = 'TestAccount')
            };
            insert accList;
            
            List<Opportunity> oppList = new List<Opportunity> { 
                new Opportunity(AccountId=accList[0].Id, Name='Test Opp', QB_Contract_Type__c = 'FED:GSA', Language__c='Malaysian', CloseDate=System.Today(), StageName='Active', Start_Date__c = System.today().addDays(-2),End_Date__c = System.today().addDays(10), RecordTypeId = oppRt[0].Id, Order__c = 'Test Order')
            };
            Insert oppList;  
            
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
        
            ConvertToProject ctp = new ConvertToProject(sc);
            if(ctp != null)
                System.assert(ctp.MsgForProductNotExist.contains('Product'));
        }      
    }
    
    // Opportunity to Project Conversion without product and Order
    private static testMethod void testMethod11() {
        
        String oppRt;
        String contrRt;
        String contrModiRt;
      
        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Contract') AND DeveloperName IN ('New_Classes_Opportunities', 'Federal_Client')]) {
            if(rt.DeveloperName == 'New_Classes_Opportunities') oppRt = rt.Id;
            if(rt.DeveloperName == 'Federal_Client') contrRt = rt.Id;
        }
        
        if(oppRt != null && oppRt != '' &&contrRt != null && contrRt != '' && contrModiRt != null && contrModiRt != '') {
            
            List<Account> accList = new List<Account> {
                new Account(Name = 'TestAccount')
            };
            insert accList;
            
            List<Contract> contractList = new List<Contract> {    
                new Contract(RecordTypeId = contrRt,AccountId = accList[0].Id, Status = 'Completed Draft',StartDate = system.today()) //,Primary_POC__c = contactList[0].Id
            };
            Insert contractList;
           
            List<Opportunity> oppList = new List<Opportunity> { 
                new Opportunity(AccountId=accList[0].Id, Name='Test Opp', Language__c='Malaysian', CloseDate=System.Today(), StageName='Active', Start_Date__c = System.today().addDays(-2), QB_Contract_Type__c = 'FED:GSA', End_Date__c = System.today().addDays(10), RecordTypeId = oppRt, ContractId = contractList[0].Id)
            };
            Insert oppList;  
            
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
        
            ConvertToProject ctp = new ConvertToProject(sc);
            if(ctp != null)
                System.assert(ctp.MsgForProductNotExist.contains('Order #'));
        }      
    } 
    
    // For updating the Planned days off Records
    private static testMethod void testMethod12() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Time Log', 'Payment', 'Material Request', 'Language Testing'}); //'Contact Assignment',
        Test.StopTest(); 
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Planned_Days_Off__c') AND DeveloperName IN ('DLI_W_TO_Opportunities', 'Project_Planned_Days_Off')];
        List<Product2> prodList = [SELECT Id, Name FROM Product2 WHERE Name = 'Language Training- Preparation'];
        
        
        if(oppList.size() > 0 && rType.size() > 0 && prodList.size() > 0) {
            
            String oppRt, planRt;
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'DLI_W_TO_Opportunities') oppRt = rt.Id;
                if(rt.DeveloperName == 'Project_Planned_Days_Off') planRt = rt.Id;
            }
          
            oppList[0].RecordTypeId = oppRt;
            oppList[0].Project_Type__c = 'AFPAK'; 
            update oppList;
           
            List<Planned_Days_Off__c> pdoList = [SELECT Id, Name FROM Planned_Days_Off__c LIMIT 1];
            
            if(pdoList.size() > 0) {
                
                pdoList[0].RecordTypeId = planRt;
                pdoList[0].Opportunity__c = oppList[0].Id;
                pdoList[0].Project__c = null;
                update pdoList;
                    
                ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]);
                
                List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Name = 'Test Contact - 1'];
                List<Schedule__c> schList = [SELECT Id, Name FROM Schedule__c LIMIT 1]; 
                               
                if(schList.size() > 0 && conList.size() > 0) {
                    schList[0].Opportunity__c = oppList[0].Id;
                    update schList;
                }
                
                ConvertToProject cTP = new ConvertToProject(sc);
                
                for(integer i=0;i<cTP.scheduleList.size();i++){
                    cTP.scheduleList[i].productNameAsProjectTask = 'Language Training- Afrikaans';
                }
                
                for(integer i=0;i<cTP.projectTaskInnserClassList.size();i++){
                    cTP.projectTaskInnserClassList[i].projTask.Project_Task_Type__c = 'Language Training';
                    cTP.projectTaskInnserClassList[i].productNameAsProjectTask = 'Test';
                } 
            
                cTP.createProjectAndProjectTask();            
                List<AcctSeed__Project__c> proUp = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppList[0].Id];
                if(proUp.size() > 0)
                    System.assertEquals(1, proUp.size());
                
                cTp.toOpportunity();
            }
        }    
    } 
    
    private static testMethod void testMethodForTransInterOpp() {
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Contact Assignment'}); //'Contact Assignment', 
        Test.StopTest();  
        
        if(oppList.size() > 0) {
            
            ApexPages.StandardController sc = new ApexPages.StandardController(oppList[1]);
            
            ConvertToProject cTP = new ConvertToProject(sc);
            
            for(integer i=0;i<cTP.PaymentLineList.size();i++){
                cTP.PaymentLineList[i].productNameAsProjectTask = 'RT';
            }
            
            for(integer i=0;i<cTP.projectTaskInnserClassList.size();i++){
                cTP.projectTaskInnserClassList[i].projTask.Project_Task_Type__c = 'Accommodations';
            }  
               
            cTP.createProjectAndProjectTask();
            List<AcctSeed__Project__c> proUp = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :oppList[0].Id];
            if(proUp.size() > 0)
                System.assertEquals(1, proUp.size());
        }  
    } 
    
    // To insert objects based on parameter
    private static List<opportunity> objInsertMethod(Set<String> insertObjSet) {
        String studRT;
        String InstRT;
        String oppRT;
        String staffRT;
        String interOppRT;
        String dliOppRT;
       
        Account acc = new Account(Name='Test Account 1');
        Insert acc;
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=acc.Id,LastName='Test Contact - 1')            
        };
        Insert contactList;
        
        for(RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType IN ('Contact_Assignments__c', 'Opportunity') AND DeveloperName IN ('DLI_W_TO_Opportunities', 'Interpretation_Opportunities', 'CD_Opportunities', 'Student', 'Instructor', 'Staff')]){
            if(rt.DeveloperName == 'Student') studRT = rt.Id;
            if(rt.DeveloperName == 'Instructor') InstRT = rt.Id;
            if(rt.DeveloperName == 'Staff') staffRT = rt.Id;
            if(rt.DeveloperName == 'CD_Opportunities') oppRT = rt.Id; 
            if(rt.DeveloperName == 'Interpretation_Opportunities') interOppRT = rt.Id; //Interpretation_Opportunities
            if(rt.DeveloperName == 'DLI_W_TO_Opportunities') dliOppRT = rt.Id; 
        }
        
        List<Opportunity> oppList = new List<Opportunity>();
        if(insertObjSet.contains('Opportunity')) {    
            oppList = new List<Opportunity> {
                new Opportunity(AccountId=acc.Id,Name='Test Opp - 1', Language__c='Malaysian', CloseDate=System.Today(),StageName='Active',Start_Date__c = system.today(),End_Date__c = system.today().addDays(10),RecordTypeId = oppRT),
                new Opportunity(AccountId=acc.Id,Name='Test Opp - 2', Language__c='Malaysian', CloseDate=System.Today(),StageName='Active',Start_Date__c = system.today(),End_Date__c = system.today().addDays(10),RecordTypeId = interOppRT),
                new Opportunity(AccountId=acc.Id,Name='Test Opp - 3', Language__c='Malaysian', CloseDate=System.Today(),StageName='Active',Start_Date__c = system.today(),End_Date__c = system.today().addDays(10),RecordTypeId = oppRT),
                new Opportunity(AccountId=acc.Id,Name='Test Opp - 4', Language__c='Malaysian', CloseDate=System.Today(),StageName='Active',Start_Date__c = system.today(),End_Date__c = system.today().addDays(10),RecordTypeId = dliOppRT, Project_Type__c = 'Resident LT')
            };
            Insert oppList;  
            System.debug('oppList==========='+oppList);
            List<Product2> proList = new List<Product2> {
                new Product2(Name = 'Language Training- Afrikaans', Description = 'Test Desc', productCode = 'Test Code', isActive = TRUE),
                new Product2(Name = 'Test Product2', Description = 'Test Desc2', productCode = 'Test Code2', isActive = TRUE),
                new Product2(Name = 'Language Training- Preparation', Family = 'Language Training', Description = 'Lang Product', productCode = 'Lang Code', isActive = TRUE),
                new Product2(Name = 'Language Training- Preparation', Family = 'Translation', Description = 'Lang Product', productCode = 'Lang Code', isActive = TRUE, Unit_Type__c = 'Hrs'),
                new Product2(Name = 'Language Training- Preparation', Family = 'Language Training', Description = 'Lang Product', productCode = 'Lang Code', isActive = TRUE, Unit_Type__c = 'Hrs'),
                new Product2(Name = 'Language Training- Preparation', Family = 'Language Training', Description = 'Lang Product', productCode = 'Lang Code', isActive = TRUE, Unit_Type__c = 'Hrs')
            };
            insert proList;
            List<Pricebook2> standardPbList = [SELECT Id,Name FROM Pricebook2 WHERE isStandard = true];
            
            List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = standardPbList[0].Id, Product2Id = proList[0].Id, IsActive = TRUE, UnitPrice = 100),
                new PricebookEntry(Pricebook2Id = standardPbList[0].Id, Product2Id = proList[1].Id, IsActive = TRUE, UnitPrice = 100),
                new PricebookEntry(Pricebook2Id = standardPbList[0].Id, Product2Id = proList[2].Id, IsActive = TRUE, UnitPrice = 100),
                new PricebookEntry(Pricebook2Id = standardPbList[0].Id, Product2Id = proList[3].Id, IsActive = TRUE, UnitPrice = 100),
                new PricebookEntry(Pricebook2Id = standardPbList[0].Id, Product2Id = proList[5].Id, IsActive = TRUE, UnitPrice = 100)
            };
            insert priceBookEntryList; 
            
            List<Language__c> newlangList = new List<Language__c>{
                new Language__c(Name ='English')
            }; 
            insert newlangList;
            
            List<OpportunityLineItem> opliList = new List<OpportunityLineItem> {
             new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = priceBookEntryList[0].Id, Quantity = 2, UnitPrice = 200,Language__c = newlangList[0].Id),
             new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = priceBookEntryList[1].Id, Quantity = 1, UnitPrice = 200,Language__c = newlangList[0].Id),
             new OpportunityLineItem(OpportunityId = oppList[1].Id, PricebookEntryId = priceBookEntryList[2].Id, Quantity = 1, UnitPrice = 200,Language__c = newlangList[0].Id),
             new OpportunityLineItem(OpportunityId = oppList[1].Id, PricebookEntryId = priceBookEntryList[3].Id, Quantity = 1, UnitPrice = 200,Language__c = newlangList[0].Id),
             new OpportunityLineItem(OpportunityId = oppList[1].Id, PricebookEntryId = priceBookEntryList[0].Id, Quantity = 1, UnitPrice = 200,Language__c = newlangList[0].Id,Product2Id = proList[0].Id),
             new OpportunityLineItem(OpportunityId = oppList[2].Id, PricebookEntryId = priceBookEntryList[2].Id, Quantity = 1, UnitPrice = 700,Language__c = newlangList[0].Id),
             new OpportunityLineItem(OpportunityId = oppList[3].Id, PricebookEntryId = priceBookEntryList[3].Id, Quantity = 1, UnitPrice = 700,Language__c = newlangList[0].Id),
             new OpportunityLineItem(OpportunityId = oppList[3].Id, PricebookEntryId = priceBookEntryList[4].Id, Quantity = 1, UnitPrice = 700,Language__c = newlangList[0].Id)        
            };
            insert opliList;
        }
        
        if(insertObjSet.contains('Contact Assignment')) {
            List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = oppList[0].Id,RecordTypeId = InstRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10)),
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = oppList[1].Id,RecordTypeId = staffRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10)),
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = oppList[0].Id,RecordTypeId = studRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10)),
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = oppList[3].Id,RecordTypeId = studRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
            }; 
            Insert contAssignList;
            
            List<Planned_Days_Off__c> plannedDaysOffList = new List<Planned_Days_Off__c>{
                new Planned_Days_Off__c(Contact__c = contactList[0].Id,Date__c=System.today(),Description__c='Test',Requested_Reschedule_Date__c=System.today()+1)
            };
            Insert plannedDaysOffList;
            
            List<Schedule__c> schList = new List<Schedule__c>{
                new Schedule__c(Instructor__c=contactList[0].Id,End_Date__c=System.Today() + 10,Start_Date__c=System.Today(),Start_Time__c='09:00 AM',End_Time__c='10:00 AM',Tuesday__c=True,Monday__c=True,Opportunity__c = oppList[0].Id)
            };
            Insert schList;
            
            Date eveDate = date.ValueOf('2017-01-02');
            List<Events__c> eventList = new List<Events__c>{
                new Events__c(Instructor__c = contactList[0].Id,Schedule__c=schList[0].Id,Start_Time__c='9:00 AM',End_Time__c='10:00 AM',Date__c=system.today(),Status__c='Scheduled',SequenceNo__c=1235),
                new Events__c(Instructor__c = contactList[0].Id,Schedule__c=schList[0].Id,Start_Time__c='9:00 AM',End_Time__c='10:00 AM',Date__c=eveDate,Status__c='Scheduled',SequenceNo__c=1235),
                new Events__c(Instructor__c = contactList[0].Id,Schedule__c=schList[0].Id,Start_Time__c='9:00 AM',End_Time__c='10:00 AM',Date__c=system.today().addDays(1),Status__c='Scheduled',SequenceNo__c=1235)
            };
            Insert eventList; 
         }
         
         if(insertObjSet.contains('Payment')) {   
            List<Transaction__c> paymentList = new List<Transaction__c>{new Transaction__c(Opportunity__c = oppList[0].Id,Transaction_Date__c=System.today())};
            Insert paymentList;
            
            List<Payment_Item__c> paymentItemList = new List<Payment_Item__c>{new Payment_Item__c(Payment__c = paymentList[0].Id,Amount__c=100)};
            Insert paymentItemList; 
        }
        
        if(insertObjSet.contains('Material')) {
            List<Materials__c> materialsList = new List<Materials__c>{
                new Materials__c(Name = 'Test Material 1', Book_Series__c = 'SN0012', Cost__c = 40),
                new Materials__c(Name = 'Test Material 2',Book_Series__c = 'SN0043', Cost__c = 50)
            };
            insert materialsList;
        }
        
        if(insertObjSet.contains('Material Request')) {
            List<Materials_Request__c> matReq = new List<Materials_Request__c>{new Materials_Request__c(Name = 'LMS Enrollment', Class_Name__c = oppList[0].Id,Date_Delivered__c = System.Today(),Request_Status__c = 'Requested by LTS',Vendor_Name__c = acc.Id)};
            Insert matReq;
        }
        
        if(insertObjSet.contains('Language Testing')) {
            List<Language_Testing__c> langList = new List<Language_Testing__c>{new Language_Testing__c(Examiner__c = contactList[0].Id,Opportunity__c = oppList[0].Id)};
            Insert langList;
        } 
        
        if(insertObjSet.contains('Get Feedback')) {
            Id getFBRtId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByName().get('Two Week Survey').getRecordTypeId();
            List<Get_Feedback__c> getFeedList = new List<Get_Feedback__c>{new Get_Feedback__c(RecordTypeId = getFBRtId,Opportunity__c = oppList[0].Id,Contact__c = contactList[0].Id)};
            Insert getFeedList;
        }
        
        if(insertObjSet.contains('Time Log')) {
            List<Time_Log__c> timelogList = new List<Time_Log__c>{new Time_Log__c(Opportunity__c = oppList[0].Id,Date__c = System.Today(),Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'Interpretation (per hr)'),
               new Time_Log__c(Opportunity__c = oppList[0].Id,Date__c = System.Today()+100,Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'SVC:Language Training:Arabic'), // Afrikaans
               new Time_Log__c(Opportunity__c = oppList[0].Id,Date__c = System.Today()-2,Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'FMLA',Unposted__c = False,Notes__c = 'prepare Notes'),
               new Time_Log__c(Opportunity__c = oppList[0].Id,Date__c = System.Today()-7,Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'FMLA'),
               new Time_Log__c(Opportunity__c = oppList[0].Id,Date__c = System.Today()-5,Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'ADMINISTRATIVE'),
               new Time_Log__c(Opportunity__c = oppList[0].Id,Date__c = System.Today()-3,Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'Fringe',PayRoll_item__c = 'HOL'),
               new Time_Log__c(Opportunity__c = oppList[0].Id,Date__c = System.Today()+107,Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'SVC:Curriculum Development'),
               new Time_Log__c(Opportunity__c = oppList[3].Id,Date__c = System.Today()+107,Hours__c=2,Contact__c = contactList[0].Id,Service_Item__c = 'SVC:Preparation time')
            };
            Insert timelogList;
        } 
        
        //List<Holiday> holidayList = [SELECT Id, Name, ActivityDate FROM Holiday WHERE ActivityDate = 2017-01-02];
        return oppList;
    }
    
    private static testMethod void myTestMethod1(){
    
        Account acc = new Account(Name='Test Account 1');
        insert acc;
        
        Id recordTypeId =[SELECT Id FROM RecordType WHERE DeveloperName = 'Interpretation_Opportunities' AND sObjectType = 'Opportunity'].Id;
        
        Opportunity opp = new Opportunity(AccountId=acc.Id,Name='Test Opp - 1', Language__c='Malaysian', CloseDate=System.Today(),StageName='Active',Start_Date__c = system.today(),End_Date__c = system.today().addDays(10), RecordTypeId = recordTypeId );
        insert opp;
        
        Product2 prod = new Product2(Name = 'ELC Language Training', Family = 'Transcription', Description = 'Lang Product', productCode = 'Lang Code', isActive = TRUE, Unit_Type__c = 'Hrs');
        insert prod;
        
        List<Pricebook2> standardPbList = [SELECT Id,Name FROM Pricebook2 WHERE isStandard = true];
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPbList[0].Id, Product2Id = prod.Id, IsActive = TRUE, UnitPrice = 100);
        insert pbe;
        
        List<Language__c> newlangList = new List<Language__c>{
            new Language__c(Name ='English')
        }; 
        insert newlangList;
            
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 700,Language__c = newlangList[0].Id);
        insert oli;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            
        ConvertToProject cTP = new ConvertToProject(sc);
        
        cTP.createProjectAndProjectTask();
    }
    
    private static testMethod void myTestMethod2(){
    
        Account acc = new Account(Name='Test Account 1');
        insert acc;
        
        Id recordTypeId =[SELECT Id FROM RecordType WHERE DeveloperName = 'CD_Opportunities' AND sObjectType = 'Opportunity'].Id;
        
        Opportunity opp = new Opportunity(AccountId=acc.Id,Name='Test Opp - 1', Language__c='Malaysian', CloseDate=System.Today(),StageName='Active',Start_Date__c = system.today(),End_Date__c = system.today().addDays(10), RecordTypeId = recordTypeId );
        insert opp;
        
        Product2 prod = new Product2(Name = 'ODC Product', Description = 'Lang Product', productCode = 'Lang Code', isActive = TRUE, Family = 'ODC');
        insert prod;
        
        List<Pricebook2> standardPbList = [SELECT Id,Name FROM Pricebook2 WHERE isStandard = true];
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPbList[0].Id, Product2Id = prod.Id, IsActive = TRUE, UnitPrice = 100);
        insert pbe;
        
        List<Language__c> newlangList = new List<Language__c>{
            new Language__c(Name ='English')
        }; 
        insert newlangList;
            
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 700,Language__c = newlangList[0].Id);
        insert oli;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            
        ConvertToProject cTP = new ConvertToProject(sc);
        
        cTP.createProjectAndProjectTask();
    }
    
    private static testMethod void myTestMethod3(){
    
        Account acc = new Account(Name='Test Account 1');
        insert acc;
        
        Id recordTypeId =[SELECT Id FROM RecordType WHERE DeveloperName = 'CD_Opportunities' AND sObjectType = 'Opportunity'].Id;
        
        Opportunity opp = new Opportunity(AccountId=acc.Id,Name='Test Opp - 1', Language__c='Malaysian', CloseDate=System.Today(),StageName='Active',Start_Date__c = system.today(),End_Date__c = system.today().addDays(10), RecordTypeId = recordTypeId );
        insert opp;
        
        Product2 prod = new Product2(Name = 'Language Training- Preparation', Description = 'Lang Product', productCode = 'Lang Code', isActive = TRUE, Family = 'ODC');
        insert prod;
        
        List<Pricebook2> standardPbList = [SELECT Id,Name FROM Pricebook2 WHERE isStandard = true];
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPbList[0].Id, Product2Id = prod.Id, IsActive = TRUE, UnitPrice = 100);
        insert pbe;
        
        List<Language__c> newlangList = new List<Language__c>{
            new Language__c(Name ='English')
        }; 
        insert newlangList;
            
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 700,Language__c = newlangList[0].Id);
        insert oli;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            
        ConvertToProject cTP = new ConvertToProject(sc);
        
        cTP.createProjectAndProjectTask();
    }
     private static testMethod void myTestMethod3a(){
    
         Account acc = new Account(Name='Test Account 1');
         insert acc;
         
         List<Contact> contactList = new List<Contact>{
             new Contact(AccountId=acc.Id,LastName='Test Contact - 1')            
         };
        Insert contactList;
        
        Id recordTypeId =[SELECT Id FROM RecordType WHERE DeveloperName = 'Testing_Opportunities' AND sObjectType = 'Opportunity'].Id;
        
        Opportunity opp = new Opportunity(AccountId=acc.Id,Name='Test Opp - 1', Language__c='Malaysian', CloseDate=System.Today(),StageName='Active',Start_Date__c = system.today(),End_Date__c = system.today().addDays(10), RecordTypeId = recordTypeId );
        insert opp;
        
        Product2 prod = new Product2(Name = 'Language Training- Preparation', Description = 'Lang Product', productCode = 'Lang Code', isActive = TRUE, Family = 'ODC');
        insert prod;
        
        List<Pricebook2> standardPbList = [SELECT Id,Name FROM Pricebook2 WHERE isStandard = true];
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPbList[0].Id, Product2Id = prod.Id, IsActive = TRUE, UnitPrice = 100);
        insert pbe;
        
        List<Language__c> newlangList = new List<Language__c>{
            new Language__c(Name ='English')
        }; 
        insert newlangList;
            
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 700,Language__c = newlangList[0].Id);
        insert oli;
           Id staffRT =[SELECT Id FROM RecordType WHERE DeveloperName = 'Staff' AND sObjectType = 'Contact_Assignments__c'].Id;
         
          List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = opp.Id,RecordTypeId = staffRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
              }; 
              Insert contAssignList;
         
         List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
             new AcctSeed__Cost_Rates__c(Contact__c = contactList[0].Id, Pay_Type__c = 'Hourly', Rate_Type__c = 'FT Hourly & Benefits',AcctSeed__Hourly_Cost__c = 43 , Status__c = 'Draft', Payroll_Item__c='R' , Salary_Cost_Per_Hour__c = 3 , Annual_Salary_Cost__c = 2)
            };
            insert costrateList;
         Test.startTest();
         ApexPages.StandardController sc = new ApexPages.StandardController(opp);
         
         ConvertToProject cTP = new ConvertToProject(sc);
         
         cTP.createProjectAndProjectTask();
         Test.stopTest();
     }
    
    private static testMethod void myTestMethod3b(){
        
        Account acc = new Account(Name='Test Account 1');
        insert acc;
        
        List<Contact> contactList = new List<Contact>{
            new Contact(AccountId=acc.Id,LastName='Test Contact - 1')            
            };
           Insert contactList;
        
        Id recordTypeId =[SELECT Id FROM RecordType WHERE DeveloperName = 'Testing_Opportunities' AND sObjectType = 'Opportunity'].Id;
        
        Opportunity opp = new Opportunity(AccountId=acc.Id,Name='Test Opp - 1', Language__c='Malaysian', CloseDate=System.Today(),StageName='Active',Start_Date__c = system.today(),End_Date__c = system.today().addDays(10), RecordTypeId = recordTypeId );
        insert opp;
        
        Product2 prod = new Product2(Name = 'Language Training- Preparation', Description = 'Lang Product', productCode = 'Lang Code', isActive = TRUE, Family = 'ODC');
        insert prod;
        
        List<Pricebook2> standardPbList = [SELECT Id,Name FROM Pricebook2 WHERE isStandard = true];
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPbList[0].Id, Product2Id = prod.Id, IsActive = TRUE, UnitPrice = 100);
        insert pbe;
        
        List<Language__c> newlangList = new List<Language__c>{
            new Language__c(Name ='English')
             }; 
             insert newlangList;
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 700,Language__c = newlangList[0].Id);
        insert oli;
        Id staffRT =[SELECT Id FROM RecordType WHERE DeveloperName = 'Staff' AND sObjectType = 'Contact_Assignments__c'].Id;
        
        List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = opp.Id,RecordTypeId = staffRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
            }; 
            Insert contAssignList;
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = contactList[0].Id, Pay_Type__c = 'Hourly', Rate_Type__c = 'FT Salary & Benefits',AcctSeed__Hourly_Cost__c = 43 , Status__c = 'Draft', Payroll_Item__c='R' , Salary_Cost_Per_Hour__c = 2 , Annual_Salary_Cost__c = 3)
            };
            insert costrateList;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        
        ConvertToProject cTP = new ConvertToProject(sc);
        
        cTP.createProjectAndProjectTask();
        Test.stopTest();
    }
    
    
    private static testMethod void myTestMethod3c(){
        
        Account acc = new Account(Name='Test Account 1');
        insert acc;
        
        List<Contact> contactList = new List<Contact>{
         new Contact(AccountId=acc.Id,LastName='Test Contact - 1')            
         };
                    Insert contactList;
        
        Id recordTypeId =[SELECT Id FROM RecordType WHERE DeveloperName = 'Testing_Opportunities' AND sObjectType = 'Opportunity'].Id;
        
        Opportunity opp = new Opportunity(AccountId=acc.Id,Name='Test Opp - 1', Language__c='Malaysian', CloseDate=System.Today(),StageName='Active',Start_Date__c = system.today(),End_Date__c = system.today().addDays(10), RecordTypeId = recordTypeId );
        insert opp;
        
        Product2 prod = new Product2(Name = 'Language Training- Preparation', Description = 'Lang Product', productCode = 'Lang Code', isActive = TRUE, Family = 'ODC');
        insert prod;
        
        List<Pricebook2> standardPbList = [SELECT Id,Name FROM Pricebook2 WHERE isStandard = true];
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPbList[0].Id, Product2Id = prod.Id, IsActive = TRUE, UnitPrice = 100);
        insert pbe;
        
        List<Language__c> newlangList = new List<Language__c>{
           new Language__c(Name ='English')
           }; 
          insert newlangList;
       
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 700,Language__c = newlangList[0].Id);
        insert oli;
        Id staffRT =[SELECT Id FROM RecordType WHERE DeveloperName = 'Staff' AND sObjectType = 'Contact_Assignments__c'].Id;
        
        List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = opp.Id,RecordTypeId = staffRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
         }; 
         Insert contAssignList;
        
        List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = contactList[0].Id, Rate_Type__c = 'PT Hourly (OH & G&A)',AcctSeed__Hourly_Cost__c = 43 , Status__c = 'Draft',Payroll_Item__c='R')
        };
        insert costrateList;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        
        ConvertToProject cTP = new ConvertToProject(sc);
        
        cTP.createProjectAndProjectTask();
        Test.stopTest();
    }
    /*
    // To cover DLI-W LT Projects create LMS Enrollment (Free) Material Request
    private static testMethod void lMSEnrollFreeTestMethod(){
    
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Contact Assignment', 'Material'}); //'Contact Assignment',
         
        
        Id dliOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DLI_W_TO_Opportunities').getRecordTypeId();
        List<Opportunity> dliOpp = new List<Opportunity>();
        
        if(oppList.size() > 0) {
        
            for(Opportunity opp : oppList){
            
                if(opp.RecordTypeId == dliOppRTId){
                    dliOpp.add(opp);
                }
            }
            Test.StopTest(); 
            if(dliOpp.size() > 0){
            
                ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
                ConvertToProject cTP = new ConvertToProject(sc);
            }
            
        }
    }
    */
    private static testMethod void TestMethod13(){
    
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        Test.StopTest();  
        
        Id dliOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DLI_W_TO_Opportunities').getRecordTypeId();
        List<Opportunity> dliOpp = new List<Opportunity>();
        
        if(oppList.size() > 0) {
        
            for(Opportunity opp : oppList){
            
                if(opp.RecordTypeId == dliOppRTId){
                    dliOpp.add(opp);
                }
            }
            
            if(dliOpp.size() > 0){
            
                ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
                ConvertToProject cTP = new ConvertToProject(sc);
            }
        }
    }
    
    private static testMethod void TestMethod14(){
    
        Test.StartTest();
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        Test.StopTest();  
        
        Id dliOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DLI_W_TO_Opportunities').getRecordTypeId();
        List<Opportunity> dliOpp = new List<Opportunity>();
        
        User user = [Select Id, ProfileId from User where Id=: UserInfo.getUserId()];
        
        if(oppList.size() > 0) {
        
            for(Opportunity opp : oppList){
            
                if(opp.RecordTypeId == dliOppRTId){
                    dliOpp.add(opp);
                }
            }
            
            if(dliOpp.size() > 0){
            
                System.runAs(user){
                
                    ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
                    ConvertToProject cTP = new ConvertToProject(sc);
                }
            }
        }
    }
    /*
    // If there is no CR for that contact and Rate Type combination, automatically create CR based on LCR Master custom setting for DLI-W To Opportunity RT
    private static testMethod void TestMethod15(){
                        
        Id staffRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        Id stdRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id insRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
                    
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment'
        
        
        List<Contact> contactList = [SELECT Id,AccountId,LastName FROM Contact LIMIT 1];
                    
        Id dliOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DLI_W_TO_Opportunities').getRecordTypeId();
        List<Opportunity> dliOpp = new List<Opportunity>();
                
        if(oppList.size() > 0) {
        
            for(Opportunity opp : oppList){
            
                if(opp.RecordTypeId == dliOppRTId){
                    dliOpp.add(opp);
                }
            }
            
            if(dliOpp.size() > 0){
                         
                    dliOpp[0].Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA LT';
                    update dliOpp[0];
                               
                           
                    List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
                        new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = staffRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10)),
                        new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = stdRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10)),
                        new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = insRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
                    }; 
                    
                    insert contAssignList;
                    
                    //List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Id = :dliOpp[0].Id];
                    ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
                    Test.startTest();
                    ConvertToProject cTP = new ConvertToProject(sc);
                    cTP.createProjectAndProjectTask(); 
                    Test.stopTest();
            }
        }
    }
    */
    //If there is no CR for that contact and Rate Type combination, automatically create CR based on LCR Master custom setting for DLI-W To Opportunity RT 
    private static testMethod void TestMethod16(){
        
        List<Opportunity> oppList = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        
        List<Contact> contactList = [SELECT Id,AccountId,LastName FROM Contact LIMIT 1];
        
        Id dliOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DLI_W_TO_Opportunities').getRecordTypeId();
        List<Opportunity> dliOpp = new List<Opportunity>();
        System.debug('oppList========='+oppList);
                
        if(oppList.size() > 0) {
        
            for(Opportunity opp : oppList){
            
                if(opp.RecordTypeId == dliOppRTId){
                    dliOpp.add(opp);
                }
            }
                        
            if(dliOpp.size() > 0){
                dliOpp[0].Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA LT';
                                
                update dliOpp[0];
                Test.startTest();
                Id staffRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
                Id stdRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
                Id insRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
                
                List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
                    new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = staffRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10)),
                    new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = stdRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10)),
                    new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = insRT,Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
                }; 
                insert contAssignList;  
                                             
                List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                    new AcctSeed__Cost_Rates__c(Contact__c = contactList[0].Id, Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 43 , Status__c = 'Approved',Payroll_Item__c='R')
                };
                insert costrateList;
               
                //List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Id = :dliOpp[0].Id];
                ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
                ConvertToProject cTP = new ConvertToProject(sc);
                //cTP.createProjectAndProjectTask();
                Test.stopTest();  
            }
        }
    }
    
    //If there is no CR for that contact for Staff/Supervisor and assign CR to Contact if anyone CostRate have ( FT Salary & Benefits,FT Hourly & Benefit ,PT Hourly (OH & G&A) for Testing Opportunity RT
    // LCR Rate : FT Salary & Benefits, Status : Draft
    private static testMethod void TestMethod17(){
    
        Test.StartTest();
         List<Opportunity> dliOpp = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        
        List<Contact> contactList = [SELECT Id,AccountId,LastName FROM Contact LIMIT 1];
                    
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
        Test.StopTest(); 
       
        if(dliOpp.size() > 0) {
            
            List<OpportunityLineItem> opli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :dliOpp[0].Id];
            
            dliOpp[0].Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA LT';
            dliOpp[0].RecordTypeId = testOppRTId;
            update dliOpp[0];
            
            Id staffRT =[SELECT Id FROM RecordType WHERE DeveloperName = 'Staff' AND sObjectType = 'Contact_Assignments__c'].Id;
            
            List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = staffRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10)),
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = staffRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10)),
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = staffRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
            }; 
            insert contAssignList;
            
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = contactList[0].Id, Rate_Type__c = 'FT Salary & Benefits',Salary_Cost_Per_Hour__c = 43, Annual_Salary_Cost__c = 20, Status__c = 'Draft',Payroll_Item__c='R')
            };
            //insert costrateList;
    
            List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Id = :dliOpp[0].Id];
            ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
            ConvertToProject cTP = new ConvertToProject(sc);
            cTP.createProjectAndProjectTask();
        }
    }
    
    // LCR Rate : FT Salary & Benefits, Status : Approved
    private static testMethod void TestMethod17a(){
    
        Test.StartTest();
            List<Opportunity> dliOpp = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        Test.StopTest();  
        
        List<Contact> contactList = [SELECT Id,AccountId,LastName FROM Contact LIMIT 1];
        
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
                
        if(dliOpp.size() > 0) {
            
            List<OpportunityLineItem> opli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :dliOpp[0].Id];
            
            dliOpp[0].Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA LT';
            dliOpp[0].RecordTypeId = testOppRTId;
            update dliOpp[0];
            
            Id staffRT =[SELECT Id FROM RecordType WHERE DeveloperName = 'Staff' AND sObjectType = 'Contact_Assignments__c'].Id;
            
            List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = staffRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10)),
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = staffRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10)),
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = staffRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
            }; 
            insert contAssignList;
            
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = contactList[0].Id, Rate_Type__c = 'FT Salary & Benefits',Salary_Cost_Per_Hour__c = 43, Annual_Salary_Cost__c = 20, Status__c = 'Approved',Payroll_Item__c='R')
            };
            //insert costrateList;
    
            List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Id = :dliOpp[0].Id];
            ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
            ConvertToProject cTP = new ConvertToProject(sc);
            cTP.createProjectAndProjectTask();
        }
    }
    
    //If there is no CR for that contact for Staff/Supervisor and assign CR to Contact if anyone CostRate have ( FT Salary & Benefits,FT Hourly & Benefit ,PT Hourly (OH & G&A) for Testing Opportunity RT
    // LCR Rate : FT Hourly & Benefits, Status : Draft
    private static testMethod void TestMethod18(){
    
        Test.StartTest();
            List<Opportunity> dliOpp = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        Test.StopTest();  
        
        List<Contact> contactList = [SELECT Id,AccountId,LastName FROM Contact LIMIT 1];
                    
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
                
        if(dliOpp.size() > 0) {
            
            List<OpportunityLineItem> opli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :dliOpp[0].Id];
            
            dliOpp[0].Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA LT';
            dliOpp[0].RecordTypeId = testOppRTId;
            update dliOpp[0];
            
            Id staffRT =[SELECT Id FROM RecordType WHERE DeveloperName = 'Staff' AND sObjectType = 'Contact_Assignments__c'].Id;
            
            List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = staffRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
            }; 
            insert contAssignList;
            
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = contactList[0].Id, Rate_Type__c = 'FT Hourly & Benefits',Salary_Cost_Per_Hour__c = 43, Annual_Salary_Cost__c = 30, Status__c = 'Draft',Payroll_Item__c='R')
            };
            //insert costrateList;
    
            List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Id = :dliOpp[0].Id];
            ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
            ConvertToProject cTP = new ConvertToProject(sc);
            cTP.createProjectAndProjectTask();
        }
    }
    
    // LCR Rate : FT Hourly & Benefits, Status : Approved
    private static testMethod void TestMethod18a(){
    
        Test.StartTest();
            List<Opportunity> dliOpp = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        Test.StopTest();  
        
        List<Contact> contactList = [SELECT Id,AccountId,LastName FROM Contact LIMIT 1];
        
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
                
        if(dliOpp.size() > 0) {
            
            List<OpportunityLineItem> opli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :dliOpp[0].Id];
            
            dliOpp[0].Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA LT';
            dliOpp[0].RecordTypeId = testOppRTId;
            update dliOpp[0];
            
            Id staffRT =[SELECT Id FROM RecordType WHERE DeveloperName = 'Staff' AND sObjectType = 'Contact_Assignments__c'].Id;
            
            List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = staffRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
            }; 
            insert contAssignList;
            
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = contactList[0].Id, Rate_Type__c = 'FT Hourly & Benefits',Salary_Cost_Per_Hour__c = 43, Annual_Salary_Cost__c = 30, Status__c = 'Approved',Payroll_Item__c='R')
            };
            //insert costrateList;
    
            List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Id = :dliOpp[0].Id];
            ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
            ConvertToProject cTP = new ConvertToProject(sc);
            cTP.createProjectAndProjectTask();
        }
    }
    
    //If there is no CR for that contact for Staff/Supervisor and assign CR to Contact if anyone CostRate have ( FT Salary & Benefits,FT Hourly & Benefit ,PT Hourly (OH & G&A) for Testing Opportunity RT
    // LCR Rate : PT Hourly (OH & G&A), Status : Draft
    private static testMethod void TestMethod19(){
    
        Test.StartTest();
            List<Opportunity> dliOpp = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        Test.StopTest();  
        
        List<Contact> contactList = [SELECT Id,AccountId,LastName FROM Contact LIMIT 1];
        
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
                
        if(dliOpp.size() > 0) {
            
            List<OpportunityLineItem> opli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :dliOpp[0].Id];
            
            dliOpp[0].Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA LT';
            dliOpp[0].RecordTypeId = testOppRTId;
            update dliOpp[0];
            
            Id staffRT =[SELECT Id FROM RecordType WHERE DeveloperName = 'Staff' AND sObjectType = 'Contact_Assignments__c'].Id;
            
            List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = staffRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
            }; 
            insert contAssignList;
            
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = contactList[0].Id, Rate_Type__c = 'PT Hourly (OH & G&A)', AcctSeed__Hourly_Cost__c = 43, Status__c = 'Draft',Payroll_Item__c='R')
            };
            insert costrateList;
    
            List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Id = :dliOpp[0].Id];
            ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
            ConvertToProject cTP = new ConvertToProject(sc);
            cTP.createProjectAndProjectTask();
        }
    }
    
    // LCR Rate : PT Hourly (OH & G&A), Status : Approved
    private static testMethod void TestMethod19a(){
    
        Test.StartTest();
            List<Opportunity> dliOpp = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        Test.StopTest();  
        
        List<Contact> contactList = [SELECT Id,AccountId,LastName FROM Contact LIMIT 1];
        
        Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
                
        if(dliOpp.size() > 0) {
            
            List<OpportunityLineItem> opli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :dliOpp[0].Id];
            
            dliOpp[0].Default_Cost_Rate_Rate_Type__c = 'DLI-21 SCA LT';
            dliOpp[0].RecordTypeId = testOppRTId;
            update dliOpp[0];
            
            Id staffRT =[SELECT Id FROM RecordType WHERE DeveloperName = 'Staff' AND sObjectType = 'Contact_Assignments__c'].Id;
            
            List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = staffRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
            }; 
            insert contAssignList;
            
            List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
                new AcctSeed__Cost_Rates__c(Contact__c = contactList[0].Id, Rate_Type__c = 'PT Hourly (OH & G&A)', AcctSeed__Hourly_Cost__c = 43, Status__c = 'Approved',Payroll_Item__c='R')
            };
            insert costrateList;
    
            List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Id = :dliOpp[0].Id];
            ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
            ConvertToProject cTP = new ConvertToProject(sc);
            cTP.createProjectAndProjectTask();
        }
    }
    
    private static testMethod void TestMethod20(){
    
        Test.StartTest();
            List<Opportunity> dliOpp = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        Test.StopTest();
        
        List < Get_Feedback__c > getFeedBackList = new List < Get_Feedback__c > {
            new Get_Feedback__c(Name = 'Test Record 1', Opportunity__c = dliOpp[0].Id), 
            new Get_Feedback__c(Name = 'Test Record 2', Opportunity__c = dliOpp[0].Id) 
        };
        insert getFeedBackList;
            
        ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
        ConvertToProject cTP = new ConvertToProject(sc);
        cTP.createProjectAndProjectTask();
    }
    
    //Child PVT Account creation
    private static testMethod void TestMethod21(){
    
        Test.StartTest();
            List<Opportunity> dliOpp = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        Test.StopTest();
        
        if(dliOpp.size() > 0) {
            
            List<Account> parentAccList = [SELECT Id,Name FROM Account WHERE name='PVT' LIMIT 1];
            
            List<Contact> contactList = new List<Contact>{
                new Contact(AccountId=parentAccList[0].Id,LastName='Test Contact - 1')            
            };
            insert contactList;
        
            dliOpp[0].AccountId = parentAccList[0].Id;
            update dliOpp[0];
            
            List<OpportunityLineItem> opli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :dliOpp[0].Id];
            
            Id stdfRT =[SELECT Id FROM RecordType WHERE DeveloperName = 'Student' AND sObjectType = 'Contact_Assignments__c'].Id;
            
            List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = stdfRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10),Assignment_Position__c = 'Class Leader'), 
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = stdfRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10))
            }; 
            insert contAssignList;
                        
            ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
            ConvertToProject cTP = new ConvertToProject(sc);
            cTP.createProjectAndProjectTask();
        }
    }
    
    // Language Testing creation
    private static testMethod void TestMethod22(){
    
        Test.StartTest();
            List<Opportunity> dliOpp = objInsertMethod(new Set<String>{'Opportunity', 'Time Log'}); //'Contact Assignment',
        Test.StopTest();
        
        if(dliOpp.size() > 0) {
            
            List<Account> parentAccList = [SELECT Id,Name FROM Account WHERE name='PVT' LIMIT 1];
            
            List<Contact> contactList = new List<Contact>{
                new Contact(AccountId=parentAccList[0].Id,LastName='Test Contact - 1')            
            };
            insert contactList;
        
            dliOpp[0].AccountId = parentAccList[0].Id;
            dliOpp[0].Program_type__c = 'Familiarization';
            update dliOpp[0];
            
            List<OpportunityLineItem> opli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :dliOpp[0].Id];
            
            Id stdfRT =[SELECT Id FROM RecordType WHERE DeveloperName = 'Student' AND sObjectType = 'Contact_Assignments__c'].Id;
            
            List<Contact_Assignments__c> contAssignList = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Status__c = 'Active', Candidate_Name__c=contactList[0].Id,Opportunity_Name__c = dliOpp[0].Id,RecordTypeId = stdfRT, Opportunity_Product_Id__c = opli[0].Id, Start_Date__c = system.today(),End_Date__c = system.today().addDays(10),Assignment_Position__c = 'Class Leader')
            }; 
            insert contAssignList;
                        
            ApexPages.StandardController sc = new ApexPages.StandardController(dliOpp[0]);
            ConvertToProject cTP = new ConvertToProject(sc);
            cTP.createProjectAndProjectTask();    
        }
    }
    
}