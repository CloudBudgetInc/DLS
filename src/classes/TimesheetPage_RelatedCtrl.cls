/**********************************************************************
Created to reduce the code on each time sheet related class
Common methods are constructed here
By NS on MAR 3 2018
**********************************************************************/

public class TimesheetPage_RelatedCtrl {

    
    //Accounting Period Creation based on start & end date for a Month
    public static void accountingPeriodCreation(Date startDate,Date endDate) {
        
        String month;
        
        date monthStart = startDate.toStartofMonth();
        date monthEnd = startDate.addMonths(1).toStartofMonth().addDays(-1);
        date monthStart1 = endDate.toStartofMonth();
        date monthEnd1 = endDate.addMonths(1).toStartofMonth().addDays(-1);
        // Added For future date records creation 
        // To check Account period records are exist or not & create if not
        // Account Period Query
        
        List<AcctSeed__Accounting_Period__c> accPeriodList = new List<AcctSeed__Accounting_Period__c>();
        List<AcctSeed__Accounting_Period__c> accPeriodNextMonthList = new List<AcctSeed__Accounting_Period__c>();
        
        if(monthStart == monthStart1 && monthEnd == monthEnd1) {
            //accPeriodList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c,AcctSeed__Status__c FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c =: monthStart AND AcctSeed__End_Date__c =: monthEnd];
            accPeriodList = AccountingPeriodService.getAccountperiodRec(new Set<Date>{monthStart},new Set<Date>{monthEnd});
            
            system.debug('::::accPeriodList::::'+accPeriodList.size());
        } else {
        
            //accPeriodList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c,AcctSeed__Status__c FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c =: monthStart AND AcctSeed__End_Date__c =: monthEnd];
            accPeriodList = AccountingPeriodService.getAccountperiodRec(new Set<Date>{monthStart},new Set<Date>{monthEnd});
            
            //accPeriodNextMonthList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c,AcctSeed__Status__c FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c =: monthStart1 AND AcctSeed__End_Date__c =: monthEnd1];
            accPeriodNextMonthList = AccountingPeriodService.getAccountperiodRec(new Set<Date>{monthStart1},new Set<Date>{monthEnd1});
            
            system.debug('::::accPeriodList::::'+accPeriodList.size());
        }
        
        if (accPeriodList == null || accPeriodList.size() == 0) {
            
            if(monthStart.month() < 10){
                month = '0'+monthStart.month();
            }else {
                month = String.valueOf(monthStart.month());
            }
            
            AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c();
            accPeriod.name = startDate.year()+'-' +month;
            accPeriod.AcctSeed__Start_Date__c = monthStart;
            accPeriod.AcctSeed__End_Date__c = monthEnd;
            system.debug(':::::::::accPeriod::iggg::::'+accPeriod);
            Insert accPeriod;
            system.debug('**accPeriod**'+accPeriod.id);
        } 
        
        if (monthStart != monthStart1 && monthEnd != monthEnd1 && (accPeriodNextMonthList == null || accPeriodNextMonthList.size() == 0)) {
            
            if(monthStart1.month() < 10){
                month = '0'+monthStart1.month();
            }else {
                month = String.valueOf(monthStart1.month());
            }
            
            AcctSeed__Accounting_Period__c accPeriod1 = new AcctSeed__Accounting_Period__c();
            accPeriod1.name = endDate.year()+'-' +month;
            accPeriod1.AcctSeed__Start_Date__c = monthStart1;
            accPeriod1.AcctSeed__End_Date__c = monthEnd1;
            system.debug(':::::::::accPeriod1::iggg::::'+accPeriod1);
            Insert accPeriod1;
            system.debug('**accPeriod1**'+accPeriod1.id);
        }
    }
    
    //Time Card Period creation based on Start and End date for a Week
    public static String timeCardPeriodCreation(Date startDate,Date endDate) {
        
        String timeCardPeriodId;
        
         for(AcctSeed__Time_Card_Period__c timePrd :TimecardPeriodService.getTimeCardPeriodByDate(' AcctSeed__Start_Date__c = '+String.valueof(startDate).split(' ')[0]+' AND AcctSeed__End_Date__c = '+String.valueof(endDate).split(' ')[0]+'',new Set<Date>{},new Set<Date>{})) {
             timeCardPeriodId = timePrd.Id;     
         }
         system.debug('::::::timeCardPeriodId:::::::'+timeCardPeriodId);
         
         if(timeCardPeriodId != null){
             return timeCardPeriodId;
         }else {
            AcctSeed__Time_Card_Period__c period = new AcctSeed__Time_Card_Period__c();
            period.name = startDate.year()+'-' + startDate.Month();
            period.AcctSeed__Start_Date__c = startDate;
            period.AcctSeed__End_Date__c = endDate;
            
            insert period;  
            system.debug(':::::::::created::Period::::'+period);  
                
            timeCardPeriodId = period.Id;
            
            return timeCardPeriodId;
         }
    }
}