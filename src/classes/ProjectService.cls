/**********************************************************************
    Created by Shalini on Feb 2 2017: Service class used for AcctSeed__Project__c object
***********************************************************************/

public with sharing class ProjectService {
    
    public Static String fldStr = 'of_Instructors_active__c,QB_Classification__c,of_Instructors_awarded__c,of_Instructors_requested__c,AcctSeed__Account__c,AcctSeed__Budgeted_Amount__c,AcctSeed__Budgeted_Hours__c,'+
    'AcctSeed__Budgeted_Revenue__c,Cohort__c,Contract__c,Daily_Per_Diem_Rate__c,Default_Cost_Rate_Rate_Type__c,Delivery_Account__c,DLS_Ref__c,DLS_Class__c,End_Date__c,End_User_Account__c,Est_of_Days_Per_Diem_per_Instructor__c,'+
    'ILR_Final_Date__c,ILR_L_Goal__c,ILR_Midterm_Date__c,ILR_R_Goal__c,ILR_S_Goal__c,Language__c,Last_Invoice_Date__c,Materials_G_A_Expense_from_Contract__c,Notes__c,AcctSeed__Opportunity__c,Payment_Term__c,Payroll_Item__c,PC_Cust_Job__c,'+
    'PC_GL_Code__c,Program_type__c,Project_Manager__c,QB_Cust_Job__c,Quantity__c,AcctSeed__Revenue_Recognition_Method__c,Service_Item__c,Start_Date__c,AcctSeed__Status__c,Stripped_Class_Number_This_Year__c,Sub_Program__c,Task_Order__c,AcctSeed__Template_Project__c,'+
    'TO__c,Total_Amount_Funded__c,Total_Materials_Funded__c,Total_Materials_G_A_Expense__c,Total_ODCs_Funded__c,Total_ODCs_Task__c,Total_Price_All_Tasks__c,Total_Refund_Amount__c,Total_Services_Funded__c,Total_Services_Tasks__c,'+
    'Total_Travel_Funded__c,Total_Travel_Task__c,Training_Location__c,Travel_In_Date__c,Travel_Out_Date__c,Material_budget_Budgeted__c,Material_budget_Paid__c,Material_budget_Used__c,Material_Budget_Remaining__c,'+
    'Material_budget_Paid_Remaining__c,Id,Name,RecordTypeId,Accounting_Notes__c,Instructors__c,Students__c,Auth_End_Date__c,Auth_Start_Date__c,Billing_Type__c,CLIN__c,Close_Date__c,Country_Map__c,Dialects__c,End_of_Training_Goals__c,Hourly_Rate__c,Hours_Week__c,Hours_Low__c,'+
    'Hours_Remaining__c,Hours_Used_TL__c,L_Goal_Score_Applicable__c,LTS_Notes__c,Materials_Budget_Requested__c,Number_of_students__c,Number_of_Students_Active__c,Previous_Stage__c,Proficiency_Testing__c,Project_Description__c,R_Goal_Score_Applicable__c,'+
    'Room__c,Section__c,S_Goal_Score_Applicable__c,SLP_Iteration__c,Staffs__c,Total_Program_Hours__c,Totals_Hours_Paid_Auth__c,Test_Type__c';
    /**********************************************************************
        Created by Shalini on Feb 2 2017: This method return list of AcctSeed__Project__c 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        @oppIdSet - Set of any Ids
        return - list of AcctSeed__Project__c records
    ***********************************************************************/  

    public Static List<AcctSeed__Project__c> getproject(String filterQrystr, String parentFields, Set<Id> oppIdSet) {
        system.debug(':::::filterQrystr:::::::'+filterQrystr);
        List<AcctSeed__Project__c> projectList = new List<AcctSeed__Project__c>();
        //String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Project__c');
        String defalutQry = 'SELECT '+ fldStr +' FROM AcctSeed__Project__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fldStr +' ,'+ parentFields + ' FROM AcctSeed__Project__c';
        }
        system.debug(':::::defalutQry:::::::'+defalutQry);
        if(filterQrystr != null && filterQrystr != '' && oppIdSet.size() > 0 && oppIdSet != Null){
            defalutQry += filterQrystr + ' IN :oppIdSet'; 
        }
        system.debug(':::::defalutQry:::::::'+defalutQry);
        projectList = Database.query(defalutQry);        
        return projectList;              
    }

     /**********************************************************************
        Created by Shalini on Feb 2 2017: This method return list of AcctSeed__Project__c 
        @projList - List of AcctSeed__Project__c records
        return - list of AcctSeed__Project__c records
    ***********************************************************************/ 
    /*public static list<AcctSeed__Project__c> insertProject(list<AcctSeed__Project__c> projList) {
    
        if(projList != null && projList.size() > 0){
            insert projList;            
        }
        return projList;    
    }*/

    /**********************************************************************
        Created by Shalini on Feb 2 2017: This method return list of AcctSeed__Project__c 
        @projList - List of AcctSeed__Project__c records
        return - list of AcctSeed__Project__c records
    ***********************************************************************/ 
    public static list<AcctSeed__Project__c> updateProject(list<AcctSeed__Project__c> projList) {

        if(projList != null && projList.size() > 0){
            update projList;            
        }
        return projList;    
    }

    //Commented this method because doesn't use any component.
    /**********************************************************************
        Created by Shalini on Feb 2 2017: This method return list of AcctSeed__Project__c 
        @fltrqryStr - pass where Conditions
        @contactId - Set of contact IDs
        @projectId - Set of Project Ids
        return - list of AcctSeed__Project__c records
    ***********************************************************************/  

    /*public Static List<AcctSeed__Project__c> getProjectByconIdandProId(String filterQrystr,Set<Id> contactId,Set<Id> projectId) {

        List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c>();
        //String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Project__c');
        //String childObjfieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c');
        String childObjfieldName = ContactAssignmentService.fieldStr;
        String defalutQry = 'SELECT '+ fldStr 
           +', ('
               +'SELECT '
                    + childObjfieldName 
                +' FROM Contact_Assignments__r'
                +' WHERE Assignment_Position__c = \''+'LTS'+'\''
                +' AND'
                +' Candidate_Name__c IN :contactId'
                +')'
         +' FROM AcctSeed__Project__c';

        if(filterQrystr != null && filterQrystr != '' && projectId.size() > 0 && projectId != Null){
            defalutQry += filterQrystr + ' IN :projectId'; 
        }

        System.debug('::defalutQry:::'+defalutQry);
        projList = Database.query(defalutQry);        
        return projList;  

    }*/
    
    //Commented this method because doesn't use any component.
    /**********************************************************************
        Created by Vinitha on Feb 20 2017: This method return list of AcctSeed__Project__c
        @recTypeId - Pass recordtype id field name
        return - list of AcctSeed__Project__c records
    ***********************************************************************/  

    /*public Static List<AcctSeed__Project__c> getProjectbyRecType(Id recTypeId) {

        List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c>();
        String defalutQry;        
        defalutQry = 'SELECT Id,Name,RecordType.Name,DLS_Ref__c,Start_Date__c,Program_type__c,End_Date__c,AcctSeed__Status__c,Project_Manager__c,AcctSeed__Project_Manager__r.Name,'+
                        '(SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Name FROM Contact_Assignments__r WHERE RecordTypeId=\''+recTypeId+'\'),(SELECT Id,Name,AcctSeed__Project__r.Name,'+
                        'AcctSeed__Project__r.DLS_Class__c,AcctSeed__Project__r.AcctSeed__Status__c,AcctSeed__Project__r.End_Date__c,AcctSeed__Project__r.Start_Date__c,Total_Qty_Planned__c,Total_Qty_Paid__c,'+
                        'Total_Qty_Used__c,Total_Qty_Planned_Remaining__c,Total_Qty_Paid_Remaining__c,Total_Hours__c,Project_Task_Type__c,Unit__c FROM AcctSeed__Project_Tasks__r),CreatedDate FROM  AcctSeed__Project__c ORDER BY CreatedDate DESC LIMIT 15000';

        projList = Database.query(defalutQry);        
        return projList;        

    }*/
    /**********************************************************************
        Created by Karthiga on April 04 2017: This method return list of AcctSeed__Project__c
        @filterQuery - filter Query String
        @parentFields - Parent Feilds as Comma Separated
        @startDate - Created Date starts from 
        @endDate - Created Date ends on
        return - list of AcctSeed__Project__c records
    ***********************************************************************/  
    public Static List<AcctSeed__Project__c> getProjectsCreatedThisYear(String filterQuery,String parentFields,DateTime startDate,DateTime endDate) {
        List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c>();
        String defaultProjQry = 'SELECT ' + fldStr /*SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Project__c')*/ +
                                parentFields+                                       
                                ' FROM'+' AcctSeed__Project__c';
        if(startDate != Null && endDate != Null){
          defaultProjQry += ' WHERE CreatedDate >= :startDate ' + 
                           ' AND CreatedDate <= :endDate AND DLS_Class__c != null AND Stripped_Class_Number_This_Year__c > 0'; //ORDER BY CreatedDate Desc LIMIT 1';//ORDER By DLS_Class__c Desc';
        }
        if(filterQuery != '') {
         defaultProjQry += filterQuery;
        }
        
        defaultProjQry += 'ORDER BY Stripped_Class_Number_This_Year__c DESC LIMIT 1';
        
        System.debug('defaultProjQry Inside ProjectService:::::'+defaultProjQry);
        projList = database.query(defaultProjQry);                           
        return projList;
    }
}