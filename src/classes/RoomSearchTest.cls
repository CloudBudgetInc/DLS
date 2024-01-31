@isTest
public class RoomSearchTest {
    @testSetup static void setup(){
        
        List<Schedule__c> schlist = TestClassUtil.createTestSchedule();
        List<Room__c> roomlist = TestClassUtil.createTestRoom();
          
    }
    public static testMethod void roomTest() {
        Set<Id> roomIds = new Set<Id>();
        List<Id> roomIdList = new List<Id>();
        
        List<Contact> contactList = [SELECT Id,LastName FROM Contact LIMIT 2];
        List<Room__c> roomlist = [SELECT Id, Name FROM Room__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id, Name, AcctSeed__Project__c, AcctSeed__Project__r.AcctSeed__Opportunity__c FROM AcctSeed__Project_Task__c LIMIT 2];
        /*Schedule__c sc = new Schedule__c(Name = 'test 1',Project__c = projTask[0].AcctSeed__Project__c, Project_Task__c=projTask[0].Id, Total_Hours__c = 5, End_Date__c=System.Today() + 10, Start_Date__c=System.Today(),Status__c= 'Scheduled');
        insert sc;
        system.debug('::sc::::'+sc);
        List<Schedule__c> schlist1 = [SELECT Id, Name, Project__c, Project__r.AcctSeed__Opportunity__c, Room__c FROM Schedule__c WHERE Name = 'test 1'];*/
        List<Schedule__c> schlist = [SELECT Id, Name, Project__c, Opportunity__c, Project__r.AcctSeed__Opportunity__c, Room__c FROM Schedule__c LIMIT 2];
        schlist[0].Room__c = roomlist[0].Id;
        schlist[0].Instructor__c = contactList[0].Id;
        update schlist;
       
        List<MTT_Location__c> loclist = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        List<Floor_Suite__c> suitlist = [SELECT Id, Name FROM Floor_Suite__c LIMIT 1]; 
        
        RoomSearchController.ConflictSearchParameter cs1 = new RoomSearchController.ConflictSearchParameter();
        cs1.startDate = String.valueOf(system.today().addDays(-5));
        cs1.endDate = String.valueOf(system.today());
        RoomSearchController.setRoom(schlist[0].Id,roomlist[0].Id);
       
        roomIds.add(roomlist[0].Id);
        roomIdList.add(roomlist[0].Id);
        
        RoomSearchController.getRoomDetails(roomIdList);
        
        
        RoomSearchController.ConflictSearchParameter cs = new RoomSearchController.ConflictSearchParameter();
        cs.monday = true;
        cs.tuesday = true;
        cs.wednesday = true;
        cs.thursday = true;
        cs.friday = true;
        cs.saturday = true;
        cs.sunday = true;

        cs.startDate = '2016-06-15';
        cs.endDate = '2016-06-25';
        cs.startTime = '09:00 AM';
        cs.endTime = '10:00 AM';

        RoomSearchController.ConflictSearchParameter cs2 = new RoomSearchController.ConflictSearchParameter();
        cs2.monday = false;
        cs2.tuesday = false;
        cs2.wednesday = false;
        cs2.thursday = false;
        cs2.friday = false;
        cs2.saturday = false;
        cs2.sunday = false;
        
        RoomSearchController.SearchParameter sp = new RoomSearchController.SearchParameter();
        List<String> funlist = new List<String>();
        funlist.add('Classroom');
        List<String> floorlist = new List<String>();
        floorlist.add('1st');
        List<Id> suilist = new List<Id>();
        suilist.add(suitlist[0].Id);
        sp.locationId = loclist[0].Id;
        sp.function = funlist;
        sp.floor = floorlist;
        sp.capacity = 1;
        sp.roomType = 'Window';
        sp.suiteId = suilist;
        sp.section = true;
        sp.language = true;
        sp.instructor = true;
        sp.resultSize = 20;
        sp.offset = 0;
        
        Id scheduleId = schlist[0].Id;
        Id roomId = roomlist[0].Id;
        Id returnId = schlist[0].Project__c;
        String jsonstring = '[{"Id":"'+roomlist[0].Id+'","Notes__c":"test"}]'; 
        
        Test.startTest();
        RoomSearchController.getRooms(cs,sp,scheduleId);
        RoomSearchController.getschedulesWithConflicts(cs,roomIds);
        RoomSearchController.getFloorPicklist();
        RoomSearchController.getSchedulesByInstructor(scheduleId);
        RoomSearchController.getSchedulesByRooms(roomId);
        RoomSearchController.getroomsByRoomId(roomId);
        RoomSearchController.prepopLocationAndCapacity(scheduleId,returnId);
        //RoomSearchController.getSuitebylocation(loclist[0].Id);
        RoomSearchController.getFloorsbylocation(loclist[0].Id);
        RoomSearchController.getSuitesbyRoomFloors(floorlist);
        RoomSearchController.updateRoom(jsonstring);
        RoomSearchController.getTimePicklist();
        RoomSearchController.getFunctionPicklist();
        RoomSearchController.getLocation();
        RoomSearchController.checkForRoomEditCP();
        Test.stopTest();        
        
    }
}