@isTest
private class BillDotComUtil_Test{

    //Cover getCookieAndSessionId()
    private static testMethod void myTest1(){
    
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        
        Test.startTest();
        
            BillDotComUtil.getCookieAndSessionId(); 
            
        Test.stopTest();
    }
    
    //Cover dateTimeConverion()
    private static testMethod void myTest2(){
            
        BillDotComUtil.dateTimeConverion('2020-04-24 08:32:42.000+0000'); 
    }
    
    //Cover vendorMethod()
    private static testMethod void myTest3(){
            
        BillDotComUtil.VendorRequest vendorReq = new BillDotComUtil.VendorRequest();
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        
        Test.startTest();
        
            BillDotComUtil.vendorMethod(vendorReq, 'create'); 
        Test.stopTest();
    }
    
    //Cover vendorMethod()
    private static testMethod void myTest3a(){
            
        BillDotComUtil.VendorRequest vendorReq = new BillDotComUtil.VendorRequest();
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        
        Test.startTest();
        
            BillDotComUtil.vendorMethod(vendorReq, 'update'); 
        Test.stopTest();
    }
    
    //Cover jobMethod()
    private static testMethod void myTest4(){
            
        BillDotComUtil.JobRequest jobReq = new BillDotComUtil.JobRequest();
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        
        Test.startTest();
            Map<String,String> cookieAdSessionMap;
            BillDotComUtil.jobMethod(jobReq, 'create', cookieAdSessionMap); 
        Test.stopTest();
    }
    
    //Cover jobMethod()
    private static testMethod void myTest4a(){
            
        BillDotComUtil.JobRequest jobReq = new BillDotComUtil.JobRequest();
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        
        Test.startTest();
            Map<String,String> cookieAdSessionMap;
            BillDotComUtil.jobMethod(jobReq, 'update', cookieAdSessionMap); 
        Test.stopTest();
    }
    
    //Cover itemMethod()
    private static testMethod void myTest5(){
            
        BillDotComUtil.ItemRequest itemReq = new BillDotComUtil.ItemRequest();
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        
        Test.startTest();
            Map<String,String> cookieAdSessionMap;
            BillDotComUtil.itemMethod(itemReq, 'create', cookieAdSessionMap); 
        Test.stopTest();
    }
    
    //Cover itemMethod()
    private static testMethod void myTest5a(){
            
        BillDotComUtil.ItemRequest itemReq = new BillDotComUtil.ItemRequest();
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        
        Test.startTest();
            Map<String,String> cookieAdSessionMap;
            BillDotComUtil.itemMethod(itemReq, 'update', cookieAdSessionMap); 
        Test.stopTest();
    }
    
    //Cover classMethod()
    private static testMethod void myTest6(){
            
        BillDotComUtil.ClassRequest classReq = new BillDotComUtil.ClassRequest();
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        
        Test.startTest();
            Map<String,String> cookieAdSessionMap;
            BillDotComUtil.classMethod(classReq, 'create', cookieAdSessionMap); 
        Test.stopTest();
    }
    
    //Cover classMethod()
    private static testMethod void myTest6a(){
            
        BillDotComUtil.ClassRequest classReq = new BillDotComUtil.ClassRequest();
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        
        Test.startTest();
            Map<String,String> cookieAdSessionMap;
            BillDotComUtil.classMethod(classReq, 'update', cookieAdSessionMap); 
        Test.stopTest();
    }
    
    //Cover chartOfAccountMethod()
    private static testMethod void myTest7(){
            
        BillDotComUtil.ChartOfAccountRequest cOAReq = new BillDotComUtil.ChartOfAccountRequest();
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        
        Test.startTest();
            Map<String,String> cookieAdSessionMap;
            BillDotComUtil.chartOfAccountMethod(cOAReq, 'create', cookieAdSessionMap); 
        Test.stopTest();
    }
    
    //Cover chartOfAccountMethod()
    private static testMethod void myTest7a(){
            
        BillDotComUtil.ChartOfAccountRequest cOAReq = new BillDotComUtil.ChartOfAccountRequest();
        
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock1());
        
        Test.startTest();
            Map<String,String> cookieAdSessionMap;
            BillDotComUtil.chartOfAccountMethod(cOAReq, 'update', cookieAdSessionMap); 
        Test.stopTest();
    }

    //Cover BillDotComUtil.getList() for Bill and Bill Line Items
    private static testMethod void myTest8(){
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock8());
        
        Test.startTest();
        
        BillDotComUtil.getList('Bill',system.today()+'T00:00:00.000+0000',system.today()+'T00:00:00.000+0000');
        Test.stopTest();
    }
    //Cover BillDotComUtil.getList()  for SendpayList
     private static testMethod void myTest8b(){
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock9());
        
        Test.startTest();
        
        BillDotComUtil.getList('SentPay',system.today()+'T00:00:00.000+0000',system.today()+'T00:00:00.000+0000');
        Test.stopTest();
    }
     //Cover BillDotComUtil.getList()  for VendorCredit and VendorCreditLine
     private static testMethod void myTest9(){
        Test.setMock(HttpCalloutMock.class, new BillDotComUtilMockHttpResponseGenerator.BillDotComUtilMock12());
        
        Test.startTest();
        
        BillDotComUtil.getList('VendCredit',system.today()+'T00:00:00.000+0000',system.today()+'T00:00:00.000+0000');
        Test.stopTest();
    }
    
}