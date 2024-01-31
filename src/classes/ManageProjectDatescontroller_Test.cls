@isTest
private class ManageProjectDatescontroller_Test {
   
    @testsetup static void setup() { 
        Test.StartTest();
        List<Contact_Assignments__c> conAssList = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
        
        List<Schedule__c> schTask = TestClassUtil.createTestSchedule();          
        
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'FALSE')};
        insert sysVal;
    }
    
    // For Query the Contact Assignment, Schedule, PlannedDaysOff and ProjectTask records related to Project
    private static testMethod void testMethod1() {
       
        List<Account> acc = [SELECT Id, Name FROM Account LIMIT 1];
        List<AcctSeed__Project__c> pro = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 2];
        pro[0].AcctSeed__Account__c = acc[0].Id;
        update pro[0];
        
        List<RecordType> rtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Contact_Assignments__c', 'Planned_Days_Off__c', 'AcctSeed__Project__c') AND DeveloperName IN ('Instructor', 'Project_Planned_Days_Off', 'DLI_W_LT_Projects')];
        Id caRtId, pdoRtId, proRtId;
        
        if(rtype.size() > 0) {
            for(RecordType rt : rtype) {
                if(rt.DeveloperName == 'Instructor') 
                    caRtId = rt.Id;
                else if(rt.DeveloperName == 'Project_Planned_Days_Off')
                    pdoRtId = rt.Id;
                else 
                    proRtId = rt.Id;
            }
        }
        
        List<Contact> con = new List<Contact> {
            new Contact(LastName = 'Test Cont1', Email = 'test1@gmail.com'),
            new Contact(LastName = 'Test Cont2', Email = 'test2@gmail.com')
        };
        insert con;
        
        if(pro.size() > 0) {
            
            pro[0].RecordTypeId = proRtId;
            pro[1].RecordTypeId = proRtId;
            update pro;
            
            List<Contact_Assignments__c> conAss = new List<contact_Assignments__c> {
                new Contact_Assignments__c(Project__c = pro[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active'),
                new Contact_Assignments__c(Project__c = pro[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[1].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active')
            };
            insert conAss;
            
            List<Planned_Days_Off__c> pdo = new List<Planned_Days_Off__c> {
                new Planned_Days_Off__c(Project__c = pro[0].Id, Contact__c = con[0].Id, Date__c = System.today().addDays(-1), Description__c = 'Test1', RecordTypeId = pdoRtId),
                new Planned_Days_Off__c(Project__c = pro[1].Id, Contact__c = con[1].Id, Date__c = System.today().addDays(-1), Description__c = 'Test2', RecordTypeId = pdoRtId)
            };
            insert pdo;
            
            ManageProjectDatescontroller mpdc = new ManageProjectDatescontroller();
            ManageProjectDatescontroller.ConAssign_Sch_PlannedDay warp = ManageProjectDatescontroller.getChilDetails(pro[0].Id,'Active',null);
            if(warp != null)
                System.assertEquals('Project', warp.parentType);
        }
    }  
    
    // For Query the Contact Assignment, Schedule and PlannedDaysOff records related to Opportunity
    private static testMethod void testMethod2() {
        
        List<Opportunity> opp = [SELECT Id, Name FROM Opportunity LIMIT 2];
        
        List<RecordType> rtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Contact_Assignments__c', 'Planned_Days_Off__c', 'Opportunity') AND DeveloperName IN ('Instructor', 'Project_Planned_Days_Off', 'DLI_W_TO_Opportunities')];
        Id caRtId, pdoRtId, oppRtId;
        
        if(rtype.size() > 0) {
            for(RecordType rt : rtype) {
                if(rt.DeveloperName == 'Instructor') 
                    caRtId = rt.Id;
                else if(rt.DeveloperName == 'DLI_W_TO_Opportunities')
                    oppRtId = rt.Id;
                else 
                    pdoRtId = rt.Id;
            }
        }
        
        List<Contact> con = new List<Contact> {
            new Contact(LastName = 'Test Cont1', Email = 'test1@gmail.com'),
            new Contact(LastName = 'Test Cont2', Email = 'test2@gmail.com')
        };
        insert con;
        
        if(opp.size() > 0) {
            
            opp[0].recordTypeId = oppRtId;
            opp[0].Project_Type__c = 'Resident LT';
            opp[1].recordTypeId = oppRtId;
            opp[1].Project_Type__c = 'AFPAK';
            update opp;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAss = new List<contact_Assignments__c> {
                new Contact_Assignments__c(Opportunity_Name__c = opp[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active'),
                new Contact_Assignments__c(Opportunity_Name__c = opp[1].Id, RecordTypeId = caRtId, Candidate_Name__c = con[1].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active')
            };
            insert conAss;
            
            Test.stopTest();
            
            List<Planned_Days_Off__c> pdo = new List<Planned_Days_Off__c> {
                new Planned_Days_Off__c(Opportunity__c = opp[0].Id, Contact__c = con[0].Id, Date__c = System.today().addDays(-1), Description__c = 'Test1', RecordTypeId = pdoRtId),
                new Planned_Days_Off__c(Opportunity__c = opp[1].Id, Contact__c = con[1].Id, Date__c = System.today().addDays(-1), Description__c = 'Test2', RecordTypeId = pdoRtId)
            };
            insert pdo;
            
            ManageProjectDatescontroller.ConAssign_Sch_PlannedDay warp = ManageProjectDatescontroller.getChilDetails(opp[0].Id,null,null);
            if(warp != null)
                System.assertEquals('Opportunity', warp.parentType);
        }
    }  
    
    // For Contact Assignment, Schedule, Project Task, PlannedDaysOff, Project and Opportunity records Updation and PlannedDayOff deletion
    private static testMethod void testMethod3() {
       
        List<AcctSeed__Project__c> pro = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 2];
        List<Opportunity> opp = [SELECT Id, Name FROM Opportunity LIMIT 2];
        Set<Id> proId = new Set<Id>();
        
        List<RecordType> rtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Contact_Assignments__c', 'Planned_Days_Off__c', 'AcctSeed__Project__c', 'Opportunity') AND DeveloperName IN ('Instructor', 'Project_Planned_Days_Off', 'DLI_W_TO_Opportunities', 'DLI_W_LT_Projects')];
        Id caRtId, pdoRtId, proRtId, oppRtId;
        
        if(rtype.size() > 0) {
            for(RecordType rt : rtype) {
                if(rt.DeveloperName == 'Instructor') 
                    caRtId = rt.Id;
                else if(rt.DeveloperName == 'Project_Planned_Days_Off')
                    pdoRtId = rt.Id;
                else if(rt.DeveloperName == 'DLI_W_TO_Opportunities')
                    oppRtId = rt.Id;
                else 
                    proRtId = rt.Id;
            }
        }
        
        List<Contact> con = new List<Contact> {
            new Contact(LastName = 'Test Cont1', Email = 'test1@gmail.com'),
            new Contact(LastName = 'Test Cont2', Email = 'test2@gmail.com')
        };
        insert con;
  
        if(pro.size() > 0) {
            
            proId.add(pro[0].Id);
            proId.add(pro[1].Id);
            
            pro[0].RecordTypeId = proRtId;
            pro[1].RecordtypeId = proRtId;
            update pro;
            
            opp[0].recordTypeId = oppRtId;
            opp[0].Project_Type__c = 'Resident LT';
            opp[1].recordTypeId = oppRtId;
            opp[1].Project_Type__c = 'AFPAK';
            update opp;
            
            List<AcctSeed__Project_Task__c> proTask = [SELECT Id, Name FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :proId LIMIT 2];
            List<Schedule__c> sch = [SELECT Id, Name FROM Schedule__c WHERE Project__c  IN :proId LIMIT 2];

            if(opp.size() > 0 && proTask.size() > 0 && sch.size() > 0) {
                
                Test.startTest();
                
                List<Contact_Assignments__c> conAss = new List<contact_Assignments__c> {
                    new Contact_Assignments__c(Opportunity_Name__c = opp[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+10, Status__c = 'Active'),
                    new Contact_Assignments__c(Opportunity_Name__c = opp[1].Id, RecordTypeId = caRtId, Candidate_Name__c = con[1].Id, Start_Date__c = System.today(), End_Date__c = System.today()+10, Status__c = 'Active')
                };
                insert conAss;
                
                Test.stopTest();
                
                List<Planned_Days_Off__c> pdoDel = new List<Planned_Days_Off__c> {
                    new Planned_Days_Off__c(Opportunity__c = opp[1].Id, Contact__c = con[1].Id, Date__c = System.today().addDays(-1), Description__c = 'Test2', RecordTypeId = pdoRtId),
                    new Planned_Days_Off__c(Project__c = pro[1].Id, Contact__c = con[1].Id, Date__c = System.today().addDays(-1), Description__c = 'Test4', RecordTypeId = pdoRtId)
                };
                insert pdoDel;
                
                List<Planned_Days_Off__c> pdoIn = new List<Planned_Days_Off__c> {
                    new Planned_Days_Off__c(Opportunity__c = opp[0].Id, Contact__c = con[0].Id, Date__c = System.today().addDays(-1), Description__c = 'Test1', RecordTypeId = pdoRtId),
                    new Planned_Days_Off__c(Project__c = pro[0].Id, Contact__c = con[0].Id, Date__c = System.today().addDays(-1), Description__c = 'Test3', RecordTypeId = pdoRtId)
                };
                
                for(Integer i = 0; i < pro.size(); i++) {
                    pro[i].Start_Date__c = System.today().addDays(-5);
                    pro[i].End_Date__c = System.today().addDays(30);
                }
                
                for(Integer i = 0; i < opp.size(); i++) {
                    opp[i].Start_Date__c = System.today().addDays(-5);
                    opp[i].End_Date__c = System.today().addDays(30);
                }
                
                List<Assessment_Report__c> assessmentReport = new List<Assessment_Report__c> {
                    new Assessment_Report__c(Name = 'Test Report1', Instructor__c = con[0].Id, Project__c = pro[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
                };
                
                insert assessmentReport;
                
                assessmentReport[0].Report_Date__c = System.today().addDays(5);
                
                if(pdoIn.size() > 0 && pdoDel.size() > 0) {
                    
                    List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
                    
                    for(Contact_Assignments__c ca : [SELECT Id, Start_Date__c, End_Date__C FROM Contact_Assignments__c WHERE Project__c IN : pro]){
                        ca.Start_Date__c = Date.Today().addDays(-4);
                        ca.End_Date__C = Date.Today().addDays(-2);
                        updateCAs.add(ca);
                    }
                    
                    update updateCAs;
                    
                    String status = ManageProjectDatescontroller.saveAllDetails(JSON.serialize(pro), JSON.serialize(opp), JSON.serialize(proTask), JSON.serialize(conAss), JSON.serialize(sch), JSON.serialize(pdoIn), JSON.serialize(pdoDel), JSON.serialize(assessmentReport),'Ended');
                    /*if(status != '')
                        System.assertEquals('Success', status);*/
                    
                    //String status1 = ManageProjectDatescontroller.saveAllDetails(JSON.serialize(pro), JSON.serialize(opp), JSON.serialize(proTask), JSON.serialize(conAss), JSON.serialize(sch), JSON.serialize(pdoDel), JSON.serialize(pdoIn), 'Ended');
                    //System.assertEquals('Failure', status1);
                }
            }
        }
    } 
    
    // For Contact Assignment, Schedule, Project Task, PlannedDaysOff, Project and Opportunity records Updation and PlannedDayOff deletion
    private static testMethod void testMethod3a() {
       
        List<AcctSeed__Project__c> pro = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 2];
        List<Opportunity> opp = [SELECT Id, Name FROM Opportunity LIMIT 2];
        Set<Id> proId = new Set<Id>();
        
        List<RecordType> rtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Contact_Assignments__c', 'Planned_Days_Off__c', 'AcctSeed__Project__c', 'Opportunity') AND DeveloperName IN ('Instructor', 'Project_Planned_Days_Off', 'DLI_W_TO_Opportunities', 'DLI_W_LT_Projects')];
        Id caRtId, pdoRtId, proRtId, oppRtId;
        
        if(rtype.size() > 0) {
            for(RecordType rt : rtype) {
                if(rt.DeveloperName == 'Instructor') 
                    caRtId = rt.Id;
                else if(rt.DeveloperName == 'Project_Planned_Days_Off')
                    pdoRtId = rt.Id;
                else if(rt.DeveloperName == 'DLI_W_TO_Opportunities')
                    oppRtId = rt.Id;
                else 
                    proRtId = rt.Id;
            }
        }
        
        List<Contact> con = new List<Contact> {
            new Contact(LastName = 'Test Cont1', Email = 'test1@gmail.com'),
            new Contact(LastName = 'Test Cont2', Email = 'test2@gmail.com')
        };
        insert con;
  
        if(pro.size() > 0) {
            
            proId.add(pro[0].Id);
            proId.add(pro[1].Id);
            
            pro[0].RecordTypeId = proRtId;
            pro[1].RecordtypeId = proRtId;
            update pro;
            
            opp[0].recordTypeId = oppRtId;
            opp[0].Project_Type__c = 'Resident LT';
            opp[1].recordTypeId = oppRtId;
            opp[1].Project_Type__c = 'AFPAK';
            update opp;
            
            List<AcctSeed__Project_Task__c> proTask = [SELECT Id, Name FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN :proId LIMIT 2];
            List<Schedule__c> sch = [SELECT Id, Name FROM Schedule__c WHERE Project__c  IN :proId LIMIT 2];

            if(opp.size() > 0 && proTask.size() > 0 && sch.size() > 0) {
                
                Test.startTest();
                
                List<Contact_Assignments__c> conAss = new List<contact_Assignments__c> {
                    new Contact_Assignments__c(Opportunity_Name__c = opp[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active'),
                    new Contact_Assignments__c(Opportunity_Name__c = opp[1].Id, RecordTypeId = caRtId, Candidate_Name__c = con[1].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active')
                };
                insert conAss;
                
                Test.stopTest();
                
                List<Planned_Days_Off__c> pdoDel = new List<Planned_Days_Off__c> {
                    new Planned_Days_Off__c(Opportunity__c = opp[1].Id, Contact__c = con[1].Id, Date__c = System.today().addDays(-1), Description__c = 'Test2', RecordTypeId = pdoRtId),
                    new Planned_Days_Off__c(Project__c = pro[1].Id, Contact__c = con[1].Id, Date__c = System.today().addDays(-1), Description__c = 'Test4', RecordTypeId = pdoRtId)
                };
                insert pdoDel;
                 
                List<Planned_Days_Off__c> pdoIn = new List<Planned_Days_Off__c> {
                    new Planned_Days_Off__c(Opportunity__c = opp[0].Id, Contact__c = con[0].Id, Date__c = System.today().addDays(-1), Description__c = 'Test1', RecordTypeId = pdoRtId),
                    new Planned_Days_Off__c(Project__c = pro[0].Id, Contact__c = con[0].Id, Date__c = System.today().addDays(-1), Description__c = 'Test3', RecordTypeId = pdoRtId)
                };
                
                
                for(Integer i = 0; i < pro.size(); i++) {
                    pro[i].Start_Date__c = System.today().addDays(-5);
                    pro[i].End_Date__c = System.today().addDays(30);
                }
                
                for(Integer i = 0; i < opp.size(); i++) {
                    opp[i].Start_Date__c = System.today().addDays(-5);
                    opp[i].End_Date__c = System.today().addDays(30);
                }
                               
                List<Assessment_Report__c> assessmentReport = new List<Assessment_Report__c> {
                    new Assessment_Report__c(Name = 'Test Report1', Instructor__c = con[0].Id, Project__c = pro[0].Id, Report_Type__c = 'DLI',Status__c = 'Draft',Language__c = 'Tamil',Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
                };
                
                insert assessmentReport;
                
                assessmentReport[0].Report_Date__c = System.today().addDays(5);
                
                if(pdoIn.size() > 0 && pdoDel.size() > 0) {
                    
                    String status1 = ManageProjectDatescontroller.saveAllDetails(JSON.serialize(pro), JSON.serialize(opp), JSON.serialize(proTask), JSON.serialize(conAss), JSON.serialize(sch),JSON.serialize(pdoIn), JSON.serialize(pdoDel), JSON.serialize(assessmentReport),'');
                    /*if(status1 != '')
                    System.assertEquals('Failure', status1);*/
                }
            }
        }
    } 
    
    // For cloning the Project related PlannedDaysOff
    private static testMethod void testMethod4() {
        
        List<AcctSeed__Project__c> pro = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 2];
        
        List<RecordType> rtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Contact_Assignments__c', 'Planned_Days_Off__c', 'AcctSeed__Project__c') AND DeveloperName IN ('Instructor', 'DLI_W_LT_Training_Holidays', 'Instructor_Planned_Days_Off', 'Student_Planned_Days_Off', 'Staff_Planned_Days_Off', 'DLI_W_LT_Projects')];
        Id caRtId, pdoDliRtId, pdoInsRtId, pdoStuRtId, pdoStaffRtId, proRtId;
        
        if(rtype.size() > 0) {
            for(RecordType rt : rtype) {
                if(rt.DeveloperName == 'Instructor') 
                    caRtId = rt.Id;
                else if(rt.DeveloperName == 'DLI_W_LT_Training_Holidays')
                    pdoDliRtId = rt.Id;
                else if(rt.DeveloperName == 'Instructor_Planned_Days_Off')
                    pdoInsRtId = rt.Id;   
                else if(rt.DeveloperName == 'Student_Planned_Days_Off')
                    pdoStuRtId = rt.Id;   
                else if(rt.DeveloperName == 'Staff_Planned_Days_Off')
                    pdoStaffRtId = rt.Id;   
                else 
                    proRtId = rt.Id;
            }
        }
        
        List<Contact> con = new List<Contact> {
            new Contact(LastName = 'Test Cont1', Email = 'test1@gmail.com'),
            new Contact(LastName = 'Test Cont2', Email = 'test2@gmail.com')
        };
        insert con;
        
        List<AcctSeed__Project__c> oldPro = new List<AcctSeed__Project__c>();
        List<AcctSeed__Project__c> newPro = new List<AcctSeed__Project__c>();
        Integer i = 0;
        if(pro.size() > 0) {
            
            for(AcctSeed__Project__c proj : pro) {
                proj.RecordTypeId = proRtId;
                if(i == 0) {
                    proj.Start_Date__c = System.today().addDays(-5);
                    proj.End_Date__c = System.today().addDays(20);
                    oldPro.add(proj);
                    i = 1;
                } else {
                    proj.Start_Date__c = System.today().addDays(-3);
                    proj.End_Date__c = System.today().addDays(15);
                    newPro.add(proj);
                    i = 0;
                }
            }
           
            update oldPro;
            update newPro;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAss = new List<contact_Assignments__c> {
                new Contact_Assignments__c(Project__c = oldPro[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active'),
                new Contact_Assignments__c(Project__c = newPro[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[1].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active')
            };
            insert conAss;
            
            Test.stopTest();
            
            List<Planned_Days_Off__c> pdo = new List<Planned_Days_Off__c> {
                new Planned_Days_Off__c(Date__c = System.today().addDays(-2), Description__c = 'Test1', RecordTypeId = pdoDliRtId),
                new Planned_Days_Off__c(Contact__c = con[0].Id, Date__c = System.today().addDays(-1), Description__c = 'Test2', RecordTypeId = pdoInsRtId),
                new Planned_Days_Off__c(Contact__c = con[0].Id, Date__c = System.today().addDays(1), Description__c = 'Test3', RecordTypeId = pdoStuRtId),
                new Planned_Days_Off__c(Contact__c = con[0].Id, Date__c = System.today().addDays(2), Description__c = 'Test4', RecordTypeId = pdoStaffRtId),
                new Planned_Days_Off__c(Date__c = System.today().addDays(3), Description__c = 'Test5', RecordTypeId = pdoInsRtId),
                new Planned_Days_Off__c(Date__c = System.today().addDays(4), Description__c = 'Test6', RecordTypeId = pdoStuRtId),
                new Planned_Days_Off__c(Date__c = System.today().addDays(5), Description__c = 'Test7', RecordTypeId = pdoStaffRtId),
                new Planned_Days_Off__c(Contact__c = con[0].Id, Project__c = oldPro[0].Id, Date__c = System.today().addDays(6), Description__c = 'Test8', RecordTypeId = pdoDliRtId),
                new Planned_Days_Off__c(Date__c = System.today().addDays(-10), Description__c = 'Test9', RecordTypeId = pdoInsRtId)
            };
            insert pdo;
            
            List<Id> conId = new List<Id>();
            conId.add(conAss[0].Candidate_Name__c);
            conId.add(conAss[0].Candidate_Name__c);
            
            if(conId.size() > 0) {
                
                List<ManageProjectDatescontroller.Days_Off_Wrapper> dowList = new List<ManageProjectDatescontroller.Days_Off_Wrapper>();
                for(Planned_Days_Off__c pdoff : pdo) {
                    if((pdoff.Contact__c == null && pdoff.RecordTypeId != pdoDliRtId) ||(pdoff.Contact__c == null && pdoff.RecordTypeId != pdoDliRtId)) {
                        ManageProjectDatescontroller.Days_Off_Wrapper dow = new ManageProjectDatescontroller.Days_Off_Wrapper();
                        dow.dayOff = pdoff;
                        dow.contactName = pdoff.Contact__r.Name;
                        dowList.add(dow);
                    }
                }
                List<ManageProjectDatescontroller.Days_Off_Wrapper> warp1 = ManageProjectDatescontroller.clonePlannedDaysOff(JSON.serialize(oldPro), JSON.serialize(newPro), JSON.serialize(dowList), 'Project', conId);
                if(warp1 != Null)
                    System.assertEquals(true,warp1[0].selected);
                List<ManageProjectDatescontroller.Days_Off_Wrapper> warp2 = ManageProjectDatescontroller.clonePlannedDaysOff(JSON.serialize(newPro), JSON.serialize(oldPro), JSON.serialize(dowList), 'Project', conId);
                if(warp2 != Null)
                    System.assertEquals(true,warp2[0].selected);
            }
        }
       
    } 
    
    // For cloning the Opportunity related PlannedDaysOff
    private static testMethod void testMethod5() {
        
        List<Opportunity> opp = [SELECT Id, Name FROM Opportunity LIMIT 2];
        
        List<RecordType> rtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Contact_Assignments__c', 'Planned_Days_Off__c', 'Opportunity') AND DeveloperName IN ('Instructor', 'DLI_W_LT_Training_Holidays', 'Instructor_Planned_Days_Off', 'Student_Planned_Days_Off', 'Staff_Planned_Days_Off', 'DLI_W_TO_Opportunities')];
        Id caRtId, pdoDliRtId, pdoInsRtId, pdoStuRtId, pdoStaffRtId, oppRtId;
        
        if(rtype.size() > 0) {
            for(RecordType rt : rtype) {
                if(rt.DeveloperName == 'Instructor') 
                    caRtId = rt.Id;
                else if(rt.DeveloperName == 'DLI_W_LT_Training_Holidays')
                    pdoDliRtId = rt.Id;
                else if(rt.DeveloperName == 'Instructor_Planned_Days_Off')
                    pdoInsRtId = rt.Id;   
                else if(rt.DeveloperName == 'Student_Planned_Days_Off')
                    pdoStuRtId = rt.Id;   
                else if(rt.DeveloperName == 'Staff_Planned_Days_Off')
                    pdoStaffRtId = rt.Id;   
                else 
                    oppRtId = rt.Id;
            }
        }
        
        List<Contact> con = new List<Contact> {
            new Contact(LastName = 'Test Cont1', Email = 'test1@gmail.com'),
            new Contact(LastName = 'Test Cont2', Email = 'test2@gmail.com')
        };
        insert con;
        
        List<Opportunity> oldOpp = new List<Opportunity>();
        List<Opportunity> newOpp = new List<Opportunity>();
        Integer i = 0;
        if(opp.size() > 0) {
            
            for(Opportunity oppor : opp) {
                oppor.RecordTypeId = oppRtId;
                if(i == 0) {
                    oppor.Start_Date__c = System.today().addDays(-5);
                    oppor.End_Date__c = System.today().addDays(20);
                    oldOpp.add(oppor);
                    i = 1;
                } else {
                    oppor.Start_Date__c = System.today().addDays(-3);
                    oppor.End_Date__c = System.today().addDays(15);
                    newOpp.add(oppor);
                    i = 0;
                }
            }
           
            update oldOpp;
            update newOpp;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAss = new List<contact_Assignments__c> {
                new Contact_Assignments__c(Opportunity_Name__c = oldOpp[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active'),
                new Contact_Assignments__c(Opportunity_Name__c = newOpp[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[1].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active')
            };
            insert conAss;
            
            Test.stopTest();
            
            List<Planned_Days_Off__c> pdo = new List<Planned_Days_Off__c> {
                new Planned_Days_Off__c(Date__c = System.today().addDays(-2), Description__c = 'Test1', RecordTypeId = pdoDliRtId),
                new Planned_Days_Off__c(Contact__c = con[0].Id, Date__c = System.today().addDays(-1), Description__c = 'Test2', RecordTypeId = pdoInsRtId),
                new Planned_Days_Off__c(Contact__c = con[0].Id, Date__c = System.today().addDays(1), Description__c = 'Test3', RecordTypeId = pdoStuRtId),
                new Planned_Days_Off__c(Contact__c = con[0].Id, Date__c = System.today().addDays(2), Description__c = 'Test4', RecordTypeId = pdoStaffRtId),
                new Planned_Days_Off__c(Date__c = System.today().addDays(3), Description__c = 'Test5', RecordTypeId = pdoInsRtId),
                new Planned_Days_Off__c(Date__c = System.today().addDays(4), Description__c = 'Test6', RecordTypeId = pdoStuRtId),
                new Planned_Days_Off__c(Date__c = System.today().addDays(5), Description__c = 'Test7', RecordTypeId = pdoStaffRtId),
                new Planned_Days_Off__c(Contact__c = con[0].Id, Opportunity__c = oldOpp[0].Id, Date__c = System.today().addDays(6), Description__c = 'Test8', RecordTypeId = pdoDliRtId),
                new Planned_Days_Off__c(Date__c = System.today().addDays(-10), Description__c = 'Test9', RecordTypeId = pdoInsRtId)
            };
            insert pdo;

            List<Id> conId = new List<Id>();
            conId.add(conAss[0].Candidate_Name__c);
            conId.add(conAss[0].Candidate_Name__c);
            //Test.Starttest();
            if(conId.size() > 0) {
                
                List<ManageProjectDatescontroller.Days_Off_Wrapper> dowList = new List<ManageProjectDatescontroller.Days_Off_Wrapper>();
                for(Planned_Days_Off__c pdoff : pdo) {
                    if((pdoff.Contact__c == null && pdoff.RecordTypeId != pdoDliRtId) ||(pdoff.Contact__c == null && pdoff.RecordTypeId != pdoDliRtId)) {
                        ManageProjectDatescontroller.Days_Off_Wrapper dow = new ManageProjectDatescontroller.Days_Off_Wrapper();
                        dow.dayOff = pdoff;
                        dow.contactName = pdoff.Contact__r.Name;
                        dowList.add(dow);
                    }
                }
                List<ManageProjectDatescontroller.Days_Off_Wrapper> warp1 = ManageProjectDatescontroller.clonePlannedDaysOff(JSON.serialize(oldOpp), JSON.serialize(newOpp), JSON.serialize(dowList), 'Opportunity', conId);
                if(warp1 != Null)
                    System.assertEquals(true,warp1[0].selected);
                List<ManageProjectDatescontroller.Days_Off_Wrapper> warp2 = ManageProjectDatescontroller.clonePlannedDaysOff(JSON.serialize(newOpp), JSON.serialize(oldOpp), JSON.serialize(dowList), 'Opportunity', conId);
                if(warp2 != Null)
                    System.assertEquals(true,warp2[0].selected);
            }
            //Test.Stoptest();
        }
    } 
    
    // For webServices Method - Opportunity with Project
    private static testMethod void testMethod6() {
        
        List<AcctSeed__Project__c> pro = [SELECT Id, Name, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c  != null LIMIT 2];
        if(pro.size() > 0) {
            Id proId = ManageProjectDatescontroller.isProjectExist(pro[0].AcctSeed__Opportunity__c);
            System.assertEquals(pro[0].Id, proId);
        }
    } 
    
    // For webServices Method - Opportunity without Project
    private static testMethod void testMethod7() {
        
        List<Account> acc = [SELECT Id FROM Account LIMIT 2];
        List<RecordType> rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'DLI_W_TO_Opportunities'];
        if(acc.size() > 0 && rt.size() > 0) {
            List<Opportunity> opp = new List<Opportunity> {
                new Opportunity(Name = 'Test Opp 1', StageName = 'Inquiry', CloseDate = System.Today()+20, AccountId = acc[0].Id, RecordTypeId = rt[0].Id),
                new Opportunity(Name = 'Test Opp 2', StageName = 'Inquiry', CloseDate = System.Today()+20, AccountId = acc[1].Id, RecordTypeId = rt[0].Id)
            };
            insert opp;
        
            if(opp.size() > 0) {
                String ret = ManageProjectDatescontroller.isProjectExist(opp[0].Id);
                System.assertEquals('No', ret);
            }
        }
    } 
      // For Query the Contact Assignment, Schedule, PlannedDaysOff and ProjectTask records related to Project
    private static testMethod void testMethod8() { 
       
        List<Account> acc = [SELECT Id, Name FROM Account LIMIT 1];
        List<AcctSeed__Project__c> pro = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 2];
        pro[0].AcctSeed__Account__c = acc[0].Id;
        update pro[0];
        
        List<RecordType> rtype = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Contact_Assignments__c','AcctSeed__Project__c') AND DeveloperName IN ('Instructor','DLI_W_LT_Projects')];
        Id caRtId, proRtId;
        
        if(rtype.size() > 0) {
            for(RecordType rt : rtype) {
                if(rt.DeveloperName == 'Instructor') 
                    caRtId = rt.Id;
                else 
                    proRtId = rt.Id;
            }
        }
        
        List<Contact> con = new List<Contact> {
            new Contact(LastName = 'Test Cont1', Email = 'test1@gmail.com'),
            new Contact(LastName = 'Test Cont2', Email = 'test2@gmail.com')
        };
        insert con;
        
         List<AcctSeed__Cost_Rates__c>  costrateList = new List<AcctSeed__Cost_Rates__c>{
            new AcctSeed__Cost_Rates__c(Contact__c = con[0].Id, Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA MTT',AcctSeed__Hourly_Cost__c = 43 , Status__c = 'Approved',Payroll_Item__c='R'),
            new AcctSeed__Cost_Rates__c(Contact__c = con[0].Id,Pay_Type__c = 'Salary', Rate_Type__c = 'Non-SCA Testing',AcctSeed__Hourly_Cost__c = 22, Per_Test_Cost__c = 1, Status__c = 'Approved',Payroll_Item__c='P')
        };
        insert costrateList;
        
        if(pro.size() > 0) {
            
            pro[0].RecordTypeId = proRtId;
            pro[1].RecordTypeId = proRtId;
            update pro;
            
            List<Contact_Assignments__c> conAss = new List<contact_Assignments__c> {
                new Contact_Assignments__c(Project__c = pro[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active',Rate_Card_Rate__c = costrateList[0].Id),
                new Contact_Assignments__c(Project__c = pro[0].Id, RecordTypeId = caRtId, Candidate_Name__c = con[1].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Status__c = 'Active')
            };
            insert conAss;
                        
            if(costrateList.size() > 0){
                costrateList[1].Prior_Version__c = costrateList[0].Id;
                costrateList[0].Status__c = 'Inactive';
                
                update costrateList;
            }
            
            ManageProjectDatescontroller mpdc = new ManageProjectDatescontroller();
            ManageProjectDatescontroller.ConAssign_Sch_PlannedDay warp = ManageProjectDatescontroller.getChilDetails(pro[0].Id,'Active',null);
            if(warp != null)
                System.assertEquals('Project', warp.parentType);
        }
    }  
    
    // To cover try - catch block in UpdateProject_Queuable
    private static testMethod void UpdateProject_Queuable_Test() {
       
        List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c>();
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        Id usrId = UserInfo.getUserId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = acc[0].Id, Name = 'Test PGLS Project 1',AcctSeed__Status__c = 'Active',Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(30));
        projList.add(proj);
        
        UpdateProject_Queuable update_Project = new UpdateProject_Queuable(projList, new List<AcctSeed__Project_Task__c>(), new List<Planned_Days_Off__c>(), new List<Planned_Days_Off__c>(), new List<Assessment_Report__c>(), new List<Opportunity>());
        Test.startTest();
            System.enqueueJob(update_Project);
        Test.stopTest();            
    }
}