/************************************************************
 - Class to call a SubFlow from Parent Flow
 - To call a subflow to update the Parent Object's Field
 - Created by HL on June 07 2021
*************************************************************/
public class InvokeSubflowFromParentFlow{

    @InvocableMethod
    public static void invokeSubflow(List<CallSubflow_Params> subflowParams){
    
        for(CallSubflow_Params param : subflowParams){
        
            Map<String,sObject> parentRecordMap = new Map<String, sObject>();
            parentRecordMap.put('Record_From_Parent_Flow', param.sObjectRecordFromParentFlow);
            
            Flow.Interview mySubFlow = Flow.Interview.createInterview(param.subflowAPIName, parentRecordMap);
            mySubFlow.start();
        }
    }
    
    Public Class CallSubflow_Params{
        
        @InvocableVariable
        public sObject sObjectRecordFromParentFlow;
        
        @InvocableVariable
        public String subflowAPIName;
    }
}