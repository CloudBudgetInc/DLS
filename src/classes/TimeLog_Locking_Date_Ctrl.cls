global Class TimeLog_Locking_Date_Ctrl{
    
    @RemoteAction 
    global static String updateTimeLogLockVal(String DateStr){
        System_Values__c SysVal = [SELECT id,Value__c FROM System_Values__c WHERE name = 'TimeLog_Locking_Date'];
        System.debug('SysVal:::'+SysVal);
        System.debug('DateStr:::'+DateStr);
        if(SysVal != null) {
            SysVal.Value__c = DateStr;
            update SysVal;
            return DateStr;
        } else {
            return 'Failure';
        }
        
    }
    @RemoteAction 
    global static String queryTimeLogLockVal(){
        System_Values__c SysVal = [SELECT id,Value__c FROM System_Values__c WHERE name = 'TimeLog_Locking_Date'];
        System.debug('SysVal:::'+SysVal);
        if(SysVal != null && SysVal.Value__c != null) {           
            return SysVal.Value__c;
        } else {
            return '';
        }
        
    }
    
}