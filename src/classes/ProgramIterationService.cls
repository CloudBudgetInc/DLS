/**********************************************************************
    Created by Karthiga on July 19, 2018: Service class used for Program_Iteration__c object
***********************************************************************/
Public Class ProgramIterationService {
    
    /**********************************************************************
        Created by Karthiga on July 19, 2018: This method return list of Program_Iteration__c 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of Program_Iteration__c records
    ***********************************************************************/  
    public static List<Program_Iteration__c> getIterationRec(String filterQrystr, String parentFields) {
    
        List<Program_Iteration__c> iterationList = new List<Program_Iteration__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Program_Iteration__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Program_Iteration__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Program_Iteration__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        iterationList = Database.query(defalutQry);        
        return iterationList;   
    }
}