@isTest
public class LessonPlanBoxUtil_Test {
    @testSetup
    public static void testSetup(){
        TestClassUtil.createTestEvent();
    }
    @isTest
    public static void createFolder_Test(){
        List<Lesson_Plan__c> lessonPlanRecordList = [SELECT Id FROM Lesson_Plan__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new LessonPlanBoxUtilMock());
        Test.startTest();
        LessonPlanBoxUtil.createFolder('test1' , lessonPlanRecordList[0].Id);
        Test.stopTest();
    }
    @isTest
    public static void uploadFile_Test(){
        Test.setMock(HttpCalloutMock.class, new LessonPlanBoxUtilMock());
        Test.startTest();
        LessonPlanBoxUtil.uploadFile('770yuvw/' , 'test1' , '1876512');
        Test.stopTest();
    }
    @isTest
    public static void uploadFileAsync_Test(){
        BoxUtilDomain.FilesWrapper wrapperInstance = new BoxUtilDomain.FilesWrapper();
        wrapperInstance.fileName = 'test1';
        wrapperInstance.base64 = '770yuvw/';
        List<BoxUtilDomain.FilesWrapper> wrapperList = new List<BoxUtilDomain.FilesWrapper>();
        wrapperList.add(wrapperInstance);
        Test.setMock(HttpCalloutMock.class, new LessonPlanBoxUtilMock());
        LessonPlanBoxUtil.uploadFilesAsync(JSON.serialize(wrapperList) , '1876512');
    }
    @isTest
    public static void getItemsFromFolder_Test(){
        String fileId = '18765123';
        Test.setMock(HttpCalloutMock.class, new LessonPlanBoxUtilMock());
        Test.startTest();
        LessonPlanBoxUtil.getItemsFromFolder(fileId);
        Test.stopTest();
    }
    @isTest
    public static void deleteFilesAsync_Test(){
        List<String> fileIds = new List<String>{'1876512' , '18765123'};
        Test.setMock(HttpCalloutMock.class, new LessonPlanBoxUtilMock());
        LessonPlanBoxUtil.deleteFilesAsync(fileIds);
    }
}