/****************
    - Added by HL on Aug 19 2020
    - Work Item : W-003065 - Add ability for instructors and students to edit and reschedule events in the community
    - To send an email notification to LTS and Instructor If the LTS has not approved the reschedule request at 48 hours before the requested reschedule date and time
    - Email Template : Dynamic HTML template
    ******************/
    
public class RescheduleEventNeedLTSApproval implements Schedulable{

    public void execute(SchedulableContext sc) {
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Map<Id, Events__c> eventRecMap = new Map<Id, Events__c>();
        
        Date eveDate = Date.Today()+2;
        System.debug(':::eveDate::::'+eveDate);
        
        if(!Test.isRunningTest() && todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday'){
            eventRecMap = new Map<Id, Events__c>([SELECT Id, Project__c, Project__r.Project_Manager__c, Project__r.Project_Manager__r.Name, Project__r.DLS_Class__c, Date__c, 
                            Instructor__c, Instructor__r.Name, Instructor__r.IsEmailBounced, Start_Time__c, End_Time__c, Duration__c, Room__r.Name, 
                            Parent_Event__c, Parent_Event__r.Date__c, Parent_Event__r.Start_Time__c, Parent_Event__r.End_Time__c, 
                            Parent_Event__r.Duration__c, Parent_Event__r.Room__r.Name, CreatedBy.Name, Room__c
                        FROM Events__c
                        WHERE Parent_Event__c != NULL AND Approval_Status__c = 'Pending LTS Approval' AND 
                            Project__r.Project_Manager__c != NULL AND Instructor__c != NULL AND Date__c = :eveDate]); 
            
        }else if(Test.isRunningTest()){
        
            eventRecMap = new Map<Id, Events__c>([SELECT Id, Project__c, Project__r.Project_Manager__c, Project__r.Project_Manager__r.Name, Project__r.DLS_Class__c, Date__c, 
                            Instructor__c, Instructor__r.Name, Instructor__r.IsEmailBounced, Start_Time__c, End_Time__c, Duration__c, Room__r.Name, 
                            Parent_Event__c, Parent_Event__r.Date__c, Parent_Event__r.Start_Time__c, Parent_Event__r.End_Time__c, 
                            Parent_Event__r.Duration__c, Parent_Event__r.Room__r.Name, CreatedBy.Name, Room__c
                        FROM Events__c
                        WHERE Parent_Event__c != NULL AND Approval_Status__c = 'Pending LTS Approval' AND 
                            Project__r.Project_Manager__c != NULL AND Instructor__c != NULL AND Date__c = :eveDate LIMIT 1]); 
        } 
        System.debug('::::::eventRecMap::::::'+eventRecMap);
        
        if(eventRecMap != NULL && eventRecMap.size() > 0){
        
            List<Messaging.SingleEmailMessage> sendEmailToApprovalProcess = new List<Messaging.SingleEmailMessage>();
            
            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
            
            String orgWideEmailId = '';
            
            if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                orgWideEmailId = orgWideEmail[0].Id;
            }
                
            try{
            
                for(Events__c e : eventRecMap.values()){
                    
                    String s1 = String.valueOf(e.Date__c);
                    String newEveDate = s1.split('-')[1]+'/'+s1.split('-')[2]+'/'+s1.split('-')[0];
                    
                    String s2 = String.valueOf(e.Parent_Event__r.Date__c);
                    String oldEveDate = s2.split('-')[1]+'/'+s2.split('-')[2]+'/'+s2.split('-')[0];
                    
                    String tableStr = '';
                    tableStr += '<br/><table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Field Label</th><th width="25%" style="text-align: center; vertical-align: middle;">Old Value</th><th width="25%" style="text-align: center; vertical-align: middle;">New Value</th></tr>';
                    tableStr += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Date'  + '</td><td style="text-align: center; vertical-align: middle;">' + oldEveDate + '</td><td style="text-align: center; vertical-align: middle;">' + newEveDate + '</td></tr>';
                    tableStr += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Start Time'  + '</td><td style="text-align: center; vertical-align: middle;">' + e.Parent_Event__r.Start_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + e.Start_Time__c + '</td></tr>';
                    tableStr += '<tr><td style="text-align: center; vertical-align: middle;">' + 'End Time'  + '</td><td style="text-align: center; vertical-align: middle;">' + e.Parent_Event__r.End_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + e.End_Time__c + '</td></tr>';
                    tableStr += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Hours'  + '</td><td style="text-align: center; vertical-align: middle;">' + e.Parent_Event__r.Duration__c + '</td><td style="text-align: center; vertical-align: middle;">' + e.Duration__c + '</td></tr>';
                    tableStr += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Room'  + '</td><td style="text-align: center; vertical-align: middle;">' + e.Parent_Event__r.Room__r.Name + '</td><td style="text-align: center; vertical-align: middle;">' + e.Room__r.Name + '</td></tr>';
                    tableStr += '</table><br/>';
                                        
                    if(e.Project__r.Project_Manager__c != NULL){
                                                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(e.Project__r.Project_Manager__c);
                        mail.setOrgWideEmailAddressId(orgWideEmailId);
                        mail.setWhatId(e.Id);
                                                
                        String url = '<a href="' + System.Label.Org_Prefix_Start_URL +'/lightning/o/Events__c/list?filterName='+ System.Label.Event_Pending_LTS_Approval_Filter_Id + '" target="_blank"> Click Here </a>';
                        
                        mail.subject = 'PENDING APPROVAL: ' + e.CreatedBy.Name + ' for Class #: ' + e.Project__r.DLS_Class__c + ' has submitted a reschedule request for ' + newEveDate;
                        
                        String htmlBody = '';
                        htmlBody += 'Dear '+ e.Project__r.Project_Manager__r.Name + ', <br/><br/>';
                        htmlBody += 'A schedule change has been requested by '+ e.CreatedBy.Name +'. This change occurs in <b> less than 48 hours.</b><br/>';
                        htmlBody += tableStr;
                        htmlBody += 'Please ' + url + ' to approve or reject.';
                        htmlBody += '<br/><br/><a href="'+ System.Label.Org_Prefix_Start_URL +'/lightning/r/AcctSeed__Project__c/' + e.Project__c +'/view" target="_blank"> Link to Project </a>';
                        htmlBody += '<br/><br/>This is a system generated email<br/>';
                        mail.setHtmlBody(htmlBody);
                        mail.setSaveAsActivity(FALSE);
                        sendEmailToApprovalProcess.add(mail);
                    }
                    
                    if(e.Instructor__c != NULL){
                    
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(e.Instructor__c);
                        mail.setOrgWideEmailAddressId(orgWideEmailId);
                        mail.setWhatId(e.Id);
                        mail.subject = 'PENDING APPROVAL: ' + ' Your ' + e.CreatedBy.Name + ' for Class #: ' + e.Project__r.DLS_Class__c + ' has submitted a reschedule request for ' + newEveDate;
                        
                        String htmlBody = '';
                        htmlBody += 'Dear '+ e.Instructor__r.Name + ', <br/><br/>';
                        htmlBody += 'This change occurs in <b> less than 48 hours.</b><br/>';
                        htmlBody += 'Your Student, '+ e.CreatedBy.Name +', for Class # ' + e.Project__r.DLS_Class__c + ', has submitted a request to reschedule your class.<br/>';
                        htmlBody += '<u>This request is pending Your LTS, '+ e.Project__r.Project_Manager__r.Name + '\'s, approval.</u>';
                        htmlBody += '<br/><br/>Please see details of the rescheduled request below.<br/>';
                        htmlBody += tableStr;
                        htmlBody += '<br/>This is a system generated email<br/>';
                        mail.setHtmlBody(htmlBody);
                        mail.setSaveAsActivity(TRUE);
                        sendEmailToApprovalProcess.add(mail);
                    }
                } 
                
                System.debug('sendEmailToApprovalProcess::::'+sendEmailToApprovalProcess);
            
                if(sendEmailToApprovalProcess != NULL && sendEmailToApprovalProcess.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToApprovalProcess);
                }
                
            }catch(Exception e) {
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Sending an Email to LTS and Instructor for Event Reschedule approval process');
            }
        }
    }
}