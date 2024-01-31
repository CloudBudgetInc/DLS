/**********************************************************************
    Created by Sukanya on Jan 5, 2017: Service class used for Contact_Assignments__c object     
***********************************************************************/
public without sharing class ContactAssignmentService {
    
     /**********************************************************************
        Created by Vinitha on Jan 24 2017: This method return list of ContactAssignment 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        @oppId - pass set of project ids
        return - list of ContactAssignment records
    ***********************************************************************/ 
    public static String fieldStr = 'of_Per_Diem_Days__c,ACH_set_up__c,Base_Access_Letter_Requested__c,Base_Access_Letter_Uploaded__c,CC_Auth_on_Hotel_Detail_Page__c,Close_Getfeedback_Received__c,Close_Getfeedback_sent__c,Code_of_Conduct_Received__c,'+
            'Contact_Assignment_External_Id__c,Candidate_Name__c,Contract__c,Contract_Emailed_to_Instructor__c,Contract_Uploaded_Word_and_PDF__c,Daily_Per_diem_Rate__c,Drafted_Labor_Cost_Rate__c,EE_Pay_Status__c,Email__c,End_Date__c,Event_Log_Contact_Assignment__c,Flight_out_uploaded__c,Hotel__c,'+
            'Iscoursecompletefeedsend__c,Isfeedbacksent__c,Labor_Pay_Rate__c,Laptop_Returned__c,Laptop_Serial_Numbers__c,Laptops_Issued__c,L_Score_Final__c,L_Score_Initial__c,Materials_Delivered_to_Instructor__c,Linguist_Paid__c,Mobile__c,Notes__c,Opportunity_Name__c,Opportunity_Name_Formula__c,'+
            'Opportunity_Product_Id__c,Opportunity_Type__c,Oral_Exam_Date_Time__c,Payroll_Item__c,PC_EE_ID__c,Per_diem_info_sent_to_Accounting__c,Assignment_Position__c,Power_Of_1__c,Project__c,Project_Task__c,QB_Cust_Job_CA__c,QB_Vendor_Name_CA__c,Quantity_Unit__c,Quantity_Actual__c,Rate_Card_Rate__c,Rental_Car_Confirmation_Uploaded__c,'+
            'Return_Flight_Uploaded__c,R_Score_Final__c,R_Score_Initial__c,Sequence__c,Signed_contract_received__c,S_Score_Final__c,S_Score_Initial__c,Start_Date__c,Status__c,Successful_del__c,Total_Per_Diem_Amount__c,Training_Location__c,Travel_In_Date__c,Travel_Out_Date__c,Trip_Details_Emailed_to_Instructor__c,'+
            'W_9_on_file__c,Weekly_Getfeedback_Received__c,Weekly_Getfeedback_sent__c,Id,Name,RecordTypeId,Location__c,Gas_Weekly_Allowance__c,Location__r.Name,Project_Assignment_Description__c,Do_not_send_feedback_One_time__c,Fully_Loaded_Rate__c,Fringe_Total_Billable_Hours__c,'+
            'Non_Fringe_Total_Billable_Hours__c,Primary_Document_Title__c,Primary_Document__c';
            
    public static list<Contact_Assignments__c> getContactassignmentByprojectId(String filterQry, String parentFields,Set<Id> projectId, String limitQry) {
    
        System.debug(':::filterQry:::'+filterQry);
        System.debug(':::parentFields:::'+parentFields);
        System.debug(':::projectId:::'+projectId);
        System.debug(':::limitQry:::'+limitQry);
        list<Contact_Assignments__c> contactAssignments =  new list<Contact_Assignments__c>();
        //String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c');
        String defalutQry = 'SELECT '+ fieldStr +' FROM Contact_Assignments__c';
        
        if(parentFields != null && parentFields != ''){
            defalutQry = 'SELECT '+ fieldStr +' ,'+ parentFields + ' FROM Contact_Assignments__c';
        }
        
        if(filterQry != null && filterQry != '' && limitQry != null && limitQry != '' && projectId != null && projectId.size() > 0){            
            defalutQry = defalutQry + filterQry + 'IN :projectId'+limitQry;          
        } else if(filterQry != null && filterQry != '' && projectId != null && projectId.size() > 0 ){
            defalutQry = defalutQry + filterQry + 'IN :projectId';
        } else if(filterQry != null && filterQry != ''){
            defalutQry = defalutQry + filterQry;
        }
        
        System.debug('::defalutQry:::'+defalutQry);
        contactAssignments =  Database.query(defalutQry);   
        return contactAssignments;
    }
    
    /**********************************************************************
        Created by Karthiga on Jan 10 2017: This method return list of Contact Assignments
        @ projectOppidSet - pass set of project and opportunity ids
        return - list of Contact_Assignments__c records
     ***********************************************************************/
     
    
    public static list<Contact_Assignments__c> getContactassignmentByparentIds(Set<Id> projectOppidSet,Set<String> statusSet,Set<String> RTDevName,String parentFields) {
        List<Contact_Assignments__c> contactAssignments = new List<Contact_Assignments__c>();
           String contAssignQuery = 'SELECT '+
                                        fieldStr /*SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c')*/ +
                                        parentFields+                                       
                                    ' FROM'+
                                        ' Contact_Assignments__c'+
                                    ' WHERE'+
                                        ' ( Project__c IN : projectOppidSet'+
                                        ' OR'+
                                        ' Opportunity_Name__c IN : projectOppidSet'+
                                        ' OR'+
                                        ' Contract__c IN : projectOppidSet )';
            if( statusSet != null && statusSet.size() > 0 ) {
                contAssignQuery = contAssignQuery + ' And Status__c IN :statusSet';
            }
            
            if( RTDevName != null && RTDevName.size() > 0 ) {
                contAssignQuery = contAssignQuery + ' AND RecordType.DeveloperName IN: RTDevName';
            }
            System.debug('contAssignQuery :::::'+contAssignQuery );
            contactAssignments = Database.query(contAssignQuery);
            return contactAssignments;
       }
     
     /**********************************************************************
        Created by Karthiga on Jan 10 2017: This method return list of Contact Assignments
        @projectOppidSet - Project/Opportunity Id Set
        @rtNameSet - Record Type DeveloperName Set
        @fltrqryStr - pass extra Conditions 
        @parentFields - pass relationship Query fields
        return - list of Contact_Assignments__c records
     ***********************************************************************/
     public static list<Contact_Assignments__c> getContactAssignmentByParentIdsAndRTName(Set<Id> projectOppidSet,Set<String> rtNameSet,String filterQryStr,String parentFields) {
         
         list<Contact_Assignments__c> contactAssignments = new list<Contact_Assignments__c>();
         String contAssignQuery = 'SELECT '+
                                        fieldStr /*SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c')*/+
                                        parentFields+                                       
                                    ' FROM'+
                                        ' Contact_Assignments__c'+
                                    ' WHERE'+
                                        ' ( Project__c IN : projectOppidSet'+
                                        ' OR'+
                                        ' Opportunity_Name__c IN : projectOppidSet)'+ 
                                        ' AND'+ 
                                        ' RecordType.DeveloperName IN : rtNameSet';
         if(filterQryStr != '') {
             contAssignQuery += filterQryStr;
         }
         System.debug('contAssignQuery :::::'+contAssignQuery );
         contactAssignments = database.query(contAssignQuery);                           
         return contactAssignments;
     }
     
     /**********************************************************************
        Created by Karthiga on Jan 11 2017: This method return list of Contact Assignments
        @contIdSet - Contact Id Set
        @rtNameSet - Record Type DeveloperName Set
        @fltrqryStr - pass extra Conditions 
        @parentFields - pass relationship Query fields
        return - list of Contact_Assignments__c records
     ***********************************************************************/
     public static list<Contact_Assignments__c> getContactAssignmentByContIds(Set<Id> contIdSet,Set<String> rtNameSet,String filterQryStr,String parentFields) {
        
         list<Contact_Assignments__c> contactAssignments = new list<Contact_Assignments__c>();
         String contAssignQuery = 'SELECT '+
                                        fieldStr /*SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c')*/+
                                        parentFields+                                       
                                    ' FROM'+
                                        ' Contact_Assignments__c'+
                                    ' WHERE'+
                                        ' Candidate_Name__c IN : contIdSet';       
                                        
         if(rtNameSet != null && rtNameSet.Size() > 0) {
             contAssignQuery += ' AND RecordType.DeveloperName IN : rtNameSet';
         }
         
         if(filterQryStr != '') {
             contAssignQuery += filterQryStr;
         }
         System.debug('contAssignQuery :::::'+contAssignQuery );
         contactAssignments = database.query(contAssignQuery);                           
         return contactAssignments;
     }
     
     /**********************************************************************
        Created by Arun on Jan 17 2017: This method return list of Contact Assignments
        @ConIdSet - Contact Id Set
        @assPositionSet - Assignment Position Set
        @fltrqryStr - pass extra Conditions 
        @parentFields - pass relationship Query fields
        return - list of Contact_Assignments__c records
     ***********************************************************************/
     public static list<Contact_Assignments__c> getContactAssignmentByContIdsAndAssPositions(Set<Id> ConIdSet, Set<String> assPositionSet, String filterQryStr,String parentFields) {
         
         list<Contact_Assignments__c> contactAssignments = new list<Contact_Assignments__c>();
         String contAssignQuery = 'SELECT '+
                                        fieldStr /*SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c')*/+
                                        parentFields+                                       
                                    ' FROM'+
                                        ' Contact_Assignments__c'+
                                    ' WHERE'+
                                        ' Candidate_Name__c IN : ConIdSet'+ 
                                        ' AND'+ 
                                        ' Assignment_Position__c IN : assPositionSet';
         if(filterQryStr != '') {
             contAssignQuery += filterQryStr;
         }
         System.debug('contAssignQuery :::::'+contAssignQuery );
         contactAssignments = database.query(contAssignQuery);                           
         return contactAssignments;
     }
     
     /**********************************************************************
        Created by Vinitha on Jan 24 2017: This method return list of Contact_Assignments__c 
        @filterQrystr - String add to query
        return - list of Contact_Assignments__c records
    ***********************************************************************/ 
     
     public static list<Contact_Assignments__c> getContactassignmentRec(String filterQrystr,String parentFields) {
    
         List<Contact_Assignments__c> contactAssList = new List<Contact_Assignments__c>();
         
         //String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c');
         String defalutQry = 'SELECT '+ fieldStr +' FROM Contact_Assignments__c';
          
         system.debug('::::filterQrystr'+filterQrystr);
         system.debug('::::::defalutQry::::::'+defalutQry);
        
         if(parentFields != null && parentFields != ''){
             defalutQry = 'SELECT '+ fieldStr +' ,'+ parentFields + ' FROM Contact_Assignments__c';
         }
         system.debug('defalutQry:::::'+defalutQry);
         
         if(filterQrystr != '' && filterQrystr != null ) {
             defalutQry = defalutQry + filterQrystr;
         }         
         
         system.debug('filterQrystr:::::'+filterQrystr);  
         system.debug('defalutQry:::::'+defalutQry);   
         contactAssList = Database.query(defalutQry);         
         return contactAssList;
    
    }
    
     
    /**********************************************************************
        Created by Karthiga on Jan 11, 2017: To insert the given List  
        @cAList - List of Contact Assignment.
        Returns - List of inserted Contact Assignment.   
    ***********************************************************************/

    public Static List<Contact_Assignments__c> insertContactAssignments(List<Contact_Assignments__c> cAList) {
        
        if(cAList != null && cAList.size() > 0) {
            
            Insert cAList;
            return cAList;
        }
        
        return null;
    }
    
    /**********************************************************************
        Created by Karthiga on Jan 11, 2017: To update the given List  
        @cAList - List of Contact Assignment.
        Returns - List of updated Contact Assignment.   
    ***********************************************************************/

    public Static List<Contact_Assignments__c> updateContactAssignments(List<Contact_Assignments__c> cAList) {
        
        if(cAList != null && cAList.size() > 0) {
            
            Update cAList;
            return cAList;
        }
        
        return null;
    }
    
    /**********************************************************************
        Created by Karthiga on Sep 07, 2018: To upsert the given List  
        @cAList - List of Contact Assignment.
        Returns - List of upserted Contact Assignment.   
    ***********************************************************************/

    public Static List<Contact_Assignments__c> upsertContactAssignments(List<Contact_Assignments__c> cAList) {
        
        if(cAList != null && cAList.size() > 0) {
            
            Upsert cAList;
            return cAList;
        }
        
        return null;
    }
    
     /**********************************************************************
        Created by Vinitha on Jan 25 2017: This method return list of Contact Assignments
        @ coContactSet - pass set of Candicate Name ids
        @projectIdSet -  pass set of project ids
        @parentFields -  pass parent Fields 
        return - list of Contact_Assignments__c records
     ***********************************************************************/
    
    public static list<Contact_Assignments__c> getContactassignmentBYcandicate(Set<Id> coContactSet,Set<Id> projectIdSet,String parentFields) {
         
         list<Contact_Assignments__c> contactAssignments = new list<Contact_Assignments__c>();
         String contAssignQuery = 'SELECT '+
                                        fieldStr /*SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c')*/+
                                        parentFields+                                       
                                    ' FROM'+
                                        ' Contact_Assignments__c'+
                                    ' WHERE'+
                                        ' Candidate_Name__c IN :coContactSet'+
                                    ' AND'+
                                        ' Project__c NOT IN :projectIdSet';                                    
         
         System.debug('contAssignQuery :::::'+contAssignQuery );
         contactAssignments = database.query(contAssignQuery);                           
         return contactAssignments;
     }
     
     /**********************************************************************
        Created by Vinitha on Mar 3 2017: This method return list of Contact Assignments
        @ conassId - pass set of Contact Assignment ids
        @groupfields -  pass Group by field name
        return - list of Contact_Assignments__c records
     ***********************************************************************/
    
    public static list<AggregateResult> getAggregateresult(String objfield,Set<Id> conassId,String groupfields) {
         
         list<AggregateResult> contactAssignments = new list<AggregateResult>();
         String contAssignQuery = 'SELECT '+
                                    objfield +
                                    ' FROM Contact_Assignments__c WHERE Id IN :conassId'+
                                    ' GROUP BY '+ groupfields;                               
         
         System.debug('contAssignQuery ::getAggregateresult:::'+contAssignQuery );
         contactAssignments = database.query(contAssignQuery);                           
         return contactAssignments;
    }
    
     /**********************************************************************
        Created by Siva Prasanth on May 08 2019: This method return list of Contact_Assignments__c 
        @filterQrystr - String add to query
        return - list of Contact_Assignments__c records
    ***********************************************************************/ 
     
     public static list<Contact_Assignments__c> getContactassignmentByCRId(String filterQrystr,String parentfields ,set<Id> crIds,set<Id> excludeCAId) {
    
        List<Contact_Assignments__c> contactAssList = new List<Contact_Assignments__c>();
         
        if(parentfields != '' && parentfields != null) {
            fieldStr += parentfields;
        }
        //String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c');
        String defalutQry = 'SELECT '+ fieldStr +' FROM Contact_Assignments__c';
         
         if(filterQrystr != '' && filterQrystr != null ) {
             defalutQry = defalutQry + filterQrystr;
         }         
         if(crIds != null && crIds.size() > 0) {
              defalutQry = defalutQry + ' AND (Rate_Card_Rate__c IN :crIds OR  Drafted_Labor_Cost_Rate__c IN :crIds)';
         }      
         if(excludeCAId != null && excludeCAId.size() > 0) {
              defalutQry = defalutQry + 'AND Id NOT IN :excludeCAId';
         }
        system.debug('filterQrystr:::::'+filterQrystr);  
        system.debug('defalutQry:::::'+defalutQry);   
        contactAssList = Database.query(defalutQry);         
        return contactAssList;  
    }        
}