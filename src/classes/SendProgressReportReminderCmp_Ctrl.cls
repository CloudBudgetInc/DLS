public class SendProgressReportReminderCmp_Ctrl {
    @auraEnabled
    public static String sendReminderMailToInstructor(Id recId){
        String result = 'success';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        try{            
            Assessment_Report__c report = [SELECT Id, Report_Date__c, Supervisor_Name__c, Project__c, Project__r.DLS_Ref__c, Student__c, 
                                           Student__r.Name, Instructor__c, Instructor__r.FirstName 
                                           FROM Assessment_Report__c 
                                           WHERE Id = :recId LIMIT 1];
            
            String dt = DateTime.newInstance(report.Report_Date__c.year(),report.Report_Date__c.month(),report.Report_Date__c.day()).format('MM/dd/YYYY');
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       
            String subject = 'Reminder: Complete DLS Progress Report for Class # '+ report.Project__r.DLS_Ref__c;
            
            String mailContent = '<html>Dear '+report.Instructor__r.FirstName+',<br /><br />';
			mailContent += 'Please complete the Progress Report for your student '+report.Student__r.Name+' for Class # '+report.Project__r.DLS_Ref__c+' which is due on '+dt+'.<br /><br />';
			mailContent += 'Link to Progress Report: <a href="'+Label.Instructor_Community_Site_Prefix+'/s/assessment-report/'+report.Id+'" target="_blank">DLS Online account</a>.<br /><br />';
			mailContent += 'Thank you,<br />'+report.Supervisor_Name__c;        
            mailContent += '<html>';
            
            mail.setTargetObjectId(report.Instructor__c);
            mail.setSubject(subject);
            mail.setSaveAsActivity(true);
            mail.sethtmlBody(mailContent);
            mails.add(mail);
            
            system.debug('::::::mails:::::'+mails);
                    
            if( mails != null && mails.size() > 0) {
                Messaging.sendEmail(mails);
            }
        }catch(Exception e) {
                            
           result = e.getMessage();
        } 
        return result;
    }
}