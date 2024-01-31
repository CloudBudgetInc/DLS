/****************
    - Added by HL on Aug 19 2020
    - Work Item : W-003065 - Add ability for instructors and students to edit and reschedule events in the community
    - To send an email notification to Instructor If the LTS has approved, but the Instructor has not yet approved the reschedule request at 48 hours before the requested reschedule date and time
    - Email Template : Dynamic HTML template
    ******************/
    
public class RescheduleEventNeedInsApproval implements Schedulable{

    public void execute(SchedulableContext sc) {
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Map<Id, Events__c> eventRecMap = new Map<Id, Events__c>();
        
        Date eveDate = Date.Today()+2;
        System.debug(':::eveDate::::'+eveDate);
        
        if(!Test.isRunningTest() && todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday'){
            eventRecMap = new Map<Id, Events__c>([SELECT Id, Project__c, Project__r.Project_Manager__c, Project__r.Project_Manager__r.Email, Project__r.DLS_Class__c, Date__c, 
                            Instructor__c, Instructor__r.Name, Instructor__r.IsEmailBounced, Start_Time__c, End_Time__c, Duration__c, Room__r.Name, 
                            Parent_Event__c, Parent_Event__r.Date__c, Parent_Event__r.Start_Time__c, Parent_Event__r.End_Time__c, 
                            Parent_Event__r.Duration__c, Parent_Event__r.Room__r.Name, CreatedBy.Name, Room__c, Project__r.Project_Manager__r.Name
                        FROM Events__c
                        WHERE Parent_Event__c != NULL AND Approval_Status__c = 'LTS Approved' AND 
                            Project__r.Project_Manager__c != NULL AND Instructor__c != NULL AND Date__c = :eveDate]); 
            
        }else if(Test.isRunningTest()){
        
            eventRecMap = new Map<Id, Events__c>([SELECT Id, Project__c, Project__r.Project_Manager__c, Project__r.Project_Manager__r.Email, Project__r.DLS_Class__c, Date__c, 
                            Instructor__c, Instructor__r.Name, Instructor__r.IsEmailBounced, Start_Time__c, End_Time__c, Duration__c, Room__r.Name, 
                            Parent_Event__c, Parent_Event__r.Date__c, Parent_Event__r.Start_Time__c, Parent_Event__r.End_Time__c, 
                            Parent_Event__r.Duration__c, Parent_Event__r.Room__r.Name, CreatedBy.Name, Room__c, Project__r.Project_Manager__r.Name
                        FROM Events__c
                        WHERE Parent_Event__c != NULL AND Approval_Status__c = 'LTS Approved' AND 
                            Project__r.Project_Manager__c != NULL AND Instructor__c != NULL AND Date__c = :eveDate LIMIT 1]); 
        } 
        System.debug('::::::eventRecMap::::::'+eventRecMap);
        
         if(eventRecMap != NULL && eventRecMap.size() > 0){
        
            List<Messaging.SingleEmailMessage> sendEmailToInstructor = new List<Messaging.SingleEmailMessage>();
            
            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
            
            String orgWideEmailId = '';
            
            if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                orgWideEmailId = orgWideEmail[0].Id;
            }
                
            try{
            
                for(Events__c e : eventRecMap.values()){
                                                                                
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(e.Instructor__c);
                    mail.setCcAddresses(new List<String>{e.Project__r.Project_Manager__r.Email});
                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                    mail.setWhatId(e.Id);
                    
                    String s1 = String.valueOf(e.Date__c);
                    String newEveDate = s1.split('-')[1]+'/'+s1.split('-')[2]+'/'+s1.split('-')[0];
                    
                    String s2 = String.valueOf(e.Parent_Event__r.Date__c);
                    String oldEveDate = s2.split('-')[1]+'/'+s2.split('-')[2]+'/'+s2.split('-')[0];
                    
                    mail.subject = 'PENDING APPROVAL: Your ' + e.CreatedBy.Name + ' for Class #: ' + e.Project__r.DLS_Class__c + ' has submitted a reschedule request for ' + newEveDate;
                    
                    String url = '<a href="' + System.Label.Org_Prefix_Start_URL +'/lightning/r/Events__c/' + e.Id + '/view" target="_blank"> Click Here </a>';
                                        
                    String htmlBody = '';
                    htmlBody += 'Dear '+ e.Instructor__r.Name + ', <br/><br/>';
                    htmlBody += 'This change occurs in <b> less than 48 hours.</b>';
                    htmlBody += '<br/>Your Student, '+ e.CreatedBy.Name +', for Class # ' + e.Project__r.DLS_Class__c + ', has submitted a request to reschedule your class.';
                    htmlBody += '<br/>Your LTS, '+ e.Project__r.Project_Manager__r.Name + ', has approved this request.';
                    htmlBody += '<br/><br/>Please see details of the rescheduled request below and ' + url + ' to approve or reject.';
                    htmlBody += '<br/><br/><table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Field Label</th><th width="25%" style="text-align: center; vertical-align: middle;">Old Value</th><th width="25%" style="text-align: center; vertical-align: middle;">New Value</th></tr>';
                    htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Date'  + '</td><td style="text-align: center; vertical-align: middle;">' + oldEveDate + '</td><td style="text-align: center; vertical-align: middle;">' + newEveDate + '</td></tr>';
                    htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Start Time'  + '</td><td style="text-align: center; vertical-align: middle;">' + e.Parent_Event__r.Start_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + e.Start_Time__c + '</td></tr>';
                    htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'End Time'  + '</td><td style="text-align: center; vertical-align: middle;">' + e.Parent_Event__r.End_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + e.End_Time__c + '</td></tr>';
                    htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Hours'  + '</td><td style="text-align: center; vertical-align: middle;">' + e.Parent_Event__r.Duration__c + '</td><td style="text-align: center; vertical-align: middle;">' + e.Duration__c + '</td></tr>';
                    htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Room'  + '</td><td style="text-align: center; vertical-align: middle;">' + e.Parent_Event__r.Room__r.Name + '</td><td style="text-align: center; vertical-align: middle;">' + e.Room__r.Name + '</td></tr>';
                    htmlBody += '</table><br/>';
                    htmlBody += '<br/>This is a system generated email<br/>';
                    mail.setHtmlBody(htmlBody);
                    mail.setSaveAsActivity(TRUE);
                    sendEmailToInstructor.add(mail);
                } 
                
                System.debug('sendEmailToInstructor::::'+sendEmailToInstructor);
            
                if(sendEmailToInstructor != NULL && sendEmailToInstructor.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToInstructor);
                }
                
            }catch(Exception e) {
                                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Sending an Email to Instructor for Event Reschedule approval process');
            }
        }
    }
}