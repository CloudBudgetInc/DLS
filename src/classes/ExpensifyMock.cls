@isTest
global class ExpensifyMock {
    global class ExpensifyExportReportMock implements HttpCalloutMock {
        
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();        
            if(req.getEndpoint().contains('fileExtension')){
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"responseCode":"200","filename":"testFileName"}');
                res.setStatusCode(200);
            }else{
                
                res.setHeader('Content-Type', 'application/json');
                res.setBody('[{"invoiceComment":"Google*ads5896285286cc Google.com","postDate":"2021-02-19","total":13.58,"Expense_GL_Account":"89340 - Promotional Costs - Unallowable","GL_Account_Variable_1":"ADM0BD","empEmail":"abellas@dlsdc.com","Internal_Comment":"February 2021 Google Ads","bank":"oauth.americanexpress.com","status":"Approved","transactionId":"52186854828539937","cardId":"12150699","firstName":"April","lastName":"Bellas"},]');
                res.setStatusCode(200);
            }
            return res;
        }
    }
    
    global class ExpensifyCreditCardMock implements HttpCalloutMock {
        
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();        
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"domainCardList": [{"bank": "citibank.com","cardID": 5312342,"cardName": "John Doe - 1979","cardNumber": "1234XXXXXXXX1979","created": "2018-01-01 12:34:56","email": "john.doe@domain.com","externalEmployeeID": "1234567","lastImport": "2018-07-03 23:45:01","lastImportResult": 200,"reimbursable": false,"scrapeMinDate": ""}]}');
            res.setStatusCode(200);
            
            return res;
        }
    }
}