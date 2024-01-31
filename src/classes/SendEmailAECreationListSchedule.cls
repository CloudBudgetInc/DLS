// To send email to the Accounting Group
// with the link to the page to view the Amortization Entries, getting created
// Created by GRK on 28/08/2018
// scheduled on ('0 0 8 16 * ?')

global class SendEmailAECreationListSchedule implements Schedulable {
   
    global void execute(SchedulableContext sc) {
   
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Set<Id> idList = new Set<Id>();
        List<String> mailToAddresses = new List<String>(); 
        //Date lastworkingDate = sendFeedbackFormHelper.monthlySendDate(System.Today().addMonths(1).toStartOfMonth().addDays(-1), -1); // to find last working day of month
        Date lastWorkingDate = sendFeedbackFormHelper.monthlySendDate(Date.newInstance(System.Today().year(), System.Today().month(), 16), -1);
        // Need to check for the FA availability to send email
        
        if(lastworkingDate == System.Today() || Test.isRunningTest()) {
        
            Group gp = [SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE Name = 'Accounting' AND Type = 'Regular' LIMIT 1];
            for (GroupMember gm : gp.GroupMembers) {
                idList.add(gm.UserOrGroupId);
            }
            
            for(User u : [SELECT Id, Name, Email FROM User WHERE Id IN :idList AND isActive = True]) {
                
                // Modified By HL on Mar 22 2021
                if(u.Name != 'Bethany Zimmerman'){
                    mailToAddresses.add(u.email);
                }
            } 
            System.debug('::::mailToAddresses::'+mailToAddresses);
            System.debug('::::mailToAddresses::'+mailToAddresses.size());
            
            if( mailToAddresses != null && mailToAddresses.size() > 0 ) {
            
                String htmlBody = '<div>Hi Team,</div>'+
                                  '<div><br/>Here is the link to review the Amortization Entries, Please review and do the changes needed in Fixed Asset. <a href="' + System.Label.Org_Prefix_Start_URL + '/lightning/n/PostAmortizationEntry" target="_blank">Click Here</a></div>' +
                                  '<div><br/>Thanks,<br/>DLS<br/>This is a system generated email, Please do no respond.</div>';
                mail.setToAddresses(mailToAddresses);
                mail.setSubject('Please review the Amortization Entries');
                mail.setHtmlBody(htmlBody);
                if(!Test.isRunningTest()) {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
        }
    }
}