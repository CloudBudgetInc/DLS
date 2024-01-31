global class GoogleBooksMerge implements Database.batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    public class ISBNdetails {
        public String ISBNType;
        public String ISBN;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){
        return Database.getQueryLocator('SELECT Id, Name FROM Materials__c');
    }
    
    global void finish(Database.BatchableContext context) {
        //
    }
    
    global void execute(Database.BatchableContext info, List<Materials__c> materialList) {
        for(Materials__c material : materialList) {
            mergeGoogleBookData(material);
        }
    }

    public void mergeGoogleBookData(Materials__c material) {
        System.debug('Matertial Id: ' + material.Id);
        List<GoogleBooks.Book> bookList = GoogleBooks.getBookByTitle(material.Name);
        List<GoogleBooks.Book> matchedBooks = new List<GoogleBooks.Book>();
        System.debug('Returned Book List: ' + bookList);
        if(bookList != null) {
            for(GoogleBooks.Book book : bookList) {
                if(book.volumeInfo != null && book.volumeInfo.title.toUpperCase() == material.Name.toUpperCase()) {
                    matchedBooks.add(book);
                }
            }
        }
        System.debug('Book Title : ' + material.Name + ' ' + matchedBooks);
        System.debug('Matched Book Count: ' + matchedBooks.size());
        if(matchedBooks.size() == 1) {
            System.debug('Updating Book Data');
            GoogleBooks.assignBook(GoogleBooks.getGoogleBookData(matchedBooks[0]), material.Id);
        } else {
            System.debug('Updating count');
            GoogleBooks.setGoogleBookCount(material.Id, matchedBooks.size());
        }
    }
}