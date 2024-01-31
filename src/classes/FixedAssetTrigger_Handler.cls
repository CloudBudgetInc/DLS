public class FixedAssetTrigger_Handler{
    
    /*************
        - Added by HL on Oct 09 2019
        - To send an email notification to Accounting group when Fixed Asset record is updated
        - Work Item : W-002996 - Email Notification to Accounting whenever a Computer Equipment Fixed Asset is moved or disposed
        - HTML body
        ************/
    public static void sendingEmailToAccGroup(List<AcctSeed__Fixed_Asset__c> newFAs, Map<Id, AcctSeed__Fixed_Asset__c> oldFAs){
                
        Id comEquipId = Schema.SObjectType.AcctSeed__Fixed_Asset__c.getRecordTypeInfosByDeveloperName().get('Computer_Equipment').getRecordTypeId();
        
        Set<Id> fixedAssetIds = new Set<Id>();
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType faSchema = schemaMap.get('AcctSeed__Fixed_Asset__c');
        Map<String, Schema.SObjectField> fieldMap = faSchema.getDescribe().fields.getMap();
        
        Set<String> fieldAPINames = new Set<String>{'location__c', 'stage__c'};
        Map<String, String> fieldLabelAndfieldvalue;
        Map<Id, Map<String, String>> faIdAndfieldNamefieldValue = new Map<Id, Map<String, String>>();
        Set<Id> locIds = new Set<Id>();
        
        for(AcctSeed__Fixed_Asset__c fa : newFAs){
        
            AcctSeed__Fixed_Asset__c oldFA = oldFAs.get(fa.Id);
            
            if(fa.RecordTypeId == comEquipId && ((fa.Location__c != oldFA.Location__c && fa.Location__c != NULL && oldFA.Location__c != NULL) || (fa.Stage__c != oldFA.Stage__c && fa.Stage__c == 'Disposed' && oldFA.Stage__c != 'Disposed'))){
                
                fieldLabelAndfieldvalue = new Map<String, String>();
                fixedAssetIds.add(fa.Id);
                
                for (String fieldName: fieldAPINames) {
        
                    try {                             
                        String oldAndNewvalue = '';
                        if(fa.get(fieldName) != oldFA.get(fieldName)){ 
                            
                            if(fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.REFERENCE){
                                locIds.add(String.valueOf(oldFA.get(fieldName)));    
                                locIds.add(String.valueOf(fa.get(fieldName))); 
                            }
                            oldAndNewvalue = oldFA.get(fieldName) + ','+ fa.get(fieldName);
                            fieldLabelAndfieldvalue.put(fieldMap.get(fieldName).getDescribe().getLabel(), oldAndNewvalue);
                        } 
                    } catch (Exception e) { 
                        System.debug('Error: ' + e); 
                    } 
                }
                
                if(fieldLabelAndfieldvalue != NULL && fieldLabelAndfieldvalue.size() > 0){
            
                    if(!faIdAndfieldNamefieldValue.containsKey(fa.Id)){
                        faIdAndfieldNamefieldValue.put(fa.Id, new Map<String, String>());
                    }
                    faIdAndfieldNamefieldValue.get(fa.Id).putAll(fieldLabelAndfieldvalue);
                }
            }    
        }
        System.debug('::::fixedAssetIds::::'+fixedAssetIds);
        
        if(fixedAssetIds.size() > 0){
        
            List<Messaging.SingleEmailMessage> emailToAccountingGroup = new List<Messaging.SingleEmailMessage>();
            
            Set<Id> userIds = new Set<Id>();
            List<String> mailToAddresses = new List<String>();
            
            for (GroupMember gm : [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.Name = 'Accounting']) {
                userIds.add(gm.userOrGroupId);
            }
            
            List<User> usr = [SELECT Id, Name, Email FROM User WHERE Id IN :userIds AND IsActive = true];
            
            for(User u : usr) {
                
                // Modified By HL on Apr 22 2021
                if(u.Name != 'Bethany Zimmerman'){
                    mailToAddresses.add(u.email);
                }
            }
            System.debug(':::mailToAddresses::::'+mailToAddresses.size());
            
            Map<Id, AcctSeed__Fixed_Asset__c> faIdAndRec = new Map<Id, AcctSeed__Fixed_Asset__c>([SELECT Id, Name, LastModifiedBy.Name, LastModifiedDate, LastModifiedBy.Email FROM AcctSeed__Fixed_Asset__c WHERE Id IN :fixedAssetIds]);
            
            Map<Id, MTT_Location__c> locMap;
            if(locIds.size() > 0){
            
                locMap = new Map<Id, MTT_Location__c>([SELECT Id, Name FROM MTT_Location__c WHERE Id IN :locIds]);
            }
            
            try{
                
                if(faIdAndRec.size() > 0 && mailToAddresses.size() > 0){
                
                    for(Id faId : faIdAndRec.keySet()){
                    
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(mailToAddresses);
                        //mail.setWhatID(faId);
                        mail.subject = faIdAndRec.get(faId).Name + ' has been moved or disposed';
                        
                        String htmlBody = '';
                        htmlBody += 'Accounting Team,<br/>';
                        htmlBody += '<br/>Please see the below table for the details of the change to the Fixed Asset Record: <br/>';
    
                        //Table of fields that were changed with the old value and new value
                        
                        if(faIdAndfieldNamefieldValue.size() > 0 && faIdAndfieldNamefieldValue.containsKey(faId)){
                        
                            htmlBody += '<br/><table border="1" style="border-collapse: collapse"><tr><th width="15%" style="text-align: center; vertical-align: middle;">Asset Name</th><th width="15%" style="text-align: center; vertical-align: middle;">Edited By</th><th width="15%" style="text-align: center; vertical-align: middle;">Edit Date</th><th width="15%" style="text-align: center; vertical-align: middle;">Field / Event</th><th width="15%" style="text-align: center; vertical-align: middle;">Old Value</th><th width="15%" style="text-align: center; vertical-align: middle;">New Value</th></tr>';
                            
                            for(String label : faIdAndfieldNamefieldValue.get(faId).keySet()){
                            
                                String fieldvalue = faIdAndfieldNamefieldValue.get(faId).get(label);
                                String oldValue = '';
                                String newValue = '';
                                
                                if(label == 'Location'){
                                    if(locMap != NULL && locMap.containsKey(fieldvalue.split(',')[0])){
                                        oldValue = locMap.get(fieldvalue.split(',')[0]).Name;
                                    }
                                    if(locMap != NULL && locMap.containsKey(fieldvalue.split(',')[1])){
                                        newValue = locMap.get(fieldvalue.split(',')[1]).Name;
                                    }
                                }else{
                                
                                    oldValue = fieldvalue.split(',')[0];
                                    newValue = fieldvalue.split(',')[1];
                                }
                                
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + faIdAndRec.get(faId).Name + '</td><td style="text-align: center; vertical-align: middle;">' + faIdAndRec.get(faId).LastModifiedBy.Name + '</td><td style="text-align: center; vertical-align: middle;">' + faIdAndRec.get(faId).LastModifiedDate.format('MM/dd/yyyy HH:mm')  + '</td><td style="text-align: center; vertical-align: middle;">' + label  + '</td><td style="text-align: center; vertical-align: middle;">' + oldValue + '</td><td style="text-align: center; vertical-align: middle;">' + newValue + '</td></tr>';
                            }
                            htmlBody += '</table><br/>';
                        }
                        
                        htmlBody += 'Please contact the “Edited By” user if you have any questions or concerns. <br/>';
                        htmlBody += '<br/>System Generated Email';
                        mail.setHtmlBody(htmlBody);
                        mail.setSaveAsActivity(false);
                        emailToAccountingGroup.add(mail);
                    }
                    
                    if(emailToAccountingGroup != NULL && emailToAccountingGroup.size() > 0) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToAccountingGroup);
                    }
                }
            }catch(Exception e) {
    
                List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
                mail.setSubject('Error on Email Notification To Accounting Group whenever a Computer Equipment Fixed Asset is moved or disposed'); 
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                mail.setPlainTextBody(errorMessage);
                ErrorMailMsg.add(mail);
                try{
                    if( ErrorMailMsg != NULL && ErrorMailMsg.size() > 0 ){
                        Messaging.sendEmail(ErrorMailMsg); 
                    }
                } catch (Exception ex){
                    system.debug('Ex::::'+ex);
                }    
            } 
        }
    }
}