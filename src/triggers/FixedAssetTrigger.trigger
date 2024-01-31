trigger FixedAssetTrigger on AcctSeed__Fixed_Asset__c (before insert, after update) {
    
    // # of Months of Depreciation based on Fixed Asset Record Type 
    // By GRK - 07/27/2018
    
    if(trigger.isInsert && trigger.isBefore) {
    
        // To populate the # of Month Depreciation
        Map<Id,Integer> MonthDepreMap = new Map<Id,Integer>();
        Map<String,Id> recordTypeMap = new Map<String,Id>();
        
        // To populate GL Account value
        Map<Id,String> GLAccountMap = new Map<Id,String>();
        Map<String,Id> GLAccountRecMap = new Map<String,Id>();
        Map<Id,String> locationIdNameMap = new Map<Id,String>();
        Set<Id> locIds = new Set<Id>();
        Set<Id> equipIds = new Set<Id>();
        Map<Id,Equipment__c> equipMap = new Map<Id,Equipment__c>();
        
        Map<String,String> locationGLVal = new Map<String,String>();
        
        Id Leasehold;
        Id compEquipRTId;
        
        for(RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType = 'AcctSeed__Fixed_Asset__c']) {
            recordTypeMap.put(rt.DeveloperName, rt.Id);
            if(rt.DeveloperName == 'Leasehold_Improvements') {
                Leasehold = rt.Id;
            }
            if(rt.DeveloperName == 'Computer_Equipment') {
                compEquipRTId = rt.Id;
            }
        }
        
        for(Sobject_Master_Field_Mapping__c smf : [SELECT Id,Name, Default_Field_Value__c, Object_Name__c, RecordType_Name__c, Field_Name__c FROM Sobject_Master_Field_Mapping__c WHERE Field_Name__c IN ('of_Months_Depreciation__c', 'Related_GL_Account__c', 'AcctSeed__GL_Account_Variable_1__c') AND Object_Name__c IN ('AcctSeed__Fixed_Asset__c','AcctSeed__Scheduled_Revenue_Expense__c')]) {
            if(smf.Field_Name__c == 'of_Months_Depreciation__c') { // To populate the # of Month Depreciation
                if(recordTypeMap.containskey(smf.RecordType_Name__c)) {
                    MonthDepreMap.put(recordTypeMap.get(smf.RecordType_Name__c), Integer.ValueOf(smf.Default_Field_Value__c));
                }
            } else if (smf.Field_Name__c == 'Related_GL_Account__c') {   // To populate GL Account value
                if(recordTypeMap.containskey(smf.RecordType_Name__c)) {
                    GLAccountMap.put(recordTypeMap.get(smf.RecordType_Name__c), smf.Default_Field_Value__c);
                }
            } else if(smf.Field_Name__c == 'AcctSeed__GL_Account_Variable_1__c') {
                locationGLVal.put(smf.Name, smf.Default_Field_Value__c);
            }
        }
        
        // To populate GL Account value
        for(AcctSeed__GL_Account__c glAcc : [SELECT Id,Name,GL_Account__c FROM AcctSeed__GL_Account__c WHERE GL_Account__c IN: GLAccountMap.Values()]) {
            GLAccountRecMap.put(glAcc.GL_Account__c, glAcc.Id);
        }
        System.debug('locationGLVal::::'+locationGLVal);
        
        for( AcctSeed__Fixed_Asset__c fa : trigger.new) {
            locIds.add(fa.Location__c);
            equipIds.add(fa.Equipment__c);
        }
        if(locIds.size() > 0) {
            for(MTT_Location__c loc : [SELECT Id,Name FROM MTT_Location__c WHERE Id IN: locIds]) {
                locationIdNameMap.put(loc.Id, loc.Name);
            }
        }
        
        if(equipIds.size() > 0)
            equipMap = new Map<Id,Equipment__c>([SELECT Id,Name,Date_Disposed__c,Date_Placed_in_Service__c,
                                                    Date_Purchased_New__c,Stage__c,Assigned_Location__c, Service_Tag__c,
                                                    RecordType.DeveloperName 
                                                FROM Equipment__c 
                                                WHERE Id IN: equipIds]);
        
        for( AcctSeed__Fixed_Asset__c fa : trigger.new) {
        
            //W-002705 - To Populate field values for Location__c, Date_Disposed__c, Date_Placed_In_Service__c, Date_Purchased__c, Stage__c
            if(fa.Equipment__c != null && equipMap.containskey(fa.Equipment__c)){
            
                Equipment__c equ = equipMap.get(fa.Equipment__c);
                fa.Location__c = equ.Assigned_Location__c;
                fa.Date_Disposed__c = equ.Date_Disposed__c;
                fa.Date_Placed_in_Service__c = equ.Date_Placed_in_Service__c;
                fa.Date_Purchased__c = equ.Date_Purchased_New__c;
                fa.Stage__c = equ.Stage__c;
                if(fa.RecordTypeId == compEquipRTId && equ.RecordType.DeveloperName == 'Computer'){
                    fa.Asset_Id__c = equ.Service_Tag__c;
                }
            }
            
            // To populate the # of Month Depreciation
            if(fa.of_Months_Depreciation__c == null) {
                if(MonthDepreMap.containskey(fa.RecordTypeId)) {
                    fa.of_Months_Depreciation__c = MonthDepreMap.get(fa.RecordTypeId);
                } else if (fa.RecordTypeId == Leasehold && fa.Contract_End_Date__c > fa.Date_Placed_in_Service__c) {
                    fa.of_Months_Depreciation__c = fa.Date_Placed_in_Service__c.monthsBetween(fa.Contract_End_Date__c); 
                }
            }
            // To populate GL Account value
            if(fa.Related_GL_Account__c == null) {
                if(GLAccountMap.containskey(fa.RecordTypeId) && GLAccountRecMap.containskey(GLAccountMap.get(fa.RecordTypeId))) {
                    fa.Related_GL_Account__c = GLAccountRecMap.get(GLAccountMap.get(fa.RecordTypeId));
                }
            }
            
            if(fa.Current_Month_GLAV_1__c == null || fa.Current_Month_GLAV_1__c == '') {
                 if(fa.Location__c != null && locationIdNameMap.containskey(fa.Location__c)) {
                    String loc = locationIdNameMap.get(fa.Location__c);
                    if(loc == 'DLS - Rosslyn' || loc == 'Telework')
                        fa.Current_Month_GLAV_1__c = (locationGLVal.containsKey('AE-GL Acc Var1 FA-Loc(Rosslyn)'))?locationGLVal.get('AE-GL Acc Var1 FA-Loc(Rosslyn)'):'';
                    else if(loc == 'DLS - Herndon')
                        fa.Current_Month_GLAV_1__c = (locationGLVal.containsKey('AE-GL Acc Var1 FA-Loc(Herndon)'))?locationGLVal.get('AE-GL Acc Var1 FA-Loc(Herndon)'):'';
                    else if(loc == 'DLS - Elkridge')
                        fa.Current_Month_GLAV_1__c = (locationGLVal.containsKey('AE-GL Acc Var1 FA-Loc(Elkridge)'))?locationGLVal.get('AE-GL Acc Var1 FA-Loc(Elkridge)'):'';       
                        
                }
            }
        }        
    }
    
    if(Trigger.isAfter){
        
        if(Trigger.isUpdate){
            FixedAssetTrigger_Handler.sendingEmailToAccGroup(Trigger.new, Trigger.oldMap);
        }
    }
}