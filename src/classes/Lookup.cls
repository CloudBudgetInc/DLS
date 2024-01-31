/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 10/20/2022
 * @last modified by  : Dhinesh Kumar
**/
public with sharing class Lookup {

    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , String searchField, String fields, string sObjectApiName, String filter , List<String> selectedIds) {    
        System.debug('selectedIds : '+selectedIds);
        List < sObject > returnList = new List < sObject > ();
        if(String.isBlank(fields)){
            fields = 'Id, Name';
        }
        string sQuery = 'Select '+ fields +' from '+sObjectApiName;

        if(!String.isBlank(searchKey)){
            sQuery += ' Where '+searchField+' Like  \'%' + searchKey + '%\'';
            if(filter != null && filter != ''){
                sQuery += ' AND '+filter;
                if(selectedIds != null && selectedIds.size() > 0 ){
                    sQuery += 'AND Id NOT IN :selectedIds ';    
                }
            }
            else if((filter == null || filter == '') && ( selectedIds != null && selectedIds.size() > 0) ){
                sQuery += 'AND Id NOT IN :selectedIds ';
            }
        }                        

        if(String.isBlank(searchKey)){
            if(filter != null && filter != ''){
                sQuery += ' Where '+filter;
            }
            else if((filter == null || filter == '') && ( selectedIds != null && selectedIds.size() > 0) ){
                sQuery += ' WHERE Id NOT IN :selectedIds ';
            }
            sQuery += ' ORDER BY LastModifiedDate DESC';
        }

        sQuery += ' LIMIT  5';
        System.debug(sQuery);
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
}