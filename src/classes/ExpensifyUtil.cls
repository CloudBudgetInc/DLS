public class ExpensifyUtil {

    public static final String partnerUserID = 'aa_apisync_dlsdc_com';
    public static final String partnerUserSecret = '1c37614beac18b3dd08e3df7388ec851fd802ffd';
	
    public class getCreditCardReqWrap{
        public String type = 'get';
        public wrapCredentials credentials = new wrapCredentials();
        public Map<String, String> inputSettings = new Map<String, String>{
            'type' => 'domainCardList',
            'domain' => 'dlsdc.com'
        };      	
    }
    
    public class createReportReqWrap{
        public String type = 'reconciliation';
        public wrapCredentials credentials = new wrapCredentials();
        public inputSettingsReportWrap inputSettings = new inputSettingsReportWrap();    
      	public Map<String, String> outputSettings = new Map<String, String>{ 'fileExtension' => 'json'};       
    }
    
    public class getReportReqWrap{
        
        public String type = 'download';
        public wrapCredentials credentials = new wrapCredentials();
        public String fileName;
        public String fileSystem = 'reconciliation';      
    }
    
    public class wrapCredentials{
        public String partnerUserID = ExpensifyUtil.partnerUserID;
        public String partnerUserSecret = ExpensifyUtil.partnerUserSecret;
    }    
    
    public class inputSettingsReportWrap{
        
        public String type = 'All';
        public Boolean async = false;
        public String feed = 'export_all_feeds';
        public String startDate;
        public String endDate;
        public String domain = 'dlsdc.com';
    }    
    	   
    public static String createReport(String startDate, String endDate){
        
        String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        String endPoint = 'https://integrations.expensify.com/Integration-Server/ExpensifyIntegrations?requestJobDescription=';
        createReportReqWrap reportReqObj = new createReportReqWrap();
        reportReqObj.inputSettings.startDate = startDate;
        reportReqObj.inputSettings.endDate = endDate;
        endPoint += JSON.serialize(reportReqObj);
        System.debug('endPoint::>'+endPoint);
        req2.setEndpoint(endPoint);
        req2.setMethod('POST');
        req2.setHeader('Content-Length', '4000');
        req2.setHeader('Content-Type', 'application/x-www-form-urlencoded');
       
        req2.setTimeout(120000); 
        req2.setBody('template=%3C%21--%20use%20cardOwnerData%20--%3E%0A%3C%23function%20quoteCsv%20string%3E%0A%20%20%20%3C%23if%20string%3Fcontains%28%22%2C%22%29%20%26%26%20%21string%3Fstarts_with%28%22%5C%22%22%29%3E%0A%20%20%20%20%20%20%20%3C%23return%20%22%5C%22%22%20%2B%20string%3Freplace%28%22%5C%22%22%2C%20%22%5C%5C%5C%22%22%29%20%2B%20%22%5C%22%22%3E%0A%20%20%20%3C%2F%23if%3E%0A%20%20%20%20%3C%23return%20string%3E%0A%3C%2F%23function%3E%0A%3C%23function%20unescapeHtml%20string%3E%0A%20%20%20%20%3C%23return%20string%3Freplace%28%22%26lt%3B%22%2C%20%22%3C%22%29%3Freplace%28%22%26gt%3B%22%2C%20%22%3E%22%29%3Freplace%28%22%26amp%3B%22%2C%20%22%26%22%29%3Freplace%28%22%26quot%3B%22%2C%20%22%5C%22%22%29%3Freplace%28%22%26apos%3B%22%2C%20%22%27%22%29%3E%0A%3C%2F%23function%3E%0A%5B%0A%3C%23lt%3E%0A%20%20%20%20%3C%23list%20cards%20as%20card%2C%20reports%3E%0A%3C%23assign%20individualEmployeeObject%20%3D%20cardOwnerData%5Bcard.owner%5D%21%7B%7D%3E%0A%3C%23assign%20individualEmployeeData%20%3D%20individualEmployeeObject.mapData%21%7B%7D%3E%0A%20%20%20%20%20%20%20%20%3C%23list%20reports%20as%20report%3E%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%3C%23list%20report.transactionList%20as%20expense%3E%20%20%20%20%20%20%20%20%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%7B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3C%23lt%3E%20%22invoiceComment%22%3A%20%22%24%7Bexpense.originalMerchant%7D%22%2C%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3C%23lt%3E%20%22postDate%22%3A%20%22%24%7Bexpense.posted%7D%22%2C%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3C%23lt%3E%20%22total%22%3A%20%24%7B%28expense.originalAmount%2F100%29%3Fstring%28%220.00%22%29%7D%2C%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3C%23lt%3E%20%22Expense_GL_Account%22%3A%20%22%24%7BquoteCsv%28unescapeHtml%28expense.category%29%29%7D%22%2C%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3C%23lt%3E%20%22GL_Account_Variable_1%22%3A%20%22%24%7BquoteCsv%28unescapeHtml%28expense.tag%29%29%7D%22%2C%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3C%23lt%3E%20%22empEmail%22%3A%20%22%24%7BquoteCsv%28unescapeHtml%28card.owner%29%29%7D%22%2C%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3C%23lt%3E%20%22Internal_Comment%22%3A%20%22%24%7BquoteCsv%28unescapeHtml%28expense.comment%29%29%7D%22%2C%0A%09%09%3C%23lt%3E%20%22bank%22%3A%22%24%7Bcard.bank%7D%22%2C%0A%09%09%3C%23lt%3E%20%22status%22%3A%22%24%7Breport.status%21%22%22%7D%22%2C%0A%09%09%3C%23lt%3E%20%22transactionId%22%3A%22%24%7Bexpense.ID%7D%22%2C%0A%09%09%3C%23lt%3E%20%22cardId%22%3A%20%22%24%7Bcard.ID%7D%22%2C%0A%09%09%3C%23lt%3E%20%22firstName%22%3A%20%22%24%7BindividualEmployeeData.firstName%7D%22%2C%0A%09%09%3C%23lt%3E%20%22lastName%22%3A%20%22%24%7BindividualEmployeeData.lastName%7D%22%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3C%23lt%3E%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%7D%2C%0A%20%20%20%20%20%20%20%20%20%20%20%20%3C%23lt%3E%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%3C%2F%23list%3E%0A%20%20%20%20%20%20%20%20%3C%2F%23list%3E%0A%20%20%20%20%3C%2F%23list%3E%0A%5D%20');        
        System.debug(req2.getBody());
        HttpResponse res = http.send(req2);
        Map<String, Object> resultObj = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        System.debug('resultObj::>'+resultObj);
        if(res.getStatusCode() == 200){
			
            if(String.valueof(resultObj.get('responseCode')) == '200'){
                String fileName =  String.valueof(resultObj.get('filename'));
            	System.debug('filename:>'+fileName);
                result = getReport(fileName);                
            }else{
                System.debug( String.valueof(resultObj.get('responseMessage'))); 
            }           
        }else{
        	result = res.getBody();
        }
        
        return result;
    }
    
    public static String getReport(String fileName){
        
    	String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        getReportReqWrap reqWrap = new getReportReqWrap();
        reqWrap.fileName = fileName;
        String endPoint = 'https://integrations.expensify.com/Integration-Server/ExpensifyIntegrations?requestJobDescription=';
        endPoint += JSON.serialize(reqWrap);
        req2.setEndpoint(endPoint);
        req2.setMethod('POST');
        req2.setHeader('Content-Length', '99');
        req2.setTimeout(120000);
        req2.setBody('');
        HttpResponse res = http.send(req2);
        result = res.getBody();
        System.debug('result::>'+result);
        if(res.getStatusCode() == 200){
            result = result.replaceAll('<!-- use cardOwnerData -->','');            
            Integer index;
            if(result.countMatches(']') > 1){                
                index = result.lastIndexOf(']');               
                result = result.left(index);                  
                index = result.lastIndexOf('[');
                result = result.substring(0, index) + result.substring(index+1); 
                index = result.lastIndexOf(']');
                result = result.substring(0, index) + result.substring(index+1); 
                index = result.lastIndexOf(',');
            	result = result.left(index)+result.right(result.length()-index-1)+']';
            }else{
                index = result.lastIndexOf(',');
            	result = result.left(index)+result.right(result.length()-index-1);
            }
			                         
        }else{
        	result = res.getBody();
        }
        
        return result;
    } 
    
    public static String getExpensifyCreditCards(){
        
    	String result ='';
        
        Http http = new Http();
        HttpRequest req2 = new HttpRequest();
        
        String endPoint = 'https://integrations.expensify.com/Integration-Server/ExpensifyIntegrations?requestJobDescription=';
        endPoint += JSON.serialize(new getCreditCardReqWrap());
        req2.setEndpoint(endPoint);
        req2.setMethod('POST');
        req2.setHeader('Content-Length', '99');
        req2.setTimeout(120000);
        req2.setBody('');
        HttpResponse res = http.send(req2);
        String resultStr = res.getBody();
        System.debug('result::>'+result);
        Map<String, Object> resultObj = (Map<String, Object>) JSON.deserializeUntyped(resultStr);
        result = JSON.serialize(resultObj.get('domainCardList'));
        
        return result;
    }
}