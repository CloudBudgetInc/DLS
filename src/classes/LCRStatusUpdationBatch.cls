/*************
    - Work Item : W-001471
    - To update Status__c = "Inactive" in AcctSeed__Cost_Rates__c (Prior Version) if it have Expiration_Date__c is less than or equal to Today 
    - To update its related Contact_Assignments__c Status__c field as "Ended" if its End_Date__c matches with Expiration_Date__c 
    - And finally send an email notification to Admin people (Chris, April and Natalia) and email contains information about updated AcctSeed__Cost_Rates__c and Contact_Assignments__c 
******************/

global class LCRStatusUpdationBatch implements Database.batchable<Sobject>,Database.Stateful {

    global String exceptionMsg = '';
        
    List<CRTableWrap> CRTableWrapList = new List<CRTableWrap>();
    List<CATableWrap> CATableWrapList = new List<CATableWrap>();
    List<CATableWrap> CATableWrapListForStaff = new List<CATableWrap>();

    List<CATableWrap> CAActiveTableWrapList = new List<CATableWrap>();
    Map<Id, Id> priorLCRIdAndCAId = new Map<Id, Id>();
    Map<Id, Id> priorIdAndCAId = new Map<Id, Id>();
    
    class CRTableWrap{
    
        String crName;
        String crId;
        String conName;
        String conId;
        String expDate;
        String oldStatus;
        String newStatus;
        String rateType;
    }
    
    class CATableWrap{
    
        String contId;
        String contName;
        String lCRId;
        String lCRName;
        String oldLCRId;
        String oldLCRName;
        String startDate;
        String endDate;
        String oldStatus;
        String newStatus;
    }
    
    global Iterable<sObject> start(Database.BatchableContext BC) {
        return ([
            SELECT Id, Prior_Version__c,Rate_Type__c,Name,Status__c,Prior_Version__r.Status__c,Effective_Date__c,Prior_Version__r.Expiration_Date__c, Prior_Version__r.Name, Prior_Version__r.Contact__r.Name, Prior_Version__r.Contact__c
            FROM AcctSeed__Cost_Rates__c
            WHERE Prior_Version__c != NULL AND Prior_Version__r.Status__c != 'Inactive' AND Rate_Type__c IN ('FSI','LT with Prep','LT without Prep','Non-SCA CD','Non-SCA CD (1099)', 'FT Hourly & Benefits', 'PT Hourly (OH & G&A)', 'FT Salary & Benefits','International Salary','Non-SCA LT','DLI-W LT','DODA PS','DLI-W PS - Group 3','DLI-W PS - Group 4') AND Prior_Version__r.Expiration_Date__c != NULL   // Non-SCA LT
                AND Status__c = 'Approved' AND Prior_Version__r.Expiration_Date__c <= TODAY 
        ]);
    }
    
    //Execute Method.
    global void execute(Database.BatchableContext BC, List<AcctSeed__Cost_Rates__c> costRates) {
    
        System.debug('costRates=========='+costRates+'costRates SIZE====='+costRates.size());
        Map<Id, CRTableWrap> priorLCRIdAndCRTableWrap = new Map<Id, CRTableWrap>();
        Map<Id, AcctSeed__Cost_Rates__c> updateOldLCRs = new Map<Id, AcctSeed__Cost_Rates__c>();
        List<Contact_Assignments__c> updateConAssigns = new List<Contact_Assignments__c>();
        Map<Id, Date> priorLCRIdAndExpDate = new Map<Id, Date>();
        Map<Id,AcctSeed__Cost_Rates__c> priorLCRIdAndnewCRRec = new Map<Id,AcctSeed__Cost_Rates__c>();
        Set<String> projStatus = new Set<String>{'Order', 'Active'};
        List<AcctSeed__Cost_Rates__c> updatePriorVersion = new List<AcctSeed__Cost_Rates__c>();
        Set<Id> newLCRIds = new Set<Id>();
        Set<Id> allCRIds = new Set<Id>();
        
        // To update Prior Version Cost Rate status as "Inactive"
        if(costRates.size() > 0){
                        
            for(AcctSeed__Cost_Rates__c c : costRates){
                            
                AcctSeed__Cost_Rates__c oldLCR = new AcctSeed__Cost_Rates__c();
                oldLCR.Id = c.Prior_Version__c;
                oldLCR.Status__c = 'Inactive';
                updateOldLCRs.put(oldLCR.Id, oldLCR);
                priorLCRIdAndnewCRRec.put(c.Prior_Version__c,c);
                priorLCRIdAndExpDate.put(c.Prior_Version__c, c.Prior_Version__r.Expiration_Date__c);
                newLCRIds.add(c.Id);
                String s = String.valueOf(c.Prior_Version__r.Expiration_Date__c);
                
                CRTableWrap wrap = new CRTableWrap();
                wrap.crId = c.Prior_Version__c;
                wrap.crName = c.Prior_Version__r.Name;
                wrap.conId = c.Prior_Version__r.Contact__c;
                wrap.conName = c.Prior_Version__r.Contact__r.Name;
                wrap.expDate = s.split('-')[1]+'/'+s.split('-')[2]+'/'+s.split('-')[0];
                wrap.oldStatus = c.Prior_Version__r.Status__c;
                wrap.newStatus = oldLCR.Status__c;
                wrap.rateType = c.Rate_Type__c;
                priorLCRIdAndCRTableWrap.put(c.Prior_Version__c, wrap);
                //CRTableWrapList.add(wrap);                
            }
            
            if( priorLCRIdAndExpDate.keySet().size() > 0 ) {
                allCRIds.addall(priorLCRIdAndExpDate.keySet());
            }
            if( newLCRIds.size() > 0 ) {
                allCRIds.addall(newLCRIds);
            }
            
            //List<Contact_Assignments__c> conAssigns = [SELECT Id, Name, Candidate_Name__r.Name, Start_Date__c, End_Date__c, Status__c, Drafted_Labor_Cost_Rate__c, Drafted_Labor_Cost_Rate__r.Name, Rate_Card_Rate__c, Rate_Card_Rate__r.Name FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c != 'Ended' AND End_Date__c IN :priorLCRIdAndExpDate.values() AND (Rate_Card_Rate__c IN :priorLCRIdAndExpDate.keySet() OR Drafted_Labor_Cost_Rate__c IN :priorLCRIdAndExpDate.keySet()) AND Project__r.AcctSeed__Status__c IN :projStatus];
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Name, Candidate_Name__r.Name, Start_Date__c, End_Date__c, Status__c, Drafted_Labor_Cost_Rate__c, Drafted_Labor_Cost_Rate__r.Name, Rate_Card_Rate__c, Rate_Card_Rate__r.Name,RecordType.DeveloperName FROM Contact_Assignments__c WHERE ((RecordType.DeveloperName = 'Instructor' AND Status__c != 'Ended') OR (RecordType.DeveloperName = 'Staff' AND Status__c IN ('Active','Planned'))) AND ( Rate_Card_Rate__c IN :allCRIds OR Drafted_Labor_Cost_Rate__c IN :allCRIds) AND Project__r.AcctSeed__Status__c IN :projStatus];
            
            System.debug('conAssigns============'+conAssigns+'conAssigns SIZE=========='+conAssigns.size());
           
            // To update Contact Assignment records under Prior Version Cost Rate If its Status__c != 'Ended' and End_Date__c equals with Cost Rate Expiration_Date__c
            if(conAssigns.size() > 0){
                                                
                for(Contact_Assignments__c ca : conAssigns){
                    
                    
                    Id costRateId = (ca.Rate_Card_Rate__c != NULL ? ca.Rate_Card_Rate__c : (ca.Drafted_Labor_Cost_Rate__c != NULL ? ca.Drafted_Labor_Cost_Rate__c : NULL));
                    String crName = (ca.Rate_Card_Rate__c != NULL ? ca.Rate_Card_Rate__r.Name : (ca.Drafted_Labor_Cost_Rate__c != NULL ? ca.Drafted_Labor_Cost_Rate__r.Name : ''));
                    System.debug('costRateId='+costRateId);
                    System.debug('ca='+ca.Id);

                    if(costRateId != NULL){
                        // Updated Contact assignment as Ended if CA EndDate is equal to LCR Expiration date
                        if(ca.RecordType.DeveloperName == 'Instructor' && priorLCRIdAndExpDate.containsKey(costRateId)){
                            
                            priorIdAndCAId.put(costRateId, ca.Id);
                            if(ca.End_Date__c == priorLCRIdAndExpDate.get(costRateId)){
                                
                                priorLCRIdAndCAId.put(costRateId, ca.Id);
                                
                                String sd = String.valueOf(ca.Start_Date__c);
                                String ed = String.valueOf(ca.End_Date__c);
                                
                                CATableWrap wrap = new CATableWrap();
                                wrap.contId = ca.Candidate_Name__c;
                                wrap.contName = ca.Candidate_Name__r.Name;
                                wrap.lCRId = costRateId;
                                wrap.lCRName = crName;
                                wrap.startDate = sd.split('-')[1]+'/'+sd.split('-')[2]+'/'+sd.split('-')[0];
                                wrap.endDate = ed.split('-')[1]+'/'+ed.split('-')[2]+'/'+ed.split('-')[0];
                                wrap.oldStatus = ca.Status__c;
                                wrap.newStatus = 'Ended';
                                
                                if(ca.RecordType.DeveloperName == 'Instructor'){
                                    ca.Status__c = 'Ended';
                                    
                                    updateConAssigns.add(ca);
                                    CATableWrapList.add(wrap);
                                }
                            }
                            // To check for the Contact Assignment under New LCR which may be created for a future date 
                            // It will have Status as Planned During CA creation
                        } else if(ca.RecordType.DeveloperName == 'Instructor' && newLCRIds.contains(costRateId)) {
                            if(ca.Status__c == 'Planned') {
                                String sdt = String.valueOf(ca.Start_Date__c);
                                String edt = String.valueOf(ca.End_Date__c);
                                
                                CATableWrap wrap = new CATableWrap();
                                wrap.contId = ca.Candidate_Name__c;
                                wrap.contName = ca.Candidate_Name__r.Name;
                                wrap.lCRId = costRateId;
                                wrap.lCRName = crName;
                                wrap.startDate = sdt.split('-')[1]+'/'+sdt.split('-')[2]+'/'+sdt.split('-')[0];
                                wrap.endDate = edt.split('-')[1]+'/'+edt.split('-')[2]+'/'+edt.split('-')[0];
                                wrap.oldStatus = ca.Status__c;
                                wrap.newStatus = 'Active';
                                CAActiveTableWrapList.add(wrap);
                                ca.Status__c = 'Active';
                                updateConAssigns.add(ca);
                            }
                        } else  if(ca.RecordType.DeveloperName == 'Staff' && priorLCRIdAndnewCRRec.containsKey(costRateId)){
                            //#W-007674 -  Enable Cost Rate Auto-Deactivation Process for Additional Rate Types
                            //update the new Cost rate record to CA Staff if EffectiveDate new LCR less than equal to today of current LCR. 
                            String sd = String.valueOf(ca.Start_Date__c);
                            String ed = String.valueOf(ca.End_Date__c);
                            
                            CATableWrap wrap = new CATableWrap();
                            wrap.contId = ca.Candidate_Name__c;
                            wrap.contName = ca.Candidate_Name__r.Name;
                            wrap.startDate = sd.split('-')[1]+'/'+sd.split('-')[2]+'/'+sd.split('-')[0];
                            wrap.endDate = ed.split('-')[1]+'/'+ed.split('-')[2]+'/'+ed.split('-')[0];
                            wrap.oldStatus = ca.Status__c;
                            wrap.lCRId = priorLCRIdAndnewCRRec.get(costRateId).Id;
                            wrap.lCRName = priorLCRIdAndnewCRRec.get(costRateId).Name;  
                            wrap.oldLCRId = costRateId;
                            wrap.oldLCRName = crName;
                            
                            Date newEffDate = priorLCRIdAndnewCRRec.get(costRateId).Effective_Date__c;
                            if(newEffDate <=  System.today()){
                                if(priorLCRIdAndnewCRRec.get(costRateId).Status__c == 'Approved'){
                                    ca.Rate_Card_Rate__c = priorLCRIdAndnewCRRec.get(costRateId).Id;
                                }else if(priorLCRIdAndnewCRRec.get(costRateId).Status__c == 'Draft' || priorLCRIdAndnewCRRec.get(costRateId).Status__c == 'Submitted for Approval') {
                                    ca.Drafted_Labor_Cost_Rate__c  = priorLCRIdAndnewCRRec.get(costRateId).Id;
                                }
                                updateConAssigns.add(ca);
                                CATableWrapListForStaff.add(wrap);
                            }
                        }
                    }
                }
            }
            System.debug('updateOldLCRs==='+updateOldLCRs+'updateOldLCRs SIZE==========='+updateOldLCRs.size());
            System.debug('updateConAssigns==='+updateConAssigns+'updateConAssigns SIZE==========='+updateConAssigns.size());
            
            if(priorLCRIdAndCRTableWrap.size () > 0){
            
                for(Id priorLCRId : priorLCRIdAndCRTableWrap.keySet()){
                
                    if(priorIdAndCAId.containsKey(priorLCRId)){
                    
                        if(priorLCRIdAndCAId.containsKey(priorLCRId)){
                        
                            CRTableWrapList.add(priorLCRIdAndCRTableWrap.get(priorLCRId));
                            updatePriorVersion.add(updateOldLCRs.get(priorLCRId));
                        }
                    }else{
                        
                        CRTableWrapList.add(priorLCRIdAndCRTableWrap.get(priorLCRId));
                        updatePriorVersion.add(updateOldLCRs.get(priorLCRId));
                    }               
                }
            }
            
            try{
                if(updatePriorVersion.size() > 0){
                    update updatePriorVersion;
                }
                if(updateConAssigns.size() > 0){
                    update updateConAssigns;
                }
            }catch(Exception e){
            
                if(String.isNotEmpty(exceptionMsg)){
                    exceptionMsg += '\n';
                }
                exceptionMsg += e.getMessage();
            }
        }
    }
    
    //finish Method.
    global void finish(Database.BatchableContext BC) {
        
        system.debug('exceptionMsg============'+exceptionMsg);
        if(String.isNotEmpty(exceptionMsg) || Test.isRunningTest()){
        
            List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
            mail.setSubject('Error on Update of Labor Cost Rate Record'); 
            mail.setPlainTextBody(exceptionMsg);
            ErrorMailMsg.add(mail);
            try{
                if( ErrorMailMsg != null && ErrorMailMsg.size() > 0 ){
                    Messaging.sendEmail(ErrorMailMsg); 
                }
            } catch (Exception ex){
                system.debug('Ex::::'+ex);
            }    
        }
        
        String htmlBody = '';
        System.debug('htmlBody =============='+htmlBody);
                
        // Email content for Contact Assignment Instructor
        if(CRTableWrapList.size() > 0){
        
            htmlBody += '<html>Hi Admin,<br/><br/>The following Labor Cost Rates have been updated to \"Inactive\" status: <br/><br/>';
            htmlBody += '<br/><table border="1" style="border-collapse: collapse"><tr><th style="text-align: center; vertical-align: middle; padding: 5px;">Cost Rate Name</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Contact Name</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Rate Type</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Expiration Date</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Old Status</th><th style="text-align: center; vertical-align: middle; padding: 5px;">New Status</th></tr>';
            
            for(CRTableWrap w : CRTableWrapList){
            
                htmlBody += '<tr><td style="text-align: center; vertical-align: middle; padding: 5px;">' + '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+w.crId+'" target="_blank">'+ w.crName +'</a>'+ '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+w.conId+'" target="_blank">'+ w.conName +'</a>' + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + w.rateType + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + w.expDate + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + w.oldStatus + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + w.newStatus + '</td></tr>';    
            }
            htmlBody += '</table><br/><br/>';
            
            if(CATableWrapList.size()  > 0){
            
                htmlBody += 'It\'s related Contact Assignment records also updated to \"Ended\" status: <br/>';
                htmlBody += '<br/><table border="1" style="border-collapse: collapse"><tr><th style="text-align: center; vertical-align: middle; padding: 5px;">Contact Name</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Cost Rate Name</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Start Date</th><th style="text-align: center; vertical-align: middle; padding: 5px;">End Date</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Old Status</th><th style="text-align: center; vertical-align: middle; padding: 5px;">New Status</th></tr>';
                
                for(CATableWrap wr : CATableWrapList){
                
                    htmlBody += '<tr><td style="text-align: center; vertical-align: middle; padding: 5px;">' + '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+wr.contId+'" target="_blank">'+ wr.contName +'</a>' + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+wr.lCRId+'" target="_blank">'+wr.lCRName+'</a>'+ '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + wr.startDate + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + wr.endDate + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + wr.oldStatus + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + wr.newStatus + '</td></tr>';
                }
                htmlBody += '</table><br/><br/>';
            }
            
              // Email content for Contact Assignment Staff
            if(CATableWrapListForStaff.size()  > 0){
            
                htmlBody += 'It\'s related Contact Assignment records also updated with the new Rates: <br/>';
                htmlBody += '<br/><table border="1" style="border-collapse: collapse"><tr><th style="text-align: center; vertical-align: middle; padding: 5px;">Contact Name</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Start Date</th><th style="text-align: center; vertical-align: middle; padding: 5px;">End Date</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Status</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Old Cost Rate</th><th style="text-align: center; vertical-align: middle; padding: 5px;">New Cost Rate</th></tr>';
                
                for(CATableWrap wr : CATableWrapListForStaff){
                
                    htmlBody += '<tr><td style="text-align: center; vertical-align: middle; padding: 5px;">' +'<a href="'+System.Label.Org_Prefix_Start_URL+'/'+wr.contId+'" target="_blank">'+ wr.contName +'</a>' + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + wr.startDate+ '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + wr.endDate + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + wr.oldStatus + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+wr.oldLCRId+'" target="_blank">'+wr.oldLCRName+'</a>' + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+wr.lCRId+'" target="_blank">'+wr.lCRName+'</a>' + '</td></tr>';
                }
                htmlBody += '</table><br/><br/>';
            }
            
            // To add the Active updating Contact Assignments from Planned Status in the Email
            if(CAActiveTableWrapList.size()  > 0){
            
                htmlBody += 'It\'s new Labor Cost Rate related Contact Assignment records also updated to \"Active\" status: <br/>';
                htmlBody += '<br/><table border="1" style="border-collapse: collapse"><tr><th style="text-align: center; vertical-align: middle; padding: 5px;">Contact Name</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Cost Rate Name</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Start Date</th><th style="text-align: center; vertical-align: middle; padding: 5px;">End Date</th><th style="text-align: center; vertical-align: middle; padding: 5px;">Old Status</th><th style="text-align: center; vertical-align: middle; padding: 5px;">New Status</th></tr>';
                
                for(CATableWrap wr : CAActiveTableWrapList){
                
                    htmlBody += '<tr><td style="text-align: center; vertical-align: middle; padding: 5px;">' + '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+wr.contId+'" target="_blank">'+ wr.contName +'</a>' + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+wr.lCRId+'" target="_blank">'+wr.lCRName+'</a>'+ '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + wr.startDate + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + wr.endDate + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + wr.oldStatus + '</td><td style="text-align: center; vertical-align: middle; padding: 5px;">' + wr.newStatus + '</td></tr>';
                }
                htmlBody += '</table><br/><br/>';
            }
            htmlBody += 'Thank you,<br/><br/>System Generated Email<br/>';
        }
        System.debug('htmlBody ::::::'+htmlBody);
        List<String> lcrMails = new List<String>();
        for(String str : system.Label.LCR_Status_Update_Batch_Notification_Emails.split(',')){
            lcrMails.add(str.trim());
        }
        // Send an email notification to Admin People
        if(String.isNotEmpty(htmlBody) && lcrMails.size() > 0){
        
            List<Messaging.SingleEmailMessage> mailListToSend = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage(); 
            msg.setToAddresses(lcrMails);
            //msg.setToAddresses(new String[]  {'cbellas@dlsdc.com','abellas@dlsdc.com', 'nstepanov@dlsdc.com', 'bzimmerman@dlsdc.com'});
            //msg.setToAddresses(new String[]  {'karthiga@softsquare.biz','sivaprasanth.tamilselvan@softsquare.biz'});
            msg.setSubject('Update of Labor Cost Rate Record'); 
            msg.setHtmlBody(htmlBody);
            mailListToSend.add(msg);
            try{
                if( mailListToSend != null && mailListToSend.size() > 0 ){
                    Messaging.sendEmail(mailListToSend); 
                }
            } catch (Exception ex){
                system.debug('Ex=========='+ex);
            } 
        }
    }
}