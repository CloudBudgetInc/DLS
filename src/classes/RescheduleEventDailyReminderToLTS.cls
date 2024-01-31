/****************
    - Added by HL on Aug 19 2020
    - Work Item : W-003065 - Add ability for instructors and students to edit and reschedule events in the community
    - To send an email notification to LTS to approve Reschedule Event Records
    - Email Template : Dynamic HTML template
    - This scheduler runs Daily basis @ 10 AM
    ******************/
    
public class RescheduleEventDailyReminderToLTS implements Schedulable{

    public void execute(SchedulableContext sc) {
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        List<Events__c> eveRecs = new List<Events__c>();
        
        if(!Test.isRunningTest() && todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday'){
            eveRecs = [SELECT Id, Project__c, Project__r.DLS_Class__c, Date__c, Instructor__c, Instructor__r.Name, 
                            Start_Time__c, End_Time__c, Duration__c, Room__r.Name, Project__r.Project_Manager__c, 
                            Project__r.Project_Manager__r.Name, CreatedBy.Name, Project__r.Name
                        FROM Events__c
                        WHERE Parent_Event__c != NULL AND Approval_Status__c = 'Pending LTS Approval' AND 
                            Project__r.Project_Manager__c != NULL AND Date__c > TODAY]; 
            
        }else if(Test.isRunningTest()){
        
            eveRecs = [SELECT Id, Project__c, Project__r.DLS_Class__c, Date__c, Instructor__c, Instructor__r.Name, 
                            Start_Time__c, End_Time__c, Duration__c, Room__r.Name, Project__r.Project_Manager__c, 
                            Project__r.Project_Manager__r.Name, CreatedBy.Name, Project__r.Name
                        FROM Events__c
                        WHERE Parent_Event__c != NULL AND Approval_Status__c = 'Pending LTS Approval' AND 
                            Project__r.Project_Manager__c != NULL AND Date__c > TODAY LIMIT 1]; 
        } 
        System.debug('::::::eveRecs::::::'+eveRecs);
        
        if(eveRecs != NULL && eveRecs.size() > 0){
        
            Map<Id, List<Events__c>> ltsIdAndReschEventRecs = new Map<Id, List<Events__c>>();
            Map<Id, String> ltsIdAndName = new Map<Id, String>();
            
            for(Events__c eve : eveRecs){
            
                if(!ltsIdAndReschEventRecs.containsKey(eve.Project__r.Project_Manager__c)){
                
                    ltsIdAndReschEventRecs.put(eve.Project__r.Project_Manager__c, new List<Events__c>());
                }
                ltsIdAndReschEventRecs.get(eve.Project__r.Project_Manager__c).add(eve);
                ltsIdAndName.put(eve.Project__r.Project_Manager__c, eve.Project__r.Project_Manager__r.Name);
            }
            System.debug('::::::ltsIdAndReschEventRecs::::::'+ltsIdAndReschEventRecs);
            System.debug('::::::ltsIdAndReschEventRecs::::::'+ltsIdAndReschEventRecs.size());
            
            try{
            
                List<Messaging.SingleEmailMessage> sendEmailToLTS = new List<Messaging.SingleEmailMessage>();
                
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
            
                String orgWideEmailId = '';
                
                if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
                
                for(Id ltsId : ltsIdAndReschEventRecs.keySet()){
                
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(ltsId);
                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                    mail.subject = 'ACTION REQUIRED: Pending Rescheduled Event Requests';
                    
                    String url = '<a href="' + System.Label.Org_Prefix_Start_URL +'/lightning/o/Events__c/list?filterName='+ System.Label.Event_Pending_LTS_Approval_Filter_Id + '" target="_blank"> Click Here </a>';
                    
                    String htmlBody = '';
                    htmlBody += 'Dear '+ ltsIdAndName.get(ltsId) + ', <br/><br/>';
                    htmlBody += 'You have the following Reschedule Requests Pending your Approval:';
                    htmlBody += '<br/><br/><table border="1" style="border-collapse: collapse"><tr><th width="15%" style="text-align: center; vertical-align: middle;">Project Name</th><th width="15%" style="text-align: center; vertical-align: middle;">Date</th><th width="15%" style="text-align: center; vertical-align: middle;">Start Time</th><th width="15%" style="text-align: center; vertical-align: middle;">End Time</th><th width="15%" style="text-align: center; vertical-align: middle;">Room</th><th width="15%" style="text-align: center; vertical-align: middle;">Instructor</th></tr>';
                    
                    for(Events__c e : ltsIdAndReschEventRecs.get(ltsId)){
                                                                                                                                            
                        String s1 = String.valueOf(e.Date__c);
                        String newEveDate = s1.split('-')[1]+'/'+s1.split('-')[2]+'/'+s1.split('-')[0];
                                                             
                        htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">'+ e.Project__r.Name +'</td><td style="text-align: center; vertical-align: middle;">'+ newEveDate +'</td><td style="text-align: center; vertical-align: middle;">'+ e.Start_Time__c +'</td><td style="text-align: center; vertical-align: middle;">'+ e.End_Time__c +'</td><td style="text-align: center; vertical-align: middle;">'+ e.Room__r.Name +'</td><td style="text-align: center; vertical-align: middle;">'+ e.Instructor__r.Name +'</td></tr>';
                    }
                    htmlBody += '</table><br/><br/>';
                    htmlBody += 'Please ' + url + ' to approve or reject.';
                    htmlBody += '<br/><br/>This is a system generated email';
                    mail.setHtmlBody(htmlBody);
                    mail.setSaveAsActivity(FALSE);
                    sendEmailToLTS.add(mail);
                }  
                    
                System.debug('sendEmailToLTS::::'+sendEmailToLTS);
            
                if(sendEmailToLTS != NULL && sendEmailToLTS.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToLTS);
                }                    
            }catch(Exception e) {
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Daily Reminder To LTS to approve Reschedule Event records');
            }
        }
    }
}