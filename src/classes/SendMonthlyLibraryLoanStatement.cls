/********************
    - Added by HL on Feb 27 2020
    - Work Item : W-004984 - Monthly Outstanding Library Loan Statement for Instructors
    - To send an email notification to instructor about outstanding Library Loan Statement
    - Scheduled every day but only send an email notification at end date (Business Day) of every month if their Materials Requests are Date Loaned Out 
    - This scheduler runs everyday at 9.00 AM
    *******************/
public class SendMonthlyLibraryLoanStatement  implements Schedulable {

    public void execute(SchedulableContext sc) {
    
        Date startDateOfNxtMnth = System.Today().addMonths(1).toStartOfMonth();
        Date endDateOfCurMnth = startDateOfNxtMnth.addDays(-1);            
        Date lastBusiDayOfCurMnth = sendFeedbackFormHelper.monthlySendDate(endDateOfCurMnth, -1); //to find last working day of month
        
        if(lastBusiDayOfCurMnth == System.today() || Test.isRunningTest()){
        
            List<Materials_Request__c> matReqs = [SELECT Id, Materials_Name__r.Name, Date_Loaned_Out__c, Qty__c, DLS_Class_Number__c, Contact__c,
                    Contact__r.Name, Contact__r.Email, Location__r.Name
                FROM Materials_Request__c
                WHERE Contact__c != NULL AND Project__c != NULL AND Materials_Name__c != NULL AND Request_Status__c = 'Loaned Out' 
                    AND RecordType.DeveloperName = 'Material_Loan_Request' AND Date_Loaned_Out__c = THIS_MONTH];
                    
            //System.debug(':::matReqs:::::'+matReqs);
            if(matReqs != NULL && matReqs.size() > 0){
                //W-007341 - User Story - Update Material Loan Emails for each Location
                Map<String, List<Materials_Request__c>> insLocAndMRs = new Map<String, List<Materials_Request__c>>();
                Set<Id> insIds = new Set<Id>();
                
                for(Materials_Request__c m : matReqs){
                    String insLoc = m.Contact__c+'~'+m.Location__r.Name;
                    if(!insLocAndMRs.containsKey(insLoc)){
                    
                        insLocAndMRs.put(insLoc, new List<Materials_Request__c>());
                    }
                    insLocAndMRs.get(insLoc).add(m);
                    insIds.add(m.Contact__c);
                }
                //System.debug(':::insLocAndMRs::::'+insLocAndMRs);
                try {
                    if(insLocAndMRs.size() > 0){
                        List<Messaging.SingleEmailMessage> mailsToInstructor = new List<Messaging.SingleEmailMessage>();
                        
                        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, Email FROM Contact WHERE Id IN : insIds]);
                        //System.debug(':::contactMap::::'+contactMap);
                        
                        if(contactMap.size() > 0){
                        
                            Map<String, Id> oweAddressAndId = new Map<String, Id>();
                            for(OrgWideEmailAddress owe : [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address IN ('feo@dlsdc.com', 'hrn@dlsdc.com', 'md@dlsdc.com')]){
                                oweAddressAndId.put(owe.Address, owe.Id);
                            }
                            DateTime d = datetime.now();
                            String monthNameAndYear = d.format('MMMMM') + ' ' +d.Year();
    
                            for(String insLoc : insLocAndMRs.keySet()){
                            
                                Id insId = insLoc.split('~')[0];
                                String loc = insLoc.split('~')[1];
                                
                                if(contactMap.containsKey(insId)){
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                    mail.setTargetObjectId(insId);
                                    mail.subject = 'Library Loan Statement - ' + monthNameAndYear;
                                    
                                    String htmlBody = '';
                                    htmlBody += 'Dear '+contactMap.get(insId).Name+', <br/><br/>';
                                    htmlBody += 'The following library materials are recorded as currently loaned out to you. ';
                                    htmlBody += 'If you are no longer using any of these materials, please return them to the DLS Front Desk at your earliest convenience. <br/><br/>';
                                    htmlBody += '<table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Material Title</th><th width="25%" style="text-align: center; vertical-align: middle;">Date Loaned Out</th><th width="25%" style="text-align: center; vertical-align: middle;">Qty</th><th width="25%" style="text-align: center; vertical-align: middle;">DLS Class #</th></tr>';
    
                                    for(Materials_Request__c mr : insLocAndMRs.get(insLoc)){
                                    
                                        String loanedOutDate = DateTime.newInstance(mr.Date_Loaned_Out__c.year(),mr.Date_Loaned_Out__c.month(),mr.Date_Loaned_Out__c.day()).format('MM/dd/YYYY');
                                        htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + mr.Materials_Name__r.Name  + '</td><td style="text-align: center; vertical-align: middle;">' + loanedOutDate + '</td><td style="text-align: center; vertical-align: middle;">' + mr.Qty__c + '</td><td style="text-align: center; vertical-align: middle;">' + mr.DLS_Class_Number__c + '</td></tr>';
                                    } 
                                    htmlBody += '</table><br/>';
                                    htmlBody += 'If you are still using all these library materials, then no action is needed at this time. ';
                                    htmlBody += 'An email will be sent to you 1 week prior to the scheduled End Date of the class reminding you to return the book before completing the class.<br/><br/>';
                                    htmlBody += 'Thank you,<br/><br/>DLS Operations Team';
                                    
                                    mail.setHtmlBody(htmlBody);
                                    if (loc == 'DLS - Herndon' && oweAddressAndId.containsKey('hrn@dlsdc.com')) {
                                        mail.setOrgWideEmailAddressId(oweAddressAndId.get('hrn@dlsdc.com'));
                                    }else if(loc == 'DLS - Elkridge' && oweAddressAndId.containsKey('md@dlsdc.com')){
                                        mail.setOrgWideEmailAddressId(oweAddressAndId.get('md@dlsdc.com'));
                                    }else if(oweAddressAndId.containsKey('feo@dlsdc.com')){
                                        mail.setOrgWideEmailAddressId(oweAddressAndId.get('feo@dlsdc.com')); 
                                    }
                                    mail.setSaveAsActivity(true);
                                    mailsToInstructor.add(mail);
                                }
                            }
                            //System.debug(':::mailsToInstructor::'+mailsToInstructor);
                            if(mailsToInstructor != null && mailsToInstructor.size() > 0 && !Test.isRunningTest()) {
                                Messaging.sendEmail(mailsToInstructor);
                            }
                        }
                    }
                }catch(Exception e){
                    String errorMessage = 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                    ErrorHandler errHandler = new ErrorHandler();
                    errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Library Loan Statement scheduler');  
                }
            }
        }
    }
}