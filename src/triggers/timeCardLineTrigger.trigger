trigger timeCardLineTrigger on AcctSeed__Time_Card_Line__c (before update, after update,after insert) {

     if (trigger.isAfter && trigger.isUpdate) {
     
        List<Accounting_Seed_Time_Snapshot__c> tcdSnapshotList = new List<Accounting_Seed_Time_Snapshot__c>();
        for (AcctSeed__Time_Card_Line__c tcLine : trigger.new) {
        
            if (tcLine != trigger.oldMap.get(tcLine.Id)) {
                AcctSeed__Time_Card_Line__c oldTCL = trigger.oldMap.get(tcLine.Id);
                
                Accounting_Seed_Time_Snapshot__c tcdSnapshot = new Accounting_Seed_Time_Snapshot__c();
                
                tcdSnapshot.Time_Card_Line__c = oldTCL.Id;
                tcdSnapshot.Approved_Time__c = String.valueOf(oldTCL.ApprovedTime__c);
                tcdSnapshot.Billable__c = oldTCL.AcctSeed__Billable__c;
                tcdSnapshot.Billed__c = oldTCL.AcctSeed__Billed__c;
                tcdSnapshot.TCL_Approved_By__c = oldTCL.Approved_By__c;
                tcdSnapshot.Day_Count__c = String.valueOf(oldTCL.AcctSeed__Day_Count__c);
                tcdSnapshot.TCL_Parent_Status__c = oldTCL.AcctSeed__Parent_Status__c;
                tcdSnapshot.TCL_Project__c = oldTCL.AcctSeed__Project__c;
                tcdSnapshot.Project_Task__c = oldTCL.AcctSeed__Project_Task__c;
                tcdSnapshot.TCL_Status__c = oldTCL.Status__c;
                tcdSnapshot.Time_Card__c = oldTCL.AcctSeed__Time_Card__c;
                tcdSnapshot.Time_Card_Variable_1__c = oldTCL.AcctSeed__Time_Card_Variable_1__c;
                tcdSnapshot.Time_Card_Variable_2__c = oldTCL.AcctSeed__Time_Card_Variable_2__c;
                tcdSnapshot.Total_Hours__c = String.valueOf(oldTCL.AcctSeed__Total_Hours__c);
                tcdSnapshot.of_Approved_Hours__c = String.valueOf(oldTCL.of_Approved_Hours__c);
                tcdSnapshot.of_Pending_Time_Logs__c = String.valueOf(oldTCL.of_Pending_Time_Logs__c);
                tcdSnapshot.of_Rejected_Hours__c = String.valueOf(oldTCL.of_Rejected_Hours__c);
                tcdSnapshot.of_Submitted_Hours__c = String.valueOf(oldTCL.of_Submitted_Hours__c);
                tcdSnapshot.Display_in_Future_Weeks__c = oldTCL.Display_in_Future_Weeks__c;
                tcdSnapshot.TCL_Location__c = oldTCL.Location__c;
                tcdSnapshot.Overtime__c = oldTCL.AcctSeed__Overtime__c;
                tcdSnapshot.TCL_Payroll_Item__c = oldTCL.Payroll_Item__c;
                
                tcdSnapshotList.add(tcdSnapshot);
            }
        } 
        
        if (tcdSnapshotList.size() > 0) {
            insert tcdSnapshotList;
        }   
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        Set<Id> projectIds = new Set<Id>();
        Set<Date> dates = new Set<Date>();
        Set<Id> instructorIds = new Set<Id>();
        for(AcctSeed__Time_Card_Line__c tcLine : trigger.new){
            if(tcLine.Submitted_Date_Time__c != null && trigger.oldMap.get(tcLine.Id).Submitted_Date_Time__c != tcLine.Submitted_Date_Time__c){
                dates.add(Date.newInstance(tcLine.Submitted_Date_Time__c.year(), tcLine.Submitted_Date_Time__c.month(), tcLine.Submitted_Date_Time__c.day()));
                projectIds.add(tcLine.AcctSeed__Project__c);
                instructorIds.add(tcLine.Instructor_Id__c);
            }
        }
        
        if(projectIds.size() > 0){
            Map<Id, Set<Id>> conIdsWithProjectIds = new Map<Id, Set<Id>>();
            
            for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Project__c 
                                             FROM Contact_Assignments__c 
                                             WHERE Candidate_Name__c = :instructorIds AND RecordType.DeveloperName IN ('Instructor')]){
                                                 
                if(!conIdsWithProjectIds.containsKey(ca.Candidate_Name__c))
                    conIdsWithProjectIds.put(ca.Candidate_Name__c, new Set<Id>());
                                                 
                conIdsWithProjectIds.get(ca.Candidate_Name__c).add(ca.Project__c);
            }
            
            TimeCardDayTrigger_Handler.pdosByProjectId = TimeEntryHelper.getApprovedPDOsByProjectIds(conIdsWithProjectIds, dates, projectIds);
            
            for (AcctSeed__Time_Card_Line__c tcLine : trigger.new) {
                if(tcLine.Submitted_Date_Time__c != null && trigger.oldMap.get(tcLine.Id).Submitted_Date_Time__c != tcLine.Submitted_Date_Time__c){
                    Date periodEndDatePlusOne = TimeCardDayTrigger_Handler.getNextWorkingDay(tcLine.Period_End_Date__c, tcLine.AcctSeed__Project__c);
                    TimezoneUtilClass userTimeZone = new TimezoneUtilClass();
                    tcLine.Submitted_On_Time__c = userTimeZone.getUserTimeZoneDateTime(tcLine.Submitted_Date_Time__c) <= userTimeZone.getUserTimeZoneDateTime(Datetime.newInstance(periodEndDatePlusOne.year(), periodEndDatePlusOne.month(), periodEndDatePlusOne.day(), 12, 0, 0));
                    tcLine.Submitted_Late__c = !tcLine.Submitted_On_Time__c;
                }                                            
            }
        }
    } 
}