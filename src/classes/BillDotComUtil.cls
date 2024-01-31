/**********************************************************************************
- For Bill.com integration
- All objects request & response wrapper will be placed here (Account, Project, Project Task, Accounting Variable, GL Accounts) - 
    (Vendor, Job, Item, Class, Chart of Accounts)
- Created by NS on April 23 2020
***********************************************************************************/
global class BillDotComUtil {
    
    public static Boolean updateFromBillDotComSync = false;
    
    //Authendication & Login
    global class LoginResponse {
        public String response_status; // 0:Success, 1:Failed
        public String response_message;
        public ResponseData response_data;
    }
    
    //Login response data node details
    global class ResponseData {
        public String sessionId;
        public String orgId;
        public String apiEndPoint;
        public String usersId;
        public String error_code;
        public String error_message;
    }
    
    //VendorCredit
    global class VendorCreditRequest { 
        public String id;    
        public String entity;
        public String isActive;  //1. Active   2. Inactive  
        public String vendorId;
        public String refNumber; 
        public String approvalStatus; //  0. Unassigned 1. Assigned 4. Approving 3. Approved 5. Denied   
        public Date creditDate; 
        public Date glPostingDate;
        public Decimal amount;
        public String localAmount;
        public String exchangeRate;
        public String appliedAmount;
        public String creditStatus; //1. Unapplied 2. PartiallyApplied 0. FullyApplied
        public String description;
        public String poNumber;
        public DateTime createdTime;
        public DateTime updatedTime;
        public String applyToBankAccountId;
        public String applyToChartOfAccountId;
        public List<VendorCreditLineItemsRequest> vendorCreditLineItems;
        public String error_code;
        public String error_message;
    }
    
    // VendorCreditLineItems
    global class VendorCreditLineItemsRequest{
        public String id;
        public String vendorCreditId;
        public Decimal amount;
        public String chartOfAccountId;
        public String departmentId;
        public String locationId;
        public String jobId;
        public String customerId;
        public Boolean jobBillable;
        public String description;
        public DateTime createdTime;
        public DateTime updatedTime;
        public String lineType; //1. expense  2. item
        public String itemId;
        public Decimal quantity;
        public Decimal unitPrice;
        public String employeeId;
        public String actgClassId;
        public String error_code;
        public String error_message;
    }
    
    global class VendorCreditResponse {
        public String response_status;    // 0:Success, 1:Failed
        public String response_message;
        public VendorCreditRequest response_data;
    }
    
    //Account object
    global class VendorRequest {   
        public String id;    
        public String entity;
        public String isActive;    // 1:Active  2:Inactive
        public DateTime createdTime;
        public DateTime updatedTime;
        public String name;
        public String shortName;
        public String companyName;
        public String nameOnCheck;
        public String taxId;
        public Boolean track1099;
        public String contactFirstName;
        public String contactLastName;
        public String accNumber;
        public String address1;
        public String address2;
        public String address3;
        public String address4;
        public String addressCity;
        public String addressState;    // Double digit code refer state
        public String addressZip;    
        public String addressCountry;    // Country code
        public String email;
        public String phone;
        public String fax;
        public String description;
        public String payBy;        // 0:check 1:ach 2:rpps
        public String paymentEmail;
        public String paymentPhone;
        public String accountType;    // 0:none 1:business 2:person It 
        public String error_code;
        public String error_message;
    }
    
    global class VendorResponse {
        public String response_status;    // 0:Success, 1:Failed
        public String response_message;
        public VendorRequest response_data;
    }
    
    //Project Object
    global class JobRequest {
        public String id;
        public String entity;
        public String name;
        public String shortName;
        public String isActive;
        //public String description;
        //public String parentJobId;
        public DateTime createdTime;
        public DateTime updatedTime;
        //public String mergedIntoId;
        public String error_code;
        public String error_message;
    }
    
    global class JobResponse {    
        public String response_status;    // 0:Success, 1:Failed
        public String response_message;
        public JobRequest response_data;
    }
    
    //Project Task object
    global class ItemRequest {
        public String id;
        public String entity;
        public String isActive;
        public DateTime createdTime;
        public DateTime updatedTime;
        public Decimal price;
        public String name;
        public String type;    // enum data type starts with 0,1,2...13.
        public String description;
        /*public String parentItemId;
        public String expenseAccount;
        public String purDescription;
        public String chartOfAccountId;
        public String shortName;
        public String mergedIntoId;*/
        public String error_code;
        public String error_message;
    }
    
    global class ItemResponse {
        public String response_status;    // 0:Success, 1:Failed
        public String response_message;
        public ItemRequest response_data;
    }
    
    
    //Accounting Variable Object
    global class ClassRequest {
        public String id;
        public String entity;
        public String name;
        public String isActive;
        public DateTime createdTime;
        public DateTime updatedTime;
        public String error_code;
        public String error_message;
    }
    
    global class ClassResponse {    
        public String response_status;    // 0:Success, 1:Failed
        public String response_message;
        public ClassRequest response_data;
    }
    
    //GL Account Object - COA
    global class ChartOfAccountRequest {
        public String id;
        public String entity;
        public String name;
        public String isActive;
        public String accountType;
        public String accountNumber;
        public String description;
        public DateTime createdTime;
        public DateTime updatedTime;
        public String error_code;
        public String error_message;
    }
    
    global class ChartOfAccountResponse {    
        public String response_status;    // 0:Success, 1:Failed
        public String response_message;
        public ChartOfAccountRequest response_data;
    }
    
    //Account Payable object
    global class BillRequest {
        public String id;
        public String isActive;    // 1:Active 2:Inactive
        public String entity;
        public String vendorId;
        public String invoiceNumber;
        public String approvalStatus;    // 0:Unassigned 1:Assigned 4:Approving 3:Approved 5:Denied 
        public Date invoiceDate;
        public Date dueDate;
        public Date glPostingDate;
        public Decimal amount;
        //public Decimal scheduledAmount;
        public Decimal paidAmount;
        public String paymentStatus;    // 0:PaidInFull 1:Open 2:PartialPayment 4:Scheduled 
        //public String description;
        //public String poNumber;
        public DateTime createdTime;
        public DateTime updatedTime;
        //public String payFromBankAccountId;
        //public String payFromChartOfAccountId;
        public List<BillLineItemRequest> billLineItems;
        public String error_code;
        public String error_message;
    }
    
    //Payable Line object
    global class BillLineItemRequest {
        public String id;
        public String entity;
        public String billId;
        public Decimal amount;
        public Decimal price;
        public Date serviceDate;
        public Decimal ratePercent;
        public String chartOfAccountId;
        public String departmentId;
        //public String locationId;
        //public String customerId;
        public String jobId;
        public String description;
        //public Boolean jobBillable;
        public DateTime createdTime;
        public DateTime updatedTime;
        Public String lineType;    // 1:expense 2:item
        public String itemId;
        public Decimal quantity;
        public Boolean jobBillable;
        public Decimal unitPrice;
        //public String employeeId;
        public String actgClassId;
        public String error_code;
        public String error_message;
    }
    
    global class BillResponse {
        public String response_status;    // 0:Success, 1:Failed
        public String response_message;
        public BillRequest response_data;
    }
    
    //Cash Disburshment object
    global class SendPayRequest {    //BillPayment is also called SendPay    
        public String id; 
        public Date processDate;
        public Decimal amount;
        public String status;    // 1:Scheduled 2:Paid 3:Canceled 4:Void   
        public String description;
        public String txnNumber;
        public String name;
        public String vendorId;
        public Boolean isOnline;
        public String paymentType;    // 0:Check 1:ACH 2:RPPS 3:PayPal 4:Other
        public String chartOfAccountId;
        public String syncReference;
        public Boolean toPrintCheck;
        public DateTime createdTime;
        public DateTime updatedTime;
        public String bankAccountId;
        public List<BillPaysRequest> billPays;
        public List<BillCreditRequest> billCredits;
        public String error_code;
        public String error_message;
    }
    
    global class BillPaysRequest {
        public String id; 
        public String billId;  
        public Decimal amount;
        public DateTime createdTime;
        public DateTime updatedTime;
        public String error_code;
        public String error_message;
    }
    
    global class BillCreditRequest {
        public String id; 
        public String billId; 
        public String vendorCreditId; 
        public Decimal amount;
        public DateTime createdTime;
        public DateTime updatedTime;
        public String error_code;
        public String error_message;
    }
    
    global class SendPayResponse {
        public String response_status;    // 0:Success, 1:Failed
        public String response_message;
        public SendPayRequest response_data;
    }
    
    global class BillResponseList {    
        public String response_status;    // 0:Success, 1:Failed
        public String response_message;
        public List<BillRequest> response_data;
    }
    
    global class SendPayResponseList {    
        public String response_status;    // 0:Success, 1:Failed
        public String response_message;
        public List<SendPayRequest> response_data;
    }
    
    global class VendorCreditResponseList {    
        public String response_status;    // 0:Success, 1:Failed
        public String response_message;
        public List<VendorCreditRequest> response_data;
    }
    
    //To pull bluk records use list response
    global class ListResponse {
        public Boolean responseStatus;
        public String responseMessage;
        public List<BillRequest> responseBillList;    // Bill & Bill Line
        public List<SendPayRequest> responseSendPayList; // BillPayment
        public List<VendorCreditRequest> responseVendorCreditList; // VendorCredit
    }
    
    public static Map<String,String> getCookieAndSessionId() {
    
        Map<String,String> cookieAndSessionIdMap = new Map<String, String>();
        String reqBody = 'userName='+Label.Bill_com_UserName+'&password='+Label.Bill_com_Password+'&orgId='+Label.Bill_com_Org_Id+'&devKey='+Label.Bill_com_Dev_Key;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Label.Bill_com_Base_URL+'/api/v2/Login.json');
        req.setMethod('POST');
        req.setHeader('connection', 'close');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(reqBody);
            
        HttpResponse res = h.send(req);
        System.debug(':::Login Detail::::' +res.getBody());
        LoginResponse login = (LoginResponse)JSON.deserialize(res.getBody(),LoginResponse.class);
        
        if(login != null && login.response_status == '0' && login.response_message == 'Success') {
            if(login.response_data != null && login.response_data.sessionId != null) {
                 cookieAndSessionIdMap.put('Session',login.response_data.sessionId);
                    
                String setCookieStr = 'sid=' + login.response_data.sessionId;
                String cookieStr = res.getHeader('Set-Cookie');
                if(cookieStr != null && cookieStr != '') {
                    String[] csrfStr = cookieStr.split('un_csrf=!');
                    if(csrfStr.size() > 1) {
                        csrfStr = csrfStr[1].split('==;');
                        setCookieStr += ';un_csrf=!'+csrfStr[0];
                    }
                    
                    String[] pageuidStr = cookieStr.split('pageuid=!');
                    if(pageuidStr.size() > 1) {
                        csrfStr = pageuidStr[1].split('path=/;;');
                        setCookieStr += ';pageuid=!'+csrfStr[0];
                    }
                    cookieAndSessionIdMap.put('Cookie',setCookieStr);
                }
            }        
        }
        
        return cookieAndSessionIdMap;
    }
    
    public static DateTime dateTimeConverion(String inputDt) {
        
        String dateVal = inputDt.split(' ')[0];
        
        Integer year = Integer.ValueOf(dateVal.split('-')[0]);
        Integer mom = Integer.ValueOf(dateVal.split('-')[1]);
        Integer dat = Integer.ValueOf(dateVal.split('-')[2]);
        
        String timeVal = inputDt.split(' ')[1];
        
        Integer hour = Integer.ValueOf(timeVal.split(':')[0]);
        Integer min = Integer.ValueOf(timeVal.split(':')[1]);
        String sec = timeVal.split(':')[2];
        String secStr = sec.mid(0, 2);
        Integer secVal = Integer.ValueOf(secStr);
        
        Time tval = Time.newInstance(hour, min, secval, 0);
        
        DateTime convertedDt = DateTime.newInstance(year, mom, dat, hour, min, secVal);
        System.debug('::::convertedDt:::'+convertedDt);
        
        return convertedDt;
    } 
    
    //Vendor create & update action
    public static VendorResponse vendorMethod(VendorRequest vendorDetails,String type) {
        
        system.debug(':::::enter::vendor:::method:'+vendorDetails);
        
        VendorResponse vendor = new VendorResponse();
        Map<String,String> cookieAdSessionMap = getCookieAndSessionId();
     
        if(vendorDetails != null && cookieAdSessionMap.size() > 1) {
            try {
                
                String sessionId = (cookieAdSessionMap.containsKey('Session')) ? cookieAdSessionMap.get('Session') : '';
                String setCookieStr = (cookieAdSessionMap.containsKey('Cookie')) ? cookieAdSessionMap.get('Cookie') : '';
                String vendorData = 'data={"obj" :'+JSON.Serialize(vendorDetails)+'}&devKey='+Label.Bill_com_Dev_Key;
                
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                
                if(type == 'create'){
                    req.setEndpoint(Label.Bill_com_Base_URL+'/api/v2/Crud/Create/Vendor.json');    
                }else {
                    req.setEndpoint(Label.Bill_com_Base_URL+'/api/v2/Crud/Update/Vendor.json');
                }
                
                req.setMethod('POST');
                req.setHeader('authorization', sessionId);    
                req.setHeader('connection', 'close');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setHeader('Cookie',setCookieStr);
                req.setHeader('content-length', ''+vendorData.length());
                req.setBody(vendorData);
                System.debug(':::req:::' + req);
                
                HttpResponse res = h.send(req);
                System.debug(':::Create vendor::::' +res.getBody());
                vendor = (VendorResponse)JSON.deserialize(res.getBody(),VendorResponse.class);
            } catch(Exception e) {
                vendor.response_status = 'Failed';
                vendor.response_message = e.getMessage();
            }
        }
        return vendor;
    }  
    
    public static JobResponse jobMethod(JobRequest jobDetails,String type, Map<String,String> cookieAdSessionMap) {
        
        JobResponse response = new JobResponse();
        if(cookieAdSessionMap == null){
            cookieAdSessionMap = getCookieAndSessionId();
        }
        
        if(jobDetails != null && cookieAdSessionMap.size() > 1) {
            try {
                String sessionId = (cookieAdSessionMap.containsKey('Session')) ? cookieAdSessionMap.get('Session') : '';
                String setCookieStr = (cookieAdSessionMap.containsKey('Cookie')) ? cookieAdSessionMap.get('Cookie') : '';
                String jobData = 'data={"obj" :'+JSON.Serialize(jobDetails)+'}&devKey='+Label.Bill_com_Dev_Key;
                            
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                
                if(type == 'create'){
                    req.setEndpoint(Label.Bill_com_Base_URL+'/api/v2/Crud/Create/Job.json');
                }else {
                    req.setEndpoint(Label.Bill_com_Base_URL+'/api/v2/Crud/Update/Job.json');
                }
                
                req.setMethod('POST');
                req.setHeader('authorization', sessionId);    
                req.setHeader('connection', 'close');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setHeader('Cookie',setCookieStr);
                req.setHeader('content-length', ''+jobData.length());
                req.setBody(jobData);
                //System.debug(':::req:::' + req.getBody());
                
                HttpResponse res = h.send(req);
                System.debug(':::Create Job::::' +res.getBody());
                response = (JobResponse)JSON.deserialize(res.getBody(),JobResponse.class);
            } catch(Exception e) {
                response.response_status = 'Error';
                response.response_message = e.getMessage();
            }
        }
        return response;   
    }
    
    public static ItemResponse itemMethod(ItemRequest itemDetails,String type, Map<String,String> cookieAdSessionMap) {
        
        ItemResponse response = new ItemResponse();
        if(cookieAdSessionMap == null){
            cookieAdSessionMap = getCookieAndSessionId();
        }
        
        System.debug(':::itemDetails:::'+itemDetails+'\n:::cookieAdSessionMap:::'+cookieAdSessionMap+':::size:::'+cookieAdSessionMap.size());
        
        if(itemDetails != null && cookieAdSessionMap.size() > 1) {
            try {
                String sessionId = (cookieAdSessionMap.containsKey('Session')) ? cookieAdSessionMap.get('Session') : '';
                String setCookieStr = (cookieAdSessionMap.containsKey('Cookie')) ? cookieAdSessionMap.get('Cookie') : '';
                String itemData = 'data={"obj":'+JSON.Serialize(itemDetails)+'}&devKey='+Label.Bill_com_Dev_Key;
               
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                
                if(type == 'create'){
                    req.setEndpoint(Label.Bill_com_Base_URL+'/api/v2/Crud/Create/Item.json');
                }else {
                    req.setEndpoint(Label.Bill_com_Base_URL+'/api/v2/Crud/Update/Item.json');
                }
                
                req.setMethod('POST');
                req.setHeader('authorization', sessionId);    
                req.setHeader('connection', 'close');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setHeader('Cookie',setCookieStr);
                req.setHeader('content-length', ''+itemData.length());
                req.setBody(itemData);
                //System.debug(':::req:::' + req.getBody());
                
                HttpResponse res = h.send(req);
                System.debug(':::Create Item::::' +res.getBody());
                response = (ItemResponse)JSON.deserialize(res.getBody(),ItemResponse.class);
            } catch(Exception e) {
                response.response_status = 'Error';
                response.response_message = e.getMessage();
            }
        }
        return response;   
    }
    
    //For Accounting Variable
    public static ClassResponse classMethod(ClassRequest classDetails,String type,Map<String,String> cookieAdSessionMap) {
        
        ClassResponse response = new ClassResponse();
        if(cookieAdSessionMap == null){
            cookieAdSessionMap = getCookieAndSessionId();
        }
        
        System.debug(':::classDetails:::'+classDetails+'\n:::cookieAdSessionMap:::'+cookieAdSessionMap+':::size:::'+cookieAdSessionMap.size());
        
        if(classDetails != null && cookieAdSessionMap.size() > 1) {
            try {
                String sessionId = (cookieAdSessionMap.containsKey('Session')) ? cookieAdSessionMap.get('Session') : '';
                String setCookieStr = (cookieAdSessionMap.containsKey('Cookie')) ? cookieAdSessionMap.get('Cookie') : '';
                String itemData = 'data={"obj":'+JSON.Serialize(classDetails)+'}&devKey='+Label.Bill_com_Dev_Key;
               
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                
                if(type == 'create'){
                    req.setEndpoint(Label.Bill_com_Base_URL+'/api/v2/Crud/Create/ActgClass.json');
                }else {
                    req.setEndpoint(Label.Bill_com_Base_URL+'/api/v2/Crud/Update/ActgClass.json');
                }
                
                req.setMethod('POST');
                req.setHeader('authorization', sessionId);    
                req.setHeader('connection', 'close');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setHeader('Cookie',setCookieStr);
                req.setHeader('content-length', ''+itemData.length());
                req.setBody(itemData);
                //System.debug(':::req:::' + req.getBody());
                
                HttpResponse res = h.send(req);
                System.debug(':::Create Class::::' +res.getBody());
                response = (ClassResponse)JSON.deserialize(res.getBody(),ClassResponse.class);
            } catch(Exception e) {
                response.response_status = 'Error';
                response.response_message = e.getMessage();
            }
        }
        return response;   
    }
    
    //For GL Account
    public static ChartOfAccountResponse chartOfAccountMethod(ChartOfAccountRequest chartOfAccDetails,String type,Map<String,String> cookieAdSessionMap) {
        
        ChartOfAccountResponse response = new ChartOfAccountResponse();
        if(cookieAdSessionMap == null){
            cookieAdSessionMap = getCookieAndSessionId();
        }
        
        System.debug(':::chartOfAccDetails:::'+chartOfAccDetails+'\n:::cookieAdSessionMap:::'+cookieAdSessionMap+':::size:::'+cookieAdSessionMap.size());
        
        if(chartOfAccDetails != null && cookieAdSessionMap.size() > 1) {
            try {
                String sessionId = (cookieAdSessionMap.containsKey('Session')) ? cookieAdSessionMap.get('Session') : '';
                String setCookieStr = (cookieAdSessionMap.containsKey('Cookie')) ? cookieAdSessionMap.get('Cookie') : '';
                String itemData = 'data={"obj":'+JSON.Serialize(chartOfAccDetails)+'}&devKey='+Label.Bill_com_Dev_Key;
               
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                
                if(type == 'create'){
                    req.setEndpoint(Label.Bill_com_Base_URL+'/api/v2/Crud/Create/ChartOfAccount.json');
                }else {
                    req.setEndpoint(Label.Bill_com_Base_URL+'/api/v2/Crud/Update/ChartOfAccount.json');
                }
                
                req.setMethod('POST');
                req.setHeader('authorization', sessionId);    
                req.setHeader('connection', 'close');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setHeader('Cookie',setCookieStr);
                req.setHeader('content-length', ''+itemData.length());
                req.setBody(itemData);
                //System.debug(':::req:::' + req.getBody());
                
                HttpResponse res = h.send(req);
                System.debug(':::Create Chart of Account::::' +res.getBody());
                response = (ChartOfAccountResponse)JSON.deserialize(res.getBody(),ChartOfAccountResponse.class);
            } catch(Exception e) {
                response.response_status = 'Error';
                response.response_message = e.getMessage();
            }
        }
        return response;   
    }
    
    //To pull data from bill.com we use list api
     public static ListResponse getList(String objName, String fromDate,String toDate) {
        
        ListResponse response = new ListResponse();
        Map<String,String> cookieAdSessionMap = getCookieAndSessionId();
     
        if(objName != null && objName != '' && fromDate != null && fromDate != '' && cookieAdSessionMap.size() > 1) {
            try {
                String sessionId = (cookieAdSessionMap.containsKey('Session')) ? cookieAdSessionMap.get('Session') : '';
                String setCookieStr = (cookieAdSessionMap.containsKey('Cookie')) ? cookieAdSessionMap.get('Cookie') : '';
                
                String listData = 'data={"start" : 0,"max" : 999,"filters" : [{"field":"updatedTime", "op":">","value":"'+fromDate;
                listData +=  '"},{"field":"updatedTime","op":"<","value":"'+toDate+'"}';
                
                /*if(objName == 'SentPay'){
                   listData += ',{"field":"status","op":"=","value":"2"},{"field":"status","op":"=","value":"4"},{"field":"status","op":"=","value":"1"}';    
                }*/
                
               /* if(objName == 'Bill'){
                    listData += ',{"field":"approvalStatus","op":"=","value":"3"}';    
                }*/
                
                listData += '],"sort" : [{"field":"updatedTime", "asc":0}]}&devKey='+Label.Bill_com_Dev_Key;
                
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(Label.Bill_com_Base_URL+'/api/v2/List/'+objName+'.json');
                req.setMethod('POST');
                req.setHeader('authorization', sessionId);    
                req.setHeader('connection', 'close');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setHeader('Cookie',setCookieStr);
                req.setHeader('content-length', ''+listData.length());
                req.setBody(listData);
                System.debug(':::req:::' + req.getBody());
                
                HttpResponse res = h.send(req);
                System.debug(':::Received List::::' +res.getBody());
                response.responseStatus = True;
                response.responseMessage = 'Success';
                /*if(objName == 'ReceivedPay') {    
                    ARPaymentRespListClass arPayment = (ARPaymentRespListClass)JSON.deserialize(res.getBody(),ARPaymentRespListClass.class);
                    response.responseARPaymentList = arPayment.response_data;
                } else if(objName == 'Customer') {    
                    customerRespListClass customer = (customerRespListClass)JSON.deserialize(res.getBody(),customerRespListClass.class);
                    response.responseCustomerList = customer.response_data;
                } else if(objName == 'Invoice') {
                    invoiceRespListClass inv = (invoiceRespListClass)JSON.deserialize(res.getBody(),invoiceRespListClass.class);
                    response.responseInvoiceList = inv.response_data;
                } else if(objName == 'Job') {
                    jobRespListClass job = (jobRespListClass)JSON.deserialize(res.getBody(),jobRespListClass.class);
                    response.responseJobList = job.response_data;
                } else if(objName == 'Department') {
                    departmentRespListClass dept = (departmentRespListClass)JSON.deserialize(res.getBody(),departmentRespListClass.class);
                    response.responseDepartmentList = dept.response_data;
                } else if(objName == 'Location') {
                    locationRespListClass loc = (locationRespListClass)JSON.deserialize(res.getBody(),locationRespListClass.class);
                    response.responseLocationList = loc.response_data;
                } else */
                
                if(objName == 'Bill') { 
                    BillResponseList bill = (BillResponseList)JSON.deserialize(res.getBody(),BillResponseList.class);
                    response.responseBillList = bill.response_data; 
                }else if(objName == 'SentPay') {
                    SendPayResponseList pay = (SendPayResponseList)JSON.deserialize(res.getBody(),SendPayResponseList.class);
                    response.responseSendPayList = pay.response_data; 
                }else if(objName == 'VendorCredit'){
                    VendorCreditResponseList vend = (VendorCreditResponseList)JSON.deserialize(res.getBody(), VendorCreditResponseList.class);
                    response.responseVendorCreditList = vend.response_data;
                }
                /*else if(objName == 'Vendor') {
                    vendorRespListClass ven = (vendorRespListClass)JSON.deserialize(res.getBody(),vendorRespListClass.class);
                    response.responseVendorList = ven.response_data;   
                }else if(objName == 'ChartOfAccount') {
                    ChartAccountRespListClass chart = (ChartAccountRespListClass)JSON.deserialize(res.getBody(),ChartAccountRespListClass.class);
                    response.responseChartofAccountList = chart.response_data;   
                }else if(objName == 'ActgClass') {
                    ClassRespListClass cls = (ClassRespListClass)JSON.deserialize(res.getBody(),ClassRespListClass.class);
                    response.responseClassList = cls.response_data; 
                }else if(objName == 'SentPay') {
                    
                    SendPayRespListClass pay = (SendPayRespListClass)JSON.deserialize(res.getBody(),SendPayRespListClass.class);
                    response.responseSendPayList = pay.response_data; 
                }*/
                
            } catch(Exception e) {    
                response.responseStatus = False;
                response.responseMessage = e.getMessage();
            }
        }
        return response;
    }
}