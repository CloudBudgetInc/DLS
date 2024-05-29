/**********************************************************************
    Created by Sukanya on Jan 12 2017: Translator class used for Time card Day object inner class formation
***********************************************************************/

global class TimeCardDayTranslator {
     
     /**********************************************************************
        Created by Sukanya on Jan 12 2017: Translator class used for DLS_Staff_Time_Entry_Ctrl inner class formation
        return - instance for EmployeeDetails - inner class
    ***********************************************************************/
     
     global static TimeCardDayDomain.EmployeeDetails employeeDetailsMethod(List<AcctSeed__Project_Task__c> projectTaskList,List<AcctSeed__Project__c> projectList,List<Contact> conRecList,List<AcctSeed__Time_Card_Line__c> timeCardLineWithDayvalues,String timeZone,Date lockingDate,List<Accounting_Seed_Time_Snapshot__c> timeSnapshots,List<Date> dateList,Set<Date> holidayDates,List<AcctSeed__Time_Card_Line__c> previousWeektimeDetails,List<Document> documentList,List<Contact_Assignments__c> conAssignList,List<Contact_Assignments__c> projectsSupervisors,List<Project_Task_Master__c> PTMValue) {
         
         TimeCardDayDomain.EmployeeDetails empDetails = new TimeCardDayDomain.EmployeeDetails();
         empDetails.projectTasks = projectTaskList;
         empDetails.projects = projectList; 
         
         if(conRecList != null && conRecList.size() > 0) {
         
             system.debug(':::::::::Supervisor_Name_Formula__c:::::::::::'+conRecList[0].Supervisor_Name_Formula__c);
             
             empDetails.ContactId = conRecList[0].Id;
             empDetails.Name = conRecList[0].Name;
             empDetails.HomeDeptProId = conRecList[0].Home_Department_Project__c;
             empDetails.HomeDepartProName = conRecList[0].Home_Department_Project__r.Name;
             empDetails.supervisorId =  conRecList[0].Supervisor_Name__c;
             empDetails.supervisorName = conRecList[0].Supervisor_Name_Formula__c;
             empDetails.EEPayStatus = conRecList[0].EE_Pay_Status__c;
             empDetails.ContactRecordType = conRecList[0].RecordType.DeveloperName;
             empDetails.timeCardDayDetails = timeCardDayFormation(timeCardLineWithDayvalues,dateList,conRecList[0].Id);
             empDetails.previousWeekprojectTasks = getPreviousWeekTaskDetails(previousWeektimeDetails,conRecList[0].Id);
             empDetails.PaycomId = conRecList[0].PC_EE_ID__c;
         }
         empDetails.UserName = UserInfo.getName();
         empDetails.UserTimezoneValue = timeZone;
         empDetails.timeLogLockDate = lockingDate;
         empDetails.timeSnapshotDetails = timeSnapshots;
         
         // below payroll item field is refered from "Cost Rate" object - because we are not using payroll item fields in project task object
         // Modified by Sukanya on July 14 2017
         empDetails.payRollItemList = SObjectQueryService.PicklistValues('AcctSeed__Cost_Rates__c','Payroll_Item__c');
         empDetails.holidayList = holidayDates;
         
         empDetails.timekeepingRelatedDocuments = documentList;
         empDetails.contactAssignmentList = conAssignList;
         empDetails.projectRelatedSupervisors = projectsSupervisors;
         
         empDetails.taskName_PayrollItemMap = payrollItemFormation(PTMValue);
               
         system.debug('::::::empDetails::::::::'+empDetails);
         
         return empDetails;
     }   
    
     /**********************************************************************
        Created by Sukanya on Jan 12 2017: Translator class used for DLS_Staff_Time_Entry_Ctrl inner class formation
     ***********************************************************************/
     
     global static List<TimeCardDayDomain.TimeCardDay> timeCardDayFormation(List<AcctSeed__Time_Card_Line__c> LineWithDayRecords,List<Date> daysList,String InstructorId) {
         
         List<TimeCardDayDomain.TimeCardDay> existingTimeCardDays = new List<TimeCardDayDomain.TimeCardDay>();
         
         for(AcctSeed__Time_Card_Line__c LineRec : LineWithDayRecords) {
            if(LineRec.AcctSeed__Time_Card_Days__r != null && LineRec.AcctSeed__Time_Card_Days__r.size() > 0) {
                TimeCardDayDomain.TimeCardDay timeday = new TimeCardDayDomain.TimeCardDay();
                
                timeday.SelectedProject = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                timeday.SelectedProTask = LineRec.AcctSeed__Project_Task__c;
                timeday.SelectedInstructor = InstructorId;
                
                timeday.Day1 = daysList[0];
                timeday.Day2 = daysList[1];
                timeday.Day3 = daysList[2];
                timeday.Day4 = daysList[3];
                timeday.Day5 = daysList[4];
                timeday.Day6 = daysList[5];
                timeday.Day7 = daysList[6];
                
                timeday.TaskName = LineRec.AcctSeed__Project_Task__r.Name;
                timeday.ProjectName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                timeday.isBillable = LineRec.AcctSeed__Billable__c;
                timeday.TaskType = LineRec.AcctSeed__Project_Task__r.Project_Task_Type__c;
                timeday.timeCardLineId = LineRec.Id;
                timeday.payRollItem = LineRec.Payroll_Item__c;
                
                if(LineRec.Location__c != null) {
                    timeday.locationId = LineRec.Location__c;
                    timeday.locationName = LineRec.Location__r.Name;
                }else if(LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c != null) {
                    timeday.locationId = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c;
                    timeday.locationName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name;
                }
                
                timeday.costRateId = LineRec.Labor_Cost_Rate__c;
                timeday.contactAssignId = LineRec.Contact_Assignment__c;
                timeday.CRRateType = LineRec.Labor_Cost_Rate__r.Rate_Type__c;
                
                timeday.sequenceNumber = LineRec.Sequence_Number__c;
                
                if(LineRec.AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE')
                    timeday.IsAdminProTask = true;
                else
                    timeday.IsAdminProTask = false;
                    
                for(AcctSeed__Time_Card_Day__c td : LineRec.AcctSeed__Time_Card_Days__r) {
                    
                    if(timeday.Day1 == td.AcctSeed__Date__c) {
                        
                        if(td.Status__c == 'Unposted') {
                            timeday.Hours1 = '';
                            timeday.comment1 = '';
                        }else {
                            timeday.Hours1 = String.valueOf(td.Total_Hours_Before_Approved__c);
                            timeday.comment1 = td.AcctSeed__Internal_Comment__c;
                        }
                        timeday.Hrs1Day1Id = td.Id;
                        timeday.status1 = td.Status__c;
                        
                    }else if(timeday.Day2 == td.AcctSeed__Date__c) {
                        if(td.Status__c == 'Unposted') {
                            timeday.Hours2 = '';
                            timeday.comment2 = '';
                        }else {
                            timeday.Hours2 = String.valueOf(td.Total_Hours_Before_Approved__c);
                            timeday.comment2 = td.AcctSeed__Internal_Comment__c;
                        }
                        timeday.Hrs2Day2Id = td.Id;
                        timeday.status2 = td.Status__c;
                        
                    }else if(timeday.Day3 == td.AcctSeed__Date__c) {
                        if(td.Status__c == 'Unposted') {
                            timeday.Hours3 = '';
                            timeday.comment3 = '';
                        }else {
                            timeday.Hours3 = String.valueOf(td.Total_Hours_Before_Approved__c);
                            timeday.comment3 = td.AcctSeed__Internal_Comment__c;
                        }
                        timeday.Hrs3Day3Id = td.Id;
                        timeday.status3 = td.Status__c;
                        
                    }else if(timeday.Day4 == td.AcctSeed__Date__c) {
                        if(td.Status__c == 'Unposted') {
                            timeday.Hours4 = '';
                            timeday.comment4 = '';
                        }else {
                            timeday.Hours4 = String.valueOf(td.Total_Hours_Before_Approved__c);
                            timeday.comment4 = td.AcctSeed__Internal_Comment__c;
                        }
                        timeday.Hrs4Day4Id = td.Id;
                        timeday.status4 = td.Status__c;
                        
                    }else if(timeday.Day5 == td.AcctSeed__Date__c) {
                        if(td.Status__c == 'Unposted') {
                            timeday.Hours5 = '';
                            timeday.comment5 = '';
                        }else {
                            timeday.Hours5 = String.valueOf(td.Total_Hours_Before_Approved__c);
                            timeday.comment5 = td.AcctSeed__Internal_Comment__c;
                        }
                        timeday.Hrs5Day5Id = td.Id;
                        timeday.status5 = td.Status__c;
                        
                    }else if(timeday.Day6 == td.AcctSeed__Date__c) {
                        if(td.Status__c == 'Unposted') {
                            timeday.Hours6 = '';
                            timeday.comment6 = '';
                        }else {
                            timeday.Hours6 = String.valueOf(td.Total_Hours_Before_Approved__c);
                            timeday.comment6 = td.AcctSeed__Internal_Comment__c;
                        }
                        timeday.Hrs6Day6Id = td.Id;
                        timeday.status6 = td.Status__c;
                        
                    }else if(timeday.Day7 == td.AcctSeed__Date__c) {
                        if(td.Status__c == 'Unposted') {
                            timeday.Hours7 = '';
                            timeday.comment7 = '';
                        }else {
                            timeday.Hours7 = String.valueOf(td.Total_Hours_Before_Approved__c);
                            timeday.comment7 = td.AcctSeed__Internal_Comment__c;
                        }
                        timeday.Hrs7Day7Id = td.Id;
                        timeday.status7 = td.Status__c;
                    }
                }
                    
                existingTimeCardDays.add(timeday);
            }
        }
        
        system.debug('::::::existingTimeCardDays::::::::'+existingTimeCardDays);
         
         return existingTimeCardDays;
     }
     
      /**********************************************************************
        Created by Sukanya on Jan 12 2017: Translator class used for DLS_Staff_Time_Entry_Ctrl inner class formation
    ***********************************************************************/
     
     global static List<TimeCardDayDomain.TimeCardDay> existingTimeDayFormation(List<AcctSeed__Time_Card_Day__c> timeCardEventList,List<Date> daysList,String InstructorId,String projectId,String taskId) {
         
         List<Accounting_Seed_Time_Snapshot__c> timeSnapShots = new List<Accounting_Seed_Time_Snapshot__c>();
         List<TimeCardDayDomain.TimeCardDay> existingTimeCardDays = new List<TimeCardDayDomain.TimeCardDay>();
         
        TimeCardDayDomain.TimeCardDay timeday = new TimeCardDayDomain.TimeCardDay();
        timeday.SelectedProject = projectId;
        timeday.SelectedProTask = taskId;
        timeday.SelectedInstructor = InstructorId;
        timeday.Day1 = daysList[0];
        timeday.Day2 = daysList[1];
        timeday.Day3 = daysList[2];
        timeday.Day4 = daysList[3];
        timeday.Day5 = daysList[4];
        timeday.Day6 = daysList[5];
        timeday.Day7 = daysList[6];
        
        
        system.debug(':::::::::timeday::::::::'+timeday);
        
        for(AcctSeed__Time_Card_Day__c td : timeCardEventList) {
            
            timeday.TaskName = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            timeday.ProjectName = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name;
            timeday.isBillable = td.AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c;
            timeday.TaskType = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c;
            timeday.timeCardLineId = td.AcctSeed__Time_Card_Line__c;
            timeday.payRollItem = td.AcctSeed__Time_Card_Line__r.Payroll_Item__c;
            
            if(td.AcctSeed__Time_Card_Line__r.Location__c != null) {
                timeday.locationId = td.AcctSeed__Time_Card_Line__r.Location__c;
                timeday.locationName = td.AcctSeed__Time_Card_Line__r.Location__r.Name;
            }else if(td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c != null) {
                timeday.locationId = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c;
                timeday.locationName = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name;
            }
            
            timeday.costRateId = td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__c;
            timeday.contactAssignId = td.AcctSeed__Time_Card_Line__r.Contact_Assignment__c;
            
            timeday.sequenceNumber = td.AcctSeed__Time_Card_Line__r.Sequence_Number__c;
            
            if(td.Accounting_Seed_Time_Snapshots__r != null && td.Accounting_Seed_Time_Snapshots__r.size() > 0) {
                for(Accounting_Seed_Time_Snapshot__c timeSnap : td.Accounting_Seed_Time_Snapshots__r) {
                    timeSnapShots.add(timeSnap);
                }
            }
            
            if(timeday.Day1 == td.AcctSeed__Date__c) {
                timeday.Hours1 = String.valueOf(td.Total_Hours_Before_Approved__c);
                timeday.Hrs1Day1Id = td.Id;
                timeday.comment1 = td.AcctSeed__Internal_Comment__c;
                timeday.status1 = td.Status__c;
                
                timeday.lateCancellation1 = td.Late_Cancellation__c;
                timeday.cancellationReason1 = td.Cancellation_Reason__c;
                
            }else if(timeday.Day2 == td.AcctSeed__Date__c) {
                timeday.Hours2 = String.valueOf(td.Total_Hours_Before_Approved__c);
                timeday.Hrs2Day2Id = td.Id;
                timeday.comment2 = td.AcctSeed__Internal_Comment__c;
                timeday.status2 = td.Status__c;
                
                timeday.lateCancellation2 = td.Late_Cancellation__c;
                timeday.cancellationReason2 = td.Cancellation_Reason__c;
                        
            }else if(timeday.Day3 == td.AcctSeed__Date__c) {
                timeday.Hours3 = String.valueOf(td.Total_Hours_Before_Approved__c);
                timeday.Hrs3Day3Id = td.Id;
                timeday.comment3 = td.AcctSeed__Internal_Comment__c;
                timeday.status3 = td.Status__c;
                
                timeday.lateCancellation3 = td.Late_Cancellation__c;
                timeday.cancellationReason3 = td.Cancellation_Reason__c;
                
            }else if(timeday.Day4 == td.AcctSeed__Date__c) {
                timeday.Hours4 = String.valueOf(td.Total_Hours_Before_Approved__c);
                timeday.Hrs4Day4Id = td.Id;
                timeday.comment4 = td.AcctSeed__Internal_Comment__c;
                timeday.status4 = td.Status__c;
                
                timeday.lateCancellation4 = td.Late_Cancellation__c;
                timeday.cancellationReason4 = td.Cancellation_Reason__c;
                
            }else if(timeday.Day5 == td.AcctSeed__Date__c) {
                timeday.Hours5 = String.valueOf(td.Total_Hours_Before_Approved__c);
                timeday.Hrs5Day5Id = td.Id;
                timeday.comment5 = td.AcctSeed__Internal_Comment__c;
                timeday.status5 = td.Status__c;
                
                timeday.lateCancellation5 = td.Late_Cancellation__c;
                timeday.cancellationReason5 = td.Cancellation_Reason__c;
                
            }else if(timeday.Day6 == td.AcctSeed__Date__c) {
                timeday.Hours6 = String.valueOf(td.Total_Hours_Before_Approved__c);
                timeday.Hrs6Day6Id = td.Id;
                timeday.comment6 = td.AcctSeed__Internal_Comment__c;
                timeday.status6 = td.Status__c;
                
                timeday.lateCancellation6 = td.Late_Cancellation__c;
                timeday.cancellationReason6 = td.Cancellation_Reason__c;
                
            }else if(timeday.Day7 == td.AcctSeed__Date__c) {
                timeday.Hours7 = String.valueOf(td.Total_Hours_Before_Approved__c);
                timeday.Hrs7Day7Id = td.Id;
                timeday.comment7 = td.AcctSeed__Internal_Comment__c;
                timeday.status7 = td.Status__c;
                
                timeday.lateCancellation7 = td.Late_Cancellation__c;
                timeday.cancellationReason7 = td.Cancellation_Reason__c;
            }
        }
        
        timeday.timeSnapshotList = timeSnapShots;
        existingTimeCardDays.add(timeday);
        system.debug(':::::::existingTimeCardDays::::::'+existingTimeCardDays);
        
        return existingTimeCardDays;
     }
     
      
     /**********************************************************************
        Created by Sukanya on Jan 12 2017: Translator class used for DLS_Staff_Time_Entry_Ctrl - TimeDaySummary inner class formation
        Modified by Sukanya on Jan 24 2017: this method for group by table data formation based on status 
    ***********************************************************************/
     
     global static Map<String,List<TimeCardDayDomain.TimeDaySummary>> summaryFormatMethod(List<AcctSeed__Time_Card_Line__c> cardLineList,List<Date> daysList) {
         
         Map<String,List<TimeCardDayDomain.TimeDaySummary>> datesummaryDataMap = new Map<String,List<TimeCardDayDomain.TimeDaySummary>>();
         List<TimeCardDayDomain.TimeDaySummary> summaryDataDetails = new List<TimeCardDayDomain.TimeDaySummary>();
         
         Map<Date,Map<String,TimeCardDayDomain.TimeDaySummary>> dateStatusMap = new Map<Date,Map<String,TimeCardDayDomain.TimeDaySummary>>();
         
         if(cardLineList != null && cardLineList.size() > 0) {
         
             for(AcctSeed__Time_Card_Line__c LineRec : cardLineList) {
                if(LineRec.AcctSeed__Time_Card_Days__r != null && LineRec.AcctSeed__Time_Card_Days__r.size() > 0) {
                    for(AcctSeed__Time_Card_Day__c td : LineRec.AcctSeed__Time_Card_Days__r) {
                    
                        // Check already date exist
                        if(!dateStatusMap.containsKey(td.AcctSeed__Date__c)) {
                            
                           TimeCardDayDomain.TimeDaySummary summary = new TimeCardDayDomain.TimeDaySummary();
                           summary.Hours = td.Total_Hours_Before_Approved__c;
                           
                           if(LineRec.Labor_Cost_Rate__c != null && LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null) {
                               summary.Payrate = LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c;
                           }
                           
                           if(summary.Payrate != null && summary.Hours != null)
                               summary.TotalAmount = ((summary.Hours) * (summary.Payrate)).setscale(2);
                            
                            dateStatusMap.put(td.AcctSeed__Date__c,new Map<String,TimeCardDayDomain.TimeDaySummary>{td.Status__c=>summary});
                            
                        }else if(dateStatusMap.containsKey(td.AcctSeed__Date__c)) {
                        
                            // Check if already Status exist
                            if(!dateStatusMap.get(td.AcctSeed__Date__c).containsKey(td.Status__c)) {
                                
                               TimeCardDayDomain.TimeDaySummary summary = new TimeCardDayDomain.TimeDaySummary();
                               summary.Hours = td.Total_Hours_Before_Approved__c;
                               
                               if(LineRec.Labor_Cost_Rate__c != null && LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null) {
                                   summary.Payrate = LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c;
                               }
                               
                               if(LineRec.Labor_Cost_Rate__c != null && LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null && td.Total_Hours_Before_Approved__c != null)
                                   summary.TotalAmount = ((td.Total_Hours_Before_Approved__c) * (LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c)).setscale(2);
                                
                               dateStatusMap.get(td.AcctSeed__Date__c).put(td.Status__c,summary);
                                
                            }else if(dateStatusMap.get(td.AcctSeed__Date__c).containsKey(td.Status__c)) {
                            
                                TimeCardDayDomain.TimeDaySummary summary = dateStatusMap.get(td.AcctSeed__Date__c).get(td.Status__c);
                                
                                summary.Hours = summary.Hours + td.Total_Hours_Before_Approved__c;
                                
                                if(LineRec.Labor_Cost_Rate__c != null && LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null) {
                                    if(summary.Payrate != null)
                                        summary.Payrate = summary.Payrate + LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c;
                                    else
                                        summary.Payrate = LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c;
                                }
                                   
                                if(td.Total_Hours_Before_Approved__c != null && LineRec.Labor_Cost_Rate__c != null && LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null) {
                                    if(summary.TotalAmount != null)
                                        summary.TotalAmount = summary.TotalAmount + ((td.Total_Hours_Before_Approved__c) * (LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c)).setscale(2);
                                    else
                                        summary.TotalAmount = ((td.Total_Hours_Before_Approved__c) * (LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c)).setscale(2);
                                }
                                dateStatusMap.get(td.AcctSeed__Date__c).put(td.Status__c,summary);
                            }
                        }
                    }
                }
            }
        }
        
        system.debug(':::::::dateStatusMap::::::::::'+dateStatusMap);
        
        for(Date dt : daysList) {
            if(dateStatusMap.containsKey(dt)) {
                
                for(String status : dateStatusMap.get(dt).keySet()) {
                    TimeCardDayDomain.TimeDaySummary timeSum = dateStatusMap.get(dt).get(status);
                    timeSum.dateValue = dt;
                    timeSum.Status = status;
                   
                    if(!datesummaryDataMap.containsKey(String.valueOf(dt))) {
                        datesummaryDataMap.put(String.valueOf(dt),new List<TimeCardDayDomain.TimeDaySummary >{timeSum});
                    }else {
                        datesummaryDataMap.get(String.valueOf(dt)).add(timeSum);
                    }
                }
            }else {
                 TimeCardDayDomain.TimeDaySummary timeSum = new TimeCardDayDomain.TimeDaySummary();
                 timeSum.dateValue = dt;
                 timeSum.Hours = 0.00;
                 timeSum.Payrate = 0.00;
                 timeSum.TotalAmount = 0.00;
                 timeSum.Status = '';
                 
                 if(!datesummaryDataMap.containsKey(String.valueOf(dt))) {
                     datesummaryDataMap.put(String.valueOf(dt),new List<TimeCardDayDomain.TimeDaySummary >{timeSum});
                 }
            }
        }
        
        system.debug('::::::::datesummaryDataMap::::::::'+datesummaryDataMap);
        
        //summaryData = datesummaryDataMap.values();
        
        //return summaryData;
        return datesummaryDataMap;
     }
     
     
     /**********************************************************************
        Created by Sukanya on Jan 17 2017: Translator class used for DLS_Staff_Time_Entry_Ctrl - TimeDaySummary list of inner class formation
    ***********************************************************************/
     
     global static List<TimeCardDayDomain.TimeDaySummary> summaryShowdetailFormation(List<AcctSeed__Time_Card_Line__c> cardLineList,List<Date> daysList) {
         
         Map<Date,List<TimeCardDayDomain.TimeDaySummary>> datesummaryDataListMap = new Map<Date,List<TimeCardDayDomain.TimeDaySummary>>();
         List<TimeCardDayDomain.TimeDaySummary> summaryDataList = new List<TimeCardDayDomain.TimeDaySummary>();
         
         system.debug('::::::::datesummaryDataListMap:::::::::'+datesummaryDataListMap);
         
         
        if(cardLineList != null && cardLineList.size() > 0) {
         
            for(AcctSeed__Time_Card_Line__c LineRec : cardLineList) {
                if(LineRec.AcctSeed__Time_Card_Days__r != null && LineRec.AcctSeed__Time_Card_Days__r.size() > 0) {
                    for(AcctSeed__Time_Card_Day__c td : LineRec.AcctSeed__Time_Card_Days__r) {
                    
                        if(!datesummaryDataListMap.containsKey(td.AcctSeed__Date__c)) {
                           
                            TimeCardDayDomain.TimeDaySummary summary = new TimeCardDayDomain.TimeDaySummary();
                            
                            summary.dateValue = td.AcctSeed__Date__c;
                             
                            summary.Hours = td.Total_Hours_Before_Approved__c;
                           
                            if(LineRec.Labor_Cost_Rate__c != null && LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null)
                               summary.Payrate = LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c;
                            else
                               summary.Payrate = 0.00;
                                  
                            if(summary.Payrate != null && summary.Hours != null)
                               summary.TotalAmount = ((summary.Hours) * (summary.Payrate)).setscale(2);
                            
                            summary.Status = td.Status__c;
                            summary.ProjectName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                            summary.TaskName = LineRec.AcctSeed__Project_Task__r.Name;
                            summary.ProjectId = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                            summary.TaskId = LineRec.AcctSeed__Project_Task__c;
                            summary.DayId = td.Id;
                            summary.PayrollItem = LineRec.Payroll_Item__c;
                            summary.LocationName = LineRec.Location__r.Name;
                            
                            if(LineRec.AcctSeed__Billable__c)
                                summary.Billable = 'Billable';
                            else
                                summary.Billable = 'Non-Billable';
                            
                            if(summary.ProjectName != null || summary.TaskName != null || summary.PayrollItem != null
                                 || summary.Billable != null || summary.LocationName != null)
                                summary.ChargeCode = summary.ProjectName+' / '+summary.TaskName+' / '+summary.PayrollItem+' / '+summary.Billable+' / '+summary.LocationName;
                           
                            datesummaryDataListMap.put(td.AcctSeed__Date__c,new List<TimeCardDayDomain.TimeDaySummary>{summary});
                            
                            summaryDataList.add(summary);
                            
                        }else {
                            
                            TimeCardDayDomain.TimeDaySummary summary = new TimeCardDayDomain.TimeDaySummary();
                            
                            summary.dateValue = td.AcctSeed__Date__c;
                             
                            summary.Hours = td.Total_Hours_Before_Approved__c;
                           
                            if(LineRec.Labor_Cost_Rate__c != null && LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null)
                               summary.Payrate = LineRec.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c;
                            else
                               summary.Payrate = 0.00;
                               
                            if(summary.Payrate != null && summary.Hours != null)
                               summary.TotalAmount = ((summary.Hours) * (summary.Payrate)).setscale(2);
                            
                            summary.Status = td.Status__c;
                            summary.ProjectName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                            summary.TaskName = LineRec.AcctSeed__Project_Task__r.Name;
                            summary.ProjectId = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                            summary.TaskId = LineRec.AcctSeed__Project_Task__c;
                            summary.DayId = td.Id;
                            summary.PayrollItem = LineRec.Payroll_Item__c;
                            summary.LocationName = LineRec.Location__r.Name;
                            
                            if(LineRec.AcctSeed__Billable__c)
                                summary.Billable = 'Billable';
                            else
                                summary.Billable = 'Non-Billable';
                            
                            if(summary.ProjectName != null || summary.TaskName != null || summary.PayrollItem != null
                                 || summary.Billable != null || summary.LocationName != null)
                                summary.ChargeCode = summary.ProjectName+' / '+summary.TaskName+' / '+summary.PayrollItem+' / '+summary.Billable+' / '+summary.LocationName;
                            
                            datesummaryDataListMap.get(td.AcctSeed__Date__c).add(summary);
                            
                            summaryDataList.add(summary);
                        }
                    }
                }
            }
        }
        
        system.debug(':::::::datesummaryDataListMap::::::::::'+datesummaryDataListMap);
        
        for(Date dt : daysList) {
             
             if(!datesummaryDataListMap.containsKey(dt)) {
                 TimeCardDayDomain.TimeDaySummary timeSum = new TimeCardDayDomain.TimeDaySummary();
                 timeSum.dateValue = dt;
                 timeSum.Hours = 0.00;
                 timeSum.Payrate = 0.00;
                 timeSum.TotalAmount = 0.00;
                 timeSum.Status = '';
                 timeSum.ProjectName = '';
                 timeSum.TaskName = '';
                 
                 datesummaryDataListMap.put(dt,new List<TimeCardDayDomain.TimeDaySummary>{timeSum});
                 
                 summaryDataList.add(timeSum);
             }
        }
        
        system.debug(':::::datesummaryDataListMap:::::::::'+datesummaryDataListMap.values());
        system.debug(':::::summaryDataList:::::::::'+summaryDataList);
        
        return summaryDataList;
     }
     
     /**********************************************************************
        Created by Sukanya on Jan 13 2017: Translator class used for DLS_Staff_Time_Entry_Ctrl - userSummaryDetails inner class formation
    ***********************************************************************/
     
     global static TimeCardDayDomain.userSummaryDetails userSummaryformation(List<Contact> contactList,List<AcctSeed__Time_Card_Line__c> lineWithDayList,List<Date> daysList,date lockDate) {
         
         TimeCardDayDomain.userSummaryDetails usrSumdetails = new TimeCardDayDomain.userSummaryDetails();
         
         if(contactList != null && contactList.size() > 0) {
             usrSumdetails.userName = contactList[0].Name;
             usrSumdetails.bonusLeavebalance = contactList[0].Total_Bonus_Leave_Balance_Hours__c;
             usrSumdetails.bonusLeaveearned = contactList[0].Bonus_Leave_Earned_Hours__c;
             usrSumdetails.bonusLeavetaken = contactList[0].Bonus_Leave_Taken_Hours__c;
             
             usrSumdetails.vocationLeavebalance = contactList[0].Total_Vocation_Leave_Balance_Hours__c != null ?contactList[0].Total_Vocation_Leave_Balance_Hours__c:0;
             usrSumdetails.vocationLeaveearned = contactList[0].Vocation_Leave_Earned__c != null ?contactList[0].Vocation_Leave_Earned__c:0;
             usrSumdetails.vocationLeavetaken = contactList[0].Vocation_Leave_Taken__c != null ?contactList[0].Vocation_Leave_Taken__c:0;
             
             usrSumdetails.sickLeavebalance = contactList[0].Total_Sick_Leave_Balance_Hours__c != null ?contactList[0].Total_Sick_Leave_Balance_Hours__c:0;
             usrSumdetails.sickLeaveearned = contactList[0].Sick_Leave_Earned__c != null ?contactList[0].Sick_Leave_Earned__c:0;
             usrSumdetails.sickLeavetaken = contactList[0].Sick_Leave_Taken__c != null ?contactList[0].Sick_Leave_Taken__c:0;
         }
         usrSumdetails.timeSummaryData = summaryFormatMethod(lineWithDayList,daysList);
         usrSumdetails.showDetailsummaryData = summaryShowdetailFormation(lineWithDayList,daysList);
         
         usrSumdetails.timeLogLockDate = lockDate;
         
         system.debug(':::::::usrSumdetails::::::::::'+usrSumdetails);
         
         return usrSumdetails;
     }
    
     /**********************************************************************
        Created by Sukanya on Jan 18 2017: Translator class used for TimeSheet_Internlas_Component (Supervisor Time Approval Page) - WrapperClass inner class formation
       Modified by Sukanya on Jan 25 2017: For Supervisor Approval Page summary details qry for Week range flip
    ***********************************************************************/
    global static TimeCardDayDomain.WrapperClass approvalPagewrapperMethod(List<Attendance__c> attendace,List<AcctSeed__Time_Card_Day__c> timeCarddayForInstructor,List<AcctSeed__Time_Card_Day__c> internalTimecardDayDetails,List<AcctSeed__Time_Card_Line__c> timeCardlineList,Map<Id,String> lineIduserTypeMap,Date stDate,Date endDate,Boolean PageLoad,List<AcctSeed__Time_Card_Line__c> WeekRangeLineList,List<AcctSeed__Time_Card_Line__c> CountCalculationList,Set<String> WeekRangeSet,List<Accounting_Seed_Time_Snapshot__c> snapshotRecords,String timezone) {
        
        TimeCardDayDomain.WrapperClass wraper = new TimeCardDayDomain.WrapperClass();
        wraper.attendanceDetails = attendace;
        wraper.dayDetails = approvalPagetimeDaydetailMethod(timeCarddayForInstructor,internalTimecardDayDetails);
        wraper.summaryViewJsonData = approvalSummarytableFormationmethod(timeCardlineList,lineIduserTypeMap,stDate,endDate);
        wraper.dayIddayRecordMap = timeDaydetailsMapmethod(timeCardlineList);
        wraper.WeekRangeUserId_HrsCountMap = getTimesheetCount_HoursValues(CountCalculationList,WeekRangeSet);
        wraper.timeSnapshotDetails = snapshotRecords;
        wraper.UserTimezoneValue = timezone;
        
        if(PageLoad) {
            wraper.weekRangeValues = getWeekRangeFilterValuesForSummary(WeekRangeLineList);
        }
        
        return wraper;
    }
    
     /**********************************************************************
        Created by Sukanya on Jan 18 2017: Translator class used for TimeSheet_Internlas_Component (Supervisor Time Approval Page) - TimeCardDayDetails inner class formation
    ***********************************************************************/
    
    global static List<TimeCardDayDomain.TimeCardDayDetails> approvalPagetimeDaydetailMethod(List<AcctSeed__Time_Card_Day__c> timeCarddayForInstructor,List<AcctSeed__Time_Card_Day__c> internalTimecardDayDetails) {
        
        List<TimeCardDayDomain.TimeCardDayDetails> dayDetailsList = new List<TimeCardDayDomain.TimeCardDayDetails>();
        
        // for Instructor Approval data from  Time card day
        
        for(AcctSeed__Time_Card_Day__c timeDay : timeCarddayForInstructor) {
             TimeCardDayDomain.TimeCardDayDetails dayDetail = new TimeCardDayDomain.TimeCardDayDetails();
             
             dayDetail.Instructor = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name;
             dayDetail.InstructorId = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
             dayDetail.ProjectTaskName = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name;
             dayDetail.DLS_Class = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.DLS_Class__c;
             dayDetail.ProjectTaskId = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
             dayDetail.timeDayDate = timeDay.AcctSeed__Date__c;
             dayDetail.HrsBeforedApproved = String.valueOf(timeDay.Total_Hours_Before_Approved__c);
             //dayDetail.StartTime = timeDay.Start_Time__c;
             //dayDetail.EndTime = timeDay.End_Time__c;
             //dayDetail.lateCancellation = timeDay.Late_Cancellation__c;
             dayDetail.internalComment = timeDay.AcctSeed__Internal_Comment__c;
             dayDetail.isDisabled = true;
             dayDetail.timeDayId = timeDay.Id;
             //dayDetail.EventId = timeDay.Event__c;
             dayDetail.ProjectRTId = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId;
             dayDetail.ProjectRTName = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName;
             dayDetail.Billable = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c;
             dayDetail.ProjectName = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
             dayDetail.ProjectId = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c;
             dayDetail.ContactRecTypeName = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName;
             
             dayDetail.UserType = 'Instructor';
             
             /*if(timeDay.Event__c != null)
                 dayDetail.HrsScheduled = timeDay.Event__r.Duration__c;
             
             if(timeDay.Event__c != null) {
                if(timeDay.Total_Hours_Before_Approved__c < timeDay.Event__r.Duration__c){
                    dayDetail.hrsCompareColor = 'red';        
                }else if(timeDay.Total_Hours_Before_Approved__c > timeDay.Event__r.Duration__c){
                    dayDetail.hrsCompareColor = 'blue';
                }else{
                    dayDetail.hrsCompareColor = 'green';
                }
                
            }*/
            dayDetailsList.add(dayDetail);
             
         }
         
         // time card day for Intenals
         
         for(AcctSeed__Time_Card_Day__c timeDay : internalTimecardDayDetails) {
                                                 
                 
             TimeCardDayDomain.TimeCardDayDetails dayDetail = new TimeCardDayDomain.TimeCardDayDetails();
             
             dayDetail.Instructor = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name;
             dayDetail.InstructorId = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
             dayDetail.ProjectTaskName = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name;
             dayDetail.DLS_Class = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.DLS_Class__c;
             dayDetail.ProjectTaskId = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
             dayDetail.timeDayDate = timeDay.AcctSeed__Date__c;
             dayDetail.HrsBeforedApproved = String.valueOf(timeDay.Total_Hours_Before_Approved__c);
             //dayDetail.StartTime = timeDay.Start_Time__c;
             //dayDetail.EndTime = timeDay.End_Time__c;
             //dayDetail.lateCancellation = timeDay.Late_Cancellation__c;
             dayDetail.internalComment = timeDay.AcctSeed__Internal_Comment__c;
             dayDetail.isDisabled = true;
             dayDetail.timeDayId = timeDay.Id;
             //dayDetail.EventId = timeDay.Event__c;
             dayDetail.ProjectRTId = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId;
             dayDetail.ProjectRTName = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName;
             dayDetail.Billable = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c;
             dayDetail.ProjectName = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
             dayDetail.ProjectId = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c;
             dayDetail.ContactRecTypeName = timeDay.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName;
             
             /*if(dayDetail.ContactRecTypeName == 'DLS_Employee')
                 dayDetail.UserType = 'Internal';
             else 
                 dayDetail.UserType = 'Instructor';*/
             dayDetail.UserType = 'Internal';
             
             /*if(timeDay.Event__c != null)
                 dayDetail.HrsScheduled = timeDay.Event__r.Duration__c;
             
             if(timeDay.Event__c != null) {
                 
                if(timeDay.Total_Hours_Before_Approved__c < timeDay.Event__r.Duration__c){
                    dayDetail.hrsCompareColor = 'red';        
                }else if(timeDay.Total_Hours_Before_Approved__c > timeDay.Event__r.Duration__c){
                    dayDetail.hrsCompareColor = 'blue';
                }else{
                    dayDetail.hrsCompareColor = 'green';
                }
            }*/
            dayDetailsList.add(dayDetail);
         }
        
        system.debug(':::::::dayDetailsList::::::::::::'+dayDetailsList);
        
        return dayDetailsList;
    }
    
    
    /**********************************************************************
        Created by Sukanya on Jan 18 2017: Translator class used for TimeSheet_Internlas_Component (Supervisor Time Approval Page) - TimeCardDayForApproval inner class formation
        Modified by Sukanya on Jan 25 2017: For Supervisor Approval Page summary details qry for Week range flip
    ***********************************************************************/
    
    global static List<TimeCardDayDomain.TimeCardDayForApproval> approvalSummarytableFormationmethod(List<AcctSeed__Time_Card_Line__c> timeCardlineList,Map<Id,String> cardLineidUsertypeMap,Date startDate,Date endDate) {
        
        List<TimeCardDayDomain.TimeCardDayForApproval> timedaySummary = new List<TimeCardDayDomain.TimeCardDayForApproval>();
        
        List<Date> daysList = new List<Date>();
         
         Date weekStart = startDate;
         Date weekEnd = endDate;
        
         while(weekStart <= weekEnd) {
           daysList.add(weekStart);
           weekStart = weekStart.addDays(1);
         }
        system.debug('::::::::daysList:::::::::'+daysList);
       
        for(AcctSeed__Time_Card_Line__c LineRec : timeCardlineList) {
            if(LineRec.AcctSeed__Time_Card_Days__r != null && LineRec.AcctSeed__Time_Card_Days__r.size() > 0) {
            
                Integer approvedCnt = 0;
                Integer totalDayRec = LineRec.AcctSeed__Time_Card_Days__r.size();
            
                TimeCardDayDomain.TimeCardDayForApproval timeday = new TimeCardDayDomain.TimeCardDayForApproval();
                
                timeday.ProjectId = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                timeday.ProjectTaskId = LineRec.AcctSeed__Project_Task__c;
                timeday.InstructorId = LineRec.AcctSeed__Time_Card__r.Intructor__c;
                timeday.Instructor = LineRec.AcctSeed__Time_Card__r.Intructor__r.Name;
                
                timeday.ProjectTaskName = LineRec.AcctSeed__Project_Task__r.Name;
                timeday.ProjectName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                timeday.isBillable = LineRec.AcctSeed__Billable__c;
                timeday.TaskType = LineRec.AcctSeed__Project_Task__r.Project_Task_Type__c;
                timeday.ContactRecTypeName = LineRec.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName;
                timeday.ProjectRTName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName;
                timeday.ProjectRTId = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId;
                timeday.payRollItem = LineRec.Payroll_Item__c;
                
                if(LineRec.Location__c != null) {
                    timeday.locationId = LineRec.Location__c;
                    timeday.locationName = LineRec.Location__r.Name;
                }else if(LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c != null) {
                    timeday.locationId = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c;
                    timeday.locationName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name;
                }
                
                timeday.sequenceNumber = LineRec.Sequence_Number__c;
                
                if(cardLineidUsertypeMap.containsKey(LineRec.Id))
                    timeday.UserType = cardLineidUsertypeMap.get(LineRec.Id);
                
                timeday.Day1 = daysList[0];
                timeday.Day2 = daysList[1];
                timeday.Day3 = daysList[2];
                timeday.Day4 = daysList[3];
                timeday.Day5 = daysList[4];
                timeday.Day6 = daysList[5];
                timeday.Day7 = daysList[6];
                timeday.Hours1 = '0.00';
                timeday.Hours2 = '0.00';
                timeday.Hours3 = '0.00';
                timeday.Hours4 = '0.00';
                timeday.Hours5 = '0.00';
                timeday.Hours6 = '0.00';
                timeday.Hours7 = '0.00';
              
                for(AcctSeed__Time_Card_Day__c td : LineRec.AcctSeed__Time_Card_Days__r) {
                    
                    if(timeday.Day1 == td.AcctSeed__Date__c) {
                        timeday.Hours1 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs1Day1Id = td.Id;
                        timeday.comment1 = td.AcctSeed__Internal_Comment__c;
                        timeday.status1 = td.Status__c;
                        
                    }else if(timeday.Day2 == td.AcctSeed__Date__c) {
                        timeday.Hours2 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs2Day2Id = td.Id;
                        timeday.comment2 = td.AcctSeed__Internal_Comment__c;
                        timeday.status2 = td.Status__c;
                        
                    }else if(timeday.Day3 == td.AcctSeed__Date__c) {
                        timeday.Hours3 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs3Day3Id = td.Id;
                        timeday.comment3 = td.AcctSeed__Internal_Comment__c;
                        timeday.status3 = td.Status__c;
                        
                    }else if(timeday.Day4 == td.AcctSeed__Date__c) {
                        timeday.Hours4 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs4Day4Id = td.Id;
                        timeday.comment4 = td.AcctSeed__Internal_Comment__c;
                        timeday.status4 = td.Status__c;
                        
                    }else if(timeday.Day5 == td.AcctSeed__Date__c) {
                        timeday.Hours5 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs5Day5Id = td.Id;
                        timeday.comment5 = td.AcctSeed__Internal_Comment__c;
                        timeday.status5 = td.Status__c;
                        
                    }else if(timeday.Day6 == td.AcctSeed__Date__c) {
                        timeday.Hours6 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs6Day6Id = td.Id;
                        timeday.comment6 = td.AcctSeed__Internal_Comment__c;
                        timeday.status6 = td.Status__c;
                        
                    }else if(timeday.Day7 == td.AcctSeed__Date__c) {
                        timeday.Hours7 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs7Day7Id = td.Id;
                        timeday.comment7 = td.AcctSeed__Internal_Comment__c;
                        timeday.status7 = td.Status__c;
                    }
                    
                    if(td.Status__c == 'Approved')
                        approvedCnt = approvedCnt + 1;
                }
                 
                if(approvedCnt != totalDayRec)   
                    timedaySummary.add(timeday);
            }
        }
        
        system.debug('::::::::::timedaySummary:::::::::'+timedaySummary);
        
        return timedaySummary;
    }
    
    
    /**********************************************************************
        Created by Sukanya on Jan 18 2017: Translator class used for TimeSheet_Internlas_Component (Supervisor Time Approval Page) - map of existing time card day formation
    ***********************************************************************/
    
    global static Map<Id,AcctSeed__Time_Card_Day__c> timeDaydetailsMapmethod(List<AcctSeed__Time_Card_Line__c> timeCardlineList) {
        
        Map<Id,AcctSeed__Time_Card_Day__c> dayIddayRecMap = new Map<Id,AcctSeed__Time_Card_Day__c>();
        
        for(AcctSeed__Time_Card_Line__c LineRec : timeCardlineList) {
            if(LineRec.AcctSeed__Time_Card_Days__r != null && LineRec.AcctSeed__Time_Card_Days__r.size() > 0) {
                for(AcctSeed__Time_Card_Day__c td : LineRec.AcctSeed__Time_Card_Days__r) {
                   
                   if(!dayIddayRecMap.containsKey(td.Id)) {
                       dayIddayRecMap.put(td.Id,td);
                   }
                }
            }
        }
        
        system.debug('::::::dayIddayRecMap::::::::'+dayIddayRecMap);
        
        return dayIddayRecMap;
    }
    
       
    /**********************************************************************
        Created by Sukanya on Feb 15 2017: Translator class used for TimeSheet_Internlas_Component (Supervisor Time Approval Page) - Week Range values from existing time card day records
    ***********************************************************************/
    
    global static Set<String> getWeekRangeFilterValuesForSummary(List<AcctSeed__Time_Card_Line__c> timeCardlineList) {
        
        Set<String> WeekRangeSet = new Set<String>();
        Set<Date> dateSet = new Set<Date>();
        
        for(AcctSeed__Time_Card_Line__c LineRec : timeCardlineList) {
            if(LineRec.AcctSeed__Time_Card_Days__r != null && LineRec.AcctSeed__Time_Card_Days__r.size() > 0) {
                for(AcctSeed__Time_Card_Day__c td : LineRec.AcctSeed__Time_Card_Days__r) {
                   
                   dateSet.add(td.AcctSeed__Date__c);
                }
            }
        }
        
        system.debug('::::::dateSet::::::::'+dateSet);
        
        for(Date dt : dateSet) {
            
            Date st;
             
             if(dt.toStartofWeek().addDays(1) < dt)
                 st = dt.toStartofWeek().addDays(1);
             else
                 st = dt.addDays(-1).toStartofWeek().addDays(1);
                 
             Date ed = st.addDays(6); 
            
            if(!WeekRangeSet.contains(String.valueOf(st).split(' ')[0]+' to '+String.valueOf(ed).split(' ')[0])) {
                WeekRangeSet.add(String.valueOf(st).split(' ')[0]+' to '+String.valueOf(ed).split(' ')[0]);
            }
        }
        
        system.debug('::::::WeekRangeSet::::::::'+WeekRangeSet);
        
        return WeekRangeSet;
    }
    
   
    /**********************************************************************
        Created by Sukanya on Feb 16 2017: Translator class used for TimeSheet_Internlas_Component (Supervisor Time Approval Page) - Calculate total count of records,Hours for all Past weeks
    ***********************************************************************/
    
    global static Map<String,Decimal> getTimesheetCount_HoursValues(List<AcctSeed__Time_Card_Line__c> timeCardlineList,Set<String> weekRangeSet) {
        
        Map<String,Decimal> weekRangeUserIdHoursMap = new Map<String,Decimal>();
        Set<String> WeekRangeValues = weekRangeSet;
        
        
        for(AcctSeed__Time_Card_Line__c LineRec : timeCardlineList) {
            if(LineRec.AcctSeed__Time_Card_Days__r != null && LineRec.AcctSeed__Time_Card_Days__r.size() > 0) {
                
                for(AcctSeed__Time_Card_Day__c td : LineRec.AcctSeed__Time_Card_Days__r) {
                    
                    Date st;
                    if(td.AcctSeed__Date__c.toStartofWeek().addDays(1) < td.AcctSeed__Date__c)
                        st = td.AcctSeed__Date__c.toStartofWeek().addDays(1);
                    else
                        st = td.AcctSeed__Date__c.addDays(-1).toStartofWeek().addDays(1);
                 
                    Date ed = st.addDays(6);
                    String Key = String.valueOf(st).split(' ')[0]+' to '+String.valueOf(ed).split(' ')[0]+'-'+LineRec.AcctSeed__Time_Card__r.Intructor__c;
                    
                    if(!weekRangeUserIdHoursMap.containsKey(Key)) {
                        weekRangeUserIdHoursMap.put(key,td.Total_Hours_Before_Approved__c);
                    }else {
                        Decimal hrs = weekRangeUserIdHoursMap.get(key);
                        hrs += td.Total_Hours_Before_Approved__c;
                        weekRangeUserIdHoursMap.put(key,hrs);
                    }
                }
            }
        }
        
        system.debug(':timeCardDayTranslator::::getTimesheetCount_HoursValues::::::weekRangeUserIdHoursMap::'+weekRangeUserIdHoursMap);
        
        return weekRangeUserIdHoursMap;
    }
    
     /**********************************************************************
        Created by Sukanya on March 13 2017: Translator class used for DLS_Staff_Time_Entry_Page - Get previousWeek Project task details
    ***********************************************************************/
    global static Map<String,TimeCardDayDomain.TimeCardDay> getPreviousWeekTaskDetails(List<AcctSeed__Time_Card_Line__c> timeCardlineList,String InstructorId) {
        
        Map<String,TimeCardDayDomain.TimeCardDay> previousWeekValues = new Map<String,TimeCardDayDomain.TimeCardDay>();
        
         List<Date> daysList = new List<Date>();
         
         Date currentStart = system.today().toStartofWeek().addDays(1);
         Date currentEnd = currentStart.addDays(6);
         
         Date weekStart = currentStart;
         Date weekEnd = currentEnd;
         
         while(weekStart <= weekEnd) {
           daysList.add(weekStart);
           weekStart = weekStart.addDays(1);
        }
        
        for(AcctSeed__Time_Card_Line__c LineRec : timeCardlineList) {
            if(LineRec.AcctSeed__Time_Card_Days__r != null && LineRec.AcctSeed__Time_Card_Days__r.size() > 0) {
                TimeCardDayDomain.TimeCardDay timeday = new TimeCardDayDomain.TimeCardDay();
                
                timeday.SelectedProject = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                timeday.SelectedProTask = LineRec.AcctSeed__Project_Task__c;
                timeday.SelectedInstructor = InstructorId;
                
                timeday.Day1 = daysList[0];
                timeday.Day2 = daysList[1];
                timeday.Day3 = daysList[2];
                timeday.Day4 = daysList[3];
                timeday.Day5 = daysList[4];
                timeday.Day6 = daysList[5];
                timeday.Day7 = daysList[6];
                
                timeday.TaskName = LineRec.AcctSeed__Project_Task__r.Name;
                timeday.ProjectName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                timeday.isBillable = LineRec.AcctSeed__Billable__c;
                timeday.TaskType = LineRec.AcctSeed__Project_Task__r.Project_Task_Type__c;
                timeday.timeCardLineId = LineRec.Id;
                timeday.payRollItem = LineRec.Payroll_Item__c;
                
                if(LineRec.Location__c != null) {
                    timeday.locationId = LineRec.Location__c;
                    timeday.locationName = LineRec.Location__r.Name;
                }else if(LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c != null) {
                    timeday.locationId = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c;
                    timeday.locationName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name;
                }
                
                timeday.display_LineRec_Future = LineRec.Display_in_Future_Weeks__c;
                timeday.costRateId = LineRec.Labor_Cost_Rate__c;
                timeday.contactAssignId = LineRec.Contact_Assignment__c;
                
                timeday.sequenceNumber = LineRec.Sequence_Number__c;
                
                String key = timeday.SelectedProject+'-'+timeday.SelectedProTask+'-'+timeday.SelectedInstructor+'-'+timeday.isBillable+'-'+timeday.payRollItem+'-'+timeday.locationId;
                
                if(!previousWeekValues.containsKey(key)) {
                    previousWeekValues.put(key,timeday);
                }
            }
        }
        
        return previousWeekValues;
    }
    
    /**********************************************************************
        Created by Sukanya on March 16 2017: Translator class used for TimeKeeping_Admin_Page
    ***********************************************************************/
    
    global static TimeCardDayDomain.AdminTimeEntryDetails adminEntrypage_Recordsformation(List<AcctSeed__Time_Card_Line__c> timeCardlineList,Set<String> weekRangeValues,Boolean pageLoad,List<Accounting_Seed_Time_Snapshot__c> snapshotRecords,Date startDate,Date EndDate,String timezone,Map<Id,String> contactIdNameMap,Date timeLockDate,String InstructorId,List<AcctSeed__Project__c> projectList,List<AcctSeed__Project_Task__c> taskList,Boolean userPermissionValue,List<Contact_Assignments__c> contactAssignments,List<Project_Task_Master__c> PTMValues,String homeDept,List<Contact> contactRecords) {
        
        TimeCardDayDomain.AdminTimeEntryDetails timeDetails = new TimeCardDayDomain.AdminTimeEntryDetails();
        
        timeDetails.timeCardDayRecords = adminTimeEntryFormation(timeCardlineList,startDate,EndDate,InstructorId);
        timeDetails.timeSnapshotDetails = snapshotRecords;
        timeDetails.UserTimezoneValue= timezone;
        timeDetails.UserName = Userinfo.getName();
        timeDetails.timelockLockingDate = timeLockDate;
        
        // We are refering the Payroll Item field from Cost Rate object - because project task object payroll item field is deleted
        // Modfied by Sukanya on July 14 2017
        timeDetails.payRollItemList = SObjectQueryService.PicklistValues('AcctSeed__Cost_Rates__c','Payroll_Item__c');
        timeDetails.projects = projectList;
        timeDetails.projectTasks = taskList;
        timeDetails.userHaspermission = userPermissionValue;
        timeDetails.contactAssignements = contactAssignments;
        timeDetails.taskName_PayrollItemMap = payrollItemFormation(PTMValues);
        timeDetails.HomeDeptProId = homeDept;
        
        if(pageLoad) {
            timeDetails.weekRangeValues = weekRangeValues;
            timeDetails.contactIdNameMap = contactIdNameMap;
            timeDetails.contactStatusValues = SObjectQueryService.PicklistValues('Contact','Instructor_Status__c');
            timeDetails.contactRecords = contactRecords;
            timeDetails.studentStatusValues = ScheduleCmpLightningController.getPickListValues('AcctSeed__Time_Card_Day__c','Student_Approval_Status__c');  //Added by Mohana on November 15
        }
        
        return timeDetails;
    }
    
    /**********************************************************************
        Created by Sukanya on March 17 2017: Translator class used for TimeKeeping_Admin_Page inner class formation
    ***********************************************************************/
     
     global static List<TimeCardDayDomain.TimeCardDay> adminTimeEntryFormation(List<AcctSeed__Time_Card_Line__c> LineWithDayRecords,Date startDate,Date endDate,String InstructorId) {
         
         List<TimeCardDayDomain.TimeCardDay> dayDetailsList = new List<TimeCardDayDomain.TimeCardDay>();
         
         List<Date> daysList = new List<Date>();
         
         Date weekStart = startDate;
         Date weekEnd = endDate;
         
         while(weekStart <= weekEnd) {
           daysList.add(weekStart);
           weekStart = weekStart.addDays(1);
        }
         
         for(AcctSeed__Time_Card_Line__c LineRec : LineWithDayRecords) {
            if(LineRec.AcctSeed__Time_Card_Days__r != null && LineRec.AcctSeed__Time_Card_Days__r.size() > 0) {
                
                TimeCardDayDomain.TimeCardDay timeday = new TimeCardDayDomain.TimeCardDay();
                
                timeday.SelectedProject = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                timeday.SelectedProTask = LineRec.AcctSeed__Project_Task__c;
                timeday.SelectedInstructor = InstructorId;
                
                timeday.Day1 = daysList[0];
                timeday.Day2 = daysList[1];
                timeday.Day3 = daysList[2];
                timeday.Day4 = daysList[3];
                timeday.Day5 = daysList[4];
                timeday.Day6 = daysList[5];
                timeday.Day7 = daysList[6];
                
                timeday.TaskName = LineRec.AcctSeed__Project_Task__r.Name;
                timeday.ProjectName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                timeday.isBillable = LineRec.AcctSeed__Billable__c;
                timeday.TaskType = LineRec.AcctSeed__Project_Task__r.Project_Task_Type__c;
                timeday.timeCardLineId = LineRec.Id;
                timeday.payRollItem = LineRec.Payroll_Item__c;
                timeday.timeCardId = LineRec.AcctSeed__Time_Card__c;
                
                if(LineRec.Location__c != null) {
                    timeday.locationId = LineRec.Location__c;
                    timeday.locationName = LineRec.Location__r.Name;
                }else if(LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c != null) {
                    timeday.locationId = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c;
                    timeday.locationName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name;
                }
                
                timeday.costRateId = LineRec.Labor_Cost_Rate__c;
                timeday.contactAssignId = LineRec.Contact_Assignment__c;
                
                timeday.sequenceNumber = LineRec.Sequence_Number__c;
                
                if(LineRec.AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE')
                    timeday.IsAdminProTask = true;
                else
                    timeday.IsAdminProTask = false;
                    
                for(AcctSeed__Time_Card_Day__c td : LineRec.AcctSeed__Time_Card_Days__r) {
                    
                    if(timeday.Day1 == td.AcctSeed__Date__c) {
                        timeday.Hours1 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs1Day1Id = td.Id;
                        timeday.comment1 = td.AcctSeed__Internal_Comment__c;
                        timeday.status1 = td.Status__c;
                        
                        timeday.lateCancellation1 = td.Late_Cancellation__c;
                        timeday.cancellationReason1 = td.Cancellation_Reason__c;
                        
                    }else if(timeday.Day2 == td.AcctSeed__Date__c) {
                        timeday.Hours2 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs2Day2Id = td.Id;
                        timeday.comment2 = td.AcctSeed__Internal_Comment__c;
                        timeday.status2 = td.Status__c;
                        
                        timeday.lateCancellation2 = td.Late_Cancellation__c;
                        timeday.cancellationReason2 = td.Cancellation_Reason__c;
                        
                    }else if(timeday.Day3 == td.AcctSeed__Date__c) {
                        timeday.Hours3 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs3Day3Id = td.Id;
                        timeday.comment3 = td.AcctSeed__Internal_Comment__c;
                        timeday.status3 = td.Status__c;
                        
                        timeday.lateCancellation3 = td.Late_Cancellation__c;
                        timeday.cancellationReason3 = td.Cancellation_Reason__c;
                        
                    }else if(timeday.Day4 == td.AcctSeed__Date__c) {
                        timeday.Hours4 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs4Day4Id = td.Id;
                        timeday.comment4 = td.AcctSeed__Internal_Comment__c;
                        timeday.status4 = td.Status__c;
                        
                        timeday.lateCancellation4 = td.Late_Cancellation__c;
                        timeday.cancellationReason4 = td.Cancellation_Reason__c;
                        
                    }else if(timeday.Day5 == td.AcctSeed__Date__c) {
                        timeday.Hours5 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs5Day5Id = td.Id;
                        timeday.comment5 = td.AcctSeed__Internal_Comment__c;
                        timeday.status5 = td.Status__c;
                        
                        timeday.lateCancellation5 = td.Late_Cancellation__c;
                        timeday.cancellationReason5 = td.Cancellation_Reason__c;
                        
                    }else if(timeday.Day6 == td.AcctSeed__Date__c) {
                        timeday.Hours6 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs6Day6Id = td.Id;
                        timeday.comment6 = td.AcctSeed__Internal_Comment__c;
                        timeday.status6 = td.Status__c;
                        
                        timeday.lateCancellation6 = td.Late_Cancellation__c;
                        timeday.cancellationReason6 = td.Cancellation_Reason__c;
                        
                    }else if(timeday.Day7 == td.AcctSeed__Date__c) {
                        timeday.Hours7 = String.valueOf(td.Total_Hours_Before_Approved__c);
                        timeday.Hrs7Day7Id = td.Id;
                        timeday.comment7 = td.AcctSeed__Internal_Comment__c;
                        timeday.status7 = td.Status__c;
                        
                        timeday.lateCancellation7 = td.Late_Cancellation__c;
                        timeday.cancellationReason7 = td.Cancellation_Reason__c;
                    }
                }
                    
                dayDetailsList.add(timeday);
            }
        }
        
        system.debug('::::::dayDetailsList::::::::'+dayDetailsList);
         
         return dayDetailsList;
     }
     
     /**********************************************************************
        Created by Sukanya on July 18 2017: Translator class used for custom setting payroll item formation for all timesheet page
    ***********************************************************************/
     
     global static Map<String,List<String>> payrollItemFormation(List<Project_Task_Master__c> PTMValues) {
         
         Map<String,List<String>> task_payrollItemMap = new Map<String,List<String>>();
         
         for(Project_Task_Master__c PTM : PTMValues){
             
             List<String> payrollItems = new List<String>();
             
             if(PTM.Payroll_Item__c != null && PTM.Payroll_Item__c.contains(';'))
                 payrollItems = PTM.Payroll_Item__c.split(';');
             else
                 payrollItems.add(PTM.Payroll_Item__c);
             
             if(!task_payrollItemMap.containsKey(PTM.Name)) {
                 task_payrollItemMap.put(PTM.Name,payrollItems);
             }
         }
         
         return task_payrollItemMap;
     }
     
     /**********************************************************************
        Created by Sukanya on August 10 2017: Formation of time card line wihout time card day records in staff time entry
    ***********************************************************************/
    global static List<TimeCardDayDomain.TimeCardDay> existingLineFormation_WithoutDay(List<AcctSeed__Time_Card_Line__c> LineWithDayRecords,List<Date> daysList,String InstructorId) {
        List<TimeCardDayDomain.TimeCardDay> existingTimeCardDays = new List<TimeCardDayDomain.TimeCardDay>();
         
         for(AcctSeed__Time_Card_Line__c LineRec : LineWithDayRecords) {
             system.debug('::::::::AcctSeed__Time_Card_Days__r::::::'+LineRec.AcctSeed__Time_Card_Days__r);
            if(LineRec.AcctSeed__Time_Card_Days__r == null || LineRec.AcctSeed__Time_Card_Days__r.size() == 0) {
                
                TimeCardDayDomain.TimeCardDay timeday = new TimeCardDayDomain.TimeCardDay();
                
                timeday.SelectedProject = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                timeday.SelectedProTask = LineRec.AcctSeed__Project_Task__c;
                timeday.SelectedInstructor = InstructorId;
                
                timeday.Day1 = daysList[0];
                timeday.Day2 = daysList[1];
                timeday.Day3 = daysList[2];
                timeday.Day4 = daysList[3];
                timeday.Day5 = daysList[4];
                timeday.Day6 = daysList[5];
                timeday.Day7 = daysList[6];
                
                timeday.TaskName = LineRec.AcctSeed__Project_Task__r.Name;
                timeday.ProjectName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                timeday.isBillable = LineRec.AcctSeed__Billable__c;
                timeday.TaskType = LineRec.AcctSeed__Project_Task__r.Project_Task_Type__c;
                timeday.timeCardLineId = LineRec.Id;
                timeday.payRollItem = LineRec.Payroll_Item__c;
                
                if(LineRec.Location__c != null) {
                    timeday.locationId = LineRec.Location__c;
                    timeday.locationName = LineRec.Location__r.Name;
                }else if(LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c != null) {
                    timeday.locationId = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c;
                    timeday.locationName = LineRec.AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__r.Name;
                }
                
                timeday.costRateId = LineRec.Labor_Cost_Rate__c;
                timeday.contactAssignId = LineRec.Contact_Assignment__c;
                
                timeday.sequenceNumber = LineRec.Sequence_Number__c;
                timeday.Hours1 = '';
                timeday.Hours2 = '';
                timeday.Hours3 = '';
                timeday.Hours4 = '';
                timeday.Hours5 = '';
                timeday.Hours6 = '';
                timeday.Hours7 = '';
              
                existingTimeCardDays.add(timeday);
            }
        }
        
        system.debug('::::::existingTimeCardDays::::::::'+existingTimeCardDays);
         
         return existingTimeCardDays;
    }
    
    /**********************************************************************
        Created by Sukanya on August 18 2017: Formation of semi monthly view formation
    ***********************************************************************/
    global static TimeCardDayDomain.Approval_SemiMonthlyWrapper approvalSemiMonthlyFormation(List<AcctSeed__Time_Card_Day__c> timeCarddayList,List<Date> daysList) {
    
        TimeCardDayDomain.Approval_SemiMonthlyWrapper semiMonthly = new TimeCardDayDomain.Approval_SemiMonthlyWrapper();
        
        semiMonthly.contactIdNameMap = contactFormation(timeCarddayList);
        semiMonthly.dateSummaryDetailMap = contact_Date_SummarydataFormation(timeCarddayList,daysList);
        semiMonthly.summaryList = summaryDetailsFormation(timeCarddayList,daysList);
        
        return semiMonthly;
    } 
    
    
    /**********************************************************************
        Created by Sukanya on August 18 2017: Formation of Contact filter formation for Approval page semi monthly view
    ***********************************************************************/
    global static Map<Id,String> contactFormation(List<AcctSeed__Time_Card_Day__c> timeCarddayList) {
        
        Map<Id,String> conIdNameMap = new Map<Id,String>();
        
        for(AcctSeed__Time_Card_Day__c day : timeCarddayList) {
            if(!conIdNameMap.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c))
                conIdNameMap.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name);  
        }
        system.debug(':::contactFormation:::::::conIdNameMap:::::'+conIdNameMap);
        return conIdNameMap;
    }
    
    
    /**********************************************************************
        Created by Sukanya on August 18 2017: Formation of contact,Date & summary data for semi monthly view formation
    ***********************************************************************/
    global static Map<String,List<TimeCardDayDomain.TimeDaySummary>> contact_Date_SummarydataFormation(List<AcctSeed__Time_Card_Day__c> timeCarddayList,List<Date> daysList) {
        
        Map<String,List<TimeCardDayDomain.TimeDaySummary>> datesummaryDataMap = new Map<String,List<TimeCardDayDomain.TimeDaySummary>>();
        
        // For date,Status & contact combination of record formation
        Map<Date,Map<String,TimeCardDayDomain.TimeDaySummary>> dateStatusContactMap = new Map<Date,Map<String,TimeCardDayDomain.TimeDaySummary>>();
        
        for(AcctSeed__Time_Card_Day__c td : timeCarddayList) {
            // Check already date exist
            if(!dateStatusContactMap.containsKey(td.AcctSeed__Date__c)) {
                
               TimeCardDayDomain.TimeDaySummary summary = new TimeCardDayDomain.TimeDaySummary();
               summary.Hours = td.Total_Hours_Before_Approved__c;
               
               if(td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__c != null && td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null) {
                   summary.Payrate = td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c;
               }
               
               if(summary.Payrate != null && summary.Hours != null)
                   summary.TotalAmount = ((summary.Hours) * (summary.Payrate)).setscale(2);
               
               //summary.contactId = td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
               summary.contactName = td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name;
                
                String key = td.Status__c+'-'+td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;

                dateStatusContactMap.put(td.AcctSeed__Date__c,new Map<String,TimeCardDayDomain.TimeDaySummary>{key=>summary});
                
            }else if(dateStatusContactMap.containsKey(td.AcctSeed__Date__c)) {
            
                // Check if already Status & Contact exist

                String key = td.Status__c+'-'+td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;

                if(!dateStatusContactMap.get(td.AcctSeed__Date__c).containsKey(key)) {
                    
                   TimeCardDayDomain.TimeDaySummary summary = new TimeCardDayDomain.TimeDaySummary();
                   summary.Hours = td.Total_Hours_Before_Approved__c;
                   
                   if(td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__c != null && td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null) {
                       summary.Payrate = td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c;
                   }
                   
                   if(td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__c != null && td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null && td.Total_Hours_Before_Approved__c != null)
                       summary.TotalAmount = ((td.Total_Hours_Before_Approved__c) * (td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c)).setscale(2);
                    
                   //summary.contactId = td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
                   summary.contactName = td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name;
                    
                   dateStatusContactMap.get(td.AcctSeed__Date__c).put(key,summary);
                    
                }else if(dateStatusContactMap.get(td.AcctSeed__Date__c).containsKey(key)) {
                
                    TimeCardDayDomain.TimeDaySummary summary = dateStatusContactMap.get(td.AcctSeed__Date__c).get(key);
                    
                    summary.Hours = summary.Hours + td.Total_Hours_Before_Approved__c;
                    
                    if(td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__c != null && td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null) {
                        if(summary.Payrate != null)
                            summary.Payrate = summary.Payrate + td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c;
                        else
                            summary.Payrate = td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c;
                    }
                       
                    if(td.Total_Hours_Before_Approved__c != null && td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__c != null && td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null) {
                        if(summary.TotalAmount != null)
                            summary.TotalAmount = summary.TotalAmount + ((td.Total_Hours_Before_Approved__c) * (td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c)).setscale(2);
                        else
                            summary.TotalAmount = ((td.Total_Hours_Before_Approved__c) * (td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c)).setscale(2);
                    }
                    
                    //summary.contactId = td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
                    summary.contactName = td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name;
                    
                    dateStatusContactMap.get(td.AcctSeed__Date__c).put(key,summary);
                }
            }
           
        }
        
        system.debug(':::::::dateStatusContactMap::::::::::'+dateStatusContactMap);
        
        for(Date dt : daysList) {
            if(dateStatusContactMap.containsKey(dt)) {
                
                for(String statusVal : dateStatusContactMap.get(dt).keySet()) {
                    TimeCardDayDomain.TimeDaySummary timeSum = dateStatusContactMap.get(dt).get(statusVal);
                    timeSum.dateValue = dt;
                    timeSum.Status = statusVal.split('-')[0];
                    timeSum.contactId = statusVal.split('-')[1];
                   
                    if(!datesummaryDataMap.containsKey(String.valueOf(dt))) {
                        datesummaryDataMap.put(String.valueOf(dt),new List<TimeCardDayDomain.TimeDaySummary >{timeSum});
                    }else {
                        datesummaryDataMap.get(String.valueOf(dt)).add(timeSum);
                    }
                }
            }else {
                 TimeCardDayDomain.TimeDaySummary timeSum = new TimeCardDayDomain.TimeDaySummary();
                 timeSum.dateValue = dt;
                 timeSum.Hours = 0.00;
                 timeSum.Payrate = 0.00;
                 timeSum.TotalAmount = 0.00;
                 timeSum.Status = '';
                 timeSum.contactId = '';
                 timeSum.contactName = '';
                 
                 if(!datesummaryDataMap.containsKey(String.valueOf(dt))) {
                     datesummaryDataMap.put(String.valueOf(dt),new List<TimeCardDayDomain.TimeDaySummary >{timeSum});
                 }
            }
        }
        
        system.debug('::::::::datesummaryDataMap::::::::'+datesummaryDataMap);
        
        return datesummaryDataMap;
    }
    
    
    /**********************************************************************
        Created by Sukanya on August 18 2017: Formation of contact,Date & summary data for semi monthly view formation
    ***********************************************************************/
    global static List<TimeCardDayDomain.TimeDaySummary> summaryDetailsFormation(List<AcctSeed__Time_Card_Day__c> timeCarddayList,List<Date> daysList) {
        
        Map<Date,List<TimeCardDayDomain.TimeDaySummary>> dateSummarydataListMap = new Map<Date,List<TimeCardDayDomain.TimeDaySummary>>();
        
        List<TimeCardDayDomain.TimeDaySummary> summaryDetailList = new List<TimeCardDayDomain.TimeDaySummary>();
        
        for(AcctSeed__Time_Card_Day__c td : timeCarddayList) {
                    
            if(!datesummaryDataListMap.containsKey(td.AcctSeed__Date__c)) {
               
                TimeCardDayDomain.TimeDaySummary summary = new TimeCardDayDomain.TimeDaySummary();
                
                summary.dateValue = td.AcctSeed__Date__c;
                 
                summary.Hours = td.Total_Hours_Before_Approved__c;
               
                if(td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__c != null && td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null)
                   summary.Payrate = td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c;
                else
                   summary.Payrate = 0.00;
                      
                if(summary.Payrate != null && summary.Hours != null)
                   summary.TotalAmount = ((summary.Hours) * (summary.Payrate)).setscale(2);
                
                summary.Status = td.Status__c;
                summary.ProjectName = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                summary.TaskName = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name;
                summary.ProjectId = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                summary.TaskId = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
                summary.DayId = td.Id;
                summary.PayrollItem = td.AcctSeed__Time_Card_Line__r.Payroll_Item__c;
                summary.LocationName = td.AcctSeed__Time_Card_Line__r.Location__r.Name;
                summary.contactId = td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
                summary.contactName = td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name;
                
                if(td.AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c)
                    summary.Billable = 'Billable';
                else
                    summary.Billable = 'Non-Billable';
                
                if(summary.ProjectName != null || summary.TaskName != null || summary.PayrollItem != null
                     || summary.Billable != null || summary.LocationName != null)
                    summary.ChargeCode = summary.ProjectName+' / '+summary.TaskName+' / '+summary.PayrollItem+' / '+summary.Billable+' / '+summary.LocationName;
               
                datesummaryDataListMap.put(td.AcctSeed__Date__c,new List<TimeCardDayDomain.TimeDaySummary>{summary});
                
                summaryDetailList.add(summary);
                
            }else {
                
                TimeCardDayDomain.TimeDaySummary summary = new TimeCardDayDomain.TimeDaySummary();
                
                summary.dateValue = td.AcctSeed__Date__c;
                 
                summary.Hours = td.Total_Hours_Before_Approved__c;
               
                if(td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__c != null && td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c != null)
                   summary.Payrate = td.AcctSeed__Time_Card_Line__r.Labor_Cost_Rate__r.AcctSeed__Hourly_Cost__c;
                else
                   summary.Payrate = 0.00;
                   
                if(summary.Payrate != null && summary.Hours != null)
                   summary.TotalAmount = ((summary.Hours) * (summary.Payrate)).setscale(2);
                
                summary.Status = td.Status__c;
                summary.ProjectName = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                summary.TaskName = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name;
                summary.ProjectId = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                summary.TaskId = td.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
                summary.DayId = td.Id;
                summary.PayrollItem = td.AcctSeed__Time_Card_Line__r.Payroll_Item__c;
                summary.LocationName = td.AcctSeed__Time_Card_Line__r.Location__r.Name;
                summary.contactId = td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
                summary.contactName = td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name;
                
                if(td.AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c)
                    summary.Billable = 'Billable';
                else
                    summary.Billable = 'Non-Billable';
                
                if(summary.ProjectName != null || summary.TaskName != null || summary.PayrollItem != null
                     || summary.Billable != null || summary.LocationName != null)
                    summary.ChargeCode = summary.ProjectName+' / '+summary.TaskName+' / '+summary.PayrollItem+' / '+summary.Billable+' / '+summary.LocationName;
                
                datesummaryDataListMap.get(td.AcctSeed__Date__c).add(summary);
                
                summaryDetailList.add(summary);
            }
        }
        
        for(Date dt : daysList) {
             
             if(!datesummaryDataListMap.containsKey(dt)) {
                 TimeCardDayDomain.TimeDaySummary timeSum = new TimeCardDayDomain.TimeDaySummary();
                 timeSum.dateValue = dt;
                 timeSum.Hours = 0.00;
                 timeSum.Payrate = 0.00;
                 timeSum.TotalAmount = 0.00;
                 timeSum.Status = '';
                 timeSum.ProjectName = '';
                 timeSum.TaskName = '';
                 timeSum.contactId = '';
                 timeSum.contactName = '';
                 
                 datesummaryDataListMap.put(dt,new List<TimeCardDayDomain.TimeDaySummary>{timeSum});
                 
                 summaryDetailList.add(timeSum);
             }
        }
        
        system.debug('::summaryDetailsFormation:::datesummaryDataListMap:::::::::'+datesummaryDataListMap.values());
        system.debug('::summaryDetailsFormation:::summaryDetailList:::::::::'+summaryDetailList);
        
        return summaryDetailList;
    }
    
    /**********************************************************************
        Created by Sukanya on Feb 21 2018: Formation of Daily time entry initial data formation
    ***********************************************************************/
    
    public static TimeCardDayDomain.dailyInitialInfo Daily_InitialData(Set<String> weekRange,Date lockingDate,List<Contact> conRecord,List<Date> holiday, List<Project_Task_Master__c> taskMaster,List<ContentDocument> docsList) {
    
        TimeCardDayDomain.dailyInitialInfo dailyInfo = new TimeCardDayDomain.dailyInitialInfo();
        
        List<String> weeks = new List<String>(weekRange);
        dailyInfo.weekRange = weeks;
        //dailyInfo.projectList = projects;
        //dailyInfo.taskList = tasks;
        dailyInfo.taskMasterList = taskMaster;
        dailyInfo.lockingDate = lockingDate;
        dailyInfo.holidays = holiday;
        //dailyInfo.relatedContactAssign = conAssign;
        dailyInfo.currWeekStart = system.today().toStartofWeek().addDays(1);
        dailyInfo.currWeekEnd = dailyInfo.currWeekStart.addDays(6);
        
        if(conRecord != null && conRecord.size() > 0) {
            dailyInfo.contactId = conRecord[0].Id;
            dailyInfo.conRec = conRecord[0];
        }
        
        //dailyInfo.locationList = locations;
        dailyInfo.currDate = system.today();
        dailyInfo.documentList = docsList;
        
        // For Mobile Approval Page
        dailyInfo.userId = UserInfo.getUserId();
        
        return dailyInfo;
    }
    
    public static TimeCardDayDomain.WeekViewDetails WeekDetailsFormation(Date startDate, Date endDate, List<AcctSeed__Time_Card_Line__c> timecardline, List<Accounting_Seed_Time_Snapshot__c> snapshot, List<Contact> contact,List<AcctSeed__Time_Card_Line__c> previousWeekLines,List<AcctSeed__Project__c> projectList, List<AcctSeed__Project_Task__c> taskList, List<Contact_Assignments__c> contactAssignment, List<Project_Task_Master__c> taskMaster,Set<Date> holidaySet){
    
        TimeCardDayDomain.WeekViewDetails weekDetails = new TimeCardDayDomain.WeekViewDetails();
        weekDetails.startDate = startDate;
        weekDetails.endDate = endDate;
        weekDetails.entryDetails = daily_SummaryDetailsFormation(timecardline,startDate,endDate,contact,previousWeekLines,projectList,taskList,contactAssignment,taskMaster,holidaySet);
        weekDetails.notes = notesFormation(snapshot);
        
        Date st = startDate;
        Date ed = endDate;
        
        List<String> weekDates = new List<String>();
        
        while(st <= ed){
            weekDates.add(String.valueOf(st).split('-')[1]+'/'+String.valueOf(st).split('-')[2]+'/'+String.valueOf(st).split('-')[0]);
            st = st.addDays(1);
        }
        
        weekDetails.weekDates = weekDates;
        
        List<TimeCardDayDomain.DayEntries> entriesList = new List<TimeCardDayDomain.DayEntries>();
        
        for(TimeCardDayDomain.DateBasedEntries dtEntry : weekDetails.entryDetails){
            if(dtEntry.entries != null)
                entriesList.addAll(dtEntry.entries);
        }
        
        TimeCardDayDomain.ButtonDisplay btnDisplay = buttonDisplayFunction(entriesList,startDate,endDate);
        weekDetails.displaySubmitBtn = btnDisplay.submitBtn;
        weekDetails.displayRecallBtn = btnDisplay.recallBtn;
       
        weekDetails.previousWeekEntries = previousWeekFormation(previousWeekLines,contact);
        weekDetails.projectList = projectList;
        weekDetails.taskList = taskList;
        weekDetails.relatedContactAssign = contactAssignment;
        
        return weekDetails;
    
    }
    
    public static List<TimeCardDayDomain.DateBasedEntries> daily_SummaryDetailsFormation(List<AcctSeed__Time_Card_Line__c> timeCardLines,Date st,Date ed,List<Contact> conRec,List<AcctSeed__Time_Card_Line__c> previousWeekLines,List<AcctSeed__Project__c> projects, List<AcctSeed__Project_Task__c> tasks, List<Contact_Assignments__c> conAssign, List<Project_Task_Master__c> taskMaster,Set<Date> holidaySet) {
        
        List<Id> dayIdSet = new List<Id>();
        List<TimeCardDayDomain.DateBasedEntries> dateEntryList = new List<TimeCardDayDomain.DateBasedEntries>();
        Id homeDepartProId = (conRec.size() > 0) ? conRec[0].Home_Department_Project__c : null;
        String homeDeptProRTName = (conRec.size() > 0) ? conRec[0].Home_Department_Project__r.RecordType.DeveloperName : null;
        
        system.debug('::::::::homeDepartProId:::::'+homeDepartProId);
        system.debug('::::::::homeDeptProRTName:::::'+homeDeptProRTName);
        
        Map<Date,List<TimeCardDayDomain.DayEntries>> dateEntryMap = new Map<Date,List<TimeCardDayDomain.DayEntries>>();
        Date startDt = st;
        Date endDt = ed;
        
        while(startDt <= endDt){
            system.debug('startDt::::'+startDt);
            dateEntryMap.put(startDt,new List<TimeCardDayDomain.DayEntries>{});
            startDt = startDt.addDays(1);
        }
        system.debug(':::::::dateEntryMap::::::'+dateEntryMap);
        
        Boolean homeDeptExist = false;
        Boolean adminTaskExist = false;
        Boolean formAllRows = false;
        Boolean formFringeRows = false;
        
        Set<String> uniqueKeySet;
        
        Integer totalRecCnt = 0;
        Integer submitCnt = 0;
        
        for(AcctSeed__Time_Card_Line__c line : timeCardLines) {
            
            if(line.AcctSeed__Time_Card_Days__r != null || line.AcctSeed__Time_Card_Days__r.size() > 0) {
                
                for(AcctSeed__Time_Card_Day__c day : line.AcctSeed__Time_Card_Days__r) {
                    TimeCardDayDomain.DayEntries dayRec = new TimeCardDayDomain.DayEntries();
                    
                    String billingType;
                    
                    if(line.AcctSeed__Billable__c)
                        billingType = 'Billable';
                    else
                        billingType = 'Non - Billable';
                    
                    String code = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name+' / '+line.AcctSeed__Project_Task__r.Name+' / ';
                    code += line.Payroll_Item__c+' / '+billingType+' / '+line.Location__r.Name;
                    
                    dayRec.chargeCode = code;
                    dayRec.hours = day.Total_Hours_Before_Approved__c;
                    dayRec.dayId = day.Id;
                    dayRec.lineId = day.AcctSeed__Time_Card_Line__c;
                    dayRec.projectId = line.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                    dayRec.taskId = line.AcctSeed__Project_Task__c;
                    dayRec.locationId = line.Location__c;
                    dayRec.isBillable = line.AcctSeed__Billable__c;
                    dayRec.payrollItem = line.Payroll_Item__c;
                    dayRec.status = day.Status__c;
                    dayRec.dateVal = day.AcctSeed__Date__c;
                    dayRec.comments = day.AcctSeed__Internal_Comment__c;
                    dayRec.costrateId = line.Labor_Cost_Rate__c;
                    dayRec.contactAssignid = line.Contact_Assignment__c;
                    dayRec.sequenceNumber = Integer.valueOf(line.Sequence_Number__c);
                    dayRec.projectRTName = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName;
                    dayRec.TaskType = line.AcctSeed__Project_Task__r.Project_Task_Type__c;
                    dayRec.TaskName = line.AcctSeed__Project_Task__r.Name;
                    dayRec.ProjectName = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                    dayRec.locationName = line.Location__r.Name;
                    
                    if(line.AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE')
                        dayRec.IsAdminProTask = true;
                    else
                        dayRec.IsAdminProTask = false;
                    
                    if(line.AcctSeed__Project_Task__r.AcctSeed__Project__c == homeDepartProId)
                        dayRec.isHomeDepartment = true;
                    else
                        dayRec.isHomeDepartment = false;
                        
                    dayRec.isNew = false;
                    dayRec.isUpdated = false;
                    
                    if(dayRec.dateVal > system.today()) {
                        dayRec.isHrsDisabled = true;
                    } else if(dayRec.status == 'Submitted'){
                        submitCnt += 1;
                        dayRec.isHrsDisabled = true;
                    } else {
                        dayRec.isHrsDisabled = false;
                    }
                    
                    totalRecCnt += 1;
                    
                    
                    if(dateEntryMap.containsKey(day.AcctSeed__Date__c))
                        dateEntryMap.get(day.AcctSeed__Date__c).add(dayRec);
                }
            }
        }
        
        //system.debug('::::::::dateEntryMap:::::::::::'+dateEntryMap);
        system.debug(':::submitCnt::::::::::totalRecCnt::::'+submitCnt +' ' + totalRecCnt);
        
        for(Date dt : dateEntryMap.keySet()) {
            
            TimeCardDayDomain.DateBasedEntries outerWrapper = new TimeCardDayDomain.DateBasedEntries();
            
            uniqueKeySet = new Set<String>();
            
            outerWrapper.dateVal = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];
            outerWrapper.totalHrs = 0;
            outerWrapper.dayType = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0)).format('EEE').toUpperCase();
            
            Set<Id> existingIds = new Set<Id>();
            Set<String> uniqueKey = new Set<String>();
            
            TimeCardDayDomain.DayEntries adminRow = new TimeCardDayDomain.DayEntries();
            
            if(dateEntryMap.containsKey(dt) && dateEntryMap.get(dt) != null && dateEntryMap.get(dt).size() > 0) {
                for(TimeCardDayDomain.DayEntries entry : dateEntryMap.get(dt)) {
                    existingIds.add(entry.dayId);
                    outerWrapper.totalHrs += entry.hours;
                    
                    if(!entry.isHomeDepartment){
                        homeDeptExist = false;
                    }else {
                        if(entry.projectRTName == 'Admin_Projects' && !entry.IsAdminProTask)
                            adminTaskExist = false;
                        else if(entry.projectRTName == 'Admin_Projects' && entry.IsAdminProTask)
                            adminRow = entry;
                    }
                    
                    String key = entry.projectId+'-'+entry.taskId+'-'+entry.payrollItem+'-'+entry.isBillable+'-'+entry.locationId;
                    if(!uniqueKeySet.contains(key))
                        uniqueKeySet.add(key);
                    
                }
                //system.debug('::::::::::::dateEntryMap.get(dt):::::::'+dateEntryMap.get(dt).size());
                outerWrapper.entries = dateEntryMap.get(dt);
                
                //system.debug('::::::::homeDeptProRTName:::::'+homeDeptProRTName);
                
                outerWrapper.dayRecIds = existingIds;
            }else {
                outerWrapper.totalHrs = 0;
                outerWrapper.entries = new List<TimeCardDayDomain.DayEntries>();
            }
            
            //system.debug(':::::::::outerWrapper.entries::::'+outerWrapper.entries);
            
            // Call Home department row formations
            if((homeDeptProRTName == 'Admin_Projects' || homeDeptProRTName == 'CD_Projects' || homeDeptProRTName == 'Linguist_Support_Projects') && !homeDeptExist) {
                List<TimeCardDayDomain.DayEntries> initialRowsList = adminRowsFormation(dt,uniqueKeySet,conRec,projects,tasks,conAssign,taskMaster,holidaySet,submitCnt,totalRecCnt);
                
                //system.debug(':::::::::initialRowsList::::'+initialRowsList.size());
                
                // Holiday hours inclusion in summary level
                Boolean addHolidayHRs = false;
                for(TimeCardDayDomain.DayEntries fringeEntry : initialRowsList){
                    if(fringeEntry.TaskType == 'Fringe' && fringeEntry.isHoliday && fringeEntry.hours == 8.00 && holidaySet.contains(dt)){
                        addHolidayHRs = true;
                    }
                }
                if(addHolidayHRs)
                    outerWrapper.totalHrs += 8;
                
                outerWrapper.entries.addAll(initialRowsList);
            } else if((homeDeptProRTName == 'Admin_Projects' || homeDeptProRTName == 'CD_Projects' || homeDeptProRTName == 'Linguist_Support_Projects') && !adminTaskExist) {
                List<TimeCardDayDomain.DayEntries> fringeRowsList = new List<TimeCardDayDomain.DayEntries>();
                
                if(adminRow.projectRTName != 'Linguist_Support_Projects' || (adminRow.projectRTName == 'Linguist_Support_Projects' && adminRow.CRRateType == 'FT Salary & Benefits')) {
                    fringeRowsList = fringeRowsFormation(dt,adminRow,uniqueKeySet,conRec,projects,tasks,conAssign,taskMaster,holidaySet,submitCnt,totalRecCnt);
                }
                
                //system.debug(':::::::::fringeRowsList::::'+fringeRowsList.size());
                
                // Holiday hours inclusion in summary level
                Boolean addHolidayHRs = false;
                for(TimeCardDayDomain.DayEntries fringeEntry : fringeRowsList){
                    if(fringeEntry.isHoliday && fringeEntry.hours == 8.00 && holidaySet.contains(dt)){
                        addHolidayHRs = true;
                    }
                }
                if(addHolidayHRs)
                    outerWrapper.totalHrs += 8;
                    
                outerWrapper.entries.addAll(fringeRowsList);
            }
            
            //Sequence Number based Ordering
            List<Integer> seqNumbers = new List<Integer>();
            Map<Integer,TimeCardDayDomain.DayEntries> seqNum_EntryMap = new Map<Integer,TimeCardDayDomain.DayEntries>();
            List<TimeCardDayDomain.DayEntries> OrderedList = new List<TimeCardDayDomain.DayEntries>();
            List<TimeCardDayDomain.DayEntries> seqNumberNotExist = new List<TimeCardDayDomain.DayEntries>();
            
            for(TimeCardDayDomain.DayEntries entry : outerWrapper.entries){
                if(entry.sequenceNumber != null) {
                    seqNumbers.add(entry.sequenceNumber);
                    
                    if(!seqNum_EntryMap.containsKey(entry.sequenceNumber))
                        seqNum_EntryMap.put(entry.sequenceNumber,entry);
                }else {
                    seqNumberNotExist.add(entry);
                }
            }
            
            seqNumbers.sort();
            
            for(Integer sNum : seqNumbers){
                
                if(seqNum_EntryMap.containsKey(sNum))
                    OrderedList.add(seqNum_EntryMap.get(sNum));
            }
            
            OrderedList.addAll(seqNumberNotExist);

            outerWrapper.entries = OrderedList;
            
            // Previous Week Entries Adding
            for(AcctSeed__Time_Card_Line__c line : previousWeekLines){
                String key = line.AcctSeed__Project_Task__r.AcctSeed__Project__c+'-'+line.AcctSeed__Project_Task__c+'-'+line.Payroll_Item__c+'-'+line.AcctSeed__Billable__c+'-'+line.Location__c;
                if(!uniqueKeySet.contains(key) && line.Display_in_Future_Weeks__c){
                    TimeCardDayDomain.DayEntries oldEntry = new TimeCardDayDomain.DayEntries();
                    
                    String billingType;
                    
                    if(line.AcctSeed__Billable__c)
                        billingType = 'Billable';
                    else
                        billingType = 'Non - Billable';
                    
                    String code = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name+' / '+line.AcctSeed__Project_Task__r.Name+' / ';
                    code += line.Payroll_Item__c+' / '+billingType+' / '+line.Location__r.Name;
                    
                    oldEntry.chargeCode = code;
                    oldEntry.projectId = line.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                    oldEntry.taskId = line.AcctSeed__Project_Task__c;
                    oldEntry.locationId = line.Location__c;
                    oldEntry.isBillable = line.AcctSeed__Billable__c;
                    oldEntry.payrollItem = line.Payroll_Item__c;
                    oldEntry.costrateId = line.Labor_Cost_Rate__c;
                    oldEntry.contactAssignid = line.Contact_Assignment__c;
                    oldEntry.projectRTName = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName;
                    oldEntry.TaskName = line.AcctSeed__Project_Task__r.Name;
                    oldEntry.TaskType = line.AcctSeed__Project_Task__r.Project_Task_Type__c;
                    oldEntry.ProjectName = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                    oldEntry.locationName = line.Location__r.Name;
                    oldEntry.dateVal = dt;
                    oldEntry.status = '';
                    oldEntry.isAvailable_FutureWeek = line.Display_in_Future_Weeks__c;
                    
                    Integer index = outerWrapper.entries.size() - 1;
                    oldEntry.sequenceNumber = outerWrapper.entries.get(index).sequenceNumber + 1;
                    
                    oldEntry.isNew = true;
                    oldEntry.isUpdated = false;
                    oldEntry.isHoliday = false;
                    
                    if(oldEntry.dateVal > system.today())
                        oldEntry.isHrsDisabled = true;
                    else if(submitCnt == totalRecCnt && submitCnt != 0)
                        oldEntry.isHrsDisabled = true;
                    else
                        oldEntry.isHrsDisabled = false;
                    
                    uniqueKeySet.add(key);
                    outerWrapper.entries.add(oldEntry);
                }
            }
            
            //system.debug('::::::::outerWrapper.entries::::size::'+outerWrapper.entries.size());
        
            dateEntryList.add(outerWrapper);
        }
        
        //system.debug('before::::adding::::::rows::for:all::dates;:'+dateEntryList);
        
        //push particular date entries to other dates
        Map<String,TimeCardDayDomain.DayEntries> uniqueEntriesMap = new Map<String,TimeCardDayDomain.DayEntries>();
        List<TimeCardDayDomain.DayEntries> newEntriesList = new List<TimeCardDayDomain.DayEntries>();
        
        for(TimeCardDayDomain.DateBasedEntries dtEntry : dateEntryList){
            for(TimeCardDayDomain.DayEntries entry : dtEntry.entries){
                String key = entry.projectId+'-'+entry.taskId+'-'+entry.payrollItem+'-'+entry.isBillable+'-'+entry.locationId;
                if(!uniqueEntriesMap.containsKey(key)){
                    uniqueEntriesMap.put(key,entry);
                }
            }
        }
        
        for(TimeCardDayDomain.DateBasedEntries dtEntry : dateEntryList){
            Set<String> selectedUniqueKeys = new Set<String>();
            Set<String> entriesKeys = new Set<String>();
            for(TimeCardDayDomain.DayEntries entry : dtEntry.entries){
                String key = entry.projectId+'-'+entry.taskId+'-'+entry.payrollItem+'-'+entry.isBillable+'-'+entry.locationId;
                
                if(!entriesKeys.contains(key))
                    entriesKeys.add(key);
            }
            
            for(String mapKey : uniqueEntriesMap.keySet()){
                if(!entriesKeys.contains(mapKey)){
                    selectedUniqueKeys.add(mapKey);
                }
            }
            
            for(String key : selectedUniqueKeys) {
                TimeCardDayDomain.DayEntries newEntryToAdd = uniqueEntriesMap.get(key);
                TimeCardDayDomain.DayEntries newEntry2 = new TimeCardDayDomain.DayEntries();
                
                newEntry2.taskId = newEntryToAdd.taskId;
                newEntry2.projectId = newEntryToAdd.projectId;
                newEntry2.TaskName = newEntryToAdd.TaskName;
                newEntry2.ProjectName = newEntryToAdd.ProjectName;
                newEntry2.TaskType = newEntryToAdd.TaskType;
                newEntry2.locationName = newEntryToAdd.TaskName;
                newEntry2.locationId = newEntryToAdd.locationId;
                newEntry2.PayRollItemList = newEntryToAdd.PayRollItemList;
                newEntry2.chargeCode = newEntryToAdd.chargeCode;
                newEntry2.contactAssignid = newEntryToAdd.contactAssignid;
                newEntry2.isAdminProTask = newEntryToAdd.isAdminProTask;
                newEntry2.isAvailable_FutureWeek = newEntryToAdd.isAvailable_FutureWeek;
                newEntry2.isBillable = newEntryToAdd.isBillable;
                newEntry2.isHoliday = newEntryToAdd.isHoliday;
                newEntry2.isHomeDepartment = newEntryToAdd.isHomeDepartment;
                //newEntry2.isHrsDisabled = newEntryToAdd.isHrsDisabled;
                newEntry2.lineId = null;
                newEntry2.payrollItem = newEntryToAdd.payrollItem;
                newEntry2.projectRTName = newEntryToAdd.projectRTName;
                newEntry2.hours = null;
                newEntry2.dayId = null;
                newEntry2.status = '';
                newEntry2.comments = '';
                newEntry2.dateVal = dtEntry.entries[dtEntry.entries.size() - 1].dateVal;
                Integer newSquenceNum = dtEntry.entries[dtEntry.entries.size() - 1].sequenceNumber + 1;
                newEntry2.sequenceNumber = newSquenceNum;
                newEntry2.isUpdated = false;
                newEntry2.isNew = true;
                
                if(submitCnt == totalRecCnt && submitCnt != 0)
                    newEntry2.isHrsDisabled = true;
                else
                    newEntry2.isHrsDisabled = newEntryToAdd.isHrsDisabled;
                
                dtEntry.entries.add(newEntry2);
            }
        }
        
        system.debug(':::::::::dateEntryList:::after::::'+dateEntryList.size());
        return dateEntryList;
    }
    
    public static List<TimeCardDayDomain.DayEntries> adminRowsFormation(Date dt,Set<String> uniqueKeySet,List<Contact> conRec,List<AcctSeed__Project__c> projects, List<AcctSeed__Project_Task__c> taskList, List<Contact_Assignments__c> conAssignList, List<Project_Task_Master__c> taskMaster,Set<Date> holidaySet,Integer submitCnt,Integer totalRecCnt){
        List<TimeCardDayDomain.DayEntries> initialRowsList = new List<TimeCardDayDomain.DayEntries>();
        
        List<Contact> contact = conRec;
        
        TimeCardDayDomain.DayEntries adminRow = new TimeCardDayDomain.DayEntries();
        adminRow.isBillable = false;
        
        // Project information
        for(AcctSeed__Project__c pro : projects){
            if(pro.Id == contact[0].Home_Department_Project__c) {
                adminRow.projectId = pro.Id;
                adminRow.projectRTName = pro.RecordType.DeveloperName;
                adminRow.ProjectName = pro.Name;
                adminRow.isHomeDepartment = true;
                
                if(pro.Training_Location__c != null){
                    adminRow.locationId = pro.Training_Location__c;
                    adminRow.locationName = pro.Training_Location__r.Name;
                }
            }
        }
        
        String payroll = '';
        
        // Task information
        for(AcctSeed__Project_Task__c task : taskList){
            if(adminRow.projectId == task.AcctSeed__Project__c){
                if(task.Project_Task_Type__c != null && task.Project_Task_Type__c == 'ADMINISTRATIVE' && task.Name.contains('ADMINISTRATIVE')){
                    adminRow.taskId = task.Id;
                    adminRow.TaskName = task.Name;
                    adminRow.TaskType = task.Project_Task_Type__c;
                    adminRow.isAdminProTask = true;
                    
                    if(task.Payroll_Item__c == 'RNB')
                        payroll = task.Payroll_Item__c;
                }
            }
        }
        
        //CA Information
        for(Contact_Assignments__c conAss : conAssignList){
            if(conAss.Project__c == adminRow.projectId && conAss.Candidate_Name__c == contact[0].Id && conAss.Payroll_Item__c != null){
                if(payroll != '' && payroll != null)
                    adminRow.payrollItem = payroll;
                else
                    adminRow.payrollItem = conAss.Payroll_Item__c;
                
                adminRow.costrateId = conAss.Rate_Card_Rate__c;
                adminRow.contactAssignid = conAss.Id;
                adminRow.CRRateType = conAss.Rate_Card_Rate__r.Rate_Type__c;
            }
        }
        
        String billingType;
        
        if(adminRow.isBillable)
            billingType = 'Billable';
        else
            billingType = 'Non - Billable';
        
        adminRow.chargeCode = adminRow.ProjectName+' / '+adminRow.TaskName+' / '+adminRow.payrollItem+' / '+billingType+' / '+adminRow.locationName;
        
        adminRow.sequenceNumber = 1;
        adminRow.dateVal = dt;
        adminRow.isNew = true;
        adminRow.isUpdated = false;
        adminRow.isHoliday = false;
        
        if(adminRow.dateVal > system.today()) {
            adminRow.isHrsDisabled = true;
        } else if(adminRow.status == 'Submitted'){
            adminRow.isHrsDisabled = true;
        } else if(submitCnt == totalRecCnt && submitCnt != 0){
            adminRow.isHrsDisabled = true;
        } else {
            adminRow.isHrsDisabled = false;
        }
        
        //system.debug('::::::::adminRow::::::'+adminRow);
        
        String adminKey = adminRow.projectId+'-'+adminRow.taskId+'-'+adminRow.payrollItem+'-'+adminRow.isBillable+'-'+adminRow.locationId; 
        
        if(!uniqueKeySet.contains(adminKey) && adminRow.TaskType == 'ADMINISTRATIVE') {
            initialRowsList.add(adminRow);
            uniqueKeySet.add(adminKey);
        }
        
        if(contact[0].EE_Pay_Status__c != 'Hourly - PT'&& (adminRow.projectRTName != 'Linguist_Support_Projects' 
                || (adminRow.projectRTName == 'Linguist_Support_Projects' && adminRow.CRRateType == 'FT Salary & Benefits'))) {
            initialRowsList.addAll(fringeRowsFormation(dt,adminRow,uniqueKeySet,contact,projects,taskList,conAssignList,taskMaster,holidaySet,submitCnt,totalRecCnt));
            //system.debug('::::::::initialRowsList::::::'+initialRowsList);
        }
        
        return initialRowsList;
    }
    
    public static List<TimeCardDayDomain.DayEntries> fringeRowsFormation(Date dt,TimeCardDayDomain.DayEntries adminRow,Set<String> uniqueKeySet,List<Contact> conRec,List<AcctSeed__Project__c> projects, List<AcctSeed__Project_Task__c> taskList, List<Contact_Assignments__c> conAssignList, List<Project_Task_Master__c> taskMaster,Set<Date> holidaySet,Integer submitCnt,Integer totalRecCnt){
        List<TimeCardDayDomain.DayEntries> fringeRowsList = new List<TimeCardDayDomain.DayEntries>();
        
        TimeCardDayDomain.DayEntries holidayRow = new TimeCardDayDomain.DayEntries();
        TimeCardDayDomain.DayEntries sickRow = new TimeCardDayDomain.DayEntries();
        TimeCardDayDomain.DayEntries vacationRow = new TimeCardDayDomain.DayEntries();
        
        holidayRow.isBillable = false;
        sickRow.isBillable = false;
        vacationRow.isBillable = false;
        
        holidayRow.dateVal = dt;
        sickRow.dateVal = dt;
        vacationRow.dateVal = dt;
        
        holidayRow.isNew = true;
        holidayRow.isUpdated = false;
        
        sickRow.isNew = true;
        sickRow.isUpdated = false;
        
        vacationRow.isNew = true;
        vacationRow.isUpdated = false;
        
        
        holidayRow.CRRateType = adminRow.CRRateType;
        sickRow.CRRateType = adminRow.CRRateType;
        vacationRow.CRRateType = adminRow.CRRateType;
        
        Set<String> rateTypeSet = new Set<String>{'FT Salary & Benefits','FT Hourly & Benefits'};
        Integer dayOfWeek = dayOfWeekNumber(holidayRow.dateVal);
        if(holidaySet.contains(holidayRow.dateVal)) {
            if(rateTypeSet.contains(holidayRow.CRRateType) && dayOfWeek != 0 && dayOfWeek != 6)
                holidayRow.hours = 8.00;
                
            holidayRow.isHrsDisabled = true;
        }else if(holidayRow.dateVal > system.today()) {
            holidayRow.isHrsDisabled = true;
        } else if(holidayRow.status == 'Submitted'){
            holidayRow.isHrsDisabled = true;
        } else if(submitCnt == totalRecCnt && submitCnt != 0){
            holidayRow.isHrsDisabled = true;
        } else if(adminRow.TaskName == 'Fringe-Holiday'){
            holidayRow.isHrsDisabled = true;
        } else {
            holidayRow.isHrsDisabled = false;
        }
        
        String holidayKey = '';
        String sickKey = '';
        String vacationKey = '';
        
        //Project Task Master map formation
        Map<String,List<String>> task_payrollItemMap = new Map<String,List<String>>();
         
         for(Project_Task_Master__c PTM : taskMaster){
             
             List<String> payrollItems = new List<String>();
             
             if(PTM.Payroll_Item__c != null && PTM.Payroll_Item__c.contains(';'))
                 payrollItems = PTM.Payroll_Item__c.split(';');
             else
                 payrollItems.add(PTM.Payroll_Item__c);
             
             if(!task_payrollItemMap.containsKey(PTM.Name)) {
                 task_payrollItemMap.put(PTM.Name,payrollItems);
             }
         }
        
        for(AcctSeed__Project_Task__c task : taskList){
            if(conRec[0].Home_Department_Project__c == task.AcctSeed__Project__c){
                // Holiday Row
                if(task.Project_Task_Type__c == 'Fringe' && task.Name.contains('Holiday')){
                    holidayRow.projectId = adminRow.projectId ;
                    holidayRow.projectRTName = adminRow.projectRTName;
                    holidayRow.ProjectName = adminRow.ProjectName;
                    holidayRow.isHomeDepartment = adminRow.isHomeDepartment;
                    holidayRow.locationId = adminRow.locationId;
                    holidayRow.locationName = adminRow.locationName;
                    
                    holidayRow.costrateId = adminRow.costrateId;
                    holidayRow.contactAssignid = adminRow.contactAssignid;
                    
                    // Removing extra space between (-) symbol
                    if(task.Name.contains(' - '))
                        task.Name = task.Name.replaceAll('(\\s+)', '');
                    
                    holidayRow.taskId = task.Id;
                    holidayRow.TaskName = task.Name;
                    holidayRow.TaskType = task.Project_Task_Type__c;
                    
                    if(task_payrollItemMap.containsKey(task.Name)) {
                        holidayRow.PayRollItemList = task_payrollItemMap.get(task.Name);
                        holidayRow.payrollItem = (holidayRow.PayRollItemList.size() > 0) ? holidayRow.PayRollItemList[0]:null;
                    }
                    
                    holidayRow.sequenceNumber = 2;
                    if(rateTypeSet.contains(holidayRow.CRRateType))
                        holidayRow.isHoliday = true;
                    else
                        holidayRow.isHoliday = false;
                    
                    String billingType;
                    if(holidayRow.isBillable)
                        billingType = 'Billable';
                    else
                        billingType = 'Non - Billable';
                    
                    holidayRow.isHrsDisabled = true;        
                    
                    holidayRow.chargeCode = holidayRow.ProjectName+' / '+holidayRow.TaskName+' / '+holidayRow.payrollItem+' / '+billingType+' / '+holidayRow.locationName;
                    
                    holidayKey =  holidayRow.projectId+'-'+holidayRow.taskId+'-'+holidayRow.payrollItem+'-'+holidayRow.isBillable+'-'+holidayRow.locationId;  
                }
                
                // Sick Row formation
                if(task.Project_Task_Type__c == 'Fringe' && task.Name.contains('Sick')){
                    sickRow.projectId = adminRow.projectId ;
                    sickRow.projectRTName = adminRow.projectRTName;
                    sickRow.ProjectName = adminRow.ProjectName;
                    sickRow.isHomeDepartment = adminRow.isHomeDepartment;
                    sickRow.locationId = adminRow.locationId;
                    sickRow.locationName = adminRow.locationName;
                    
                    sickRow.costrateId = adminRow.costrateId;
                    sickRow.contactAssignid = adminRow.contactAssignid;
                    
                    // Removing extra space between (-) symbol
                    if(task.Name.contains(' - '))
                        task.Name = task.Name.replaceAll('(\\s+)', '');
                    
                    sickRow.taskId = task.Id;
                    sickRow.TaskName = task.Name;
                    sickRow.TaskType = task.Project_Task_Type__c;
                    
                    if(task_payrollItemMap.containsKey(task.Name)) {
                        sickRow.PayRollItemList = task_payrollItemMap.get(task.Name);
                        sickRow.payrollItem = (sickRow.PayRollItemList.size() > 0) ? sickRow.PayRollItemList[0]:null;
                    }
                    
                    sickRow.sequenceNumber = 3;
                    sickRow.isHoliday = false;
                    
                    if(sickRow.status == 'Submitted')
                        sickRow.isHrsDisabled = true;
                    else if(submitCnt == totalRecCnt && submitCnt != 0)
                        sickRow.isHrsDisabled = true;
                    else
                        sickRow.isHrsDisabled = false;
                    
                    String billingType;
                    if(sickRow.isBillable)
                        billingType = 'Billable';
                    else
                        billingType = 'Non - Billable';
                    
                    sickRow.chargeCode = sickRow.ProjectName+' / '+sickRow.TaskName+' / '+sickRow.payrollItem+' / '+billingType+' / '+sickRow.locationName;
                    
                    sickKey = sickRow.projectId+'-'+sickRow.taskId+'-'+sickRow.payrollItem+'-'+sickRow.isBillable+'-'+sickRow.locationId;  
                }
                
                // Vacation Row Formation
                if(task.Project_Task_Type__c == 'Fringe' && task.Name.contains('Vacation')){
                    vacationRow.projectId = adminRow.projectId ;
                    vacationRow.projectRTName = adminRow.projectRTName;
                    vacationRow.ProjectName = adminRow.ProjectName;
                    vacationRow.isHomeDepartment = adminRow.isHomeDepartment;
                    vacationRow.locationId = adminRow.locationId;
                    vacationRow.locationName = adminRow.locationName;
                    
                    vacationRow.costrateId = adminRow.costrateId;
                    vacationRow.contactAssignid = adminRow.contactAssignid;
                    
                    // Removing extra space between (-) symbol
                    if(task.Name.contains(' - '))
                        task.Name = task.Name.replaceAll('(\\s+)', '');
                    
                    vacationRow.taskId = task.Id;
                    vacationRow.TaskName = task.Name;
                    vacationRow.TaskType = task.Project_Task_Type__c;
                    
                    if(task_payrollItemMap.containsKey(task.Name)) {
                        vacationRow.PayRollItemList = task_payrollItemMap.get(task.Name);
                        vacationRow.payrollItem = (vacationRow.PayRollItemList.size() > 0) ? vacationRow.PayRollItemList[0]:null;
                    }
                    
                    vacationRow.sequenceNumber = 4;
                    vacationRow.isHoliday = false;
                    
                    if(vacationRow.status == 'Submitted')
                        vacationRow.isHrsDisabled = true;
                    else if(submitCnt == totalRecCnt && submitCnt != 0)
                        vacationRow.isHrsDisabled = true;
                    else
                        vacationRow.isHrsDisabled = false;
                    
                    String billingType;
                    if(vacationRow.isBillable)
                        billingType = 'Billable';
                    else
                        billingType = 'Non - Billable';
                    
                    vacationRow.chargeCode = vacationRow.ProjectName+' / '+vacationRow.TaskName+' / '+vacationRow.payrollItem+' / '+billingType+' / '+vacationRow.locationName;
                    
                    vacationKey = vacationRow.projectId+'-'+vacationRow.taskId+'-'+vacationRow.payrollItem+'-'+vacationRow.isBillable+'-'+vacationRow.locationId; 
                }
            }
        }
        
        if(!uniqueKeySet.contains(holidayKey)) {
            uniqueKeySet.add(holidayKey);
            fringeRowsList.add(holidayRow);
        }
         
        if(!uniqueKeySet.contains(sickKey)) {
            uniqueKeySet.add(sickKey);
            fringeRowsList.add(sickRow);
        }
        
        if(!uniqueKeySet.contains(vacationKey)) {
            uniqueKeySet.add(vacationKey);
            fringeRowsList.add(vacationRow);
        }   
        
        return fringeRowsList;
    }
    
    public static List<TimeCardDayDomain.NotesDetails> notesFormation(List<Accounting_Seed_Time_Snapshot__c> snapshotList){
        List<TimeCardDayDomain.NotesDetails> notesDetails = new List<TimeCardDayDomain.NotesDetails>();
        List<TimeCardDayDomain.NotesDetails> tempList = new List<TimeCardDayDomain.NotesDetails>();
        Map<String,List<TimeCardDayDomain.NotesDetails>> tempMap = new Map<String,List<TimeCardDayDomain.NotesDetails>>();
        
        for(Accounting_Seed_Time_Snapshot__c snapshot : snapshotList) {
            TimeCardDayDomain.NotesDetails notes = new TimeCardDayDomain.NotesDetails();
            notes.userName = snapshot.CreatedBy.Name;
            notes.Edited = snapshot.CreatedDate;
            notes.ChargeCode = snapshot.Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
            notes.TaskName = snapshot.Time_Card_Line__r.AcctSeed__Project_Task__r.Name;
            
            String dt = String.valueOf(snapshot.Date__c);
            notes.Daydate = dt.split('-')[1]+'/'+dt.split('-')[2]+'/'+dt.split('-')[0];
            
            notes.OldHours = String.valueOf(snapshot.Total_Hours_Before_Approved__c) + ' Hrs';
            notes.NewHours = String.valueOf(snapshot.Time_Card_Day__r.Total_Hours_Before_Approved__c)+ ' Hrs';
            notes.OldStatus = snapshot.TCD_Status__c;
            notes.NewStatus = snapshot.TCD_New_Status__c;
            notes.Comment = snapshot.Internal_Comment__c;
            notes.createdDate = snapshot.createdDate;
            notes.ReferenceId = snapshot.Reference_Id__c;
            notes.InstructorId = snapshot.Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
            
            //For Instructor Time Entry usage
            notes.editedDT = snapshot.CreatedDate.format('MM/dd/yyyy HH:mm:ss a', UserInfo.getTimeZone().getID());
            notes.dayId = snapshot.Time_Card_Day__c;
            notes.projectName = snapshot.Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.DLS_Class__c;
            
            tempList.add(notes);
        }
        
        system.debug('::::::tempList:::::::::'+tempList.size());
        
        for(TimeCardDayDomain.NotesDetails temp : tempList){
            if(temp.ReferenceId != null){
                if(!tempMap.containsKey(temp.ReferenceId)) {
                    TimeCardDayDomain.NotesDetails newNote = temp;
                    TimeCardDayDomain.NotesDetails newNote1 = new TimeCardDayDomain.NotesDetails();
                    newNote1.ChargeCode = '';
                    newNote1.Edited = null;
                    newNote1.TaskName = '';
                    newNote1.Daydate = null;
                    newNote1.NewHours = '';
                    newNote1.OldHours = '';
                    newNote1.OldStatus = '';
                    newNote1.NewStatus = '';
                    newNote1.dayId = '';
                    newNote1.editedDT = '';
                    newNote1.projectName = '';
                    newNote1.Comment = newNote.Comment;
                    newNote1.createdDate = newNote.createdDate;
                    newNote1.ReferenceId = newNote.ReferenceId;
                    newNote1.InstructorId = newNote.InstructorId;
                    newNote1.userName = newNote.userName;
                    notesDetails.add(newNote1);
                    tempMap.put(temp.ReferenceId,new List<TimeCardDayDomain.NotesDetails>{temp});
                }else {
                    tempMap.get(temp.ReferenceId).add(temp);
                }
            }else {
                notesDetails.add(temp);
            }
        }
        
        system.debug('::::::::notesDetails::::::'+notesDetails);
        
        return notesDetails;
    }
    
    public static List<TimeCardDayDomain.DayEntries> entriesFormation(List<AcctSeed__Time_Card_Line__c> timeCardLines,List<AcctSeed__Time_Card_Line__c> previousWeekLines,List<AcctSeed__Project__c> projects, List<AcctSeed__Project_Task__c> tasks, List<Contact_Assignments__c> conAssign, List<Project_Task_Master__c> taskMaster,List<Contact> contactRec) {
        
        List<TimeCardDayDomain.DayEntries> entriesList = new List<TimeCardDayDomain.DayEntries>();
        
        Id homeDepartProId = (contactRec != null) ? contactRec[0].Home_Department_Project__c : null;
        Boolean homeDeptExist = false;
        Boolean adminTaskExist = false;
        
        for(AcctSeed__Time_Card_Line__c line : timeCardLines) {
            if(line.AcctSeed__Time_Card_Days__r != null && line.AcctSeed__Time_Card_Days__r.size() > 0){
                for(AcctSeed__Time_Card_Day__c day : line.AcctSeed__Time_Card_Days__r){
                    TimeCardDayDomain.DayEntries dayRec = new TimeCardDayDomain.DayEntries();
                    
                    String billingType;
                    
                    if(line.AcctSeed__Billable__c)
                        billingType = 'Billable';
                    else
                        billingType = 'Non - Billable';
                    
                    String code = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name+' / '+line.AcctSeed__Project_Task__r.Name+' / ';
                    code += line.Payroll_Item__c+' / '+billingType+' / '+line.Location__r.Name;
                    
                    dayRec.chargeCode = code;
                    dayRec.hours = day.Total_Hours_Before_Approved__c;
                    dayRec.dayId = day.Id;
                    dayRec.lineId = day.AcctSeed__Time_Card_Line__c;
                    dayRec.projectId = line.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                    dayRec.taskId = line.AcctSeed__Project_Task__c;
                    dayRec.locationId = line.Location__c;
                    dayRec.isBillable = line.AcctSeed__Billable__c;
                    dayRec.payrollItem = line.Payroll_Item__c;
                    dayRec.status = day.Status__c;
                    dayRec.dateVal = day.AcctSeed__Date__c;
                    dayRec.comments = day.AcctSeed__Internal_Comment__c;
                    dayRec.costrateId = line.Labor_Cost_Rate__c;
                    dayRec.contactAssignid = line.Contact_Assignment__c;
                    dayRec.sequenceNumber = Integer.valueOf(line.Sequence_Number__c);
                    
                    if(line.AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE')
                        dayRec.IsAdminProTask = true;
                    else
                        dayRec.IsAdminProTask = false;
                    
                    if(line.AcctSeed__Project_Task__r.AcctSeed__Project__c == homeDepartProId)
                        dayRec.isHomeDepartment = true;
                    else
                        dayRec.isHomeDepartment = false;
                        
                    dayRec.isNew = false;
                    dayRec.isUpdated = false;
                        
                     entriesList.add(dayRec);
                }
            }
        }
        return entriesList;
    }
    
    public static TimeCardDayDomain.ButtonDisplay buttonDisplayFunction(List<TimeCardDayDomain.DayEntries> entryDetails,Date startDate,Date endDate){
        
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        Date previuosWkStart = currStart.addDays(-7);
        Date previuosWkEnd = currEnd.addDays(-7);
        
        Boolean isCurrentWeek = false;
        Boolean isBeforeLastWeek = false;
        
        if(startDate == currStart && endDate == currEnd) {
            isCurrentWeek = true;
        }
        
        if(previuosWkStart > startDate && previuosWkEnd > endDate){
            isBeforeLastWeek = true;
        }
        
        system.debug(':::::::::isCurrentWeek::::::'+isCurrentWeek);
        system.debug(':::::::::isBeforeLastWeek::::::'+isBeforeLastWeek);
        
        TimeCardDayDomain.ButtonDisplay btnDisp = new TimeCardDayDomain.ButtonDisplay();
        btnDisp.submitBtn = false;
        btnDisp.recallBtn = false;
        
        Integer submitCnt = 0;
        Integer approvedCnt = 0;
        Integer rejectedCnt = 0;
        Integer recallCnt = 0;
        Integer revertCnt = 0;
        Integer otherStatusCnt = 0;
        Integer totalCnt = 0;
        
        List<String> statusList = new List<String>();
        
        for(TimeCardDayDomain.DayEntries entry : entryDetails){
            if(String.isNotBlank(entry.status) && entry.status != 'Unposted') {
                totalCnt += 1; 
                
                // This is for Submit
                if(entry.status == 'Submitted') {
                    submitCnt = submitCnt + 1;
                }
                // This is for approved
                if(entry.status == 'Approved' || entry.status == 'Admin Approved') {
                    approvedCnt = approvedCnt + 1;
                }
                
                // This is for Rejected
                if(entry.status == 'Rejected') {
                    rejectedCnt = rejectedCnt + 1;
                }
                
                // This for Recalled
                if(entry.status == 'Recalled') {
                    recallCnt = recallCnt + 1;
                }
                
                // This is for Draft / Reverted
                if(entry.status == 'Draft') {
                    otherStatusCnt = otherStatusCnt + 1;
                }
                
                // This is for Reverted
                if(entry.status == 'Reverted') {
                    revertCnt = revertCnt + 1;
                }
            }
        }
        
        if(totalCnt > 0){
            
            if(!isBeforeLastWeek) { // This condition to check selected week range is before last week - then dont show any btns
                    
                if(isCurrentWeek) {
                    if(submitCnt > 0 || (approvedCnt > 0 && approvedCnt != totalCnt) 
                        && rejectedCnt == 0 && otherStatusCnt == 0 && revertCnt == 0) {        // For Recall btn display conditions
                        btnDisp.recallBtn = true;
                    }
                    
                    if(submitCnt == 0 && (rejectedCnt > 0 || recallCnt > 0 || (approvedCnt > 0 && approvedCnt != totalCnt) 
                        || otherStatusCnt > 0 || revertCnt > 0)) {    // For Submit & Save btn display
                        btnDisp.submitBtn = true;
                    }
                    
                    // For all approved / Admin appoved conditions
                    if(approvedCnt > 0 && approvedCnt == totalCnt) {
                        btnDisp.recallBtn = true;
                    }
                        
                }else {
                    // Last Week btns display conditions
                    if(submitCnt > 0) {
                        btnDisp.recallBtn = true;                // For Recall btn display conditions
                    }
                    
                    if(submitCnt == 0 && (otherStatusCnt > 0 || rejectedCnt > 0 || recallCnt > 0 || revertCnt > 0)){    // For Save & Submit btn display
                        btnDisp.submitBtn = true;
                    }
                }
                
            }else {
                // For all other past weeks btns display
                if(revertCnt > 0) {
                    btnDisp.submitBtn = true;
                }
            }
        }else {
            if(!isBeforeLastWeek) {
                btnDisp.recallBtn = false;
                btnDisp.submitBtn = true;
                
            }else {
                btnDisp.recallBtn = false;
                btnDisp.submitBtn = false;
            }
        }
        
        return btnDisp;
    }
    
    // Previous week rows formation for manage operation on Weekly summary view
    public static List<TimeCardDayDomain.DayEntries> previousWeekFormation(List<AcctSeed__Time_Card_Line__c> previousWeekLines,List<Contact> conRec){
        
        List<TimeCardDayDomain.DayEntries> previousWeekEntries = new List<TimeCardDayDomain.DayEntries>();
        
        Id homeDepartProId = (conRec.size() > 0) ? conRec[0].Home_Department_Project__c : null;
        
        system.debug('::::::::previousWeekLines:::::'+previousWeekLines.size());
        
        for(AcctSeed__Time_Card_Line__c line : previousWeekLines){
            system.debug(':::::line:::;'+line);
            if(line.Display_in_Future_Weeks__c && line.AcctSeed__Project_Task__r.AcctSeed__Project__c != homeDepartProId){
                TimeCardDayDomain.DayEntries oldEntry = new TimeCardDayDomain.DayEntries();
                
                String billingType;
                
                if(line.AcctSeed__Billable__c)
                    billingType = 'Billable';
                else
                    billingType = 'Non - Billable';
                
                String code = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name+' / '+line.AcctSeed__Project_Task__r.Name+' / ';
                code += line.Payroll_Item__c+' / '+billingType+' / '+line.Location__r.Name;
                
                oldEntry.chargeCode = code;
                oldEntry.projectId = line.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                oldEntry.taskId = line.AcctSeed__Project_Task__c;
                oldEntry.locationId = line.Location__c;
                oldEntry.isBillable = line.AcctSeed__Billable__c;
                oldEntry.payrollItem = line.Payroll_Item__c;
                oldEntry.costrateId = line.Labor_Cost_Rate__c;
                oldEntry.contactAssignid = line.Contact_Assignment__c;
                oldEntry.projectRTName = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName;
                oldEntry.TaskName = line.AcctSeed__Project_Task__r.Name;
                oldEntry.TaskType = line.AcctSeed__Project_Task__r.Project_Task_Type__c;
                oldEntry.ProjectName = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                oldEntry.locationName = line.Location__r.Name;
                oldEntry.status = '';
                oldEntry.isAvailable_FutureWeek = line.Display_in_Future_Weeks__c;
                oldEntry.lineId = line.Id;
                oldEntry.isNew = true;
                oldEntry.isUpdated = false;
                oldEntry.isHoliday = false;
                oldEntry.isHrsDisabled = false;
                
                previousWeekEntries.add(oldEntry);
            }
        }
        
        system.debug('::::::::previousWeekEntries:::::'+previousWeekEntries);        
        return previousWeekEntries;
    }
    
    /******************************************************************************
    - For Mobile Approval Page weeklyInformation formation
    - created by NS on June 8 2018
    ********************************************************************************/
    public static TimeCardDayDomain.WeekViewDetails approvalWeekDetailFormation(Date startDate,Date endDate,String summaryType,List<AcctSeed__Time_Card_Line__c> timeCardLine,List<Accounting_Seed_Time_Snapshot__c> snapshotDetails){
        
        TimeCardDayDomain.WeekViewDetails weekDetails = new TimeCardDayDomain.WeekViewDetails();
        weekDetails.startDate = startDate;
        weekDetails.endDate = endDate;
        
        
        // Instructor based notes formation
        Map<Id,List<TimeCardDayDomain.NotesDetails>> insIdNotesDetails = new Map<Id,List<TimeCardDayDomain.NotesDetails>>();
        List<TimeCardDayDomain.NotesDetails> notesDetails = notesFormation(snapshotDetails);
        
        for(TimeCardDayDomain.NotesDetails note : notesDetails){
            if(!insIdNotesDetails.containsKey(note.InstructorId))
                insIdNotesDetails.put(note.InstructorId, new List<TimeCardDayDomain.NotesDetails>{note});
            else
                insIdNotesDetails.get(note.InstructorId).add(note);
        }
        
        weekDetails.insIdNotesDetails = insIdNotesDetails;
        
        // Contact filter formation
        weekDetails.contactList = approvalContactFilterFormation(timecardline,new List<AcctSeed__Time_Card_Day__c>());
        
        if(summaryType == 'Date'){
           
            weekDetails.insIdDateEntries = approvalSummaryDetailFormation(timecardline,startDate,endDate);
            
            Date st = startDate;
            Date ed = endDate;
            List<String> weekDates = new List<String>();
            while(st <= ed){
                weekDates.add(String.valueOf(st).split('-')[1]+'/'+String.valueOf(st).split('-')[2]+'/'+String.valueOf(st).split('-')[0]);
                st = st.addDays(1);
            }
            weekDetails.weekDates = weekDates;
        
        }else {
            
            weekDetails.insIdProEntries = project_ApporvalSummaryFormation(timecardline,startDate,endDate);
            
            // Instructor based project list formation
            Map<Id,List<AcctSeed__Project__c>> insIdproList = new Map<Id,List<AcctSeed__Project__c>>();
            
            if(weekDetails.insIdProEntries != null && weekDetails.insIdProEntries.size() > 0) {
                
                for(Id key : weekDetails.insIdProEntries.keySet()) {
                    for(TimeCardDayDomain.ProjectBasedEntries proEntry : weekDetails.insIdProEntries.get(key)){
                        AcctSeed__Project__c pro = new AcctSeed__Project__c();
                        pro.Id = proEntry.projectId;
                        pro.Name = proEntry.projectName;
                        
                        if(!insIdproList.containsKey(proEntry.instructorId))
                            insIdproList.put(proEntry.instructorId,new List<AcctSeed__Project__c>{pro});
                        else
                            insIdproList.get(proEntry.instructorId).add(pro);
                    }
                }
            }
            weekDetails.insIdProjectList = insIdproList;
        }
        
        return weekDetails;
    } 
    
    /***********************************************************************
    - Date based summary entry formation for Mobile Approval Page
    - Created by NS on June 8 2018
    ***********************************************************************/
    public static Map<Id,List<TimeCardDayDomain.DateBasedEntries>> approvalSummaryDetailFormation(List<AcctSeed__Time_Card_Line__c> timeCardLines,Date st,Date ed){
        
        Map<Id,List<TimeCardDayDomain.DateBasedEntries>> insIdDateEntries = new Map<Id,List<TimeCardDayDomain.DateBasedEntries>>();
        
        Map<String,List<TimeCardDayDomain.DayEntries>> InsIddateEntryMap = new Map<String,List<TimeCardDayDomain.DayEntries>>();
        Date startDt = st;
        Date endDt = ed;
        
        Map<Id,String> insIdInsName = new Map<Id,String>();
        
        Set<Id> insIds = new Set<Id>();
        for(AcctSeed__Time_Card_Line__c line : timeCardLines){
            insIds.add(line.AcctSeed__Time_Card__r.Intructor__c);
        }
        
        while(startDt <= endDt){
            system.debug('startDt::::'+startDt);
            for(Id conId : insIds) {
                InsIddateEntryMap.put((conId+'~'+startDt),new List<TimeCardDayDomain.DayEntries>{});
            }
            startDt = startDt.addDays(1);
        }
        system.debug(':::::::InsIddateEntryMap::::::'+InsIddateEntryMap);
        
        Set<String> uniqueKeySet;
        
        for(AcctSeed__Time_Card_Line__c line : timeCardLines) {
            
            if(line.AcctSeed__Time_Card_Days__r != null || line.AcctSeed__Time_Card_Days__r.size() > 0) {
                
                for(AcctSeed__Time_Card_Day__c day : line.AcctSeed__Time_Card_Days__r) {
                    TimeCardDayDomain.DayEntries dayRec = new TimeCardDayDomain.DayEntries();
                    
                    String billingType;
                    
                    if(line.AcctSeed__Billable__c)
                        billingType = 'Billable';
                    else
                        billingType = 'Non - Billable';
                    
                    String code = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name+' / '+line.AcctSeed__Project_Task__r.Name+' / ';
                    code += line.Payroll_Item__c+' / '+billingType+' / '+line.Location__r.Name;
                    
                    dayRec.chargeCode = code;
                    dayRec.hours = day.Total_Hours_Before_Approved__c;
                    dayRec.dayId = day.Id;
                    dayRec.projectId = line.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                    dayRec.status = day.Status__c;
                    dayRec.dateVal = day.AcctSeed__Date__c;
                    dayRec.comments = day.AcctSeed__Invoice_Comment__c;
                    dayRec.sequenceNumber = Integer.valueOf(line.Sequence_Number__c);
                    dayRec.ProjectName = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                    dayRec.taskId = line.AcctSeed__Project_Task__c;
                    dayRec.locationId = line.Location__c;
                    dayRec.isBillable = line.AcctSeed__Billable__c;
                    dayRec.payrollItem = line.Payroll_Item__c;
                    dayRec.InstructorId = line.AcctSeed__Time_Card__r.Intructor__c;
                    dayRec.InstructorName = line.AcctSeed__Time_Card__r.Intructor__r.Name;
                    
                    if(InsIddateEntryMap.containsKey(line.AcctSeed__Time_Card__r.Intructor__c+'~'+day.AcctSeed__Date__c)){
                        InsIddateEntryMap.get(line.AcctSeed__Time_Card__r.Intructor__c+'~'+day.AcctSeed__Date__c).add(dayRec);
                    }
                    
                    if(!insIdInsName.containsKey(dayRec.InstructorId))
                        insIdInsName.put(dayRec.InstructorId,dayRec.InstructorName);
                }
            }
        }
        
        for(String keyVal : InsIddateEntryMap.keySet()) {
            
            TimeCardDayDomain.DateBasedEntries outerWrapper = new TimeCardDayDomain.DateBasedEntries();
            
            uniqueKeySet = new Set<String>();
            
            Date dt = Date.valueOf(keyVal.split('~')[1]);
            String InsId = keyVal.split('~')[0];
            
            outerWrapper.dateVal = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];
            outerWrapper.dateToDisplay = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2];
            outerWrapper.pendingHrs = 0;
            outerWrapper.approvedHrs = 0;
            outerWrapper.rejectedHrs = 0;
            outerWrapper.dayType = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0)).format('EEE').toUpperCase();
            outerWrapper.instructorId = InsId;
            outerWrapper.instructorName = insIdInsName.containsKey(InsId) ? insIdInsName.get(InsId): null;
            
            Set<String> uniqueKey = new Set<String>();
            
            TimeCardDayDomain.DayEntries adminRow = new TimeCardDayDomain.DayEntries();
            
            if(InsIddateEntryMap.containsKey(keyVal) && InsIddateEntryMap.get(keyVal) != null && InsIddateEntryMap.get(keyVal).size() > 0) {
                for(TimeCardDayDomain.DayEntries entry : InsIddateEntryMap.get(keyVal)) {
                    
                    if(entry.status == 'Submitted') {
                        outerWrapper.pendingHrs += entry.hours;
                    } else if(entry.status == 'Approved') {
                        outerWrapper.approvedHrs += entry.hours;
                        outerWrapper.pendingHrs += entry.hours;
                    } else if(entry.status == 'Rejected') {
                        outerWrapper.rejectedHrs += entry.hours;
                        outerWrapper.pendingHrs += entry.hours;
                    }
                    
                    String key = entry.projectId+'-'+entry.taskId+'-'+entry.payrollItem+'-'+entry.isBillable+'-'+entry.locationId;
                    if(!uniqueKeySet.contains(keyVal))
                        uniqueKeySet.add(keyVal);
                    
                }
                //system.debug('::::::::::::dateEntryMap.get(dt):::::::'+dateEntryMap.get(dt).size());
                outerWrapper.entries = InsIddateEntryMap.get(keyVal);
            }else {
                outerWrapper.pendingHrs = 0;
                outerWrapper.approvedHrs = 0;
                outerWrapper.rejectedHrs = 0;
                outerWrapper.entries = new List<TimeCardDayDomain.DayEntries>();
            }
            
            if(!insIdDateEntries.containsKey(outerWrapper.instructorId))
                insIdDateEntries.put(outerWrapper.instructorId,new List<TimeCardDayDomain.DateBasedEntries>{outerWrapper});
            else
                insIdDateEntries.get(outerWrapper.instructorId).add(outerWrapper);
        }
        
        return insIdDateEntries;
    }
    
    /***********************************************************
    - For Project based summary information display on Mobile approval page
    - Created by NS on June 8 2018
    ***********************************************************/
    public static Map<Id,List<TimeCardDayDomain.ProjectBasedEntries>> project_ApporvalSummaryFormation(List<AcctSeed__Time_Card_Line__c> timeCardLines,Date startDate,Date endDate){
        
        Map<Id,List<TimeCardDayDomain.ProjectBasedEntries>> insIdprojectEntries = new Map<Id,List<TimeCardDayDomain.ProjectBasedEntries>>();
        
        Map<String,List<TimeCardDayDomain.DayEntries>> insIdproIdEntryMap = new Map<String,List<TimeCardDayDomain.DayEntries>>();
        
        Set<String> uniqueKeySet;
        Map<Id,String> proIdName = new Map<Id,String>();
        Map<Id,string> insIdInsName = new Map<Id,String>();
        
        for(AcctSeed__Time_Card_Line__c line : timeCardLines) {
            
            if(line.AcctSeed__Time_Card_Days__r != null || line.AcctSeed__Time_Card_Days__r.size() > 0) {
                
                for(AcctSeed__Time_Card_Day__c day : line.AcctSeed__Time_Card_Days__r) {
                    TimeCardDayDomain.DayEntries dayRec = new TimeCardDayDomain.DayEntries();
                    
                    String billingType;
                    
                    if(line.AcctSeed__Billable__c)
                        billingType = 'Billable';
                    else
                        billingType = 'Non - Billable';
                    
                    String code = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name+' / '+line.AcctSeed__Project_Task__r.Name+' / ';
                    code += line.Payroll_Item__c+' / '+billingType+' / '+line.Location__r.Name;
                    
                    dayRec.chargeCode = code;
                    dayRec.hours = day.Total_Hours_Before_Approved__c;
                    dayRec.dayId = day.Id;
                    dayRec.projectId = line.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                    dayRec.status = day.Status__c;
                    dayRec.dateVal = day.AcctSeed__Date__c;
                    dayRec.comments = day.AcctSeed__Invoice_Comment__c;
                    dayRec.sequenceNumber = Integer.valueOf(line.Sequence_Number__c);
                    dayRec.ProjectName = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name;
                    dayRec.taskId = line.AcctSeed__Project_Task__c;
                    dayRec.locationId = line.Location__c;
                    dayRec.isBillable = line.AcctSeed__Billable__c;
                    dayRec.payrollItem = line.Payroll_Item__c;
                    dayRec.InstructorId = line.AcctSeed__Time_Card__r.Intructor__c;
                    dayRec.InstructorName = line.AcctSeed__Time_Card__r.Intructor__r.Name;
                    
                    if(!insIdproIdEntryMap.containsKey(line.AcctSeed__Time_Card__r.Intructor__c+'~'+line.AcctSeed__Project_Task__r.AcctSeed__Project__c))
                        insIdproIdEntryMap.put(line.AcctSeed__Time_Card__r.Intructor__c+'~'+line.AcctSeed__Project_Task__r.AcctSeed__Project__c,new List<TimeCardDayDomain.DayEntries>{dayRec});
                    else
                        insIdproIdEntryMap.get(line.AcctSeed__Time_Card__r.Intructor__c+'~'+line.AcctSeed__Project_Task__r.AcctSeed__Project__c).add(dayRec);
                    
                    if(!proIdName.containsKey(line.AcctSeed__Project_Task__r.AcctSeed__Project__c))
                        proIdName.put(line.AcctSeed__Project_Task__r.AcctSeed__Project__c,line.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name);
                        
                    if(!insIdInsName.containsKey(dayRec.InstructorId))
                        insIdInsName.put(dayRec.InstructorId,dayRec.InstructorName);
                }
            }
        }
        system.debug(':::::::::insIdproIdEntryMap:::::'+insIdproIdEntryMap);
        
        for(String keyVal : insIdproIdEntryMap.keySet()) {
        
            String insId = keyVal.split('~')[0];
            String proId = keyVal.split('~')[1];
            
            TimeCardDayDomain.ProjectBasedEntries outerWrapper = new TimeCardDayDomain.ProjectBasedEntries();
            
            uniqueKeySet = new Set<String>();
            
            outerWrapper.pendingHrs = 0;
            outerWrapper.approvedHrs = 0;
            outerWrapper.rejectedHrs = 0;
            outerWrapper.projectId = proId;
            outerWrapper.instructorId = insId;
            outerWrapper.instructorName = insIdInsName.containsKey(insId)? insIdInsName.get(insId) : null;
            
            if(proIdName.containsKey(proId))
                outerWrapper.projectName = proIdName.get(proId);
            
            Set<String> uniqueKey = new Set<String>();
            Map<Date,List<TimeCardDayDomain.DayEntries>> dateEntryForSort = new Map<Date,List<TimeCardDayDomain.DayEntries>>();
            List<Date> datesToSort = new List<Date>();
            
            TimeCardDayDomain.DayEntries adminRow = new TimeCardDayDomain.DayEntries();
            
            if(insIdproIdEntryMap.containsKey(keyVal) && insIdproIdEntryMap.get(keyVal) != null && insIdproIdEntryMap.get(keyVal).size() > 0) {
                for(TimeCardDayDomain.DayEntries entry : insIdproIdEntryMap.get(keyVal)) {
                    
                    if(entry.status == 'Submitted') {
                        outerWrapper.pendingHrs += entry.hours;
                    } else if(entry.status == 'Approved') {
                        outerWrapper.approvedHrs += entry.hours;
                        outerWrapper.pendingHrs += entry.hours;
                    } else if(entry.status == 'Rejected') {
                        outerWrapper.rejectedHrs += entry.hours;
                        outerWrapper.pendingHrs += entry.hours;
                    }
                    
                    String key = entry.projectId+'-'+entry.taskId+'-'+entry.payrollItem+'-'+entry.isBillable+'-'+entry.locationId;
                    if(!uniqueKeySet.contains(keyVal))
                        uniqueKeySet.add(keyVal);
                    
                    // For date based sorting on project related info display
                    if(!dateEntryForSort.containsKey(entry.dateVal))
                        dateEntryForSort.put(entry.dateVal,new List<TimeCardDayDomain.DayEntries>{entry});
                    else
                        dateEntryForSort.get(entry.dateVal).add(entry);
                    
                }
                
                // Display project related time entries sort by date
                datesToSort.addAll(dateEntryForSort.keySet());
                datesToSort.sort();
                List<TimeCardDayDomain.DayEntries> orderedList = new List<TimeCardDayDomain.DayEntries>();
                
                for(Date dt : datesToSort) {
                    if(dateEntryForSort.containsKey(dt))
                        orderedList.addAll(dateEntryForSort.get(dt));
                }
                outerWrapper.entries = orderedList;
                
            }else {
                outerWrapper.pendingHrs = 0;
                outerWrapper.approvedHrs = 0;
                outerWrapper.rejectedHrs = 0;
                outerWrapper.entries = new List<TimeCardDayDomain.DayEntries>();
            }
            
            if(!insIdprojectEntries.containsKey(outerWrapper.instructorId))
                insIdprojectEntries.put(outerWrapper.instructorId,new List<TimeCardDayDomain.ProjectBasedEntries>{outerWrapper});
            else
                insIdprojectEntries.get(outerWrapper.instructorId).add(outerWrapper);
        }
        
        return insIdprojectEntries;
    }
    
    /*******************************************************************
    - Mobile Approval Page contact filter formation
    - Added by NS on June 18 2018
    ********************************************************************/
    public static List<Contact> approvalContactFilterFormation(List<AcctSeed__Time_Card_Line__c> timeCardLines,List<AcctSeed__Time_Card_Day__c> timeCardDays){
        
        Set<Id> contactIds = new Set<Id>();
        
        List<Contact> contactInfo = new List<Contact>();
        
        if(timeCardLines.size() > 0) {
            for(AcctSeed__Time_Card_Line__c line : timeCardLines){
            
                if(!contactIds.contains(line.AcctSeed__Time_Card__r.Intructor__c)) {
                    contactIds.add(line.AcctSeed__Time_Card__r.Intructor__c);
                    contactInfo.add(new Contact(Id = line.AcctSeed__Time_Card__r.Intructor__c, LastName = line.AcctSeed__Time_Card__r.Intructor__r.Name));
                }
            }
        }
        
        if(timeCardDays.size() > 0){
            for(AcctSeed__Time_Card_Day__c day : timeCardDays){
            
                if(!contactIds.contains(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)) {
                    contactIds.add(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
                    contactInfo.add(new Contact(Id = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, LastName = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name));
                }
            }
        }
        
        return contactInfo;
    }
    
    /*********************************************************************************
    - Mobile Approval Page Summary related information formation
    - Added by NS on June 27 2018
    *********************************************************************************/
    public static TimeCardDayDomain.Approval_SemiMonthlyWrapper MobileApproval_SemiMonthlyFormation(List<AcctSeed__Time_Card_Day__c> timeCardDays,List<Date> monthlyDates){
    
        TimeCardDayDomain.Approval_SemiMonthlyWrapper summaryInfo = new TimeCardDayDomain.Approval_SemiMonthlyWrapper();
        summaryInfo.contactFilters = approvalContactFilterFormation(new List<AcctSeed__Time_Card_Line__c>(),timeCardDays);
        summaryInfo.dateSummaryDetailMap = mobileSemiMonthly_SummaryFormation(timeCardDays,monthlyDates);
        
        return summaryInfo;
    }
    
    /****************************************************************************
    - Semi Monthly Summary formation from day entries
    - Added by NS on June 27 2018 
    *****************************************************************************/
    public static Map<String,List<TimeCardDayDomain.TimeDaySummary>> mobileSemiMonthly_SummaryFormation(List<AcctSeed__Time_Card_Day__c> timeCardDays,List<Date> daysList){
        Map<String,List<TimeCardDayDomain.TimeDaySummary>> insIdSummaryMap = new Map<String,List<TimeCardDayDomain.TimeDaySummary>>();
        
        Map<Id,Map<Date,Decimal>> insIdDateHRsMap = new Map<Id,Map<Date,Decimal>>();
        
        Set<Date> dates = new Set<Date>();
        dates.addAll(daysList);
        
        Set<Date> entryDates = new Set<Date>();
        
        for(AcctSeed__Time_Card_Day__c td : timeCardDays) {
            Id insId = td.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
            
            if(!insIdDateHRsMap.containsKey(insId)){
                insIdDateHRsMap.put(insId,new Map<Date,Decimal>{td.AcctSeed__Date__c => td.Total_Hours_Before_Approved__c});
            } else if(insIdDateHRsMap.containsKey(insId)){
                
                if(!insIdDateHRsMap.get(insId).containsKey(td.AcctSeed__Date__c)){
                    insIdDateHRsMap.get(insId).put(td.AcctSeed__Date__c,td.Total_Hours_Before_Approved__c);
                }else {
                    insIdDateHRsMap.get(insId).put(td.AcctSeed__Date__c,insIdDateHRsMap.get(insId).get(td.AcctSeed__Date__c) + td.Total_Hours_Before_Approved__c);
                }
            } 
            
            entryDates.add(td.AcctSeed__Date__c);  
        }
        
        system.debug(':::::::insIdDateHRsMap::::::::::'+insIdDateHRsMap);
        
        if(insIdDateHRsMap.size() > 0) {
        
            for(Id insId : insIdDateHRsMap.keySet()){
                
                for(Date dt : daysList){
                    TimeCardDayDomain.TimeDaySummary daySum = new TimeCardDayDomain.TimeDaySummary();
                    if(insIdDateHRsMap.get(insId).containsKey(dt)){
                        daySum.entryDate = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2];
                        daySum.Hours = insIdDateHRsMap.get(insId).get(dt);
                    }else {
                        daySum.entryDate = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2];
                        daySum.Hours = 0;
                    }
                    
                    daySum.dayType = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0)).format('EEE').toUpperCase();
                    
                    if(!insIdSummaryMap.containsKey(insId))
                        insIdSummaryMap.put(insId,new List<TimeCardDayDomain.TimeDaySummary>{daySum});
                    else
                        insIdSummaryMap.get(insId).add(daySum);
                }
            }
        }else {
            for(Date dt : daysList){
                TimeCardDayDomain.TimeDaySummary daySum = new TimeCardDayDomain.TimeDaySummary();
                daySum.entryDate = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2];
                daySum.Hours = 0;
                daySum.dayType = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0)).format('EEE').toUpperCase();
                
                if(!insIdSummaryMap.containsKey(''))
                    insIdSummaryMap.put('',new List<TimeCardDayDomain.TimeDaySummary>{daySum});
                else
                    insIdSummaryMap.get('').add(daySum);
            }
        }
        
        return insIdSummaryMap;
    
    }
    
    /***************
        - Created by HL on Jul 30 2019
        - For Audit Trail Report information formation
        - W-002110 : Timekeeping Audit Trail Reports
    ***************/
    
    public static List<TimeCardDayDomain.TCDHistoryReport> getTCDHistoryRecs(List<AcctSeed__Time_Card_Day__History> tcdHistoryRecs,  Map<String, String> fieldAPINameAndLabel, Map<String, User> userIdAndRec, String selectedField){
    
        List<TimeCardDayDomain.TCDHistoryReport> reportList = new List<TimeCardDayDomain.TCDHistoryReport>();
        
        for(AcctSeed__Time_Card_Day__History h : tcdHistoryRecs){
            
            if((String.isNotBlank(selectedField) && (selectedField ==  h.Field)) || String.isBlank(selectedField)){
                TimeCardDayDomain.TCDHistoryReport report = new TimeCardDayDomain.TCDHistoryReport();
                
                String fieldAPIName = h.Field;
                String fieldLabel = (fieldAPINameAndLabel.containsKey(fieldAPIName.toLowerCase())) ? fieldAPINameAndLabel.get(fieldAPIName.toLowerCase()) : '';
                
                String oldValue = '';
                String newValue = '';
                if(fieldAPIName == 'Approved_Date__c' || fieldAPIName == 'AcctSeed__Date__c' || fieldAPIName == 'Submitted_Date__c'){
                    
                    if(String.valueOf(h.OldValue) != NULL && String.valueOf(h.OldValue) != ''){
                        
                        String oldDateStr = String.valueOf(h.OldValue).split(' ')[0];
                        oldValue = oldDateStr.split('-')[1]+'/'+oldDateStr.split('-')[2]+'/'+oldDateStr.split('-')[0];
                    }else{
                        oldValue = String.valueOf(h.OldValue);
                    }
                    
                    if(String.valueOf(h.NewValue) != NULL && String.valueOf(h.NewValue) != ''){
                        
                        String newDateStr = String.valueOf(h.NewValue).split(' ')[0];
                        newValue = newDateStr.split('-')[1]+'/'+newDateStr.split('-')[2]+'/'+newDateStr.split('-')[0];
                    }else{
                        newValue = String.valueOf(h.NewValue);
                    }
                    
                }else if(fieldAPIName == 'Approved_by__c'){
                    
                    if(String.valueOf(h.OldValue) != NULL && String.valueOf(h.OldValue) != ''){
                        
                        String oldUserId = String.valueOf(h.OldValue);
                        
                        if(oldUserId.contains('005')){
                            oldValue = (userIdAndRec != NULL && userIdAndRec.size() > 0 && userIdAndRec.containsKey(oldUserId)) ? userIdAndRec.get(oldUserId).Name : '';
                        }else{
                            oldValue = String.valueOf(h.OldValue);
                        }
                    }else{
                        oldValue = String.valueOf(h.OldValue);
                    }
                    
                    if(String.valueOf(h.NewValue) != NULL && String.valueOf(h.NewValue) != ''){
                        
                        String newUserId = String.valueOf(h.NewValue);
                        
                        if(newUserId.contains('005')){
                            newValue = (userIdAndRec != NULL && userIdAndRec.size() > 0 && userIdAndRec.containsKey(newUserId)) ? userIdAndRec.get(newUserId).Name : '';
                        }else{
                            newValue = String.valueOf(h.NewValue);
                        }
                    }else{
                        newValue = String.valueOf(h.NewValue);
                    }        
                }else{
                    
                    oldValue = String.valueOf(h.OldValue);
                    newValue = String.valueOf(h.NewValue);
                }
                report.dateAndTime = h.CreatedDate.format('MM/dd/yyyy HH:mm:ss a');
                report.createdDate = h.CreatedDate;
                report.byUser = h.CreatedBy.Name;
                report.fieldEdited = fieldLabel;
                report.oldValue = oldValue;
                report.newValue = newValue;
                report.contactName = String.valueOf(h.Parent.Instructor_Name__c);
                report.project = h.Parent.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name;
                report.projectTask = h.Parent.Project_Task_Name__c;
                report.tclName = h.Parent.AcctSeed__Time_Card_Line__r.Name;
                reportList.add(report);
            }
        }
        return reportList;
    }
    
    /***************
        - Created by Siva Prasanth K.T on April 26 2024
        - For Audit Trail Report information formation
        - W-008032 : Timekeeping Audit Trail Reports
    ***************/
    public static List<TimeCardDayDomain.TCDHistoryReport> getTCLHistoryRecs(List<AcctSeed__Time_Card_Line__History> tclHistoryRecs,  Map<String, String> fieldAPINameAndLabel, Map<String, User> userIdAndRec,String selectedField){
        List<TimeCardDayDomain.TCDHistoryReport> reportList = new List<TimeCardDayDomain.TCDHistoryReport>();
        
        for(AcctSeed__Time_Card_Line__History h : tclHistoryRecs){
            if((String.isNotBlank(selectedField) && (selectedField ==  h.Field)) || String.isBlank(selectedField)){
                
                TimeCardDayDomain.TCDHistoryReport report = new TimeCardDayDomain.TCDHistoryReport();
                
                String fieldAPIName = h.Field;
                String fieldLabel = (fieldAPINameAndLabel.containsKey(fieldAPIName.toLowerCase())) ? fieldAPINameAndLabel.get(fieldAPIName.toLowerCase()) : '';
                
                String oldValue = '';
                String newValue = '';
                
                if(fieldAPIName == 'ApprovedTime__c'){
                    
                    if(String.valueOf(h.OldValue) != NULL && String.valueOf(h.OldValue) != ''){
                        String oldDateStr = String.valueOf(h.OldValue).split(' ')[0];
                        oldValue = oldDateStr.split('-')[1]+'/'+oldDateStr.split('-')[2]+'/'+oldDateStr.split('-')[0];
                    }else{
                        oldValue = String.valueOf(h.OldValue);
                    }
                    
                    if(String.valueOf(h.NewValue) != NULL && String.valueOf(h.NewValue) != ''){
                        String newDateStr = String.valueOf(h.NewValue).split(' ')[0];
                        newValue = newDateStr.split('-')[1]+'/'+newDateStr.split('-')[2]+'/'+newDateStr.split('-')[0];
                    }else{
                        newValue = String.valueOf(h.NewValue);
                    }
                    
                }else if(fieldAPIName == 'Approved_by__c'){
                    
                    if(String.valueOf(h.OldValue) != NULL && String.valueOf(h.OldValue) != ''){
                        String oldUserId = String.valueOf(h.OldValue);
                        
                        if(oldUserId.contains('005')){
                            oldValue = (userIdAndRec != NULL && userIdAndRec.size() > 0 && userIdAndRec.containsKey(oldUserId)) ? userIdAndRec.get(oldUserId).Name : '';
                        }else{
                            oldValue = String.valueOf(h.OldValue);
                        }
                    }else{
                        oldValue = String.valueOf(h.OldValue);
                    }
                    
                    if(String.valueOf(h.NewValue) != NULL && String.valueOf(h.NewValue) != ''){
                        String newUserId = String.valueOf(h.NewValue);
                        
                        if(newUserId.contains('005')){
                            newValue = (userIdAndRec != NULL && userIdAndRec.size() > 0 && userIdAndRec.containsKey(newUserId)) ? userIdAndRec.get(newUserId).Name : '';
                        }else{
                            newValue = String.valueOf(h.NewValue);
                        }
                    }else{
                        newValue = String.valueOf(h.NewValue);
                    }        
                }else{
                    
                    oldValue = String.valueOf(h.OldValue);
                    newValue = String.valueOf(h.NewValue);
                }
                report.dateAndTime = h.CreatedDate.format('MM/dd/yyyy HH:mm:ss a');
                report.createdDate = h.CreatedDate;
                report.byUser = h.CreatedBy.Name;
                report.fieldEdited = fieldLabel;
                report.oldValue = oldValue;
                report.newValue = newValue;
                report.contactName = String.valueOf(h.parent.AcctSeed__Time_Card__r.Intructor__r.Name);
                report.project = h.Parent.AcctSeed__Project__r.Name;
                report.projectTask = h.Parent.AcctSeed__Project_Task__r.Name;
                report.tclName = h.Parent.Name;
                reportList.add(report);
            }
        }
        return reportList;
    }
    
    //The follwoing methods used for Admin Time Entry Instructor component usage
    
     /******************************************************************************************
    - Method to form the existing TCD information as wrapper to display in cmp
    - Added by NS on OCT 18 2019 for Admin Time Entry Instructor cmp
    ******************************************************************************************/
    public static TimeCardDayDomain.InstructorTimeEntryDetails admin_InstructorViewDayDetailsFormation(Date startDate,Date endDate,String studentNames,String contactId,List<AcctSeed__Time_Card_Line__c> lineDetails,List<Accounting_Seed_Time_Snapshot__c> snapshot,List<AcctSeed__Project_Task__c> taskRecords,List<Contact_Assignments__c> caRecord,Map<Id,Integer> taskIdTimeCount,Map<Id,String> taskIdTimeMap,List<Contact_Assignments__History> caHistory,List<AcctSeed__Cost_Rates__c> oldCRRecord,List<Contact_Assignments__c> studentCAs,Map<Id,List<Attendance__c>> stuAttendanceMap,List<Planned_Days_Off__c> daysOffList,Set<Date> holidayDates,Decimal totalHrs){
        
        TimeCardDayDomain.InstructorTimeEntryDetails detail = new TimeCardDayDomain.InstructorTimeEntryDetails();
        
        detail.rowDetails = instructorTimeEntryRowWrapperFormation(startDate,endDate,studentNames,contactId,lineDetails,snapshot,taskRecords,caRecord,taskIdTimeCount,taskIdTimeMap,caHistory,oldCRRecord,studentCAs,stuAttendanceMap,daysOffList,holidayDates);
        detail.rowDetails.defaultCostRateRateType = taskRecords[0].AcctSeed__Project__r.Default_Cost_Rate_Rate_Type__c;
        detail.taskRecords = taskRecords;
        
        //Contact assignment filtering
        Map<Id,Id> taskIdConAssignId = new Map<Id,Id>();
        Map<Id,Id> tempTaskIdCAIdMap = new Map<Id,Id>();
        
        Map<Id,AcctSeed__Cost_Rates__c> taskIdCostRateMap = new Map<Id,AcctSeed__Cost_Rates__c>();
        Map<Id,AcctSeed__Cost_Rates__c> tempTaskIdCostRateMap = new Map<Id,AcctSeed__Cost_Rates__c>();
        List<String> uniqueKeys = new List<String>();
        
        for(Contact_Assignments__c ca : caRecord){
        
            if(!tempTaskIdCAIdMap.containsKey(ca.Project_Task__c)){
                tempTaskIdCAIdMap.put(ca.Project_Task__c,ca.Id);
            }
            
            //TaskId Cost Rate formation
            if(!tempTaskIdCostRateMap.containsKey(ca.Project_Task__c) && ca.Rate_Card_Rate__c != null){
            
                AcctSeed__Cost_Rates__c crRecord = new AcctSeed__Cost_Rates__c();
                crRecord.Id = ca.Rate_Card_Rate__c;
                crRecord.Payroll_Item__c = ca.Rate_Card_Rate__r.Payroll_Item__c;
                crRecord.Non_Billable_Payroll_Item__c = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                
                tempTaskIdCostRateMap.put(ca.Project_Task__c,crRecord);
            }
        }
        
        Id langTrainingTaskId;
                
        for(AcctSeed__Project_Task__c task : taskRecords){
            
            if(task.Project_Task_Type__c == 'Language Training'){
                langTrainingTaskId = task.Id;
            }
        
            //For Contact Assignment 
            if(tempTaskIdCAIdMap.containsKey(task.Id)){
                if(!taskIdConAssignId.containsKey(task.Id)){
                    taskIdConAssignId.put(task.Id,tempTaskIdCAIdMap.get(task.Id));
                }
            }else if(task.Project_Task_Type__c == 'Fringe') {
                
                if(!taskIdConAssignId.containsKey(task.Id)){
                    taskIdConAssignId.put(task.Id,tempTaskIdCAIdMap.get(langTrainingTaskId));
                }
                
            }else if(tempTaskIdCAIdMap.containsKey(task.Parent_Project_Task__c)){
                if(!taskIdConAssignId.containsKey(task.Id)){
                    taskIdConAssignId.put(task.Id,tempTaskIdCAIdMap.get(task.Parent_Project_Task__c));
                }
            }
            
            //For Cost Rate
            if(tempTaskIdCostRateMap.containsKey(task.Id)){
                if(!taskIdCostRateMap.containsKey(task.Id)){
                    taskIdCostRateMap.put(task.Id,tempTaskIdCostRateMap.get(task.Id));
                }
                
            }else if(task.Project_Task_Type__c == 'Fringe'){
                if(!taskIdCostRateMap.containsKey(task.Id)){
                    taskIdCostRateMap.put(task.Id,tempTaskIdCostRateMap.get(langTrainingTaskId));
                }
                
            }else if(tempTaskIdCostRateMap.containsKey(task.Parent_Project_Task__c)){
                if(!taskIdCostRateMap.containsKey(task.Id)){
                    taskIdCostRateMap.put(task.Id,tempTaskIdCostRateMap.get(task.Parent_Project_Task__c));
                }
            }
        }
        
        system.debug('::::::::taskIdConAssignId:::::'+taskIdConAssignId);
        system.debug('::::::::taskIdCostRateMap:::::'+taskIdCostRateMap);
        
        //unique key set formation
        for(AcctSeed__Time_Card_Line__c line : lineDetails){
            
            String key = line.AcctSeed__Project__c+'~'+line.AcctSeed__Project_Task__c+'~'+line.Payroll_Item__c+'~'+line.AcctSeed__Billable__c+'~'+line.Location__c;
            uniqueKeys.add(key);
        }
        
        detail.taskIdCAIdMap = taskIdConAssignId;
        detail.taskIdCostRateMap = taskIdCostRateMap;
        detail.timeList = ScheduleCmpLightningController.getPickListValues('AcctSeed__Time_Card_Day__c','Start_Time1__c');
        detail.uniqueKeySet = uniqueKeys;
        
        //To get selected week is older the 3 weeks from current week
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        Date olderWeekStart = currStart.addDays(-14);
        Date olderWeekEnd = currEnd.addDays(-14);
        
        if(olderWeekStart < startDate && olderWeekEnd < endDate){
            detail.isWeekIs3weeksOlder = false;
        }else {
            detail.isWeekIs3weeksOlder = false;
        }
        
        detail.totalHours = totalHrs;
        detail.timeCardId = (lineDetails != null && lineDetails.size() > 0) ? lineDetails[0].AcctSeed__Time_Card__c : null;
        
        return detail;
    }
    
    
    public static TimeCardDayCommunityDomain.InstructorRowDetails instructorTimeEntryRowWrapperFormation(Date startDate,Date endDate,String studentNames,String contactId,List<AcctSeed__Time_Card_Line__c> lineDetails,List<Accounting_Seed_Time_Snapshot__c> snapshot,List<AcctSeed__Project_Task__c> taskRecords,List<Contact_Assignments__c> caRecord,Map<Id,Integer> taskIdTimeCount,Map<Id,String> taskIdTimeMap,List<Contact_Assignments__History> caHistory,List<AcctSeed__Cost_Rates__c> oldCRRecord,List<Contact_Assignments__c> studentCAs,Map<Id,List<Attendance__c>> stuAttendanceMap,List<Planned_Days_Off__c> daysOffList,Set<Date> holidayDates){
        
        TimeCardDayCommunityDomain.InstructorRowDetails weekDetails = new TimeCardDayCommunityDomain.InstructorRowDetails();
        
        weekDetails.entries = instructorDayRowFormation(startDate,endDate,studentNames,lineDetails,taskRecords,caRecord,taskIdTimeCount,taskIdTimeMap,caHistory,oldCRRecord);
        weekDetails.notes = notesFormation_Instructor(snapshot);
        
        Date st = startDate;
        Date ed = endDate;
        
        List<TimeCardDayCommunityDomain.WeekRangeValues> weekDates = new List<TimeCardDayCommunityDomain.WeekRangeValues>();
        
        while(st <= ed){
            TimeCardDayCommunityDomain.WeekRangeValues wkVal = new TimeCardDayCommunityDomain.WeekRangeValues();
            wkVal.dateValue = String.valueOf(st).split('-')[1]+'/'+String.valueOf(st).split('-')[2]+'/'+String.valueOf(st).split('-')[0];
            DateTime todayVal = DateTime.newInstance(st, Time.newInstance(0, 0, 0, 0));
            wkVal.dayVal = todayVal.format('EEE').toUppercase();
            
            weekDates.add(wkVal);
            
            st = st.addDays(1);
        }
        
        weekDetails.weekDates = weekDates;
        
        List<TimeCardDayCommunityDomain.DayEntries> entriesList = new List<TimeCardDayCommunityDomain.DayEntries>();
        for(TimeCardDayCommunityDomain.InstructorDayDetails row : weekDetails.entries){
            if(row.dayEntries != null && row.dayEntries.size() > 0) {
                entriesList.addAll(row.dayEntries);
            }
        }
        
        //Student time entry content formation
        weekDetails.studentEntries = studentTimeEntriesFormation(studentCAs,startDate,endDate,stuAttendanceMap);
        
        
        if(daysOffList.size() > 0){
            
            Map<Date,TimeCardDayCommunityDomain.PlannedDaysOff> dateDaysOffValues = new Map<Date,TimeCardDayCommunityDomain.PlannedDaysOff>();
            
            for(Planned_Days_Off__c off : daysOffList){
                TimeCardDayCommunityDomain.PlannedDaysOff daysOff = new TimeCardDayCommunityDomain.PlannedDaysOff();
                daysOff.daysOffId = off.Id;
                daysOff.daysOffDate = String.valueOf(off.Date__c).split('-')[1]+'/'+String.valueOf(off.Date__c).split('-')[2]+'/'+String.valueOf(off.Date__c).split('-')[0];
                daysOff.contactName = off.Contact__r.Name;
                daysOff.description = off.Description__c;
                
                if(!dateDaysOffValues.containsKey(off.Date__c)){
                    dateDaysOffValues.put(off.Date__c,daysOff);
                }
            }
            
            weekDetails.dateDaysOffValues = dateDaysOffValues;
        }
        weekDetails.dliWLTHolidays = new List<Date>();
        weekDetails.dliWLTHolidays.addAll(holidayDates);
        
        weekDetails.federalHolidays = HolidayService.getHolidaysWithRecurrence(startDate,endDate);
        
        return weekDetails;
    }
    
     /***************************************************************************************
     - Instructor Time Entry Day rows formation 
    ****************************************************************************************/
    public static List<TimeCardDayCommunityDomain.InstructorDayDetails> instructorDayRowFormation(Date st,Date ed,String studentNames,List<AcctSeed__Time_Card_Line__c> timeCardLines,List<AcctSeed__Project_Task__c> taskRecords,List<Contact_Assignments__c> caRecord,Map<Id,Integer> taskIdTimeCount,Map<Id,String> taskIdTimeMap,List<Contact_Assignments__History> caHistory,List<AcctSeed__Cost_Rates__c> oldCRRecord){
        
        Map<String,Map<Date,TimeCardDayCommunityDomain.DayEntries>> chargeCodedateEntryMap = new Map<String,Map<Date,TimeCardDayCommunityDomain.DayEntries>>();
        List<TimeCardDayCommunityDomain.InstructorDayDetails> dayDetailsList = new List<TimeCardDayCommunityDomain.InstructorDayDetails>();
        Map<String,String> chargeCodePayrollMap = new Map<String,String>();
        Map<Date,TimeCardDayCommunityDomain.DayEntries> dateEntryMap = new Map<Date,TimeCardDayCommunityDomain.DayEntries>();
        
        Date startDt = st;
        Date endDt = ed;
        
        //check selected week range is before last week
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        
        while(startDt <= endDt){
        
            TimeCardDayCommunityDomain.DayEntries day = new TimeCardDayCommunityDomain.DayEntries();
            day.dateVal = startDt;
            
            //date formatting for display
            day.displayDate = String.valueOf(startDt).split('-')[1]+'/'+String.valueOf(startDt).split('-')[2]+'/'+String.valueOf(startDt).split('-')[0];
            
            //date type finding - mon, tues, ...
            DateTime currentDt = DateTime.newInstance(startDt, Time.newInstance(0, 0, 0, 0));
            day.dayType = currentDt.format('EEEE');
            System.debug('stDate'+day.payrollItem);
            dateEntryMap.put(startDt,day);
            startDt = startDt.addDays(1);
        }
        
        Map<Date,Boolean> dateLateCancellationMap = new Map<Date,Boolean>();
        
        Map<Id,AcctSeed__Project_Task__c> taskIdTaskRecMap = new Map<Id,AcctSeed__Project_Task__c>();
        
        for(AcctSeed__Project_Task__c task : taskRecords){
            taskIdTaskRecMap.put(task.Id,task);
        }
        
        system.debug(':::::::::::::dateEntryMap:::::::::'+dateEntryMap);
     
        //Existing records based date & day wrapper map formation
        for(AcctSeed__Time_Card_Line__c line : timeCardLines) {
            
            String code = line.AcctSeed__Project__c+'~'+line.AcctSeed__Project_Task__c+'~'+line.Payroll_Item__c+'~'+line.AcctSeed__Billable__c+'~'+line.Location__c;
            
            Map<Date,TimeCardDayCommunityDomain.DayEntries> dayMap = new Map<Date,TimeCardDayCommunityDomain.DayEntries>();
            
            if(line.AcctSeed__Time_Card_Days__r != null || line.AcctSeed__Time_Card_Days__r.size() > 0) {
                
                for(AcctSeed__Time_Card_Day__c day : line.AcctSeed__Time_Card_Days__r) {
                    TimeCardDayCommunityDomain.DayEntries dayWrap = new TimeCardDayCommunityDomain.DayEntries();
                    
                    dayWrap.dayHours = String.valueOf(day.Total_Hours_Before_Approved__c);
                    if(!dayWrap.dayHours.contains('.')){
                        dayWrap.dayHours = dayWrap.dayHours+'.00';
                    }
                    
                    dayWrap.dayId = day.Id;
                    dayWrap.lineId = day.AcctSeed__Time_Card_Line__c;
                    dayWrap.projectId = line.AcctSeed__Project_Task__r.AcctSeed__Project__c;
                    dayWrap.taskId = line.AcctSeed__Project_Task__c;
                    dayWrap.locationId = line.Location__c;
                    dayWrap.isBillable = line.AcctSeed__Billable__c;
                    dayWrap.payrollItem = line.Payroll_Item__c;
                    dayWrap.status = day.Status__c;
                    dayWrap.dateVal = day.AcctSeed__Date__c;
                    dayWrap.comments = day.AcctSeed__Internal_Comment__c;
                    dayWrap.costrateId = line.Labor_Cost_Rate__c;
                    dayWrap.contactAssignid = line.Contact_Assignment__c;
                    dayWrap.sequenceNumber = Integer.valueOf(line.Sequence_Number__c);
                    dayWrap.cancellationReason = day.Cancellation_Reason__c;
                    dayWrap.startTime1 = day.Start_Time1__c;
                    dayWrap.endTime1 = day.End_Time1__c;
                    dayWrap.locationId = line.Location__c;
                    dayWrap.TaskType = line.AcctSeed__Project_Task__r.Project_Task_Type__c;
                    dayWrap.lateCancellation = day.Late_Cancellation__c;
                    dayWrap.studentApprovalStatus = day.Student_Approval_Status__c;
                    dayWrap.ProjectName = line.AcctSeed__Project_Task__r.AcctSeed__Project__r.DLS_Class__c;
                    dayWrap.TaskName = line.AcctSeed__Project_Task__r.Name;
                    dayWrap.recallReason = day.Recall_Reason__c;                    
                    
                    if(line.AcctSeed__Project_Task__r.Name == 'Language Training- Preparation' && line.AcctSeed__Project_Task__r.Project_Task_Type__c == 'Preparation time') {
                        dayWrap.startTime2 = day.Start_Time2__c;
                        dayWrap.endTime2 = day.End_Time2__c;
                    }
                    
                    dayWrap.isNew = false;
                    dayWrap.isUpdated = false;
                    dayWrap.displayDate = String.valueOf(day.AcctSeed__Date__c).split('-')[1]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[2]+'/'+String.valueOf(day.AcctSeed__Date__c).split('-')[0];
                    
                    DateTime actualDt = DateTime.newInstance(day.AcctSeed__Date__c, Time.newInstance(0, 0, 0, 0));
                    dayWrap.dayType = actualDt.format('EEEE');
                    
                    //For TCL based input disable action
                    dayWrap.isCompleted = line.Completed__c ? line.Completed__c : false;
                    
                    dayWrap.hideFromStudent = day.Hide_From_Student__c;
                    
                    dayWrap.isHrsDisabled = false;
                    
                    if(day.Late_Cancellation__c){
                        dateLateCancellationMap.put(day.AcctSeed__Date__c,day.Late_Cancellation__c);
                    }
                    
                    if(!dayMap.containsKey(day.AcctSeed__Date__c)) {
                        dayMap.put(day.AcctSeed__Date__c,dayWrap);
                    }
                    
                }
            }
            
            system.debug('::::::::dayMap:::::'+dayMap);
            
            Map<Date,TimeCardDayCommunityDomain.DayEntries> tempMap = new Map<Date,TimeCardDayCommunityDomain.DayEntries>();
            tempMap = dateEntryMap.clone();
            
            tempMap.putAll(dayMap);
            
            if(!chargeCodedateEntryMap.containsKey(code)){
                chargeCodedateEntryMap.put(code,tempMap);
            }
            
            if(!chargeCodePayrollMap.containsKey(code)){
                chargeCodePayrollMap.put(code,line.Payroll_Item__c);
            }
        }
        
        system.debug(':::::::chargeCodedateEntryMap::::::'+chargeCodedateEntryMap);
        Integer sequenceNum = 0;
        
        Map<Integer,TimeCardDayCommunityDomain.InstructorDayDetails> seqNum_DetailsMap = new Map<Integer,TimeCardDayCommunityDomain.InstructorDayDetails>();
        
        List<TimeCardDayCommunityDomain.InstructorDayDetails> tempDetailsList = new List<TimeCardDayCommunityDomain.InstructorDayDetails>();
        List<Integer> seqNumbers = new List<Integer>();
        
        system.debug(':::::::::::caHistory:::::::'+caHistory);
        system.debug(':::::::::::caRecord:::::::'+caRecord);
        
        for(String key : chargeCodedateEntryMap.keySet()){
        
            TimeCardDayCommunityDomain.InstructorDayDetails detail = new TimeCardDayCommunityDomain.InstructorDayDetails();
            
            String taskId = key.split('~')[1];
            
            AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c();
            
            if(taskIdTaskRecMap.containsKey(taskId)){
                task = taskIdTaskRecMap.get(taskId);
            }
            
            
            //detail.chargeCode = projectName+' / <b>'+task.Name+'</b> / '+studentNames+' / '+task.AcctSeed__Project__r.Training_Location__r.Name;
            detail.chargeCode1 = task.AcctSeed__Project__r.DLS_Class__c+' / <b>'+task.Name+'</b> / ';
            //detail.chargeCode2 = studentNames+' / '+task.AcctSeed__Project__r.Training_Location__r.Name;
            detail.totalHours = '0.00';
            detail.taskName = task.Name; //Added By Dhinesh - 17/10/2023
            detail.dayEntries = new List<TimeCardDayCommunityDomain.DayEntries>();
            
            if(task.Project_Task_Type__c == 'Language Training') {
                if(sequenceNum == 0){
                    detail.sequenceNumber = 1;    
                }else {
                    detail.sequenceNumber = sequenceNum + 1;
                }
                
            }else if(task.Project_Task_Type__c == 'Preparation time'){
                if(sequenceNum == 1){
                    detail.sequenceNumber = 2;    
                }else {
                    detail.sequenceNumber = sequenceNum + 1;
                }
                
            }else if(task.Project_Task_Type__c == 'Language Testing') {
                if(sequenceNum == 2){
                    detail.sequenceNumber = 3;    
                }else {
                    detail.sequenceNumber = sequenceNum + 1;
                }
                
            }else {
                detail.sequenceNumber = sequenceNum + 1;
            }
            
            sequenceNum = sequenceNum + detail.sequenceNumber;
            detail.taskType = task.Project_Task_Type__c;
            detail.isNewRow = false;
            
            Decimal totalHr = 0.00;
            
            String payRoll = '';
            String bill = '';
            
            for(Date dt : chargeCodedateEntryMap.get(key).keySet()){
                
                TimeCardDayCommunityDomain.DayEntries day = chargeCodedateEntryMap.get(key).get(dt).clone();
                
                if(day.dayId == null){
                    
                    day.projectId = task.AcctSeed__Project__c;
                    day.taskId = task.Id;
                    day.locationId = task.AcctSeed__Project__r.Training_Location__c;
                    day.isBillable = task.Billable__c;
                    day.sequenceNumber = detail.sequenceNumber;
                    day.isNew = true;
                    day.isUpdated = false;
                    day.TaskType = detail.taskType;
                    day.lateCancellation = false;
                    day.TaskName = task.Name;
                    
                    day.isHrsDisabled = false;
                    day.showEditIcon = false;
                    day.showReverseIcon = false;
                    day.isCompleted = false;
                    day.hideFromStudent = false;
                    
                    //Payroll, CR values assigning
                    if(caHistory.size() == 0 || (caHistory.size() > 0 && caHistory[0].OldValue == null)){
                        if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c 
                            || task.Project_Task_Type__c == 'Fringe') && caRecord[0].Rate_Card_Rate__c != null){
                                
                            system.debug('::::::::if:::1::');                                
                                for(Contact_Assignments__c ca : caRecord){
                                    Date oralExamDate;
                                    if(ca.Oral_Exam_Date_Time__c != null){
                                        oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                                    }
                                    Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                                    if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                        day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                        day.contactAssignid = (Id) ca.Id;
                                        
                                        if(day.dayId == null){
                                            if(chargeCodePayrollMap.containsKey(key)){
                                                day.payrollItem = chargeCodePayrollMap.get(key);
                                            }
                                        }else{
                                            if(day.isBillable){
                                                day.payrollItem = ca.Rate_Card_Rate__r.Payroll_Item__c;
                                            }else {
                                                day.payrollItem = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                                            }
                                        }
                                    }
                                }                            
                        }
                    }else if(caHistory.size() > 0 && caRecord.size() > 0 
                            && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c || task.Project_Task_Type__c == 'Fringe')){
                        
                        system.debug('::::::::else:::1::');
                            
                        Date historyDate = Date.newInstance(caHistory[0].createdDate.year(),caHistory[0].createdDate.month(),caHistory[0].createdDate.day());
                        
                        system.debug('::::::dt:::::'+dt);
                        system.debug('::::::historyDate:::::'+historyDate);
                        
                        if(dt <= historyDate && caHistory[0].OldValue != null){
                            day.costrateId = (Id) caHistory[0].OldValue;
                            day.contactAssignid = (Id) caHistory[0].parentId;
                            
                            if(oldCRRecord.size() > 0 && oldCRRecord[0].Id == day.costrateId){
                                if(day.isBillable){
                                    day.payrollItem = oldCRRecord[0].Payroll_Item__c;
                                }else {
                                    day.payrollItem = oldCRRecord[0].Non_Billable_Payroll_Item__c;
                                }
                            }
                        }else {    //If the history date is older then populate current CR value
                            
                            system.debug('::::::::else:::2::');
                            
                            if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c
                                || task.Project_Task_Type__c == 'Fringe') && caRecord[0].Rate_Card_Rate__c != null){
                                
                                system.debug('::::inside::else:::::2::');
                                
                                for(Contact_Assignments__c ca : caRecord){
                                    Date oralExamDate;
                                    if(ca.Oral_Exam_Date_Time__c != null){
                                        oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                                    }
                                    Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                                    if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                        day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                        day.contactAssignid = (Id) ca.Id;
                                        
                                        if(day.isBillable){
                                            day.payrollItem = ca.Rate_Card_Rate__r.Payroll_Item__c;
                                        }else {
                                            day.payrollItem = ca.Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    //For Fringe Project Task get payroll item from project task
                    if(task.RecordType.DeveloperName == 'Cost' && task.Project_Task_Type__c == 'Fringe'){
                        day.payrollItem = task.Payroll_Item__c;
                    }
                    
                    if(dateLateCancellationMap.containsKey(dt) && task.Project_Task_Type__c == 'Preparation time'){
                        day.isHrsDisabled = true; 
                    }
                }
                
                if(day.hours != null){
                    totalHr += Decimal.valueOf(day.dayHours);
                }
                
                system.debug('payroll:::'+ day.payRollItem);
                /*if(String.isBlank(payRoll)){
                   payRoll = day.payRollItem;    
                }*/
                
                if(String.isBlank(bill)){
                    bill = day.isBillable == true ? 'Billable' : 'Non-Billable';    
                }
                
                //system.debug('::payRoll::::::bill::::'+payRoll+' '+bill);
                
                detail.dayEntries.add(day);
            }
            
            if(taskIdTimeCount.size() > 0){
                if(task.Project_Task_Type__c == 'Preparation time' && taskIdTimeCount.containsKey(task.Id)){
                    detail.timeRowCount = taskIdTimeCount.get(task.Id);
                    
                    if(taskIdTimeCount.get(task.Id) != 1 && taskIdTimeMap.containsKey(task.Id)){
                        detail.timeType = taskIdTimeMap.get(task.Id);
                    }else if(taskIdTimeCount.get(task.Id) == 1){
                        detail.timeType = 'Single';
                    }
                    
                }else if(task.Project_Task_Type__c != 'Preparation time'){
                    detail.timeRowCount = 1;
                    detail.timeType = 'AM';
                }
            }else {
                if(task.Project_Task_Type__c != 'Preparation time'){
                    detail.timeRowCount = 1;
                    detail.timeType = 'AM';
                    
                }else if(task.Project_Task_Type__c == 'Preparation time'){
                    detail.timeRowCount = 2;
                    detail.timeType = 'Both';
                }
            }
            
            //system.debug('::::::::studentNames::::'+studentNames+' '+payroll+' '+bill+' '+task.AcctSeed__Project__r.Training_Location__r.Name);
            
            if(chargeCodePayrollMap.containsKey(key)){//W-007660 - for fixing Payroll issues in ChargeCode2
                payRoll = chargeCodePayrollMap.get(key);
            }
            
            detail.chargeCode2 = studentNames+' / '+payRoll+' / '+bill+' / '+task.AcctSeed__Project__r.Training_Location__r.Name;
            
            detail.totalHours = String.valueOf(totalHr);
            
            tempDetailsList.add(detail);
        }
        
        system.debug(':::::::::tempDetailsList:::::'+tempDetailsList);
        
        //To display the row details in order 
        for(TimeCardDayCommunityDomain.InstructorDayDetails detail : tempDetailsList){
            if(!seqNum_DetailsMap.containsKey(detail.sequenceNumber)){
                seqNum_DetailsMap.put(detail.sequenceNumber,detail);
            }
            seqNumbers.add(detail.sequenceNumber);
        }
        
        seqNumbers.sort();
        for(Integer num : seqNumbers){
            if(seqNum_DetailsMap.containsKey(num)){
                dayDetailsList.add(seqNum_DetailsMap.get(num));
            }
        }
        
        return dayDetailsList;
    }
    
    //Student time entries table formation
    public static List<TimeCardDayCommunityDomain.StudentTimeDetail> studentTimeEntriesFormation(List<Contact_Assignments__c> studentCAs,Date st,Date ed,Map<Id,List<Attendance__c>> stuAttendanceMap){
        
        List<TimeCardDayCommunityDomain.StudentTimeDetail> studentEntries = new List<TimeCardDayCommunityDomain.StudentTimeDetail>();
        Map<Id,Map<Date,TimeCardDayCommunityDomain.StudentEntry>> stuIdDtEntryMap = new Map<Id,Map<Date,TimeCardDayCommunityDomain.StudentEntry>>();
        
        Date startDt = st;
        Date endDt = ed;
        
        //check for before last week if selected date range
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        Set<Date> weekDates = new Set<Date>();
        
        while(startDt <= endDt){
            weekDates.add(startDt);
            startDt = startDt.addDays(1);
        }
        
        for(Id key : stuAttendanceMap.keySet()){
            for(Attendance__c att : stuAttendanceMap.get(key)){
                TimeCardDayCommunityDomain.StudentEntry entry = new TimeCardDayCommunityDomain.StudentEntry();
                entry.dateVal = att.Date__c;
                
                DateTime attDate = DateTime.newInstance(att.Date__c, Time.newInstance(0, 0, 0, 0));
                entry.dayValue = attDate.format('EEEE');
                
                entry.displayDate = String.valueOf(att.Date__c).split('-')[1]+'/'+String.valueOf(att.Date__c).split('-')[2]+'/'+String.valueOf(att.Date__c).split('-')[0];
                
                entry.hours = String.valueOf(att.Duration__c);
                entry.attendanceId = att.Id;
                entry.eventId = att.Event__c;
                entry.instructorId = att.Instructor__c;
                entry.studentId = att.Student__c;
                entry.studentApprovalStatus = att.Student_Approval_Status__c;
                entry.dayId = att.Time_Card_Day__c;
                entry.isNew = false;
                entry.isUpdated = false;
                entry.rejectionReason = att.Rejection_Reason__c;
                entry.recallReason = att.Recall_Reason__c;
                entry.comments = att.Comments__c;
                entry.studentName = att.Student__r.Name;
                entry.attendance = att.Attendance__c;
                
                entry.isHrsDisabled = false;
                entry.showReverseIcon = false;
                entry.showEditIcon = false;
                
                if(att.Comments__c != null /*&& att.Time_Card_Day__r.Total_Hours_Before_Approved__c != att.Duration__c*/){
                    entry.displayNotesLink = 'true';
                }else {
                    entry.displayNotesLink = 'false';
                }
                
                if(!stuIdDtEntryMap.containsKey(att.Student__c)){
                    stuIdDtEntryMap.put(att.Student__c,new Map<Date,TimeCardDayCommunityDomain.StudentEntry>{att.Date__c => entry});
                }else {
                    stuIdDtEntryMap.get(att.Student__c).put(att.Date__c,entry);
                }
            }
        }
        
        for(Contact_Assignments__c ca : studentCAs){
            TimeCardDayCommunityDomain.StudentTimeDetail stuEntries = new TimeCardDayCommunityDomain.StudentTimeDetail();
            stuEntries.studentId = ca.Candidate_Name__c;
            stuEntries.studentName = ca.Candidate_Name__r.Name;
            stuEntries.entries = new List<TimeCardDayCommunityDomain.StudentEntry>();
            stuEntries.totalHours = '0.00';
            
            Decimal totalHrs = 0.00;
            
            for(Date dt : weekDates){
                if(stuIdDtEntryMap.containsKey(ca.Candidate_Name__c)) {
                    if(stuIdDtEntryMap.get(ca.Candidate_Name__c).containsKey(dt)) {
                    
                        totalHrs += Decimal.valueOf(stuIdDtEntryMap.get(ca.Candidate_Name__c).get(dt).hours);
                        
                        stuEntries.entries.add(stuIdDtEntryMap.get(ca.Candidate_Name__c).get(dt));
                        
                    }else {
                        TimeCardDayCommunityDomain.StudentEntry entry = new TimeCardDayCommunityDomain.StudentEntry();
                        entry.dateVal = dt;
                        
                        DateTime attDate = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0));
                        entry.dayValue = attDate.format('EEEE');
                        
                        entry.displayDate = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];
                        
                        entry.hours = '';
                        entry.attendanceId = null;
                        entry.eventId = null;
                        entry.instructorId = null;
                        entry.studentId = ca.Candidate_Name__c;
                        entry.studentApprovalStatus = '';
                        entry.dayId = null;
                        entry.isNew = true;
                        entry.isUpdated = false;
                       
                        entry.isHrsDisabled = false;
                        entry.showReverseIcon = false;
                        entry.showEditIcon = false;
                        entry.rejectionReason = '';
                        entry.recallReason = '';
                        entry.comments = '';
                        entry.studentName = ca.Candidate_Name__r.Name;
                        entry.displayNotesLink = 'false';
                       
                        stuEntries.entries.add(entry);
                    }
                }else {
                    TimeCardDayCommunityDomain.StudentEntry entry = new TimeCardDayCommunityDomain.StudentEntry();
                    entry.dateVal = dt;
                    
                    DateTime attDate = DateTime.newInstance(dt, Time.newInstance(0, 0, 0, 0));
                    entry.dayValue = attDate.format('EEEE');
                    
                    entry.displayDate = String.valueOf(dt).split('-')[1]+'/'+String.valueOf(dt).split('-')[2]+'/'+String.valueOf(dt).split('-')[0];
                    
                    entry.hours = '';
                    entry.attendanceId = null;
                    entry.eventId = null;
                    entry.instructorId = null;
                    entry.studentId = ca.Candidate_Name__c;
                    entry.studentApprovalStatus = '';
                    entry.dayId = null;
                    entry.isNew = true;
                    entry.isUpdated = false;
                    
                    entry.isHrsDisabled = false;
                    entry.showReverseIcon = false;
                    entry.showEditIcon = false;
                    entry.rejectionReason = '';
                    entry.recallReason = '';
                    entry.comments = '';
                    entry.studentName = ca.Candidate_Name__r.Name;
                    entry.displayNotesLink = 'false';
                    
                    stuEntries.entries.add(entry);
                }
            }
            
            stuEntries.totalHours = String.valueOf(totalHrs);
            
            studentEntries.add(stuEntries);
        }
        
        return studentEntries;
    }
    
    //Notes Wrapper formation
    public static List<TimeCardDayCommunityDomain.NotesDetails> notesFormation_Instructor(List<Accounting_Seed_Time_Snapshot__c> snapshotList){
        List<TimeCardDayCommunityDomain.NotesDetails> notesDetails = new List<TimeCardDayCommunityDomain.NotesDetails>();
        List<TimeCardDayCommunityDomain.NotesDetails> tempList = new List<TimeCardDayCommunityDomain.NotesDetails>();
        Map<String,List<TimeCardDayCommunityDomain.NotesDetails>> tempMap = new Map<String,List<TimeCardDayCommunityDomain.NotesDetails>>();
        
        
        for(Accounting_Seed_Time_Snapshot__c snapshot : snapshotList) {
            if(snapshot.Note_Type__c != null) {
                
                TimeCardDayCommunityDomain.NotesDetails notes = new TimeCardDayCommunityDomain.NotesDetails();
                notes.referenceId = snapshot.Reference_Id__c;
                notes.userName = snapshot.CreatedBy.Name;
                notes.dayId = snapshot.Time_Card_Day__c;
                notes.noteType = snapshot.Note_Type__c;
                notes.notes = formatNotes(snapshot.Notes__c,snapshot.Note_Type__c);
                notes.comment = snapshot.Invoice_Comment__c;
                
                String dt = String.valueOf(snapshot.Date__c);
                notes.daydate = dt.split('-')[1]+'/'+dt.split('-')[2]+'/'+dt.split('-')[0];
                
                notes.editedDT = snapshot.CreatedDate.format('MM/dd/yyyy HH:mm:ss a', UserInfo.getTimeZone().getID());
                notes.userName = snapshot.CreatedBy.Name;
                
                tempList.add(notes);
            }
        }
        
        system.debug('::::::tempList:::::::::'+tempList.size());
        
        Map<String,TimeCardDayCommunityDomain.NotesDetails> refIdNoteMap = new Map<String,TimeCardDayCommunityDomain.NotesDetails>();
        
        for(TimeCardDayCommunityDomain.NotesDetails temp : tempList){
            if(temp.referenceId != null){
                if(!refIdNoteMap.containsKey(temp.referenceId)) {
                    TimeCardDayCommunityDomain.NotesDetails newNote = temp;
                    TimeCardDayCommunityDomain.NotesDetails newNote1 = new TimeCardDayCommunityDomain.NotesDetails();
                    
                    newNote1.referenceId = newNote.referenceId;
                    
                    newNote1.notes = newNote.notes;
                    newNote1.noteType = newNote.noteType;
                    newNote1.userName = newNote.userName;
                    
                    notesDetails.add(newNote1);
                    tempMap.put(temp.referenceId,new List<TimeCardDayCommunityDomain.NotesDetails>{temp});
                    
                    refIdNoteMap.put(temp.referenceId,newNote1);
                    
                }else {
                    tempMap.get(temp.referenceId).add(temp);
                    
                    if(temp.referenceId.contains('Partial Reject')){
                        
                        for(TimeCardDayCommunityDomain.NotesDetails formatedNotes : notesDetails){
                            
                            if(formatedNotes.referenceId == temp.referenceId && formatedNotes.referenceId.contains('Partial Reject')){
                                formatedNotes.notes += '<br/> &nbsp;&nbsp;&nbsp;&nbsp;<b>'+temp.dayDate+'</b> rejected on '+temp.editedDT+' for <b>Reason: </b>'+temp.comment;
                            
                            }
                        }
                        
                    }
                }
            }else {
                notesDetails.add(temp);
            }
        }
      
        system.debug('::::::::notesDetails::::::'+notesDetails);
        
        return notesDetails;
    }
    
    public static string formatNotes(string note, string type){
        String formattedNote = '';
        
        if(type == 'Instructor Daily Entry Late Cancellation'){
        
            formattedNote = note.replace('Cancellation Reason Notes:','<b>Cancellation Reason Notes:</b>');
            
        }else if(type == 'Instructor Daily Entry Student Hours Mismatch') {
        
            formattedNote = note.replace('Notes:','<b>Notes:</b>');
            
        }else if(type == 'Daily Entry Edit'){
        
            formattedNote = note.replace('Project Task:','<b>Project Task:</b>');
            
            formattedNote = formattedNote.replace('Date:','<b>Date:</b>');
            formattedNote = formattedNote.replace('Old Hours:','<br><b>Old Hours:</b>');
            formattedNote = formattedNote.replace('New Hours:','<b>New Hours:</b>');
            formattedNote = formattedNote.replace('Old Status:','<b>Old Status:</b>');
            formattedNote = formattedNote.replace('New Status:','<b>New Status:</b>');
            formattedNote = formattedNote.replace('Comment:','<b>Comment:</b>');
            
        }else if(type == 'Student Daily Entry Reject'){
        
            formattedNote = note.replace('Reason:','<b>Reason:</b>');
            
        }else if(type == 'Instructor Daily Entry Recall') {
        
            formattedNote = note.replace('Project Task:','<b>Project Task:</b>');
            formattedNote = formattedNote.replace('Date:','<b>Date:</b>');
            formattedNote = formattedNote.replace('Hours:','<b>Hours:</b>');
            
        }else {
            formattedNote = note;
        }
        
        return formattedNote;
    }
    
    /*********************************************************************************************************
    - New row formation on Add button click in Admin Time Entry Instructor view cmp
    ***********************************************************************************************************/
    public static TimeCardDayCommunityDomain.InstructorDayDetails formNewRowContents(Date st,Date ed,List<AcctSeed__Project_Task__c> taskRecords,List<Contact_Assignments__c> caRecord,Map<Id,Integer> taskIdTimeCount,Map<Id,String> taskIdTimeMap,List<Contact_Assignments__History> caHistory,List<AcctSeed__Cost_Rates__c> oldCRRecord,Map<String,Object> inputMap){
    
        TimeCardDayCommunityDomain.InstructorDayDetails newRow = new TimeCardDayCommunityDomain.InstructorDayDetails();
        Map<Date,TimeCardDayCommunityDomain.DayEntries> dateEntryMap = new Map<Date,TimeCardDayCommunityDomain.DayEntries>();
        
        Date startDt = st;
        Date endDt = ed;

        // Modified by vasanthram R for W-007880
        Set<Date> federalHolidays = HolidayService.getHolidaysWithRecurrence(startDt,endDt);

        TimeCardDayCommunityDomain.DayEntries dayRec = new TimeCardDayCommunityDomain.DayEntries();
        dayRec.dayHours = null;
        dayRec.dayId = null;
        dayRec.lineId = null;
        dayRec.projectId = null;
        dayRec.taskId = null;
        dayRec.locationId = null;
        dayRec.isBillable = false;
        dayRec.payrollItem = '';
        dayRec.status = '';
        dayRec.dateVal = null;
        dayRec.comments = '';
        dayRec.costrateId = null;
        dayRec.contactAssignid = null;
        dayRec.sequenceNumber = 0;
        dayRec.cancellationReason = '';
        dayRec.startTime1 = null;
        dayRec.endTime1 = null;
        dayRec.startTime2 = null;
        dayRec.endTime2 = null;
        dayRec.lateCancellation = false;
        dayRec.isHrsDisabled = false;
        dayRec.showEditIcon = false;
        dayRec.showReverseIcon = false;
        dayRec.isCompleted = false;
        dayRec.hideFromStudent = false;        
        
        dayRec.isNew = false;
        dayRec.isUpdated = false;
        
        while(startDt <= endDt){
            system.debug('startDt::::'+startDt);
            TimeCardDayCommunityDomain.DayEntries day = new TimeCardDayCommunityDomain.DayEntries();
            day.dateVal = startDt;
            
            //date formatting for display
            day.displayDate = String.valueOf(startDt).split('-')[1]+'/'+String.valueOf(startDt).split('-')[2]+'/'+String.valueOf(startDt).split('-')[0];
            
            //date type finding - mon, tues, ...
            DateTime currentDt = DateTime.newInstance(startDt, Time.newInstance(0, 0, 0, 0));
            day.dayType = currentDt.format('EEEE');
            
            dateEntryMap.put(startDt,day);
            startDt = startDt.addDays(1);
        }
        
        String projectName = (String) inputMap.get('projectName');
        String studentNames = (String) inputMap.get('studentNames');
        String locationId = (String) inputMap.get('locationId');
        String locationName = (String) inputMap.get('locationName');
        Integer seqNum = (Integer) inputMap.get('seqNum');
        Boolean billable = (Boolean) inputMap.get('isBillable');
        String payrollItem = (String) inputMap.get('payrollItem');
        
        for(AcctSeed__Project_Task__c task : taskRecords){
            String key = task.AcctSeed__Project__c+'~'+task.Id;
            
            TimeCardDayCommunityDomain.InstructorDayDetails detail = new TimeCardDayCommunityDomain.InstructorDayDetails();
            
            String bill = billable == true ? 'Billable' : 'Non-Billable';
            
            detail.chargeCode1 = task.AcctSeed__Project__r.DLS_Class__c+' / <b>'+task.Name+'</b> / ';
            detail.chargeCode2 = studentNames+' / <br/>'+payrollItem+' / '+bill+' / '+locationName;
            detail.totalHours = '0.00';
            detail.dayEntries = new List<TimeCardDayCommunityDomain.DayEntries>();
            
            detail.sequenceNumber = seqNum + 1;
            
            seqNum = seqNum + detail.sequenceNumber;
            detail.taskType = task.Project_Task_Type__c;

            //Modified by Vasanthram R for W-007880
            detail.taskName = task.Name;
            detail.isNewRow = true;
            
            Decimal totalHr = 0.00;
            
            for(Date dt : dateEntryMap.keySet()){
                TimeCardDayCommunityDomain.DayEntries day = new TimeCardDayCommunityDomain.DayEntries();
                day = dateEntryMap.get(dt).clone();
                
                day.projectId = task.AcctSeed__Project__c;
                day.taskId = task.Id;
                day.locationId = locationId;
                day.isBillable = billable;
                day.sequenceNumber = detail.sequenceNumber;
                day.TaskType = detail.taskType;
                day.lateCancellation = false;
                day.taskName = task.Name;
                day.payrollItem = task.Payroll_Item__c;

                day.isNew = true;
                day.isUpdated = false;
                
                //Payroll, CR values assigning
                if(caHistory.size() == 0 || (caHistory.size() > 0 && caHistory[0].OldValue == null)){
                
                    if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c 
                        || task.Project_Task_Type__c == 'Fringe') && caRecord[0].Rate_Card_Rate__c != null){
                         
                        for(Contact_Assignments__c ca : caRecord){
                            Date oralExamDate;
                            if(ca.Oral_Exam_Date_Time__c != null){
                                oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                            }
                            Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                            if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                day.contactAssignid = (Id) ca.Id;                                                                                
                            }
                        }
                        
                        /*if(day.isBillable){
                            day.payrollItem = caRecord[0].Rate_Card_Rate__r.Payroll_Item__c;
                        }else {
                            day.payrollItem = caRecord[0].Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                        }*/
                        day.payrollItem = payrollItem;
                    }
                }else if(caHistory.size() > 0 && caRecord.size() > 0 
                    && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c || task.Project_Task_Type__c == 'Fringe')){
                                
                    Date historyDate = Date.newInstance(caHistory[0].createdDate.year(),caHistory[0].createdDate.month(),caHistory[0].createdDate.day());
                    
                    if(dt <= historyDate && caHistory[0].OldValue != null){
                        day.costrateId = (Id) caHistory[0].OldValue;
                        day.contactAssignid = (Id) caHistory[0].parentId;
                        
                        /*if(oldCRRecord.size() > 0 && oldCRRecord[0].Id == day.costrateId){
                            if(day.isBillable){
                                day.payrollItem = oldCRRecord[0].Payroll_Item__c;
                            }else {
                                day.payrollItem = oldCRRecord[0].Non_Billable_Payroll_Item__c;
                            }
                        }*/
                        day.payrollItem = payrollItem;
                    }else {
                        
                        if(caRecord.size() > 0 && (caRecord[0].Project_Task__c == task.Id || caRecord[0].Project_Task__c == task.Parent_Project_Task__c 
                            || task.Project_Task_Type__c == 'Fringe') && caRecord[0].Rate_Card_Rate__c != null){
                            
                                for(Contact_Assignments__c ca : caRecord){
                                    Date oralExamDate;
                                    if(ca.Oral_Exam_Date_Time__c != null){
                                        oralExamDate = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                                    }
                                    Date startofWeek = Integer.valueOf(DateTime.newInstance(dt, Time.newInstance(0,0,0,0)).format('u')) == 7 ? dt.addDays(-6)  : dt.toStartofWeek().addDays(1);
                                    if((dt >= ca.Start_Date__c || startofWeek >= ca.Start_Date__c  || (ca.Oral_Exam_Date_Time__c != null && (dt >=  oralExamDate || startofWeek >= oralExamDate))) && (dt <= ca.End_Date__c || startofWeek <= ca.End_Date__c)){
                                        day.costrateId = (Id) ca.Rate_Card_Rate__c;
                                        day.contactAssignid = (Id) ca.Id;                                        
                                    }
                                }
                            
                            /*if(day.isBillable){
                                day.payrollItem = caRecord[0].Rate_Card_Rate__r.Payroll_Item__c;
                            }else {
                                day.payrollItem = caRecord[0].Rate_Card_Rate__r.Non_Billable_Payroll_Item__c;
                            }*/
                            day.payrollItem = payrollItem;
                        }
                    }
                }


                
                day.isHrsDisabled = false;
                day.showEditIcon = false;
                day.showReverseIcon = false;
                day.isCompleted = false;
                day.hideFromStudent = false;
                
                // Modified by vasanthram R for W-007880
                if(task.Name == 'Fringe-Holiday') {
                    if(federalHolidays.contains(day.dateVal)){
                        day.dayHours = 8 + '.00';
                        totalHr += Decimal.valueOf(day.dayHours);
                    }
                }
                detail.dayEntries.add(day);
            }

           
            
            if(taskIdTimeCount.size() > 0){
                if(task.Project_Task_Type__c == 'Preparation time' && taskIdTimeCount.containsKey(task.Id)){
                    detail.timeRowCount = taskIdTimeCount.get(task.Id);
                    
                    if(taskIdTimeCount.get(task.Id) != 1 && taskIdTimeMap.containsKey(task.Id)){
                        detail.timeType = taskIdTimeMap.get(task.Id);
                    }else if(taskIdTimeCount.get(task.Id) == 1){
                        detail.timeType = 'Single';
                    }
                    
                }else if(task.Project_Task_Type__c != 'Preparation time'){
                    detail.timeRowCount = 1;
                    detail.timeType = 'AM';
                }
            }else {
                if(task.Project_Task_Type__c != 'Preparation time'){
                    detail.timeRowCount = 1;
                    detail.timeType = 'AM';
                    
                }else if(task.Project_Task_Type__c == 'Preparation time'){
                    detail.timeRowCount = 2;
                    detail.timeType = 'Both';
                }
            }
            
            detail.totalHours = String.valueOf(totalHr);
            
            newRow = detail;
        }
        
        system.debug('::::::newRow:::'+newRow);
        
        return newRow;
    }
    
    public static Integer dayOfWeekNumber(Date aDate) {
        return Math.mod(Date.newInstance(1900, 1, 7).daysBetween(aDate),7);
    }
}