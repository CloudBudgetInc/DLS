@isTest
public class GoogleBooksTest {
    @testsetup static void setup() {
        TestClassUtil.createTestmaterials();
    }

    public static testmethod void testGoogleBooks() {
        GoogleBooks.getBookDetails('test', 'TITLE', 0, 10, 'relevance');
        GoogleBooks.getBookDetails('test2', 'AUTHOR', 0, 10, 'newest');
        GoogleBooks.getBookDetails('test3', 'ANY', -1, 50, 'asd');
        GoogleBooks.getBookDetails('test4', 'PUBLISHER', 0, 1, 'newest');
        GoogleBooks.getBookDetails('test5', 'SUBJECT', 0, 10, 'relevance');
        GoogleBooks.getBookDetails('test6', 'ISBN', 0, 10, 'newest');
        GoogleBooks.getBookDetails('exception', 'ISBN', 0, 10, 'newest');
    
        List<Materials__c> material = [SELECT Id FROM Materials__c LIMIT 1];
        Id materialId;
        if(!material.isEmpty()) {
            materialId = material[0].Id;
            GoogleBooks.getMaterial(materialId);
            
            //Assign Book
            String descrption = 'We need a larger description. It should have more than 255 charectors. adflhgeds fdsg lgsddghldkjbdfgyarw;bdrgweghwae irghwl ugwrgergerugnvdjshgsgu sfknsdeh eugsugsdgkrh,sghmsDNgh sdb,kdskmndsfhsz gkdmghag ajskdgesmghsedhbgbyshgng g rg hg we;jg ewogWEOEQWIGTEWJG WHG WEL FGEWJG WEGBWE NGWO;JRIG EWHGWE;GH WEGWE GPEhwgfnweds fewhefwngfmbhe8hgngnweigherNGE;WMO9guewng smde,gfsewlafewuaij';
            GoogleBooks.BookData bd1 = getBookData('Test1', 'a1, a2', 'image', descrption, 'asd', 'anisbnno', 'en', 'melb', '1993-09-08', 'USD 12.00', 'Fiction');
            GoogleBooks.assignBook(bd1, materialId);
        }  
        
        Database.executeBatch(new GoogleBooksMerge(), 2); 
    }
    
    public static GoogleBooks.BookData getBookData(String title, String authors, String image, String description, String section, String isbn, String language, String publisher, String publishedDate, String price, String sub_category) {
        GoogleBooks.BookData bd = new GoogleBooks.BookData();
        bd.title = title;
        bd.authors = authors;
        bd.image = image;
        bd.description = description;
        bd.section = section;
        bd.isbn = isbn;
        bd.language = language;
        bd.publisher = publisher;
        bd.publishedDate = publishedDate;
        bd.price = price;
        bd.sub_category = sub_category;
        return bd;
    }
    
}