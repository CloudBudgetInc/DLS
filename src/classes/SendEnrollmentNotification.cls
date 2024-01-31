Global Class SendEnrollmentNotification {
 
    Webservice static String submit(String oppId) { 

        String result = '';
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> ccAddressList = new List<String>();
        for(String str : System.Label.Emai_Address_For_Enrollment_Notification.split(',')) {
            ccAddressList.add(str);
        }
        
        EmailTemplate[] emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Enrollment Notification'];
        if (emailTemplate.size() > 0) {
        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Contact con = [SELECT Id FROM Contact WHERE Name = 'Chris Bellas'];
            mail.setWhatId(oppId);
            mail.setTargetObjectId(con.Id);
            mail.setCcAddresses(ccAddressList);
            mail.setTemplateId(emailTemplate[0].id);
            mails.add(mail);
        }        
        
        if(mails.size()>0){
         system.debug('::mails:::::'+mails);
            Messaging.sendEmail(mails);
            result = 'Mail has been Successfully sent';
            system.debug('::mails:::::'+mails);
        }
        return result;
    }
}