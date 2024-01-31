/**********************************************************************
    Created by Vinitha on Jan 23 2017: Service class used for Material_Rating__c object
***********************************************************************/
public class MaterialRatingService {
    
     /**********************************************************************
        Created by Vinitha on Jan 23 2017: This method return list of MaterialRating 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of MaterialRating records
    ***********************************************************************/  
    
    public Static List<Material_Rating__c> getMaterialrating(String filterQrystr, String parentFields) {
    
        List<Material_Rating__c> matRatList = new List<Material_Rating__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Material_Rating__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Material_Rating__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Material_Rating__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        matRatList = Database.query(defalutQry);        
        return matRatList;        
    
    }
          
     /**********************************************************************
        Created by Vinitha on Jan 23 2017: This method return newly created list of MaterialRating 
        @requestList - List of MaterialRating records
        return - list of MaterialRating records
    ***********************************************************************/ 
    public static list<Material_Rating__c> insertMaterialrating(List<Material_Rating__c> materialRatList) {
    
        if(materialRatList != null && materialRatList.size() > 0){
            insert materialRatList;            
        }
        return materialRatList;    
    } 
    
    /**********************************************************************
        Created by Vinitha on Jan 23 2017: This method return list of MaterialRating 
        @requestList - List of MaterialRating records
        return - list of MaterialRating records
    ***********************************************************************/ 
    public static list<Material_Rating__c> updateMaterialrating(List<Material_Rating__c> materialRatList) {
    
        if(materialRatList != null && materialRatList.size() > 0){
            update materialRatList;            
        }
        return materialRatList;    
    } 
    /**********************************************************************
        Created by Vinitha on Jan 23 2017: This method return list of MaterialRating 
        @requestList - List of MaterialRating records
        return - list of MaterialRating records
    ***********************************************************************/ 
    public static list<Material_Rating__c> deleteMaterialrating(List<Material_Rating__c> materialRatList) {
    
        if(materialRatList != null && materialRatList.size() > 0){
            delete materialRatList;            
        }
        return materialRatList;    
    } 
}