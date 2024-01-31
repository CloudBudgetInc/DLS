@isTest
private class ErrorHandler_Test{

    // To cover sendExceptionEmail() method
    private static testMethod void myTest1(){
    
        ErrorHandler eh = new ErrorHandler();
        eh.sendExceptionEmail('Test error message', 'mytest@softsquare.biz', 'Test subject');
    }
        
    // To cover publishErrorLog() method
    private static testMethod void myTest3(){
                
        List<ErrorHandler.ErrorLogUtilDomain> errorLogUtilDomainList = new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('Test method','Test description','Test response', 'ErrorHandler_Test', 'Account', 'Trigger')};
        
        ErrorHandler.publishErrorLog(errorLogUtilDomainList);
    }
    
    // To cover publishErrorLog_Flow() method
    private static testMethod void myTest4(){
    
        List<ErrorHandler.ErrorLogUtilDomain_Flow> flowErrorLogUtilDomainList = new List<ErrorHandler.ErrorLogUtilDomain_Flow>();
        
        ErrorHandler.ErrorLogUtilDomain_Flow domain = new ErrorHandler.ErrorLogUtilDomain_Flow();
        domain.classOrTriggerName = 'ErrorHandler_Test';
        domain.methodName = 'Test Method';
        domain.Description = 'Test response';
        flowErrorLogUtilDomainList.add(domain);
        
        ErrorHandler.publishErrorLog_Flow(flowErrorLogUtilDomainList);
    }
}