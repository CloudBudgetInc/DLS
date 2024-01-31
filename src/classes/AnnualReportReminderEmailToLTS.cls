/**********
    - Created By Dhinesh on 06/10/2021
    - To send an email notification to the LTS to review the Annual Review Assessment Reports in next 28 days of Its Report_Date__c
    - This class is invoked from "Annual Review LTS Email Notification" flow
    - Dynamic HTML Email template
*********/
public class AnnualReportReminderEmailToLTS {

    // This method is called from flow, so annotated with @InvocableMethod
    @InvocableMethod
    public static void sendAnEmailLTS(){
    
        // Send an email before 28 days of Report Date
        Date reportDate = Date.Today()+28;
        Map<Id, String> ltsIdAndNameMap = new Map<Id, String>();
        Map<Id, List<Assessment_Report__c>> ltsIdAndAssRepRecs = new Map<Id, List<Assessment_Report__c>>();
        
        List<Assessment_Report__c> reports = [SELECT Id, Name, Project__c, Project__r.End_Date__c, Project_Manager__c, 
                                                     Project_Manager__r.Name, Instructor__c,
                                                     Instructor__r.Name, Instructor__r.DLI_Hours_in_Current_Year__c, Report_Date__c
                                              FROM Assessment_Report__c 
                                              WHERE Instructor__c != NULL AND Project_Manager__c != NULL AND
                                                    Status__c = 'Scheduled' AND Report_Date__c <= :reportDate AND Report_Date__c >= :System.Today() AND 
                                                    RecordType.DeveloperName = 'Annual_Instructor_Performance_Review'];
        
        if(reports != NULL && reports.size() > 0){
        
            for(Assessment_Report__c ar : reports){            
                ltsIdAndNameMap.put(ar.Project_Manager__c, ar.Project_Manager__r.Name);
                // Map to store all related Assessment Reports for LTS
                if(!ltsIdAndAssRepRecs.containsKey(ar.Project_Manager__c)){
                
                    ltsIdAndAssRepRecs.put(ar.Project_Manager__c, new List<Assessment_Report__c>());
                }
                ltsIdAndAssRepRecs.get(ar.Project_Manager__c).add(ar);
            }
            System.debug(':::::ltsIdAndAssRepRecs:::'+ltsIdAndAssRepRecs);    
            
            if(ltsIdAndAssRepRecs != NULL && ltsIdAndAssRepRecs.size() > 0){
                            
                Map<Id,Id> userIdWithContactIdMap = PlannedDaysOffHandler.getUserRelatedContacts(ltsIdAndAssRepRecs.keySet());
                List<Messaging.SingleEmailMessage> sendEmailToInstructors = new List<Messaging.SingleEmailMessage>();
                
                String mailContent = '<html>Hi Chris and April <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = FALSE;
                    
                try{
                    
                    List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
            
                    String orgWideEmailId = '';
                    
                    if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                        orgWideEmailId = orgWideEmail[0].Id;
                    }
                    
                    Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, FirstName, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :userIdWithContactIdMap.values() AND Email != NULL]);
                
                    // One email (consolidated email) per LTS for all the Assessment Reports he/she is related to
                    for(Id ltsId : ltsIdAndAssRepRecs.keySet()){
                    
                        if(userIdWithContactIdMap.get(ltsId) != null && conIdRec.containsKey(userIdWithContactIdMap.get(ltsId))){
                        
                            if(!conIdRec.get(userIdWithContactIdMap.get(ltsId)).IsEmailBounced){
                                
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if(orgWideEmailId != NULL) {
                                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                                }
                                mail.setTargetObjectId(userIdWithContactIdMap.get(ltsId));
                                mail.subject = 'Scheduled Annual Instructor Performance Reviews';
                                    
                                String htmlBody = '';
                                htmlBody += 'Hi '+ ltsIdAndNameMap.get(ltsId)  + ', <br/><br/>';
                                htmlBody += 'The below Annual Instructor Performance Reviews are Scheduled in the next four weeks.<br/>';
                                htmlBody += '<br/><table border="1" style="border-collapse: collapse"><tr>'+
                                    '<th width="15%" style="text-align: center; vertical-align: middle;">Instructor Name</th>'+
                                    '<th width="15%" style="text-align: center; vertical-align: middle;">Review Date</th>'+
                                    '<th width="15%" style="text-align: center; vertical-align: middle;">Assessment Report Name</th>'+
                                    '<th width="15%" style="text-align: center; vertical-align: middle;">DLI Hours in Current Year</th>'+
                                    '<th width="15%" style="text-align: center; vertical-align: middle;">Project End Date</th></tr>';
                                    
                                for(Assessment_Report__c ar : ltsIdAndAssRepRecs.get(ltsId)){
                                
                                    htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + ar.Instructor__r.Name + '</td>'+
                                                '<td style="text-align: center; vertical-align: middle;">' + ('0' + ar.Report_Date__c.month()).right(2)+'/'+('0' + ar.Report_Date__c.day()).right(2)+'/'+ar.Report_Date__c.year() + '</td>'+
                                                '<td><a href="'+ System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+ ar.Id +'" target="_blank">'+ ar.Name +'</a></td>'+                                             
                                                '<td style="text-align: center; vertical-align: middle;">' + ar.Instructor__r.DLI_Hours_in_Current_Year__c + '</td>'+
                                                '<td style="text-align: center; vertical-align: middle;">' + ('0' + ar.Project__r.End_Date__c.month()).right(2)+'/'+('0' + ar.Project__r.End_Date__c.day()).right(2)+'/'+ar.Project__r.End_Date__c.year()+ '</td></tr>';    
                                }
                                htmlBody += '</table><br/>';
                                
                                htmlBody += '<br/>Please review and schedule a time with the Instructor(s) or update the Review Date as needed.';
                                htmlBody += '<br/><br/>System generated email.';
                                mail.setHtmlBody(htmlBody);
                                mail.setSaveAsActivity(true);
                                sendEmailToInstructors.add(mail);
                            }else {
                            
                                mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(userIdWithContactIdMap.get(ltsId)).Id+'" target="_blank">'+conIdRec.get(userIdWithContactIdMap.get(ltsId)).Name+'</a><br/>';
                                hasBouncedEmail = TRUE;
                            }
                        }
                    }
                    mailContent += '<br/><p>This e-mail was auto generated. Please do not respond.</p>';
                    mailContent += '</html>';    
                    
                    if(hasBouncedEmail || Test.isRunningTest()) {
                    
                        //Added custome setting to hold the exception recipients email ids
                        List<String> toAddressIds = new List<String>();
            
                        System_Values__c sysVal = System_Values__c.getValues('Contact Bounced Exception Email Ids'); 
                        if (sysVal != null && sysVal.Value__c != null) {
                            for (String st : sysVal.Value__c.split(',')) {
                                toAddressIds.add(st.trim());
                            }
                        }
                        
                        Messaging.SingleEmailMessage bouncedmail = new Messaging.SingleEmailMessage();
                        bouncedmail.setToAddresses(toAddressIds);
                        bouncedmail.setSubject('Bounced email contact information');
                        bouncedmail.sethtmlBody(mailContent);
                        sendEmailToInstructors.add(bouncedmail);
                    }
                    System.debug('sendEmailToInstructors::::'+sendEmailToInstructors);
            
                    if( sendEmailToInstructors != null && sendEmailToInstructors.size() > 0 ) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToInstructors);
                    }
                }catch(Exception e) {
            
                    ErrorHandler errHandler = new ErrorHandler();
                    errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Annual Report Email To LTS');
                } 
            }
        }
    }
}