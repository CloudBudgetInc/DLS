/*
Developed by GRK
Used in Lightning Component GenerateDispositionForm
*/
Public Class GenerateDispositionFormCtrl{
    @RemoteAction
    public static string getFromAndToDate(String AccId){
        
        String rtnVal;
        List<Account> accts = [SELECT Id,Name FROM Account WHERE Id =: AccId];
        if( accts != null && accts.size() > 0 ) {
            if(accts[0].Name.contains('DLI-W')) {
                Date lastMonthSDate = System.today().addMonths(-1).toStartofMonth();
                Date lastMonthEDate = System.today().toStartofMonth().addDays(-1);
                
                System.debug('lastMonthSDate:::'+lastMonthSDate);
                System.debug('lastMonthEDate:::'+lastMonthEDate);
                
                string sDt = string.valueOf(lastMonthSDate).split(' ')[0];
                string eDt = string.valueOf(lastMonthEDate).split(' ')[0];
                
                String sDt1 = sDt.split('-')[1] + '-' + sDt.split('-')[2] + '-' + sDt.split('-')[0];
                String eDt1 = eDt.split('-')[1] + '-' + eDt.split('-')[2] + '-' + eDt.split('-')[0]; 
                rtnVal = sDt1 + '/' + eDt1;
            } else {
                rtnVal = 'Error';
            }
        } 
        return rtnVal;
    }
    
    @RemoteAction
    public static List<AcctSeed__Project__c> getProjects(String formType, String AcctId, String SDate, String eDate, String section) {
        List<AcctSeed__Project__c> proList = new List<AcctSeed__Project__c>();
        Set<Id> projIds = new Set<Id>();
        String sDt = SDate.split('-')[2] +'-'+SDate.split('-')[0]+'-'+SDate.split('-')[1];
        String eDt = eDate.split('-')[2] +'-'+eDate.split('-')[0]+'-'+eDate.split('-')[1];
        Date sD = Date.ValueOf(sDt);
        Date eD = Date.ValueOf(eDt);
        
        System.debug('sD::::'+sD);
        System.debug('eD::::'+eD);
        if(formType == 'Hour') {
            for( AcctSeed__Time_Card_Day__c tcd : [SELECT AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, Id, Name, AcctSeed__Date__c FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.AcctSeed__Account__r.Name LIKE '%DLI-W%' AND AcctSeed__Date__c >=: sD AND AcctSeed__Date__c <=: eD And AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Section__c =: section]) {
                projIds.add(tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c);
            }
            proList = [SELECT Id,Name FROM AcctSeed__Project__c WHERE Id IN: projIds];
        }
        if(formType == 'Material') {
            proList = [SELECT Id,Name,(SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Name FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Student') FROM AcctSeed__Project__c WHERE AcctSeed__Account__r.Name LIKE '%DLI-W%' AND Id IN (SELECT Project__c FROM Materials_Request__c WHERE Project__r.AcctSeed__Account__c =: AcctId AND Date_Delivered__c >=: sD AND Date_Delivered__c <=: eD AND Request_Status__c = 'Delivered')];
        }
        return proList;
    }
    
    @RemoteAction
    public static Map<String,Id> getCongaRecordMap() {
    
        Map<String,Id> congaMap = new Map<String,Id>();
        for( APXTConga4__Conga_Merge_Query__c conQ: [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c LIKE '%Disposition%']) {
            congaMap.put(conQ.APXTConga4__Name__c, conQ.Id);
        }
        
        for(APXTConga4__Conga_Template__c conT: [SELECT Id,Name,APXTConga4__Name__c,APXTConga4__Template_Group__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Template_Group__c = 'Disposition']) {
            congaMap.put(conT.APXTConga4__Name__c, conT.Id);
        }
        return congaMap;
    }
    
    @RemoteAction
    public static List<String> getSectionPicklist() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = AcctSeed__Project__c.Section__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            options.add(f.getValue());
        }
        return options;
    }
}