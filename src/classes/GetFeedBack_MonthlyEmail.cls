// This Scheduler class for Monthly Email sending for Get Feed back Student Contact
// This scheduler call the sendFeedbackFormHelper class "sendEmail" method to send mail
// Created by Karthiga on May 16 2017

global class GetFeedBack_MonthlyEmail implements Schedulable {
    
    global void execute(SchedulableContext sc) {
       // Set<Id> proIdSet = new Set<Id>();
      //  List<AcctSeed__Project__c> proList = new List<AcctSeed__Project__c>();
        DateTime tDt = system.now();
        Date nextEmailDt;
        Boolean SendEmail = False;
        Boolean notifyEmail = false;

        System_Values__c mDt = System_Values__c.getValues('Send FeedBack Monthly');// Monthly Email Date
        if( mDt != null && mDt.Value__c != null ) {
            Date oldDate = Date.ValueOf(mDt.Value__c);
           
            if(olddate.month() != tDt.month()) {
                Date dt0 = System.Today().toStartOfMonth();
           
                dt0 = sendFeedbackFormHelper.monthlySendDate(dt0, 1);  // to find first working day of month
                system.debug(':dt0:::::::'+dt0);
               
                if(System.Today() == dt0){
                    SendEmail = true;
                }
                if(Test.isRunningTest()) {
                    SendEmail = true;    
                }
            
            } else if (olddate.month() == tDt.month()) {
                nextEmailDt = System.Today().addMonths(1).toStartOfMonth();
                sendFeedbackFormHelper.sendNotificationEmailCheck(nextEmailDt, 'Monthly'/*, holSet*/);
            }
        } else {
            Date dt0 = System.Today().toStartOfMonth();
        
            dt0 = sendFeedbackFormHelper.monthlySendDate(dt0, 1);  // to find first working day of month

            system.debug(':dt0::'+dt0);
            
            if(System.Today() == dt0){
                SendEmail = true;
            }
            if(Test.isRunningTest()) {
                SendEmail = true;    
            }
           
        }
        System.debug('SendEmail:::'+SendEmail);
        System.debug('System.Today():::'+System.Today());
        
        if(SendEmail){
           // To avoid 101 query limit exception
           /* for(AcctSeed__Project__c pro :[SELECT Id,Name,Start_Date__c,End_Date__c FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active' AND End_Date__c > THIS_MONTH AND Start_Date__c <= THIS_MONTH]) {
           
                if(pro.Start_Date__c != null) {
                    proIdSet.add(pro.Id);
                    proList.add(pro);
                }
            }
            if(proIdSet.size() > 0) {
                sendFeedbackFormHelper.sendMonthlyEmail(proIdSet,proList);
            } */
            
            // Created batch to avoid 101 query limit exception
            getFeedbackMonthlyBatch getFBMonBatch = new getFeedbackMonthlyBatch();
            database.executebatch(getFBMonBatch, 10);

        }
    }
}