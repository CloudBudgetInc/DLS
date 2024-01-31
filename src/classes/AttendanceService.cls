/**********************************************************************
    Created by Arun on Jan 23, 2017: Service class used for Attendance__c
***********************************************************************/

public with sharing Class AttendanceService {
    
     /**********************************************************************
        Created by Arun on Jan 23 2017: 
        @conIdSet - Set of Contact Ids
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of Event
     ***********************************************************************/
    public Static List<Attendance__c> getAttendancesByparentIds(Set<Id> parentIdSet,String filterQuery,String parentFields) {
        List<Attendance__c> attendanceList = new List<Attendance__c>();
        String defaultAttendanceQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Attendance__c')+
                                parentFields+                                       
                                ' FROM'+
                                        ' Attendance__c';                                    
         if(filterQuery != null && filterQuery != '' && parentIdSet != null && parentIdSet.size() > 0) {
             defaultAttendanceQry += filterQuery+' IN :parentIdSet';
         }else if(filterQuery != null && filterQuery != ''){
             defaultAttendanceQry += filterQuery;
         }
         System.debug('defaultAttendanceQry  :::::'+defaultAttendanceQry);
         attendanceList = database.query(defaultAttendanceQry);                           
         return attendanceList;
    }
    
    /**********************************************************************
        Created by Vinitha on Feb 10 2017: This method return list of Attendance after upsertion
        @upsertionList - list of Attendance for upsertion
    ***********************************************************************/
     public Static List<Attendance__c> upsertAttendance(List<Attendance__c> upsertionList) {
        
        if(upsertionList != null && upsertionList.size() > 0) {
            upsert upsertionList External_Id__c;            
        }
        return upsertionList;
    }
}