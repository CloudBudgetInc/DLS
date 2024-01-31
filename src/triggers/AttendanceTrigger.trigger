trigger AttendanceTrigger on Attendance__c (after insert, after update, before insert) {

    if(Trigger.isAfter){
        
        if(Trigger.isInsert || Trigger.isUpdate){
                    
            // Insert : To send an email notification to students Immediately upon student hours save
            // Update : To send an email notification to students when the Instructor edit the student hours
            
            Set<Id> classLeaderIds = new Set<Id>();
            Set<Id> studentIds = new Set<Id>();
            Map<Id, Attendance__c> attendanceIdAndRec = new Map<Id, Attendance__c>();
            
            //Get the static set value from timeCardRelated_Email_Controller to ignore sending an email through Attendance trigger because these students received email through time entry submission
            if(classLeaderIds.size() == 0){
                classLeaderIds = timeCardRelated_Email_Controller.classLeaderIds;
            }
            System.debug('classLeaderIds ====='+classLeaderIds+'classLeaderIds  SIZE=='+classLeaderIds .size());
            
            for(Attendance__c a : trigger.new){
               
                if(a.Student__c != NULL && !classLeaderIds.contains(a.Student__c) && a.Time_Card_Day__c != NULL && a.Student_Approval_Status__c == 'Submitted' && 
                    (Trigger.isInsert || (Trigger.isUpdate && (a.Student_Approval_Status__c != Trigger.oldMap.get(a.Id).Student_Approval_Status__c || a.Duration__c != Trigger.oldMap.get(a.Id).Duration__c)))){
                    
                    attendanceIdAndRec.put(a.Id, a);
                    studentIds.add(a.Student__c );
                }               
            }
            System.debug('attendanceIdAndRec====='+attendanceIdAndRec+'attendanceIdAndRec SIZE====='+attendanceIdAndRec.size());
            System.debug('studentIds====='+studentIds+'studentIds SIZE====='+studentIds.size());
            
            if(attendanceIdAndRec.size() > 0){
                
                AttendanceTrigger_Handler.sendAnEmailToStudents(attendanceIdAndRec, studentIds);
            }
        }
        
        // Added on Jul 11
        // To send an email notification to instructor when student rejects their student hours
        if(Trigger.isUpdate){
        
            Set<Id> instructorIds = new Set<Id>();
            Map<Id, Attendance__c> attendanceIdAndRec = new Map<Id, Attendance__c>();
            
            for(Attendance__c a : trigger.new){
               
                if(a.Instructor__c != NULL && a.Student__c != NULL && a.Time_Card_Day__c != NULL && a.Student_Approval_Status__c == 'Rejected' && 
                    a.Student_Approval_Status__c != Trigger.oldMap.get(a.Id).Student_Approval_Status__c){
                    
                    instructorIds.add(a.Instructor__c);
                    attendanceIdAndRec.put(a.Id, a);
                }
            }
            System.debug('attendanceIdAndRec====='+attendanceIdAndRec+'attendanceIdAndRec SIZE=='+attendanceIdAndRec.size());
            System.debug('instructorIds====='+instructorIds+'instructorIds SIZE=='+instructorIds.size());
            
            if(instructorIds.size() > 0){
            
                AttendanceTrigger_Handler.sendAnEmailToInstructors(attendanceIdAndRec, instructorIds);
            }
        }
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        AttendanceTrigger_Handler.populateRelatedCA(Trigger.new);
    }
}