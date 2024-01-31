@isTest
private class CreateEventsFromSchedule_Test {

    @testSetup static void setup() {
    
        Test.startTest();
            List<AcctSeed__Time_Card_Day__c> tcdList = TestClassUtil.createTestTimeCardDay();
        Test.stopTest();
        List<Events__c> eveList = TestClassUtil.createTestEvent();
        List<Room__c> roomList = TestClassUtil.createTestRoom();
        List<Planned_Days_Off__c> pdoList = TestClassUtil.createTestPlannedDaysOff();
    }
    
    // To create an Event Records from Schedule
    private static testMethod void testMethod1() {
        
        List<Events__c> eveList = [SELECT Id, Name, Schedule__c FROM Events__c];
        List<AcctSeed__Project_Task__c> proTask = [SELECT Id, Name FROM AcctSeed__Project_Task__c LIMIT 1];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = 'DLS_Employee'];
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c LIMIT 2];
        List<Schedule__c> scheList = [SELECT Id, Name FROM Schedule__c WHERE Status__c != 'Active'];
        List<Planned_Days_Off__c> pdoList = [SELECT Id, Name fROM Planned_Days_Off__c LIMIT 2];
        
        if(proTask.size() > 0 && conList.size() > 0 && roomList.size() > 0 && eveList.size() > 0 && pdoList.size() > 0) {
            
            List<Schedule__c> schList = [SELECT Id,Name,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c,Instructor__c,Room__c,
                                         Meeting_URL__c,Project__c,Project_Task__c FROM Schedule__c
                                         WHERE Project__r.AcctSeed__Status__c = 'Active' AND Status__c = 'Active'];
            
            
            if(schList.size() > 0) {        
                
                for(AcctSeed__Project_Task__c pt : proTask) {
                    pt.Project_Task_Type__c = 'Language Training';
                }
                update proTask;
                
                Test.startTest();
                             
                for(Schedule__c sch : schList) {
                    sch.Project_Task__c = proTask[0].Id;
                    sch.Instructor__c = conList[0].Id;
                    sch.Room__c = roomList[0].Id;
                    sch.Prior_Schedule__c = scheList[0].Id;
                    sch.Start_Date__c =  system.today().toStartofWeek().addDays(1).addDays(-8);
                    sch.End_Date__c = System.today().addDays(10);
                    sch.Varied_Day__c = false;
                    sch.Varied_Time__c = false;
                    sch.Travel_Required__c = false;
                    sch.Monday__c = true;
                    sch.Tuesday__c = true;
                    sch.Wednesday__c = true;
                    sch.Thursday__c = true;
                }
                update schList;
                
                Date minStart, maxEnd;
                
                for(Schedule__c sch : schList) {
                    if(minStart == null || minStart > sch.Start_Date__c){
                        minStart = sch.Start_Date__c;
                    }
                    
                    if(maxEnd == null || maxEnd < sch.End_Date__c){
                        maxEnd = sch.End_Date__c;
                    }  
                }
                
                
                List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id, Name, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c WHERE Status__c  != 'Unposted' LIMIT 2];      
                
                if(tcdList.size() > 0) {
                    
                    Set<Id> tclId = new set<Id>();
                    Integer i = 0;
                    
                    for(AcctSeed__Time_Card_Day__c tcd : tcdList) {
                        tclId.add(tcd.AcctSeed__Time_Card_Line__c);
                        tcd.AcctSeed__Date__c = minStart.addDays(i);
                        tcd.Status__c = 'Approved';
                        i++;
                    }
                    update tcdList;
                    
                    List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id, Name, AcctSeed__Time_Card__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :tclId];
                    
                    if(tclList.size() > 0) {
                        
                        Set<Id> tcId = new set<Id>();
                        for(AcctSeed__Time_Card_Line__c tcl : tclList) {
                            tcId.add(tcl.AcctSeed__Time_Card__c);
                            tcl.AcctSeed__Project__c = schList[0].Project__c;
                            tcl.AcctSeed__Project_Task__c = schList[0].Project_Task__c;
                        }
                        update tclList;
                        
                        List<AcctSeed__Time_Card__c> tcList = [SELECT Id, Name, Intructor__c FROM AcctSeed__Time_Card__c WHERE Id = :tcId];
                        
                        if(tcList.size() > 0) {
                           for(AcctSeed__Time_Card__c tc : tcList) {
                               tc.Intructor__c = schList[0].Instructor__c;
                           }
                           update tcList;
                        }
                    }
                }
                
                List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Planned_Days_Off__c' AND DeveloperName IN ('DLI_W_LT_Training_Holidays','Project_Planned_Days_Off')];
                
                if(rtype.size() > 0) {
                    Id dliId, proPDOId;
                    for(RecordType rt : rType) {
                        if(rt.DeveloperName == 'DLI_W_LT_Training_Holidays') 
                            dliId = rt.Id;
                        else if(rt.DeveloperName == 'Project_Planned_Days_Off') 
                            proPDOId = rt.Id;
                    }
                    
                    pdoList[0].RecordTypeId = dliId;
                    pdoList[1].Project__c = schList[0].Project__c;
                    pdoList[1].RecordTypeId = proPDOId;
                    update pdoList;
                }
                 
                eveList[0].Schedule__c = schList[0].Id;
                eveList[0].Status__c = 'Scheduled';
                eveList[1].Schedule__c = schList[0].Id;
                eveList[1].Status__c = 'Scheduled';
                update eveList;
                
                Test.stopTest();
                
                CreateEventsFromSchedule schEveBatch = new CreateEventsFromSchedule(schList[0].Project__c);
                database.executeBatch(schEveBatch, 1);
                
            }
        }
    } 
    
    // To create an Event Records from Schedule
    private static testMethod void testMethod2() {
        
        List<Events__c> eveList = [SELECT Id, Name, Schedule__c FROM Events__c];
        List<AcctSeed__Project_Task__c> proTask = [SELECT Id, Name FROM AcctSeed__Project_Task__c LIMIT 1];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = 'DLS_Employee'];
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c LIMIT 2];
        List<Schedule__c> scheList = [SELECT Id, Name FROM Schedule__c WHERE Status__c != 'Active'];
        List<Planned_Days_Off__c> pdoList = [SELECT Id, Name fROM Planned_Days_Off__c LIMIT 2];
        
        if(proTask.size() > 0 && conList.size() > 0 && roomList.size() > 0 && eveList.size() > 0 && pdoList.size() > 0) {
             
            List<Schedule__c> schList = [SELECT Id,Name,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c,Instructor__c,Room__c,
                                         Meeting_URL__c,Project__c,Project_Task__c FROM Schedule__c
                                         WHERE Project__r.AcctSeed__Status__c = 'Active' AND Status__c = 'Active'];
            
            if(schList.size() > 0) {        
                   
                for(AcctSeed__Project_Task__c pt : proTask) {
                    pt.Project_Task_Type__c = 'Language Training';
                }
                update proTask;
                
                Test.startTest();
                                          
                for(Schedule__c sch : schList) {
                    sch.Project_Task__c = proTask[0].Id;
                    sch.Instructor__c = conList[0].Id;
                    sch.Room__c = roomList[0].Id;
                    sch.Prior_Schedule__c = scheList[0].Id;
                    sch.Start_Date__c =  system.today().addDays(-1);
                    sch.End_Date__c = System.today().addDays(10);
                    sch.Varied_Day__c = false;
                    sch.Varied_Time__c = false;
                    sch.Travel_Required__c = false;
                    sch.Sunday__c = true;
                    sch.Friday__c = true;
                    sch.Saturday__c = true;
                }
                update schList;
                
                Test.stopTest();
                
                Date minStart, maxEnd;
                
                for(Schedule__c sch : schList) {
                    if(minStart == null || minStart > sch.Start_Date__c){
                        minStart = sch.Start_Date__c;
                    }
                    
                    if(maxEnd == null || maxEnd < sch.End_Date__c){
                        maxEnd = sch.End_Date__c;
                    }  
                }
                
                
                List<AcctSeed__Time_Card_Day__c> tcdList = [SELECT Id, Name, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c WHERE Status__c  != 'Unposted' LIMIT 2];      
                
                if(tcdList.size() > 0) {
                    
                    Set<Id> tclId = new set<Id>();
                    Integer i = 0;
                    
                    for(AcctSeed__Time_Card_Day__c tcd : tcdList) {
                        tclId.add(tcd.AcctSeed__Time_Card_Line__c);
                        tcd.AcctSeed__Date__c = minStart.addDays(i);
                        tcd.Status__c = 'Approved';
                        i++;
                    }
                    update tcdList;
                    
                    List<AcctSeed__Time_Card_Line__c> tclList = [SELECT Id, Name, AcctSeed__Time_Card__c FROM AcctSeed__Time_Card_Line__c WHERE Id IN :tclId];
                    
                    if(tclList.size() > 0) {
                        
                        Set<Id> tcId = new set<Id>();
                        for(AcctSeed__Time_Card_Line__c tcl : tclList) {
                            tcId.add(tcl.AcctSeed__Time_Card__c);
                            tcl.AcctSeed__Project__c = schList[0].Project__c;
                            tcl.AcctSeed__Project_Task__c = schList[0].Project_Task__c;
                        }
                        update tclList;
                        
                        List<AcctSeed__Time_Card__c> tcList = [SELECT Id, Name, Intructor__c FROM AcctSeed__Time_Card__c WHERE Id = :tcId];
                        
                        if(tcList.size() > 0) {
                           for(AcctSeed__Time_Card__c tc : tcList) {
                               tc.Intructor__c = schList[0].Instructor__c;
                           }
                           update tcList;
                        }
                    }
                }
                
                List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Planned_Days_Off__c' AND DeveloperName IN ('DLI_W_LT_Training_Holidays','Project_Planned_Days_Off')];
                
                if(rtype.size() > 0) {
                    Id dliId, proPDOId;
                    for(RecordType rt : rType) {
                        if(rt.DeveloperName == 'DLI_W_LT_Training_Holidays') 
                            dliId = rt.Id;
                        else if(rt.DeveloperName == 'Project_Planned_Days_Off') 
                            proPDOId = rt.Id;
                    }
                    
                    pdoList[0].RecordTypeId = dliId;
                    pdoList[1].RecordTypeId = proPDOId;
                    update pdoList;
                }
                
                CreateEventsFromSchedule schEveBatch = new CreateEventsFromSchedule(null);
                database.executeBatch(schEveBatch, 1);
                
                
            }
        }
    }
    
    // To create an Event Records from Schedule
    private static testMethod void testMethod3() {
        
        List<Events__c> eveList = [SELECT Id, Name, Schedule__c FROM Events__c];
        List<AcctSeed__Project_Task__c> proTask = [SELECT Id, Name FROM AcctSeed__Project_Task__c LIMIT 1];
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = 'DLS_Employee'];
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c LIMIT 2];
        List<Schedule__c> scheList = [SELECT Id, Name FROM Schedule__c WHERE Status__c != 'Active'];
        List<Planned_Days_Off__c> pdoList = [SELECT Id, Name fROM Planned_Days_Off__c LIMIT 2];
        
        if(proTask.size() > 0 && conList.size() > 0 && roomList.size() > 0 && eveList.size() > 0 && pdoList.size() > 0) {
             
            List<Schedule__c> schList = [SELECT Id,Name,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c,Instructor__c,Room__c,
                                         Meeting_URL__c,Project__c,Project_Task__c FROM Schedule__c
                                         WHERE Project__r.AcctSeed__Status__c = 'Active' AND Status__c = 'Active'];
            
            if(schList.size() > 0) {        
                
                for(AcctSeed__Project_Task__c pt : proTask) {
                    pt.Project_Task_Type__c = 'Language Training';
                }
                update proTask;
                
                Test.startTest();
                           
                for(Schedule__c sch : schList) {
                    sch.Project_Task__c = proTask[0].Id;
                    sch.Instructor__c = conList[0].Id;
                    sch.Room__c = roomList[0].Id;
                    sch.Prior_Schedule__c = scheList[0].Id;
                    sch.Start_Date__c =  system.today().addDays(-1);
                    sch.End_Date__c = System.today().addDays(10);
                    sch.Varied_Day__c = false;
                    sch.Varied_Time__c = false;
                    sch.Travel_Required__c = false;
                    sch.Sunday__c = true;
                    sch.Friday__c = true;
                    sch.Saturday__c = true;
                }
                update schList;
                
                Test.stopTest();
                  
                List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Planned_Days_Off__c' AND DeveloperName IN ('DLI_W_LT_Training_Holidays','Project_Planned_Days_Off')];
                
                if(rtype.size() > 0) {
                    Id dliId, proPDOId;
                    for(RecordType rt : rType) {
                        if(rt.DeveloperName == 'DLI_W_LT_Training_Holidays') 
                            dliId = rt.Id;
                        else if(rt.DeveloperName == 'Project_Planned_Days_Off') 
                            proPDOId = rt.Id;
                    }
                    
                    pdoList[0].RecordTypeId = dliId;
                    pdoList[1].RecordTypeId = proPDOId;
                    update pdoList;
                }
                
                CreateEventsFromSchedule schEveBatch = new CreateEventsFromSchedule(null);
                database.executeBatch(schEveBatch, 1);
               
                
            }
        }
    }  
}