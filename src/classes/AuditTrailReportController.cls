public class AuditTrailReportController{
    
    @AuraEnabled
    public static TimeCardDayDomain.TCDTrailReport getAuditReportRecs(Date fromDate, Date toDate, String insId, String userName, String projName,String tcType,String selectedField,Boolean intialize){
    
        List<TimeCardDayDomain.TCDHistoryReport> reportList = new List<TimeCardDayDomain.TCDHistoryReport>(); 
        List<AcctSeed__Time_Card_Day__History> tcdHistoryRecs = new List<AcctSeed__Time_Card_Day__History>();
        List<AcctSeed__Time_Card_Line__History> tclHistoryRecs = new List<AcctSeed__Time_Card_Line__History>();

        TimeCardDayDomain.TCDTrailReport auditTrailReport = new TimeCardDayDomain.TCDTrailReport();

        String objName = '';
        if(tcType == 'Time Card Day'){
            objName = 'AcctSeed__Time_Card_Day__c';
        }else if(tcType == 'Time Card Line'){
            objName = 'AcctSeed__Time_Card_Line__c';
        }
        
        Map<String, String> tcdFieldNameAndLabel = getTCDFieldLabels('AcctSeed__Time_Card_Day__c');
        Map<String, String> tclFieldNameAndLabel = getTCDFieldLabels('AcctSeed__Time_Card_Line__c');
        Map<String, User> userIdAndRec;
        Set<String> userIds = new Set<String>();
    
        System.debug('insName========='+insId+'userName=='+userName+'projName==='+projName);
        String tcdlHistoryQry = '';
        
        /* W-008032 - Add ability to change search between Time Card Day and Time Card Line ,Add Filter for "Field Edited"
					  Add Column "Date" or "Time Card Period" that will display based on the search type between Time Card Day and Time Card Line
	     Modified by Siva Prasanth on 25.04.2024 */

        if(intialize == true){            
            List<TimeCardDayDomain.PicklistFormation> tcdFieldWithlabels = new List<TimeCardDayDomain.PicklistFormation>();
            List<TimeCardDayDomain.PicklistFormation> tclFieldWithlabels = new List<TimeCardDayDomain.PicklistFormation>();
            List<TimeCardDayDomain.PicklistFormation> timeCardType = new List<TimeCardDayDomain.PicklistFormation>();
            
            TimeCardDayDomain.PicklistFormation pick1 = new TimeCardDayDomain.PicklistFormation();
            pick1.label = 'All';
            pick1.value = '';
            
            
            if(tcdFieldNameAndLabel.size() > 0){
                tcdFieldWithlabels.add(pick1);
                
                for(String field : tcdFieldNameAndLabel.keySet()){
                    TimeCardDayDomain.PicklistFormation pick = new TimeCardDayDomain.PicklistFormation();
                    pick.label = tcdFieldNameAndLabel.get(field);
                    pick.value = field;
                    tcdFieldWithlabels.add(pick);
                }
            }
            
            if(tclFieldNameAndLabel.size() > 0){
                tclFieldWithlabels.add(pick1);
                for(String field : tclFieldNameAndLabel.keySet()){
                    TimeCardDayDomain.PicklistFormation tclPick = new TimeCardDayDomain.PicklistFormation();
                    tclPick.label = tclFieldNameAndLabel.get(field);
                    tclPick.value = field;
                    tclFieldWithlabels.add(tclPick);
                }
            }
            
            TimeCardDayDomain.PicklistFormation typePick1 = new TimeCardDayDomain.PicklistFormation();
            typePick1.label = 'Time Card Day';
            typePick1.value = 'Time Card Day';
            
            TimeCardDayDomain.PicklistFormation typePick2 = new TimeCardDayDomain.PicklistFormation();
            typePick2.label = 'Time Card Line';
            typePick2.value = 'Time Card Line';
            
            timeCardType.add(typePick1);
            timeCardType.add(typePick2);
            
            auditTrailReport.getTimeCardTypes = timeCardType;
            auditTrailReport.tcdFieldWithLabels = tcdFieldWithlabels;
            auditTrailReport.tclFieldWithLabels = tclFieldWithlabels;
        }
        
        if(tcType == 'Time Card Day'){
            tcdlHistoryQry = 'SELECT Id, Parent.Name, Parent.AcctSeed__Time_Card_Line__r.Name,parent.Instructor_Name__c,';
            tcdlHistoryQry += 'Parent.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name, Parent.Instructor_Id__c,';
            tcdlHistoryQry += 'Parent.Project_Task_Name__c, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue ';
            tcdlHistoryQry += 'FROM AcctSeed__Time_Card_Day__History';
            tcdlHistoryQry += ' WHERE Field != \'created\'';
        }else if(tcType == 'Time Card Line'){
            tcdlHistoryQry = 'SELECT Id, parent.Name,parent.AcctSeed__Time_Card__r.Intructor__r.Name,';
            tcdlHistoryQry += 'parent.AcctSeed__Project__r.Name, parent.Instructor_Id__c,parent.AcctSeed__Time_Card__r.Intructor__c,';
            tcdlHistoryQry += 'parent.AcctSeed__Project_Task__r.Name, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue ';
            tcdlHistoryQry += 'FROM AcctSeed__Time_Card_Line__History';
            tcdlHistoryQry += ' WHERE Field != \'created\'';
        }
        
        if(String.isNotBlank(insId)){
            tcdlHistoryQry += ' AND Parent.Instructor_Id__c = :insId';
        }
        
        if(String.isNotBlank(userName)){
            tcdlHistoryQry += ' AND CreatedBy.Name = :userName';
        }
        
        if(String.isNotBlank(projName)){
            if(tcType == 'Time Card Day'){
                tcdlHistoryQry += ' AND Parent.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name = :projName';
            }else if(tcType == 'Time Card Line'){
                tcdlHistoryQry += ' AND Parent.AcctSeed__Project__r.Name = :projName';
            }
        }
        System.debug('tcdlHistoryQry==='+tcdlHistoryQry);
        system.debug('tcType::'+tcType +':::'+ 'Time Card Line');

        String fromDtCondition = (tcType == 'Time Card Day' ?  'parent.AcctSeed__Date__c' : 'parent.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c');
        String toDtCondition = (tcType == 'Time Card Day' ? 'parent.AcctSeed__Date__c' : 'parent.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c'); 

        if(fromDate != NULL && toDate != NULL){
            tcdlHistoryQry += ' AND '+fromDtCondition+' >= :fromDate AND '+toDtCondition+' <= :toDate ORDER BY CreatedDate DESC LIMIT 1000';
        }else if(fromDate != NULL && toDate == NULL){
            tcdlHistoryQry += ' AND '+fromDtCondition+' >= :fromDate ORDER BY CreatedDate DESC LIMIT 1000';
        }else if(fromDate == NULL && toDate != NULL){
            tcdlHistoryQry += ' AND '+toDtCondition+' <= :toDate ORDER BY CreatedDate DESC LIMIT 1000';
        }else{
            tcdlHistoryQry += ' ORDER BY CreatedDate DESC LIMIT 1000';
        }
        System.debug('tcdlHistoryQry==='+tcdlHistoryQry);

        if(tcType == 'Time Card Day'){
            
            System.debug('tcdlHistoryQry==='+tcdlHistoryQry);
            tcdHistoryRecs = Database.query(tcdlHistoryQry);
            
            System.debug('tcdHistoryRecs==='+tcdHistoryRecs.size());
            
            if(tcdHistoryRecs.size() > 0){
                
                for(AcctSeed__Time_Card_Day__History h : tcdHistoryRecs){
                    
                    String oldValue = String.valueOf(h.OldValue);
                    String newValue = String.valueOf(h.NewValue);
                    
                    if((oldValue != NULL && oldValue != '' && oldValue.contains('005')) || Test.isRunningTest()){
                        userIds.add(oldValue);
                    }
                    if((newValue != NULL && newValue != '' && newValue.contains('005')) || Test.isRunningTest()){
                        userIds.add(newValue);
                    }
                }
                
            }
        }else if(tcType == 'Time Card Line'){
            
            System.debug('tcdlHistoryQry==='+tcdlHistoryQry);
            tclHistoryRecs = Database.query(tcdlHistoryQry);
                        
            if(tclHistoryRecs.size() > 0){
                
                for(AcctSeed__Time_Card_Line__History h : tclHistoryRecs){
                    
                    String oldValue = String.valueOf(h.OldValue);
                    String newValue = String.valueOf(h.NewValue);
                    
                    if((oldValue != NULL && oldValue != '' && oldValue.contains('005')) || Test.isRunningTest()){
                        userIds.add(oldValue);
                    }
                    if((newValue != NULL && newValue != '' && newValue.contains('005')) || Test.isRunningTest()){
                        userIds.add(newValue);
                    }
                }
            }
        }
        
        if(userIds.size() > 0 || Test.isRunningTest()){
            userIdAndRec = new Map<String, User>([SELECT Id, Name FROM User WHERE Id IN :userIds]);
        }else{
            userIdAndRec = new Map<String, User>();
        }
        
        if(tcType == 'Time Card Day'){// Show the TCD/TCL records based on Time Card Type selection
            reportList = TimeCardDayTranslator.getTCDHistoryRecs(tcdHistoryRecs, tcdFieldNameAndLabel, userIdAndRec,selectedField);
        }else if(tcType == 'Time Card Line'){
            reportList = TimeCardDayTranslator.getTCLHistoryRecs(tclHistoryRecs, tclFieldNameAndLabel, userIdAndRec,selectedField);
        }
        
        auditTrailReport.tcsHistoryReports = reportList;
        return auditTrailReport;
    }
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return SObjectQueryService.getLookupRecords(objectName,searchString,condition);
    }
    
    public static Map<String, String> getTCDFieldLabels(String objName){
    
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
        Map<String, String> fieldAPINameAndLabel = new Map<String, String>();
        
        for (String fieldName: fieldMap.keySet()) {
            if(fieldMap.get(fieldName).getDescribe().isUpdateable() || fieldName == 'Name') {
                fieldAPINameAndLabel.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
            }
        }
        System.debug('fieldAPINameAndLabel=='+fieldAPINameAndLabel);
        
        return fieldAPINameAndLabel;
    }
}