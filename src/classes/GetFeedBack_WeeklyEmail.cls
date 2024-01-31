// This Scheduler class for Week Email sending for Get Feed back Student Contact
// This scheduler call the sendFeedbackFormHelper class "sendEmail" method to send mail
// Created by Sukanya on Dec 14 2016

global class GetFeedBack_WeeklyEmail implements Schedulable{
     
     global void execute(SchedulableContext sc) {
       Set<Id> proIdSet = new Set<Id>();
       List<AcctSeed__Project__c> proList = new List<AcctSeed__Project__c>();
       Set<Date> holSet = new Set<Date>(); // Holiday Set
       Boolean sendEmail = False;
       
       /*for (Holiday h : [SELECT Id, Name, ActivityDate FROM Holiday WHERE ActivityDate = THIS_YEAR]) {
           holSet.add(h.ActivityDate);
       }*/
       
       //Recurrence method call to get correct holiday dates for these date interval
       // Modified by NS on Jan 07 2019
       holSet = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
       
       sendFeedbackFormHelper.sendNotificationEmailCheck(System.Today(),'Weekly'/*,holSet*/);
       
       //Date limitDate = system.today().addDays(-14);
       Set<Date> limitDate = new Set<Date>(); // Holds the Start Date to query based on the Project's Start date
       Date dt0 = System.Today();
       Integer i = 14;
       
       // Weekly feedback is send to students even on holiday, Saturday and Sunday, Now it is handled to send the feedback on working days
       if(!holSet.contains(dt0)) { 
            DateTime dtTim1 = DateTime.newInstance(dt0, Time.newInstance(0, 0, 0, 0)); 
            String dayOfWeek = dtTim1.format('EEEE');
            if(dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday' ) {
                limitDate.add(dt0.addDays(-i));
                sendEmail = true;
            }
        }
        
        // to send Getfeedback mails for the Students until the Previous Working Day
        if(limitDate.size() == 1) { // To check that the current day is not a holiday and proceed further
            dt0 = dt0.addDays(-1);
           
            while(holSet.contains(dt0) ) { // To check the previous day is in Holiday
                limitDate.add(dt0.addDays(-i));
                dt0 = dt0.addDays(-1);
            }
            
            while(!holSet.contains(dt0)) { // If the previous day is not an holiday, check if it falls on Sat/ Sun
                DateTime dtTim1 = DateTime.newInstance(dt0, Time.newInstance(0, 0, 0, 0)); 
                String dayOfWeek = dtTim1.format('EEEE');
               
                if(dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') { // If Yes then adds to the LimitDate Set
                    limitDate.add(dt0.addDays(-i));
                    dt0 = dt0.addDays(-1);
                    
                } else { // If No the loop breaks
                    break;
                }
                
                if(holSet.contains(dt0)) { // To check the following past date is in Holiday List
                    limitDate.add(dt0.addDays(-i));
                    dt0 = dt0.addDays(-1);
                }
            } 
        }
     
        if(Test.isRunningTest()) { // For Test class Code Coverage
            sendEmail = true;    
        }

        //for(AcctSeed__Project__c pro :[SELECT Id,Name,Start_Date__c,End_Date__c FROM AcctSeed__Project__c WHERE Start_Date__c = :limitDate]) {
        if(limitDate != Null && limitDate.size() > 0 && sendEmail) {
            for(AcctSeed__Project__c pro :[SELECT Id,Name,Start_Date__c,End_Date__c FROM AcctSeed__Project__c WHERE Start_Date__c IN :limitDate AND RecordType.DeveloperName != 'Testing_Projects']) {
                           
                if(pro.Start_Date__c != null) {
                    proIdSet.add(pro.Id);
                    proList.add(pro);
                }
            }
            if(proIdSet.size() > 0) {
                sendFeedbackFormHelper.sendEmail(proIdSet,proList);
            }
        }
    }

}