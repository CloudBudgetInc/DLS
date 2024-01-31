@isTest
private class ExportListViewController_Test {
    
    static testmethod void test1() {
    
        List<Export_List__mdt> exportList = [SELECT Id,DeveloperName,Field_Name__c,Condition__c,Object_Name__c FROM Export_List__mdt WHERE Object_Name__c = 'Contact' LIMIT 10];
        system.debug('::::::::exportList:::'+exportList);
        
        ExportListViewController.getListViewOptions();
        ExportListViewController.getListViewRecords(exportList[0].Id);
    }
    
}