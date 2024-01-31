/******
* Developed by Karthiga on May 17 2017 to update the Instructor Status values to "Inactive"
****/
global class ContactInsStatusUpdateBatch implements Database.batchable<Sobject>,Database.Stateful {
    global Map<Id,String> conIdOldSatusMap = new Map<Id,String>();
    global Map<Id,Contact> conMap = new Map<Id,Contact>();
    // Always need to be executed by giving 1 Contact per execution
    global Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator('SELECT Id,Name,Instructor_status__c,Email,Language_1__c,Last_Availability_Update__c FROM Contact WHERE Instructor_status__c != \'Inactive\' AND Instructor_status__c != \'Employed\' AND Last_Availability_Update__c < LAST_N_YEARS:1 AND RecordType.DeveloperName = \'Candidate\'');
    }
       
    global void execute(Database.BatchableContext info, List<Contact> conList) {
        try {
            Set<Id> cId = new Set<Id>();
            Date gtDate;
            for(Contact c : conList) {
                cId.add(c.Id);
            }
            List<Time_Log__c> tls = [SELECT Id,Name,Date__c FROM Time_Log__c WHERE Contact__c IN: cId ORDER BY Date__c DESC LIMIT 1];
            List<AcctSeed__Time_Card_Day__c> tcs = [SELECT Id,AcctSeed__Date__c FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c IN: cId ORDER BY AcctSeed__Date__c DESC LIMIT 1];
            if( tls != null && tls.size() > 0 && tcs != null && tcs.size() > 0 ) {
                gtDate = (tls[0].Date__c > tcs[0].AcctSeed__Date__c ? tls[0].Date__c : tcs[0].AcctSeed__Date__c);
            } else if (tls != null && tls.size() > 0) {
                gtDate = tls[0].Date__c;
            } else if(tcs != null && tcs.size() > 0) {
                gtDate = tcs[0].AcctSeed__Date__c;
            }
            
            for ( Contact c : conList ) {
                if( (gtDate != null && c.Last_Availability_Update__c != null && c.Last_Availability_Update__c > gtDate) || gtDate == null ) {
                    conMap.put(c.Id,c);
                    if(!conIdOldSatusMap.containskey(c.Id)) {
                        conIdOldSatusMap.put(c.Id,c.Instructor_status__c);
                    }
                    c.Instructor_status__c = 'Inactive';
                } else {
                    c.Last_Availability_Update__c = gtDate;
                }
            }
            System.debug('conList:::::'+conList);
            System.debug('conIdOldSatusMap:::::'+conIdOldSatusMap);
            update conList;
            
        } catch(Exception e) {
            System.debug('ContactInsStatusUpdate ::: Exception:::'+conList);
        }
    }  
     
    global void finish(Database.BatchableContext info) {
        System.debug('conIdOldSatusMap :::::'+conIdOldSatusMap);
        System.debug('conMap:::'+conMap);
        if( conIdOldSatusMap != null && conIdOldSatusMap.size() > 0 ) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            String mailContent = '<html>Dear Amy Murphy and Kate Marden,<br/>The following Instructor Status has changed to Inactive.'; 
            mailContent += '<br/><table border="1" style="border-collapse: collapse"><thead><th>Name</th><th>Language</th><th>Email</th><th>Old Status</th></thead><tbody>';    
            String orgUrl = URL.getSalesforceBaseUrl().toExternalForm();
            for(Id cId: conIdOldSatusMap.keyset()) {
                
                mailContent += '<tr><td width="25%"><a href="'+orgUrl+'/'+cId+'">'+conMap.get(cId).Name+'</a></td><td width="25%">'+(conMap.get(cId).Language_1__c != null ? conMap.get(cId).Language_1__c : '')+'</td><td width="25%">'+ (conMap.get(cId).Email != null ? conMap.get(cId).Email : '')+'</td><td width="25%">'+ conIdOldSatusMap.get(cId) +'</td></tr>'; 
            }
            mailContent += '</tbody></table><br/><p>This e-mail was auto generated. Please do not respond.</p><p>If you have questions, contact your Salesforce Administrator.</p>';
            mailContent += '</html>';
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();      
            System_Values__c sysVal = System_Values__c.getValues('Cont\'s Inst status Chang Notify User');            
            if (sysVal != null && sysVal.Value__c != null) {
                for (String st : sysVal.Value__c.split(',')) {
                    sendTo.add(st);
                }
            }
            System.debug('sendTo:::::'+sendTo);
            mail.setToAddresses(sendTo);
            //mail.setToAddresses(new List<String> {'karthiga@softsquare.biz'});
            mail.setSubject('Instructor Status Updated to Inactive on '+System.Today().format());
            mail.sethtmlBody(mailContent);
            mails.add(mail);
            System.debug('mails::::'+mails);
            if( mails != null && mails.size() > 0 && !Test.isRunningTest()) {
                //Messaging.sendEmail(mails);
            }
        }
    }
}