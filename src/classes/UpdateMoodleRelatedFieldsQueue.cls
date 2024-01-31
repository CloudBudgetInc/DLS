/*****************

    - Added by HL on Aug 25 2020
    - To avoid "MIXED_DML_OPERATION, DML operation on setup object is not permitted Error" created this Queueable class
    ***************/
public class UpdateMoodleRelatedFieldsQueue implements Queueable {
        
    Map<Id, Contact_Assignments__c> updateCAs;
    Map<Id, AcctSeed__Project__c> updateProjs;
    Map<Id, Contact> updateCons;
            
    public UpdateMoodleRelatedFieldsQueue(Map<Id, Contact_Assignments__c> updateCAs, Map<Id, AcctSeed__Project__c> updateProjs, Map<Id, Contact> updateCons) {
        
        this.updateCAs = updateCAs;
        this.updateProjs = updateProjs;
        this.updateCons = updateCons;
    }
    
    public void execute(QueueableContext context) {
        
        System.debug('::::::::::::::::::::::MY QUEUE::::::::::');
        if(updateCAs != NULL && updateCAs.size() > 0){
            update updateCAs.values();
        }
        
        if(updateProjs != NULL && updateProjs.size() > 0){
            update updateProjs.values();
        }
        
        if(updateCons != NULL && updateCons.size() > 0){
            update updateCons.values();
        }      
    }
}