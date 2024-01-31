public class GoogleBooks {
    private final static String TITLE_ENDPOINT = 'https://www.googleapis.com/books/v1/volumes?q=intitle:';
    private final static String ISBN_ENDPOINT = 'https://www.googleapis.com/books/v1/volumes?q=isbn:';
    private final static String SUBJECT_ENDPOINT = 'https://www.googleapis.com/books/v1/volumes?q=subject:';
    private final static String AUTHOR_ENDPOINT = 'https://www.googleapis.com/books/v1/volumes?q=inauthor:';
    private final static String PUBLISHER_ENDPOINT = 'https://www.googleapis.com/books/v1/volumes?q=inpublisher:';
    private final static String ANY_ENDPOINT = 'https://www.googleapis.com/books/v1/volumes?q=';
    
    
    @RemoteAction
    public static GoogleBooks.Book[] getBookByTitle(String keyword) {
        return GoogleBooks.getBookDetails(keyword, 'TITLE', 0, 10, 'relevance');
    }
    
    
    //Get list of books from the google books API with the folowing keywords.
    @RemoteAction
    public static GoogleBooks.Book[] getBookDetails(String keyword, String type, Integer startIndex, Integer resultPerPage, String orderBy) {
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        
        String endpoint = GoogleBooks.getEndPoint(keyword, type, startIndex, resultPerPage, orderBy);
        
        System.debug('endpoint: ' + endpoint);
        
        request.setEndpoint(endpoint);
        Http http = new Http();
        try {
            HTTPResponse response;
            if(!Test.isRunningTest()) {
                response = http.send(request);
            } else {
                response = GoogleBooks.createResponse(keyword);
            }
            if(response.getStatusCode() == 200) {
                GoogleBooks.BookResponse bookResponse = (BookResponse) JSON.deserialize(response.getBody(), GoogleBooks.BookResponse.class);
                return bookResponse.items;
            } else {
                return new List<Book>();
            }
            
        } catch(System.CalloutException e) {
            
        }
        return new List<Book>();
    }
    
    public static String getEndPoint(String keyword, String type, Integer startIndex, Integer resultPerPage, String orderBy) {
        String endpoint = '';
        
        if(orderBy != 'relevance' && orderBy != 'newest') {    //Default order should be 'relevance'.
            orderBy = 'relevance';
        }
        if(startIndex < 0) {    //StartIndex is always greater than or equal to 0.
            startIndex = 0;
        }
        if(resultPerPage > 40) {    //Highest result per page is 40 in Google Books API.
            resultPerPage = 40;
        }
        if(resultPerPage < 10) {    //Lowest Result Per Page is 10.
            resultPerPage = 10;
        }
        String encodedKeyword = EncodingUtil.urlEncode(keyword, 'UTF-8');
        
        if(type == 'ISBN') {
            endpoint = GoogleBooks.ISBN_ENDPOINT + encodedKeyword;
        } else if(type == 'AUTHOR') {
            endpoint = GoogleBooks.AUTHOR_ENDPOINT + '"' + encodedKeyword + '"';
        } else if(type == 'PUBLISHER') {
            endpoint = GoogleBooks.PUBLISHER_ENDPOINT + '"' + encodedKeyword + '"';
        } else if(type == 'SUBJECT') {
            endpoint = GoogleBooks.SUBJECT_ENDPOINT + '"' + encodedKeyword + '"';
        } else if(type == 'ANY'){
            endpoint = GoogleBooks.TITLE_ENDPOINT + '"' + encodedKeyword + '"';
        } else {
            endpoint = GoogleBooks.ANY_ENDPOINT + encodedKeyword;
        }
                
        endpoint += '&startIndex=' + startIndex + '&maxResults=' + resultPerPage + '&orderfBy=' + orderBy;
        return endPoint;
    }
    
    @RemoteAction
    public static BookData getMaterial(id materialId) {
        List<Materials__c> material = [SELECT Id, Name, Author__c, Category__c, Book_Cover__c, Description__c, ISBN__c, Google_Books_Language__c,
                                Google_Books_Language__r.ISO_2_Charac_Code__c, Publisher__c, Published_Date__c,
                                Google_Book_Price__c, Sub_Categories__c  FROM Materials__c WHERE Id = :materialId];
        BookData bd = new BookData();
        if(!material.isEmpty()) {
            bd.title = material[0].Name;
            bd.authors = material[0].Author__c;
            bd.image = material[0].Book_Cover__c;
            bd.description = material[0].Description__c;
            bd.section = material[0].Category__c;
            bd.isbn = material[0].ISBN__c;
            bd.language = material[0].Google_Books_Language__r.ISO_2_Charac_Code__c;
            bd.publisher = material[0].Publisher__c;
            bd.publishedDate = material[0].Published_Date__c;
            bd.price = material[0].Google_Book_Price__c;
            bd.sub_category = material[0].Sub_Categories__c;
        }
        return bd;
    }
    
    public static GoogleBooks.BookData getGoogleBookData(GoogleBooks.Book book) {
        //ToDo: Form BookData object from Google Books result.
        GoogleBooks.BookData bd = new GoogleBooks.BookData();
        if(book.volumeInfo != null) {
            bd.title = book.volumeInfo.title;
            bd.authors = GoogleBooks.combineArray(book.volumeInfo.authors);
            bd.image = GoogleBooks.getImage(book);
            bd.description = book.volumeInfo.description;
            bd.section = book.volumeInfo.mainCategory;
            bd.isbn = getIsbn(book);
            bd.language = book.volumeInfo.language;
            bd.publisher = book.volumeInfo.publisher;
            bd.publishedDate = book.volumeInfo.publishedDate;
            bd.price = GoogleBooks.getCost(book);
            bd.sub_category = GoogleBooks.combineArray(book.volumeInfo.categories);
        }
        return bd;
    }
    
    public static String getImage(GoogleBooks.Book book) {
        String imageUrl = null;
        String imageTag = null;
        if(book.volumeInfo != null && book.volumeInfo.imageLinks != null) {
            if(book.volumeInfo.imageLinks.thumbnail != null) {
                imageUrl = book.volumeInfo.imageLinks.thumbnail;
            } else if(book.volumeInfo.imageLinks.smallThumbnail != null) {
                imageUrl = book.volumeInfo.imageLinks.smallThumbnail;
            } else if(book.volumeInfo.imageLinks.medium != null) {
                imageUrl = book.volumeInfo.imageLinks.medium;
            } else if(book.volumeInfo.imageLinks.large != null) {
                imageUrl = book.volumeInfo.imageLinks.large;
            } else if(book.volumeInfo.imageLinks.extraLarge != null) {
                imageUrl = book.volumeInfo.imageLinks.extraLarge;
            } else if(book.volumeInfo.imageLinks.small != null) {
                imageUrl = book.volumeInfo.imageLinks.small;
            }
            if(imageUrl != null) {
                imageTag = '<img src="' + imageUrl + '" />';
            }
        }
        return imageTag;
    }
    
    public static String getIsbn(GoogleBooks.Book book) {
        if(book.volumeInfo.IndustryIdentifiers != null ) {
            for(GoogleBooks.IndustryIdentifiers identifier : book.volumeInfo.industryIdentifiers) {
                if(identifier.type == 'ISBN_10' || identifier.type == 'ISBN_13') {
                    return identifier.identifier;
                }
            }
        }
        return null;
    }
    
    public static String getCost(GoogleBooks.Book book) {
        if(book.SaleInfo != null && book.SaleInfo.listPrice != null) {
            return book.SaleInfo.listPrice.currencyCode + ' ' + book.saleInfo.listPrice.amount;
        }
        return '';
    }
    
    public static String combineArray(String[] itemList) {
        String result = '';
        if(itemList != null) {
            for(String item : itemList) {
                if(result != '') {
                    result += ', ';
                }
                result += item;
            }
        }
        return result;
    }
    
    public static void setGoogleBookCount(Id materialId, Integer count) {
        Materials__c material = new Materials__c();
        material.Id = materialId;
        material.Google_Book_Result_Count__c = count;
        update material;
    }
    
    @RemoteAction
    public static void assignBook(GoogleBooks.BookData bookData, Id materialId) {
        Materials__c material = new Materials__c();
        
        if(bookData.title != null) {
            material.Name = bookData.title;
        }
        
        if(bookData.authors != null) {
            material.Author__c = bookData.authors;
        }
        
        if(bookData.image != null) {
            material.Book_Cover__c = bookData.image;
        }
        
        if(bookData.description != null) {
            if(bookData.description.length() > 255) {
               bookData.description = bookData.description.substring(0, 252);
               bookData.description += '...';
            }
            material.Description__c = bookData.description;
        }
        
        if(bookData.section != null) {
            material.Category__c = bookData.section;
        }
        
        if(bookData.isbn != null) {
            material.ISBN__c = bookData.isbn;
        }
        
        if(bookData.language != null) {
            List<Language__c> languageList = [SELECT Name FROM Language__c WHERE ISO_2_Charac_Code__c = :bookData.language];
            if(!languageList.isEmpty()) {
                material.Google_Books_Language__c = languageList[0].Id;
            }
        }
        
        if(bookData.publisher != null) {
            material.Publisher__c = bookData.publisher;
        }
        
        if(bookData.publishedDate != null) {
            material.Published_Date__c = bookData.publishedDate;
        }
        
        if(bookData.price != null) {
            material.Google_Book_Price__c = bookData.price;
        }
        
        if(bookData.sub_category != null) {
            material.Sub_Categories__c = bookData.sub_category;
        }
        
        material.Id = materialId;
        update material;
    }
        
    /* For Test Class */
    public static HttpResponse createResponse(String keyword) {
        if(keyword == 'exception') {
            throw new CalloutException();
        }
    
        GoogleBooks.BookResponse br = new GoogleBooks.BookResponse();
        GoogleBooks.Book book = new GoogleBooks.Book();
        book.volumeInfo = new GoogleBooks.VolumeInfo();
        book.volumeInfo.title = 'Test 1';
        br.items = new List<GoogleBooks.Book>{book};
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody(JSON.serialize(br));
        return response;
    }
    
    
    public class BookData {
        public String title;
        public String authors;
        public String description;
        public String isbn;
        public String section;
        public String language;
        public String image;
        public String publisher;
        public String publishedDate;
        public String price;
        public String sub_category;
    }
    
    public class BookResponse {
        public Book[] items;
    }
    
    public class Book {
        public String kind;
        public VolumeInfo volumeInfo;
        //TODO: UserInfo
        public SaleInfo saleInfo;
        public AccessInfo accessInfo;
        public SearchInfo searchInfo;
    }
    
    public class VolumeInfo {
        public String title;
        public String subtitle;
        public String[] authors;
        public String publisher;
        public String publishedDate;
        public String description;
        public IndustryIdentifiers[] industryIdentifiers;
        public Integer pageCount;
        public Dimension dimensions;
        public String printType;
        public String mainCategory;
        public String[] categories;
        public Double averageRating;
        public Integer ratingsCount;
        public String contentVersion;
        public ImageLink imageLinks;
        public String language;
        public String previewLink;
        public String infoLink;
        public String canonicalVolumeLink;
    }
    
    public class SaleInfo {
        public String country;
        public String saleability;
        public String onSaleDate;
        public String isEbook;
        public Price listPrice;
        public Price retailPrice;
        public String buyLink;
    }
    
    public class AccessInfo {
        public String country;
        public String viewability;
        public Boolean embeddable;
        public Boolean publicDomain;
        public String textToSpeechPermission;
        public BookType epub;
        public BookType pdf;
        public String webReaderLink;
        public String accessViewStatus;
        public DownloadAccess downloadAccess;
    }
    
    public class DownloadAccess {
        public String volumeId;
        public Boolean restricted;
        public Boolean deviceAllowed;
        public Boolean justAcquired;
        public Integer maxDownloadDevices;
        public Integer downloadsAcquired;
        public String nonce;
        public String source;
        public String reasonCode;
        public String message;
        public String signature;
    }
    
    public class BookType {
        public Boolean isAvailable;
        public String downloadLink;
        public String acsTokenLink;
    }
    
    public class Price {
        public Double amount;
        public String currencyCode;
    }
    
    public class Dimension {
        public String height;
        public String width;
        public String thickness;
    }
    
    public class IndustryIdentifiers {
        public String type;
        public String identifier;
    }
    
    public class ImageLink {
        public String smallThumbnail;
        public String thumbnail;
        public String small;
        public String medium;
        public String large;
        public String extraLarge;
    }
    
    public class SearchInfo {
        public String textSnippet;
    }
    
}