/************
    - Created by Vinitha on August 29 ,2017 
    - Send e-mail alert on End Date of Project related to this to materials request, asking instructor and student to return the material 
    - Modified By HL on May 04 2020
    - Work Item : W-005325 - Email Alert Content Update: Reminder to return library loan
    - To add DLS Class # value in mail content
    ************/

global class SendMaterialReturnAlert implements Database.batchable<sObject>,Database.Stateful { 
    
    Date todaydate = system.today();
    Date oneWeekBefore = system.today().adddays(7);    
    Map<Id,Contact> conIdRecMap = new Map<Id,Contact>();
    Map<Id, Date> conIdAndEndDate = new Map<Id, Date>();
    Set<Id> projIds = new Set<Id>();
    //W-007341 - User Story - Update Material Loan Emails for each Location
    Map<String, List<Materials_Request__c>> insLocAndMRList = new Map<String, List<Materials_Request__c>>();
    Set<Id> insIds = new Set<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext info){        
        String matreqQry = 'SELECT Id, Project__c, Project__r.Name, Project__r.End_Date__c,Contact__c,Date_Loaned_Out__c,DLS_Class_Number__c,'
                           +'Materials_Name__r.Name, Contact__r.Name, Contact__r.Email,Qty__c, Location__r.Name'
                       +' FROM Materials_Request__c'
                       +' WHERE Project__c IN (SELECT Project__c FROM Contact_Assignments__c WHERE End_Date__c = :todaydate OR End_Date__c = :oneWeekBefore) AND Contact__c != null'
                           +' AND Materials_Name__c != null AND Request_Status__c = \'Loaned Out\' AND RecordType.DeveloperName =\'Material_Loan_Request\'';
        return Database.getQueryLocator(matreqQry);        
    }
    global void execute(Database.BatchableContext info, List<Materials_Request__c> mrList){
        for(Materials_Request__c mr : mrList){
            String InsAndLoc = mr.Contact__c+'~'+mr.Location__r.Name;
            
            if(!insLocAndMRList.containsKey(InsAndLoc)){
                insLocAndMRList.put(InsAndLoc,new List<Materials_Request__c>{mr});
            }else {
                insLocAndMRList.get(InsAndLoc).add(mr);
            }
            projIds.add(mr.Project__c);
            insIds.add(mr.Contact__c);
        }
        //system.debug('::::::::insLocAndMRList:::::'+insLocAndMRList);
        //system.debug('::::::::projIds:::::'+projIds);
        for(Contact con : [SELECT Id,Name,Email FROM Contact WHERE Id IN : insIds]){
            if(!conIdRecMap.containsKey(con.Id)){
                conIdRecMap.put(con.Id,con);
            }
        }
        //system.debug('::::::::conIdRecMap::::;'+conIdRecMap);
        if(conIdRecMap.size() > 0){
            for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, End_Date__c 
                                                FROM Contact_Assignments__c 
                                                WHERE Candidate_Name__c IN : conIdRecMap.keySet() AND Project__c IN : projIds AND
                                                    (End_Date__c = :todaydate OR End_Date__c = :oneWeekBefore)]){
                                                    
                if(!conIdAndEndDate.containsKey(ca.Candidate_Name__c)){
                    conIdAndEndDate.put(ca.Candidate_Name__c,ca.End_Date__c);
                }
            }
        }
        //system.debug('::::::::conIdAndEndDate::::;'+conIdAndEndDate);
    }
    
    global void finish(Database.BatchableContext info){ 
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        try{
            if(insLocAndMRList.size() > 0){
                
                Map<String, Id> oweAddressAndId = new Map<String, Id>();
                for(OrgWideEmailAddress owe : [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address IN ('feo@dlsdc.com', 'hrn@dlsdc.com', 'md@dlsdc.com')]){
                    oweAddressAndId.put(owe.Address, owe.Id);
                }
                for(String insLoc : insLocAndMRList.keySet()){
                
                    Id insId = insLoc.split('~')[0];
                    
                    if(conIdAndEndDate.containsKey(insId)){
                    
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        String loc = insLoc.split('~')[1];
                        Date endDate = Date.Today();
                        if(conIdAndEndDate.containsKey(insId)){
                            endDate = conIdAndEndDate.get(insId);
                        }
                        String dt = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format('MM/dd/YYYY');
                        
                        String mailContent = '<html>Dear '+conIdRecMap.get(insId).Name+',<br/><br/>';
                        mailContent += 'This is a courtesy reminder that your class is scheduled to end on '+dt+' and the following library materials are recorded as currently loaned out to you:<br/>';
                        mailContent += '<br/><table border="1" style="border-collapse: collapse"><tr><th width="20%" style="text-align: center; vertical-align: middle;">Material Title</th><th width="20%" style="text-align: center; vertical-align: middle;">Date Loaned Out</th><th width="20%" style="text-align: center; vertical-align: middle;">Qty</th><th width="20%" style="text-align: center; vertical-align: middle;">DLS Class #</th><th width="20%" style="text-align: center; vertical-align: middle;">Location</th></tr>';
                        
                        for(Materials_Request__c mr : insLocAndMRList.get(insLoc)){
                            String lodStr = String.valueOf(mr.Date_Loaned_Out__c);
                            String loanedOutDate = lodStr.split('-')[1]+'/'+lodStr.split('-')[2]+'/'+lodStr.split('-')[0];
                            mailContent += '<tr><td style="text-align: center; vertical-align: middle;">'+mr.Materials_Name__r.Name+'</td><td style="text-align: center; vertical-align: middle;">'+loanedOutDate+'</td><td style="text-align: center; vertical-align: middle;">'+ mr.Qty__c +'</td><td style="text-align: center; vertical-align: middle;">'+ mr.DLS_Class_Number__c +'</td><td style="text-align: center; vertical-align: middle;">'+ mr.Location__r.Name +'</td></tr>'; 
                        }
                        
                        mailContent += '</tbody></table><br/>Please remember to return the book prior to the end of the class, and please contact the Front Desk or your LTS if you have any questions or the End Date needs to be updated.<br/>';
                        mailContent += '<br/>Thank you,<br/>';
                        mailContent += '<br/>DLS Operations Team';
                        mailContent += '</html>';
                        
                        if (loc == 'DLS - Herndon' && oweAddressAndId.containsKey('hrn@dlsdc.com')) {
                            mail.setOrgWideEmailAddressId(oweAddressAndId.get('hrn@dlsdc.com'));
                        }else if(loc == 'DLS - Elkridge' && oweAddressAndId.containsKey('md@dlsdc.com')){
                            mail.setOrgWideEmailAddressId(oweAddressAndId.get('md@dlsdc.com'));
                        }else if(oweAddressAndId.containsKey('feo@dlsdc.com')){
                            mail.setOrgWideEmailAddressId(oweAddressAndId.get('feo@dlsdc.com')); 
                        }
                        mail.setTargetObjectId(insId);
                        mail.setBccAddresses(new List<String>{system.Label.MaterialRequestBCCEmail});
                        mail.setSubject('Reminder to return your loaned library materials');
                        mail.sethtmlBody(mailContent);
                        mails.add(mail);
                    }
                }
            }
            //system.debug('::::::mails:::::'+mails);
            //system.debug('::::::mails:::::'+mails.size());
            if( mails != null && mails.size() > 0) {
                Messaging.sendEmail(mails);
            }
        }catch(Exception e) {
            String errorMessage = 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Send Material Return Alert');
        } 
    }
}