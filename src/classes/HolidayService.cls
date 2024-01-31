/**********************************************************************
    Created by Sukanya on Jan 6 2017: Service class used for Holiday object
***********************************************************************/
public with sharing class HolidayService {
     
     // This method return holiday records with date filters
     public static list<Holiday> getHolidayBydate(Set<Date> dateSet) {
         
        List<Holiday> holidays = [SELECT Id,Name,ActivityDate FROM Holiday WHERE ActivityDate IN : dateSet];
        return holidays;
     }
     
     // This method return holidays without any conditions
     public static list<Holiday> getHolidays() {
        List<Holiday> holidays = [SELECT Id,Name,ActivityDate FROM Holiday];
        return holidays;
     }
     
     /************************************************************************
     - Developed by NS on Jan 07 2019
     - Method to calculate the Recurrence Holiday Date based on 2 date inputs
     - Because org activity date is updated on the actual date when it is set as Recurrence
     - Input - 2 dates & output - set<Date> holiday dates
     - All holiday queries will be replaced by this method
     *************************************************************************/
     public static Set<Date> getHolidaysWithRecurrence(Date stDate,Date endDate){
        
        system.debug(':::holiday::Service::::::::::::stDate::::'+stDate);
        system.debug(':::holiday::Service::::::::::::endDate::::'+endDate);
        
        Set<Date> existingHolidayDates = new Set<Date>();
        
        Set<Date> newHolidays = new Set<Date>();
        Set<Integer> yearValues = new Set<Integer>();
        Map<String,Integer> weekNumber = new Map<String,Integer>{'First' => 1,'Second' => 2,'Third' => 3,'Fourth' => 4,'Last' => 5};
        Map<Integer,String> dayName = new Map<Integer,String>{1 => 'Sunday', 2 => 'Monday', 4 => 'Tuesday', 8 => 'Wednesday', 16 => 'Thursday', 32 => 'Friday', 64 => 'Saturday'};
        
        
        Date dt1 = stDate;
        Date dt2 = endDate;
        
        while(dt1.year() <= dt2.year()){
             yearValues.add(dt1.year()); 
             dt1 = Date.newInstance(dt1.addYears(1).year(),dt1.month(),dt1.day());
        }
        
        system.debug('::::::::::yearValues:::::::'+yearValues);
        
        for(Holiday hol : [SELECT Id,Name,ActivityDate,IsRecurrence,RecurrenceStartDate,RecurrenceEndDateOnly,RecurrenceType,RecurrenceMonthOfYear,
                                    RecurrenceDayOfWeekMask,RecurrenceInstance 
                            FROM Holiday]){
                            
            system.debug(':::::::::hol.ActivityDate::::'+hol.ActivityDate);
            
            if(hol.IsRecurrence) {
            
                if(hol.RecurrenceType == 'RecursYearly'){
                
                    for(Integer yr : yearValues){
                        if(hol.ActivityDate.year() == yr && (hol.ActivityDate >= stDate && hol.ActivityDate <= endDate) 
                            && (hol.RecurrenceEndDateOnly == null || (hol.RecurrenceEndDateOnly != null && hol.ActivityDate <= hol.RecurrenceEndDateOnly))){
                             newHolidays.add(hol.ActivityDate);
                        }
                        if(hol.ActivityDate.year() < yr){
                            Date newHolDate = Date.newInstance(yr,hol.ActivityDate.month(),hol.ActivityDate.day());
                            if(newHolDate >= stDAte && newHolDate <= endDate 
                                && (hol.RecurrenceEndDateOnly == null || (hol.RecurrenceEndDateOnly != null && newHolDate <= hol.RecurrenceEndDateOnly))){
                                newHolidays.add(newHolDate);
                            }
                        }
                    }
                }else if(hol.RecurrenceType == 'RecursYearlyNth'){
                
                    for(Integer yr : yearValues){
                        
                        if(hol.ActivityDate.year() == yr && (hol.ActivityDate >= stDate && hol.ActivityDate <= endDate) 
                            && (hol.RecurrenceEndDateOnly == null || (hol.RecurrenceEndDateOnly != null && hol.ActivityDate <= hol.RecurrenceEndDateOnly))){
                            
                             newHolidays.add(hol.ActivityDate);
                        }
                        if(hol.ActivityDate.year() < yr){
                            Date newHolDate = Date.newInstance(yr,hol.ActivityDate.month(),hol.ActivityDate.day());
                            
                            DateTime newVal = DateTime.newInstance(newHolDate, Time.newInstance(0, 0, 0, 0));
                            String oldDayName;
                            if(dayName.containsKey(hol.RecurrenceDayOfWeekMask)){
                                oldDayName = dayName.get(hol.RecurrenceDayOfWeekMask);
                            }
                            
                            List<String> weekRangeSet = new List<String>();
                            
                            Date mnthStart = newHolDate.toStartOfMonth();
                            Date mnthEnd = mnthStart.addMonths(1).addDays(-1);
                            
                            system.debug(':::::::::mnthStart::::'+mnthStart);
                            system.debug(':::::::::mnthEnd::::'+mnthEnd);
            
                            Integer weekNum;
                            if(weekNumber.containsKey(hol.RecurrenceInstance)){
                                weekNum = weekNumber.get(hol.RecurrenceInstance);
                            }
                            
                            //Last Recurrence related actual week number (For nth value is set to last in recurrence setting)
                            if( weekNum  == 5 ) {
                                Integer weekCount = 0;
                                DateTime dtValTemp = DateTime.newInstance(mnthStart, Time.newInstance(0, 0, 0, 0));
                                
                                while (mnthStart <= mnthEnd) {
                                    dateTime dt = DateTime.newInstance(mnthStart.year(), mnthStart.month(), mnthStart.day());
                                    String dayOfWeek = dt.format('EEEE');
                                    
                                    if (dayOfWeek == oldDayName ) {
                                        weekCount++;
                                        mnthStart = mnthStart.addDays(7);
                                    } else {
                                        mnthStart = mnthStart.addDays(1);
                                    }
                                }
                                system.debug('weekCount:::::::::'+weekCount);
                                weekNum = weekCount;
                            }
                            
                            Integer i = 0;
                            mnthStart = newHolDate.toStartOfMonth();
                            mnthEnd = mnthStart.addMonths(1).addDays(-1);
                            
                            while(mnthStart <= mnthEnd){
                                DateTime dtVal = DateTime.newInstance(mnthStart, Time.newInstance(0, 0, 0, 0));
                                if(dtVal.format('EEEE') == oldDayName){
                                    i += 1;
                                    
                                    if(i == weekNum){
                                        newHolDate = mnthStart;
                                        break;
                                    }else {
                                        mnthStart = mnthStart.addDays(7);
                                    }
                                }else{
                                    mnthStart = mnthStart.addDays(1);
                                }
                            }
                            
                            if(newHolDate >= stDAte && newHolDate <= endDate 
                                && (hol.RecurrenceEndDateOnly == null || (hol.RecurrenceEndDateOnly != null && newHolDate <= hol.RecurrenceEndDateOnly))){
                                system.debug(':::::nth::recurrence::::::dt:::::'+newHolDate);
                                newHolidays.add(newHolDate);
                            }
                        }
                    }
                }
            }else {
                
                if(hol.ActivityDate >= stDate && hol.ActivityDate <= endDate){
                    newHolidays.add(hol.ActivityDate);
                }
            }
            
        }
        
        system.debug('::::::::::::newHolidays:::'+newHolidays);
        system.debug(':::::::::cpu::time::::::::::'+Limits.getCpuTime());
        
        return newHolidays;
    }
    
    /*********************************************************************************
    - Method to get the Holidays Instance to use in Calendar Section in Community
    - Added by NS on Apr 8 2019 
    *********************************************************************************/
    public static List<Holiday> getHolidayRecordsWithRecurrence(Date stDate,Date endDate){
    
        Set<Date> existingHolidayDates = new Set<Date>();
        
        Set<Date> newHolidays = new Set<Date>();
        Map<Date,String> dtHolidayNameMap = new Map<Date,String>();
        List<Holiday> holidayRecords = new List<Holiday>();
        
        Set<Integer> yearValues = new Set<Integer>();
        Map<String,Integer> weekNumber = new Map<String,Integer>{'First' => 1,'Second' => 2,'Third' => 3,'Fourth' => 4,'Last' => 5};
        Map<Integer,String> dayName = new Map<Integer,String>{1 => 'Sunday', 2 => 'Monday', 4 => 'Tuesday', 8 => 'Wednesday', 16 => 'Thursday', 32 => 'Friday', 64 => 'Saturday'};
        
        
        Date dt1 = stDate;
        Date dt2 = endDate;
        
        while(dt1.year() <= dt2.year()){
             yearValues.add(dt1.year()); 
             dt1 = Date.newInstance(dt1.addYears(1).year(),dt1.month(),dt1.day());
        }
        
        system.debug('::::::::::yearValues:::::::'+yearValues);
        
        for(Holiday hol : [SELECT Id,Name,ActivityDate,IsRecurrence,RecurrenceStartDate,RecurrenceEndDateOnly,RecurrenceType,RecurrenceMonthOfYear,
                                    RecurrenceDayOfWeekMask,RecurrenceInstance 
                            FROM Holiday]){
            system.debug(':::::::::hol.ActivityDate::::'+hol.ActivityDate);
            if(hol.IsRecurrence) {
                if(hol.RecurrenceType == 'RecursYearly'){
                
                    for(Integer yr : yearValues){
                        if(hol.ActivityDate.year() == yr && (hol.ActivityDate >= stDate && hol.ActivityDate <= endDate) 
                            && (hol.RecurrenceEndDateOnly == null || (hol.RecurrenceEndDateOnly != null && hol.ActivityDate <= hol.RecurrenceEndDateOnly))){
                            
                            system.debug(':::RecursYearly:::::holdaiy:::'+hol.ActivityDate);
                            
                             newHolidays.add(hol.ActivityDate);
                             
                             //Map to hold the name & date
                             if(!dtHolidayNameMap.containsKey(hol.ActivityDate)){
                                 dtHolidayNameMap.put(hol.ActivityDate,(hol.Name+'-'+hol.Id));
                             }
                        }
                        if(hol.ActivityDate.year() < yr){
                            Date newHolDate = Date.newInstance(yr,hol.ActivityDate.month(),hol.ActivityDate.day());
                            if(newHolDate >= stDAte && newHolDate <= endDate 
                                && (hol.RecurrenceEndDateOnly == null || (hol.RecurrenceEndDateOnly != null && newHolDate <= hol.RecurrenceEndDateOnly))){
                                newHolidays.add(newHolDate);
                                
                                system.debug(':::RecursYearly:::::newHolDate:::'+newHolDate);
                                
                                //Map to hold the name & date
                                if(!dtHolidayNameMap.containsKey(newHolDate)){
                                    dtHolidayNameMap.put(newHolDate,(hol.Name+'-'+hol.Id));
                                }
                            }
                        }
                    }
                }else if(hol.RecurrenceType == 'RecursYearlyNth'){
                
                    for(Integer yr : yearValues){
                        if(hol.ActivityDate.year() == yr && (hol.ActivityDate >= stDate && hol.ActivityDate <= endDate) 
                            && (hol.RecurrenceEndDateOnly == null || (hol.RecurrenceEndDateOnly != null && hol.ActivityDate <= hol.RecurrenceEndDateOnly))){
                             newHolidays.add(hol.ActivityDate);
                             
                             //Map to hold the name & date
                            if(!dtHolidayNameMap.containsKey(hol.ActivityDate)){
                                dtHolidayNameMap.put(hol.ActivityDate,(hol.Name+'-'+hol.Id));
                            }
                        }
                        if(hol.ActivityDate.year() < yr){
                            Date newHolDate = Date.newInstance(yr,hol.ActivityDate.month(),hol.ActivityDate.day());
                            
                            DateTime newVal = DateTime.newInstance(newHolDate, Time.newInstance(0, 0, 0, 0));
                            String oldDayName;
                            if(dayName.containsKey(hol.RecurrenceDayOfWeekMask)){
                                oldDayName = dayName.get(hol.RecurrenceDayOfWeekMask);
                            }
                            
                            List<String> weekRangeSet = new List<String>();
                            
                            Date mnthStart = newHolDate.toStartOfMonth();
                            Date mnthEnd = mnthStart.addMonths(1).addDays(-1);
                            
                            system.debug(':::::::::mnthStart::::'+mnthStart);
                            system.debug(':::::::::mnthEnd::::'+mnthEnd);
            
                            Integer weekNum;
                            if(weekNumber.containsKey(hol.RecurrenceInstance)){
                                weekNum = weekNumber.get(hol.RecurrenceInstance);
                            }
                            
                            //Last Recurrence related actual week number (For nth value is set to last in recurrence setting)
                            if( weekNum  == 5 ) {
                                Integer weekCount = 0;
                                DateTime dtValTemp = DateTime.newInstance(mnthStart, Time.newInstance(0, 0, 0, 0));
                                
                                while (mnthStart <= mnthEnd) {
                                    dateTime dt = DateTime.newInstance(mnthStart.year(), mnthStart.month(), mnthStart.day());
                                    String dayOfWeek = dt.format('EEEE');
                                    
                                    if (dayOfWeek == oldDayName ) {
                                        weekCount++;
                                        mnthStart = mnthStart.addDays(7);
                                    } else {
                                        mnthStart = mnthStart.addDays(1);
                                    }
                                }
                                system.debug('weekCount:::::::::'+weekCount);
                                weekNum = weekCount;
                            }
                            
                            Integer i = 0;
                            mnthStart = newHolDate.toStartOfMonth();
                            mnthEnd = mnthStart.addMonths(1).addDays(-1);
                            
                            while(mnthStart <= mnthEnd){
                                DateTime dtVal = DateTime.newInstance(mnthStart, Time.newInstance(0, 0, 0, 0));
                                if(dtVal.format('EEEE') == oldDayName){
                                    i += 1;
                                    
                                    if(i == weekNum){
                                        newHolDate = mnthStart;
                                        break;
                                    }else {
                                        mnthStart = mnthStart.addDays(7);
                                    }
                                }else{
                                    mnthStart = mnthStart.addDays(1);
                                }
                            }
                            
                            if(newHolDate >= stDAte && newHolDate <= endDate 
                                && (hol.RecurrenceEndDateOnly == null || (hol.RecurrenceEndDateOnly != null && newHolDate <= hol.RecurrenceEndDateOnly))){
                                system.debug(':::::nth::recurrence::::::dt:::::'+newHolDate);
                                newHolidays.add(newHolDate);
                                
                                //Map to hold the name & date
                                if(!dtHolidayNameMap.containsKey(newHolDate)){
                                    dtHolidayNameMap.put(newHolDate,(hol.Name+'-'+hol.Id));
                                }
                            }
                        }
                    }
                }
            }else {
                newHolidays.add(hol.ActivityDate);
                if(!dtHolidayNameMap.containsKey(hol.ActivityDate)){
                    dtHolidayNameMap.put(hol.ActivityDate,hol.Name+'-'+hol.Id);
                }
            }
        }
        
        system.debug('::::::::::::newHolidays:::'+newHolidays);
        system.debug(':::::::::cpu::time::::::::::'+Limits.getCpuTime());
        system.debug(':::::::::dtHolidayNameMap::::::'+dtHolidayNameMap);
        
        //Get Community related Business Horus record to check the holiday is related to Community Business Hours or not
        List<BusinessHours> businessHrs = [SELECT Id,Name FROM BusinessHours WHERE Name = 'Community'];
        
        for(Date dt : dtHolidayNameMap.keySet()){
            
            Holiday hol = new Holiday();
            hol.ActivityDate = dt;
            hol.Name = dtHolidayNameMap.get(dt).split('-')[0];
            hol.Id = dtHolidayNameMap.get(dt).split('-')[1];
            
            //To check the holday date is related to Community Business Hrs or not
            DateTime holDate = DateTime.newInstance(dt.year(),dt.month(),dt.day());
            Boolean isValidHoliday = !BusinessHours.isWithin(businessHrs[0].Id, holDate);
            
            if(isValidHoliday) {
                holidayRecords.add(hol);
            }
            
        }
        
        system.debug('::::::::holidayRecords:::::'+holidayRecords);
        
        return holidayRecords;
    }
     
}