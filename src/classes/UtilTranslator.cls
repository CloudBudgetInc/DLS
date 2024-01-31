/**********************************************************************
    Created by Sukanya on Jan 11 2017: Translator class used for UtilDomain inner class formation
***********************************************************************/

global class UtilTranslator {
    
    /***********************************************************************************************************************************
    - Added by NS on May 8 2019
    - To form the library search result related wrapper with filter information
    ************************************************************************************************************************************/
    public static UtilDomain.SearchResultInfo searchResultFormation(List<ContentVersion> contents, List<Materials__c> materials, List<AggregateResult> formats,List<AggregateResult> languages,List<AggregateResult> series,List<AggregateResult> dlsSection,Map<Id,String> langIdNameMap){ 
    
        UtilDomain.SearchResultInfo searchInfo = new UtilDomain.SearchResultInfo();
        searchInfo.contentRecords = contents;
        searchInfo.materialRecords = materials;

        //Format filter formation
        if(contents.size() > 0){
            searchInfo.formatValues = filterFormation(formats,new Map<Id,String>{},'FileType');
        }else if(materials.size() > 0){
            searchInfo.formatValues = filterFormation(formats,new Map<Id,String>{},'Book_format__c');
        }
        
        //Language filter formation
        searchInfo.languageValues = filterFormation(languages,langIdNameMap,'Language_LU__c');
       
        //Series Filter Formation
        searchInfo.seriesValues = filterFormation(series,new Map<Id,String>{},'Book_Series__c');
        
        //DLS Section filter formation
        searchInfo.dlsSectionValues = filterFormation(dlsSection,new Map<Id,String>{},'DLS_Section__c');
        
        system.debug(':::::::::searchInfo::::'+searchInfo);
        
        return searchInfo;
    }
    
    public static List<UtilDomain.FilterDetails> filterFormation(List<AggregateResult> filterRecords,Map<Id,String> langIdNameMap,String fieldName){
        
        List<UtilDomain.FilterDetails> filterValues = new List<UtilDomain.FilterDetails>();
        
        if(filterRecords.size() > 0) {
            for(AggregateResult agg : filterRecords){
            
                UtilDomain.FilterDetails info = new UtilDomain.FilterDetails();
                
                String fieldValue = (String) agg.get(fieldName);
                
                if(fieldValue == null){
                    info.label = 'Other';
                    info.value = 'Other';
                }else {
                    
                    if(fieldName == 'Language_LU__c' && langIdNameMap.containsKey(fieldValue)){
                        info.label = langIdNameMap.get(fieldValue);
                    }else {
                        info.label = fieldValue;
                    }
                    
                    info.value = fieldValue;
                }
                info.label += ' ('+String.valueOf((Integer) agg.get('expr0'))+')';
                
                filterValues.add(info);
            }
        }else {
            UtilDomain.FilterDetails info = new UtilDomain.FilterDetails();
            for(Id lanId : langIdNameMap.keySet()){
                info.label = langIdNameMap.get(lanId) + ' (0)';
                info.value = lanId;
            }
            filterValues.add(info);
        }
        
        return filterValues;
    }
}