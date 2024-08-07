/**
* CONGA BATCH
* Used in Billing List View button
* @description Builds list of sObject Ids from recordSetVar and constructs the Conductor URL
* Copy pasted code provided by Conga Batch
* used in Page BatchListView
*/
public class ConductorFromListViewController {
  private final static String urlFieldName = 'Conga_Batch_Download_Billing_PDF__c';
  private String partnerServerUrl;
  private ApexPages.StandardSetController controller;
  private List<Id> recordIds = new List<Id>();

  public ConductorFromListViewController(ApexPages.StandardSetController controller) {
    this.controller = controller;
    for (sObject sObj : controller.getSelected()){
      recordIds.add(sObj.Id);
    }
    partnerServerUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/26.0/'+UserInfo.getOrganizationId();
  } 

  public PageReference prepareConductorUrl() {
    PageReference conductorUrl = new PageReference('https://conductor.congamerge.com?');
    conductorUrl.getParameters().put('MOID', String.join(new List<Id>(recordIds),','));
    conductorUrl.getParameters().put('SessionId',  UserInfo.getSessionID());
    conductorUrl.getParameters().put('ServerUrl',  partnerServerUrl);
    conductorUrl.getParameters().put('UrlFieldName',  urlFieldName);

    return conductorUrl;
  }
}