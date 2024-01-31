@isTest
global class BillDotComUtilMockHttpResponseGenerator{

    global class BillDotComUtilMock1 implements HttpCalloutMock{
    
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            
            return login();
        }
    }
    
    global static HTTPResponse login(){
        
        BillDotComUtil.ResponseData resp = new BillDotComUtil.ResponseData();
        resp.sessionId = '';
        resp.orgId = '';
        
        BillDotComUtil.LoginResponse logRes = new BillDotComUtil.LoginResponse();
        logRes.response_status = '0';
        logRes.response_message = 'Success';
        logRes.response_data = resp;
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        //res.setHeader('Content-Type', 'application/json');
        res.setHeader('Set-Cookie', 'un_csrf=!/application/json/un_csrf=!/JSON/pageuid=!/application/json');
        res.setBody(JSON.serialize(logRes));
        res.setStatusCode(200);
        return res;
    }
    
    // For VendorCreation batch
    global class BillDotComUtilMock2 implements HttpCalloutMock{
    
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            
            if(req.getEndpoint().contains('Login.json')){
                return login();
            }else{
                BillDotComUtil.VendorRequest venReq = new BillDotComUtil.VendorRequest();
                venReq.Id = 'test';
                
                BillDotComUtil.VendorResponse venRes = new BillDotComUtil.VendorResponse();
                venRes.response_status = '0';
                venRes.response_message = 'Success';
                venRes.response_data = venReq;
                
                // Create a fake response
                HttpResponse res = new HttpResponse();
                //res.setHeader('Content-Type', 'application/json');
                res.setHeader('Set-Cookie', 'un_csrf=!/application/json/un_csrf=!/JSON/pageuid=!/application/json');
                res.setBody(JSON.serialize(venRes));
                res.setStatusCode(200);
                return res;
            }
        }
    }
    
    // For VendorCreation batch
    global class BillDotComUtilMock3 implements HttpCalloutMock{
    
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            if(req.getEndpoint().contains('Login.json')){
                return login();
            }else{
                BillDotComUtil.VendorRequest venReq = new BillDotComUtil.VendorRequest();
                venReq.Id = 'test';
                venReq.createdTime = System.now();
                venReq.updatedTime = System.now();
                
                BillDotComUtil.VendorResponse venRes = new BillDotComUtil.VendorResponse();
                venRes.response_status = '0';
                venRes.response_message = 'Success';
                venRes.response_data = venReq;
                
                // Create a fake response
                HttpResponse res = new HttpResponse();
                //res.setHeader('Content-Type', 'application/json');
                res.setHeader('Set-Cookie', 'un_csrf=!/application/json/un_csrf=!/JSON/pageuid=!/application/json');
                res.setBody(JSON.serialize(venRes));
                res.setStatusCode(200);
                return res;
            }
        }
    }
    
    // For JobCreation batch
    global class BillDotComUtilMock4 implements HttpCalloutMock{
    
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            if(req.getEndpoint().contains('Login.json')){
                return login();
            }else{
                BillDotComUtil.JobRequest jobReq = new BillDotComUtil.JobRequest();
                jobReq.Id = 'Test';
                jobReq.createdTime = System.now();
                jobReq.updatedTime = System.now();
                        
                BillDotComUtil.JobResponse jobRes = new BillDotComUtil.JobResponse();
                jobRes.response_status = '0';
                jobRes.response_data = jobReq;
            
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                //res.setHeader('Set-Cookie', 'un_csrf=!/application/json/un_csrf=!/JSON/pageuid=!/application/json');
                res.setBody(JSON.serialize(jobRes));
                res.setStatusCode(200);
                return res;
            }
        }
    }
    
    // For ChartOfAccountCreation batch
    global class BillDotComUtilMock5 implements HttpCalloutMock{
    
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            if(req.getEndpoint().contains('Login.json')){
                return login();
            }else{
                BillDotComUtil.ChartOfAccountRequest chartReq = new BillDotComUtil.ChartOfAccountRequest();
                chartReq.id = 'test1';         
               
                        
                BillDotComUtil.ChartOfAccountResponse chartRes = new BillDotComUtil.ChartOfAccountResponse();
                chartRes.response_status = '0'; 
                chartRes.response_message = 'success';
                chartRes.response_data = chartReq; 
            
                // Create a fake response
                HttpResponse res = new HttpResponse();
                //res.setHeader('Content-Type', 'application/json');
                res.setHeader('Set-Cookie', 'un_csrf=!/application/json/un_csrf=!/JSON/pageuid=!/application/json');
                res.setBody(JSON.serialize(chartRes));
                res.setStatusCode(200);
                return res;
            }
        }
    }
    
    // For ItemCreation batch
    global class BillDotComUtilMock6 implements HttpCalloutMock{
    
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            if(req.getEndpoint().contains('Login.json')){
                return login();
            }else{
                BillDotComUtil.ItemRequest itemReq = new BillDotComUtil.ItemRequest();
                itemReq.id = 'test1';         
                itemReq.createdTime = System.today();
                itemReq.updatedTime = System.today();
                        
                BillDotComUtil.ItemResponse itemRes = new BillDotComUtil.ItemResponse();
                itemRes.response_status = '0'; 
                itemRes.response_message = 'success';
                itemRes.response_data = itemReq; 
            
                // Create a fake response
                HttpResponse res = new HttpResponse();
                //res.setHeader('Content-Type', 'application/json');
                res.setHeader('Set-Cookie', 'un_csrf=!/application/json/un_csrf=!/JSON/pageuid=!/application/json');
                res.setBody(JSON.serialize(itemRes));
                res.setStatusCode(200);
                return res;
            }
        }
    }
    // For ItemCreation batch
    global class BillDotComUtilMock10 implements HttpCalloutMock{
    
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            if(req.getEndpoint().contains('Login.json')){
                return login();
            }else{
                BillDotComUtil.ItemRequest itemReq = new BillDotComUtil.ItemRequest();
                        
                BillDotComUtil.ItemResponse itemRes = new BillDotComUtil.ItemResponse();
                itemRes.response_status = '1'; 
                itemRes.response_message = 'failure';
                itemRes.response_data = itemReq; 
            
                // Create a fake response
                HttpResponse res = new HttpResponse();
                //res.setHeader('Content-Type', 'application/json');
                res.setHeader('Set-Cookie', 'un_csrf=!/application/json/un_csrf=!/JSON/pageuid=!/application/json');
                res.setBody(JSON.serialize(itemRes));
                res.setStatusCode(200);
                return res;
            }
        }
    }
    
    // For ClassCreation batch
    global class BillDotComUtilMock7 implements HttpCalloutMock{
    
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            
            if(req.getEndpoint().contains('Login.json')){
                return login();
            }else{
                BillDotComUtil.ClassRequest classReq = new BillDotComUtil.ClassRequest();
                classReq.id = 'test1';         
                classReq.createdTime = System.today();
                //classReq.updatedTime = System.today();
                        
                BillDotComUtil.ClassResponse classRes = new BillDotComUtil.ClassResponse();
                classRes.response_status = '0'; 
                classRes.response_message = 'success';
                classRes.response_data = classReq; 
                System.debug('classRes::>'+classRes);
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                //res.setHeader('Set-Cookie', 'un_csrf=!/application/json/un_csrf=!/JSON/pageuid=!/application/json');
                res.setBody(JSON.serialize(classRes));
                res.setStatusCode(200);
                return res;
            }
        }
    }
       // get get Bill,Bill Items Info
    global class BillDotComUtilMock8 implements HttpCalloutMock{
    
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            
            if(req.getEndpoint().contains('Login.json')){
                return login();
            }else{
                List<BillDotComUtil.BillLineItemRequest>  billItemsList  = new List<BillDotComUtil.BillLineItemRequest>();
                List<BillDotComUtil.BillRequest> billResponseLst = new List<BillDotComUtil.BillRequest>();
                
                BillDotComUtil.BillLineItemRequest  billItems = new BillDotComUtil.BillLineItemRequest();
                
                billItems.id = 'TestPayableLine2';
                billItems.billId = 'test';
                billItems.amount = 200;
                billItems.price = 2;        
                billItems.chartOfAccountId = 'TestchartOfAccountId';
                billItems.jobId = 'TestProject1';
                billItems.description = 'Comment';
                billItems.createdTime = System.Today();
                billItems.updatedTime = System.Today();
                billItems.lineType = '2';  
                billItems.quantity = 2;
                billItems.jobBillable = false;
                
                BillDotComUtil.BillLineItemRequest  billItems2 = new BillDotComUtil.BillLineItemRequest();
                
                billItems.id = 'TestPayableLine1';
                billItems.billId = 'test';
                billItems.amount = 100;
                billItems.price = 2;        
                billItems.chartOfAccountId = 'TestchartOfAccountId';
                billItems.jobId = 'TestProjectId';
                billItems.description = 'Comment';
                billItems.createdTime = System.Today();
                billItems.updatedTime = System.Today();
                billItems.lineType = '2';  
                billItems.quantity = 2;
                billItems.itemId = 'TestProjectTask1';
                billItems.jobId = 'TestProject1';
                billItems.jobBillable = true;  
                
                billItemsList.add(billItems);
                billItemsList.add(billItems2);
                
                BillDotComUtil.BillRequest BillRequest = new BillDotComUtil.BillRequest();
                BillRequest.id = 'TestPayable';
                BillRequest.vendorId = 'testVendor';
                BillRequest.invoiceNumber = '12345';
                BillRequest.approvalStatus = '0';    
                BillRequest.invoiceDate = System.today();
                BillRequest.dueDate = System.today();
                BillRequest.glPostingDate = System.today().addDays(2);
                BillRequest.amount = 300;
                BillRequest.paymentStatus = '4';   
                BillRequest.createdTime = System.today();
                BillRequest.updatedTime = System.today();
                BillRequest.billLineItems = billItemsList;
                
                billResponseLst.add(BillRequest);
                
                BillDotComUtil.BillRequest BillRequest2 = new BillDotComUtil.BillRequest();
                BillRequest2.id = 'TestPayable1';
                BillRequest2.vendorId = 'testVendor';
                BillRequest2.invoiceNumber = '12345';
                BillRequest2.approvalStatus = '2';    
                BillRequest2.invoiceDate = null;
                BillRequest2.dueDate = null;
                BillRequest2.paymentStatus = '4';   
                BillRequest2.createdTime = System.today();
                BillRequest2.updatedTime = System.today();
                BillRequest2.billLineItems = new List<BillDotComUtil.BillLineItemRequest>();
                
                billResponseLst.add(BillRequest2);
                
                BillDotComUtil.BillResponseList billRes = new BillDotComUtil.BillResponseList();
                billRes.response_status = '0'; 
                billRes.response_message = 'success';
                billRes.response_data = billResponseLst; 
                System.debug('billRes::>'+billRes);
                
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                //res.setHeader('Set-Cookie', 'un_csrf=!/application/json/un_csrf=!/JSON/pageuid=!/application/json');
                res.setBody(JSON.serialize(billRes));
                res.setStatusCode(200);
                return res;
            }
        }
    }
    // get Bill Payments Info
    global class BillDotComUtilMock9 implements HttpCalloutMock{
        
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            
            if(req.getEndpoint().contains('Login.json')){
                return login();
            }else{
                List<BillDotComUtil.SendPayRequest> sendPayList = new List<BillDotComUtil.SendPayRequest>();
                BillDotComUtil.SendPayRequest sendPays = new BillDotComUtil.SendPayRequest();
                
                sendPays.id = 'sendpayId';
                sendPays.amount = 200;
                sendPays.status = '4';
                sendPays.description = '12345';
                sendPays.name = 'cashDisbursement';
                sendPays.vendorId = 'testVendor'; 
                sendPays.chartOfAccountId = 'TestchartOfAccountId';
                sendPays.syncReference = '22';
                sendPays.processDate =  system.today();
                sendPays.bankAccountId = 'TestbankId';
                sendPays.createdTime = system.today();
                sendPays.updatedTime = system.today();
                
                BillDotComUtil.SendPayRequest sendPays2 = new BillDotComUtil.SendPayRequest();
                
                sendPays2.id = 'sendpay2Id';
                sendPays2.amount = 300;
                sendPays2.status = '2';
                sendPays2.description = '12345';
                sendPays2.name = 'cashDisbursement2';
                sendPays2.vendorId = 'testVendor1'; 
                sendPays2.chartOfAccountId = 'testGLAccountId2';
                sendPays2.bankAccountId = 'TestbankId';
                sendPays2.createdTime = system.today();
                sendPays2.updatedTime = system.today();
                
                sendPayList.add(sendPays);
                sendPayList.add(sendPays2);
                
                BillDotComUtil.SendPayResponseList sendPayRes = new BillDotComUtil.SendPayResponseList();
                sendPayRes.response_status = '0'; 
                sendPayRes.response_message = 'success';
                sendPayRes.response_data = sendPayList; 
                System.debug('sendPayList::>'+sendPayRes);
                
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                //res.setHeader('Set-Cookie', 'un_csrf=!/application/json/un_csrf=!/JSON/pageuid=!/application/json');
                res.setBody(JSON.serialize(sendPayRes));
                res.setStatusCode(200);
                return res;
            }
        }
    }
      // For JobCreation batch
    global class BillDotComUtilMock11 implements HttpCalloutMock{
    
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            if(req.getEndpoint().contains('Login.json')){
                return login();
            }else{
                BillDotComUtil.JobRequest jobReq = new BillDotComUtil.JobRequest();
             
                BillDotComUtil.JobResponse jobRes = new BillDotComUtil.JobResponse();
                jobRes.response_status = '1';
                jobRes.response_message = 'failure';
                jobRes.response_data = jobReq;
            
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                //res.setHeader('Set-Cookie', 'un_csrf=!/application/json/un_csrf=!/JSON/pageuid=!/application/json');
                res.setBody(JSON.serialize(jobRes));
                res.setStatusCode(200);
                return res;
            }
        }
    }
    
    global class BillDotComUtilMock12 implements HttpCalloutMock{
        
            // Implement this interface method
            global HTTPResponse respond(HTTPRequest req) {
                
                if(req.getEndpoint().contains('Login.json')){
                    return login();
                }else{
                    List<BillDotComUtil.VendorCreditLineItemsRequest>  vendCreditLinesList  = new List<BillDotComUtil.VendorCreditLineItemsRequest>();
                    List<BillDotComUtil.VendorCreditRequest> vendorCreditResponseLst = new List<BillDotComUtil.VendorCreditRequest>();
                    
                    BillDotComUtil.VendorCreditLineItemsRequest  vendCreditLines = new BillDotComUtil.VendorCreditLineItemsRequest();
                    
                    vendCreditLines.id = 'TestPayableLine2';
                    vendCreditLines.amount = 200;
                    vendCreditLines.chartOfAccountId = 'TestchartOfAccountId';
                    vendCreditLines.jobId = 'TestProject1';
                    vendCreditLines.description = 'Comment';
                    vendCreditLines.createdTime = System.Today();
                    vendCreditLines.updatedTime = System.Today();
                    vendCreditLines.lineType = '2';  
                    vendCreditLines.quantity = 2;
                    vendCreditLines.jobBillable = false;
                    
                    BillDotComUtil.VendorCreditLineItemsRequest  vendCreditLines2 = new BillDotComUtil.VendorCreditLineItemsRequest();
                    
                    vendCreditLines2.id = 'TestPayableLine1';
                    vendCreditLines2.amount = 100;
                    vendCreditLines2.chartOfAccountId = 'TestchartOfAccountId';
                    vendCreditLines2.jobId = 'TestProjectId';
                    vendCreditLines2.description = 'Comment';
                    vendCreditLines2.createdTime = System.Today();
                    vendCreditLines2.updatedTime = System.Today();
                    vendCreditLines2.lineType = '2';  
                    vendCreditLines2.quantity = 2;
                    vendCreditLines2.itemId = 'TestProjectTask1';
                    vendCreditLines2.jobId = 'TestProject1';
                    vendCreditLines2.jobBillable = true;  
                    
                    vendCreditLinesList.add(vendCreditLines);
                    vendCreditLinesList.add(vendCreditLines2);
                    
                    BillDotComUtil.VendorCreditRequest vendRequest = new BillDotComUtil.VendorCreditRequest();
                    vendRequest.id = 'TestPayable';
                    vendRequest.vendorId = 'testVendor';
                    vendRequest.approvalStatus = '0';    
                    vendRequest.glPostingDate = System.today().addDays(2);
                    vendRequest.amount = 300;
                    vendRequest.createdTime = System.today();
                    vendRequest.updatedTime = System.today();
                    vendRequest.isActive = '1';
                    vendRequest.vendorCreditLineItems = vendCreditLinesList;
                    
                    vendorCreditResponseLst.add(vendRequest);
                    
                    BillDotComUtil.VendorCreditRequest vendRequest2 = new BillDotComUtil.VendorCreditRequest();
                    vendRequest2.id = 'TestPayable1';
                    vendRequest2.vendorId = 'testVendor';
                    vendRequest2.approvalStatus = '2';    
                    vendRequest2.createdTime = System.today();
                    vendRequest2.updatedTime = System.today();
                    vendRequest2.vendorCreditLineItems = new List<BillDotComUtil.VendorCreditLineItemsRequest>();
                    
                vendorCreditResponseLst.add(vendRequest2);
                
                BillDotComUtil.VendorCreditResponseList vendRes = new BillDotComUtil.VendorCreditResponseList();
                vendRes.response_status = '0'; 
                vendRes.response_message = 'success';
                vendRes.response_data = vendorCreditResponseLst; 
                System.debug('vendRes::>'+vendRes);
                
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                //res.setHeader('Set-Cookie', 'un_csrf=!/application/json/un_csrf=!/JSON/pageuid=!/application/json');
                res.setBody(JSON.serialize(vendRes));
                res.setStatusCode(200);
                return res;
            }
        }
    }
}