@isTest
private class LTSProjectSummaryViewCntrl_Test {
    @testSetup static void setup(){
        Test.startTest();
        List<Contact_Assignments__c> caList = TestClassUtil.createTestContactAssignment();
        TestClassUtil.createTestLocations();
        Test.stopTest();
    }
    
    // For getting lookup Records, Saved_Search__c Records and getting Status pickListValues
    private static testMethod void testMethod1() {
        List<Contact> conList = [SELECT Id, Name FROM Contact ];
        LTSProjectSummaryViewCntrl.getLookupRecords('Contact','Test','RecordType.DeveloperName=\'Candidate\'');
        LTSProjectSummaryViewCntrl.getSavedSearch();
        List<String> retString = LTSProjectSummaryViewCntrl.getPicklistVal('AcctSeed__Project__c', 'AcctSeed__Status__c');  
        if(retString.size() > 0) {
            String returnString = string.valueOf(retString);
            System.assert(returnString.contains('Active'));
        }      
    }
    
    // For updating Project Status
    private static testMethod void testMethod2() {
        
        List<AcctSeed__Project__c> proList = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 2];
        
        if(proList.size() > 0) {
            for(AcctSeed__Project__c pro : proList) {
                pro.AcctSeed__Status__c = 'Order';
            }
            LTSProjectSummaryViewCntrl.updateProStatus(JSON.serialize(proList));
            List<AcctSeed__Project__c> proUp = [SELECT Id, Name, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE id = :proList[0].Id];
            if(proUp.size() > 0)
                System.assertEquals('Order', proUp[0].AcctSeed__Status__c);
        }
    }
   
    // For updating / deleting Save Searches Record
    private static testMethod void testMethod3() {
        
        List<Saved_Search__c> saveSearchRec = new List<Saved_Search__c> {
            new Saved_Search__c(Name = 'Test Save Search 1', Filter_Value__c = 'Test Filter Values 1'),
            new Saved_Search__c(Name = 'Test Save Search 2', Filter_Value__c = 'Test Filter Values 2')
        };
        
        List<Saved_Search__c> saveSearchRet = LTSProjectSummaryViewCntrl.SaveSearches(JSON.serialize(saveSearchRec));
        List<Saved_Search__c> saveSearchUp = [SELECT Id, Name FROM Saved_Search__c];
        if(saveSearchUp.size() > 0 && saveSearchRet.size() > 0)
            System.assertEquals(saveSearchUp.size(), saveSearchRet.size());
        
        LTSProjectSummaryViewCntrl.deleteSavedSearch(saveSearchUp[0].Id);
        
        saveSearchUp[0].Id = null;
        LTSProjectSummaryViewCntrl.deleteSavedSearch(saveSearchUp[0].Id);
    }
    
    // For updating Contact Record
    private static testMethod void testMethod4() {
        
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(conList.size() > 0) {
            for(Contact con : conList) {
                con.FirstName = 'FN';
            }
            List<Contact> conRet = LTSProjectSummaryViewCntrl.updateContact(JSON.serialize(conList));
            if(conRet.size() > 0)
                System.assertEquals('FN', conRet[0].FirstName);
            
            for(Contact con : conList) {
                con.FirstName = 'FN';
                con.Id = null;
            }
            LTSProjectSummaryViewCntrl.updateContact(JSON.serialize(conList));
            
        }
    }
    
    // For downloading CSV File
    private static testMethod void testMethod5() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, RecordType.DeveloperName FROM Contact_Assignments__c WHERE Project__c != null];
        if(conAssList.size() > 0) {
            List<String> proIds = new List<String>();
            
            for(Contact_Assignments__c ca : conAssList) {
                proIds.add(ca.Project__c);
            }
            
            List<LTSProjectSummaryViewCntrl.caWrapper> retwar = LTSProjectSummaryViewCntrl.downloadCsvFile(proIds,'Instructor');
            LTSProjectSummaryViewCntrl.getActiveStudentInstructorCount(proIds);
            if(retwar.size() > 0) {
                String returnWarp = String.valueOf(retwar);
                System.assert(returnWarp.contains('@test.com'));
            }
        }
    }
    
    // For Print button
    private static testMethod void testMethod6() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Project__c, RecordType.DeveloperName,RecordTypeId FROM Contact_Assignments__c WHERE Project__c != null];
        List<Contact> contactList = [SELECT Id,Name,AccountId FROM Contact LIMIT 1];
        List<MTT_Location__c> loc = [SELECT Id,Name FROM MTT_Location__c LIMIT 1];
        String accId = String.valueOf(contactList[0].AccountId);
        String conId = String.valueOf(contactList[0].Id);
        String rtId = String.valueOf(conAssList[0].RecordTypeId);
        String locId = String.valueOf(loc[0].Id);
        
        LTSProjectSummaryViewCntrl.projectRecordsForPrintView(accId,conId,'Project Manager',rtId,new List<String>{'Active','Planned'},locId,new List<String>{'Active'},'Name','DESC');
        LTSProjectSummaryViewCntrl.projectRecordsForPrintView('','','All',rtId,new List<String>{'Active','Planned'},locId,new List<String>{'Active'},'Start_Date__C','DESC');
        LTSProjectSummaryViewCntrl.projectRecordsForPrintView('','','All','',new List<String>{'Active','Planned'},'',new List<String>{'Active'},'End_Date__c','DESC');
        LTSProjectSummaryViewCntrl.projectRecordsForPrintView('','','All',rtId,new List<String>{},'',new List<String>{'Active'},'DLS_Class__c','ASC');
    }
}