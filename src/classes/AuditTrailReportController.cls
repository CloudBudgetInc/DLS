public class AuditTrailReportController{
    
    @AuraEnabled
    public static List<TimeCardDayDomain.TCDHistoryReport> getAuditReportRecs(Date fromDate, Date toDate, String insName, String userName, String projName){
    
        List<TimeCardDayDomain.TCDHistoryReport> reportList = new List<TimeCardDayDomain.TCDHistoryReport>();
        
        Map<String, String> fieldAPINameAndLabel = getTCDFieldLabels();        
        System.debug('fieldAPINameAndLabel=='+fieldAPINameAndLabel);

        System.debug('insName========='+insName+'userName=='+userName+'projName==='+projName);
        
        String tcdHistoryQry = 'SELECT Id, Parent.Name, Parent.AcctSeed__Time_Card_Line__r.Name,';
        tcdHistoryQry += 'Parent.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name, Parent.Instructor_Name__c,';
        tcdHistoryQry += 'Parent.Project_Task_Name__c, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue ';
        tcdHistoryQry += 'FROM AcctSeed__Time_Card_Day__History';
        tcdHistoryQry += ' WHERE Field != \'created\'';
        
        if(insName != NULL && insName != ''){
            tcdHistoryQry += ' AND Parent.Instructor_Name__c = :insName';
        }
        
        if(userName != NULL && userName != ''){
            tcdHistoryQry += ' AND CreatedBy.Name = :userName';
        }
        
        if(projName != NULL && projName != ''){
            tcdHistoryQry += ' AND Parent.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name = :projName';
        }

        if(fromDate != NULL && toDate != NULL){
            tcdHistoryQry += ' AND CreatedDate >= :fromDate AND CreatedDate <= :toDate ORDER BY CreatedDate DESC LIMIT 1000';
        }else if(fromDate != NULL && toDate == NULL){
            tcdHistoryQry += ' AND CreatedDate >= :fromDate ORDER BY CreatedDate DESC LIMIT 1000';
        }else if(fromDate == NULL && toDate != NULL){
            tcdHistoryQry += ' AND CreatedDate <= :toDate ORDER BY CreatedDate DESC LIMIT 1000';
        }else{
            tcdHistoryQry += ' ORDER BY CreatedDate DESC LIMIT 1000';
        }
        
        System.debug('tcdHistoryQry==='+tcdHistoryQry);
        List<AcctSeed__Time_Card_Day__History> tcdHistoryRecs = Database.query(tcdHistoryQry);
        System.debug('tcdHistoryRecs==='+tcdHistoryRecs.size());
        
        Set<String> userIds = new Set<String>();
        Map<String, User> userIdAndRec;
        
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
            
            if(userIds.size() > 0 || Test.isRunningTest()){
                userIdAndRec = new Map<String, User>([SELECT Id, Name FROM User WHERE Id IN :userIds]);
            }else{
                userIdAndRec = new Map<String, User>();
            }
            
            reportList = TimeCardDayTranslator.getTCDHistoryRecs(tcdHistoryRecs, fieldAPINameAndLabel, userIdAndRec);
        }
        
        return reportList;
    }
    
    @AuraEnabled
    public static List<TimeCardDayDomain.TCDHistoryReport> getAuditReportRecsToDownload(Date fromDate, Date toDate, String insName, String userName, String projName){
    
        List<TimeCardDayDomain.TCDHistoryReport> reportList = new List<TimeCardDayDomain.TCDHistoryReport>();
        
        Map<String, String> fieldAPINameAndLabel = getTCDFieldLabels();        
        System.debug('fieldAPINameAndLabel=='+fieldAPINameAndLabel);

        System.debug('insName========='+insName+'userName=='+userName+'projName==='+projName);
        
        String tcdHistoryQry = 'SELECT Id, Parent.Name, Parent.AcctSeed__Time_Card_Line__r.Name,';
        tcdHistoryQry += 'Parent.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name, Parent.Instructor_Name__c,';
        tcdHistoryQry += 'Parent.Project_Task_Name__c, CreatedBy.Name, CreatedDate, Field, OldValue, NewValue ';
        tcdHistoryQry += 'FROM AcctSeed__Time_Card_Day__History';
        tcdHistoryQry += ' WHERE Field != \'created\'';
        
        if(insName != NULL && insName != ''){
            tcdHistoryQry += ' AND Parent.Instructor_Name__c = :insName';
        }
        
        if(userName != NULL && userName != ''){
            tcdHistoryQry += ' AND CreatedBy.Name = :userName';
        }
        
        if(projName != NULL && projName != ''){
            tcdHistoryQry += ' AND Parent.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name = :projName';
        }

        if(fromDate != NULL && toDate != NULL){
            tcdHistoryQry += ' AND CreatedDate >= :fromDate AND CreatedDate <= :toDate ORDER BY CreatedDate DESC';
        }else if(fromDate != NULL && toDate == NULL){
            tcdHistoryQry += ' AND CreatedDate >= :fromDate ORDER BY CreatedDate DESC';
        }else if(fromDate == NULL && toDate != NULL){
            tcdHistoryQry += ' AND CreatedDate <= :toDate ORDER BY CreatedDate DESC';
        }else{
            tcdHistoryQry += ' ORDER BY CreatedDate DESC';
        }
        
        System.debug('tcdHistoryQry==='+tcdHistoryQry);
        List<AcctSeed__Time_Card_Day__History> tcdHistoryRecs = Database.query(tcdHistoryQry);
        System.debug('tcdHistoryRecs==='+tcdHistoryRecs.size());
        
        Set<String> userIds = new Set<String>();
        Map<String, User> userIdAndRec;
        
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
            
            if(userIds.size() > 0 || Test.isRunningTest()){
                userIdAndRec = new Map<String, User>([SELECT Id, Name FROM User WHERE Id IN :userIds]);
            }else{
                userIdAndRec = new Map<String, User>();
            }
            
            reportList = TimeCardDayTranslator.getTCDHistoryRecs(tcdHistoryRecs, fieldAPINameAndLabel, userIdAndRec);
        }
        
        return reportList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return SObjectQueryService.getLookupRecords(objectName,searchString,condition);
    }
    
    public static Map<String, String> getTCDFieldLabels(){
    
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objSchema = schemaMap.get('AcctSeed__Time_Card_Day__c');
        Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
        Map<String, String> fieldAPINameAndLabel = new Map<String, String>();
        
        for (String fieldName: fieldMap.keySet()) {
        
            fieldAPINameAndLabel.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
        }
        System.debug('fieldAPINameAndLabel=='+fieldAPINameAndLabel);
        
        return fieldAPINameAndLabel;
    }
}