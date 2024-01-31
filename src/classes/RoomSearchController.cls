public class RoomSearchController {

    public static Set<String> functionBlackList = new Set<String>{'Storage', 'Break Room or Kitchen', 'SUBLEASED'};
    public Id parentId {get; set;}
    public Boolean calenderOpen {get; set;}
    
    public RoomSearchController() {
        calenderOpen =  false;
    }
    
    /*
    public void displayCalender() {
        parentId = ApexPages.currentPage().getParameters().get('parentId');
        calenderOpen =  true; 
        system.debug('::::parenID::::'+parentId);
    }
    */

    @RemoteAction
    public static SearchResult getRooms(ConflictSearchParameter conflictParameter,SearchParameter roomParam, Id scheduleId) {
        system.debug('::SearchParameter:::'+roomParam+':conflictParameter:'+conflictParameter);
        Set<String> funSet = new Set<String>();
        Map<Id, Integer> conflictsMap = new Map<Id, Integer>();
        Set<Id> suiSet = new Set<Id>();
        Set<Id> conflictsId = new Set<Id>();
        Set<String> floorSet = new Set<String>();
        String functionName;
        functionName = '(';
        for(String fun : roomParam.function){
            functionName += '\''+fun+'\',';
            funSet.add(fun);
        }
        functionName += ')';
        
        String suiteName;
        suiteName = '(';
        for(String sui : roomParam.suiteId){
            suiteName += '\''+sui+'\',';
            suiSet.add(sui);
        }
        suiteName += ')';
        for(String fl : roomParam.floor){
            floorSet.add(fl);
        } 
        
        List<Schedule__c> schSecList = new List<Schedule__c>();
        Set<Id> roomsWithSection = new Set<Id>();
        String filterQueryString = '';
        
        if((roomParam.section == true || roomParam.language == true || roomParam.instructor == true) && scheduleId != null){
            List<Schedule__c> schList = [SELECT Id, Room__c, Opportunity__r.Section__c, Opportunity__r.Language__c, Project__r.Language__c, Instructor__c,Project__r.Name FROM Schedule__c WHERE Id = :scheduleId AND Project__r.AcctSeed__Status__c IN ('Active','Order')];
            //system.debug(':::schList::::'+schList);
            filterQueryString = ' SELECT Id, Room__c, Opportunity__r.Section__c, Opportunity__r.Language__c, Project__r.Language__c, Instructor__c,Project__r.Name FROM Schedule__c WHERE Project__r.AcctSeed__Status__c IN (\'Active\',\'Order\')';
            if(roomParam.section == true){
                if(schList[0].Opportunity__r.Section__c != null){
                    filterQueryString += ' AND Opportunity__r.Section__c = \''+schList[0].Opportunity__r.Section__c+'\'';        
                }
            }
            if(roomParam.language == true){
                if(schList[0].Project__r.Language__c != null){
                    if(roomParam.section != true || schList[0].Opportunity__r.Section__c == null){
                        filterQueryString += ' AND Project__r.Language__c = \''+schList[0].Project__r.Language__c+'\'';        
                    } else {
                        filterQueryString += ' AND Project__r.Language__c = \''+schList[0].Project__r.Language__c+'\'';  
                    }
                } else if(schList[0].Opportunity__r.Language__c != null){
                    if(roomParam.section != true || schList[0].Opportunity__r.Section__c == null){
                        filterQueryString += ' AND Opportunity__r.Language__c = \''+schList[0].Opportunity__r.Language__c+'\'';        
                    } else {
                        filterQueryString += ' AND Opportunity__r.Language__c = \''+schList[0].Opportunity__r.Language__c+'\'';  
                    }
                }
            }
            if(roomParam.instructor == true){
                if(schList[0].Instructor__c != null && (roomParam.section != true || schList[0].Opportunity__r.Section__c == null) && (roomParam.language != true || schList[0].Opportunity__r.Language__c == null)){
                    filterQueryString += ' AND Instructor__c = \''+schList[0].Instructor__c+'\'';        
                } else if(schList[0].Instructor__c != null){
                    filterQueryString += ' AND Instructor__c = \''+schList[0].Instructor__c+'\'';
                }
            }
            //system.debug(':::filterQueryString::'+filterQueryString);
            schSecList = Database.query(filterQueryString);
            if(schSecList.size() > 0){
                for(Schedule__c sch : schSecList){
                    roomsWithSection.add(sch.Room__c);
                }
            }
        }
        List<Id> RoomIds = new List<Id>();
        Set<Id> roomIdSet = new Set<Id>();
        SearchResult result = new SearchResult();
        system.debug(':::::roomParam:::::::::'+roomParam);
        //system.debug(':::::conflictParameter:::::::::'+conflictParameter);
        Integer queryLimit = roomParam.resultSize != null ? roomParam.resultSize : 10;
        Integer offset = queryLimit * (roomParam.offset != null ? roomParam.offset : 0);
        
        String roomquery = 'SELECT Id, Name, Location_n__c, Location_n__r.Name, Student_Capacity__c, Room_Location__c, Floor_Suite__c, Floor_Suite__r.Name,Room_Status__c,'
                             +'Function__c, Ext__c FROM Room__c WHERE (Location_n__r.RecordType.DeveloperName = \'DLS_Site\' OR Location_n__r.RecordType.DeveloperName = \'Online\') AND Room_Status__c != null AND Room_Status__c NOT IN (\'Inactive\',\'Sub-leased\') AND Function__c NOT IN :functionBlackList';
        String querycondition = '';
        String totalroomsquery = 'SELECT Id, Name, Location_n__c, Location_n__r.Name, Student_Capacity__c, Room_Location__c, Floor_Suite__c, Floor_Suite__r.Name,Room_Status__c,'
                                +'Function__c, Ext__c FROM Room__c WHERE (Location_n__r.RecordType.DeveloperName = \'DLS_Site\' OR Location_n__r.RecordType.DeveloperName = \'Online\') AND Room_Status__c != null AND Room_Status__c NOT IN (\'Inactive\',\'Sub-leased\') AND Function__c NOT IN :functionBlackList';
        //system.debug(':::::roomParam:::::::::'+roomParam.locationId);
        //system.debug(':::::roomParam:::::::::'+roomParam.function);
        //system.debug(':::::roomParam:::::::::'+roomParam.capacity);
        //system.debug(':::::roomParam:::::::::'+roomParam.suiteId);
        //system.debug(':::::roomParam:::::::::'+roomParam.roomType);
        
        if(roomsWithSection.size() > 0){
            querycondition += ' AND Id IN :roomsWithSection';
        }
        if(roomParam.locationId != null){
            querycondition += ' AND Location_n__c = \''+roomParam.locationId+'\'';
        }
        
        if(!roomParam.function.IsEmpty()){
            querycondition += ' AND Function__c IN :funSet';
        }
        
        if(!roomParam.floor.IsEmpty() /*&& !roomParam.suiteId.IsEmpty()*/){
            //querycondition += ' AND Floor_Suite__r.Floor__c IN :floorSet';
            querycondition += ' AND Floor_Suite_Level__c IN :floorSet';
        }
        if(roomParam.capacity != null){
            querycondition += ' AND Student_Capacity__c >= '+roomParam.capacity;
        }
        if(roomParam.roomType != null){
            querycondition += ' AND Room_Location__c = \''+roomParam.roomType+'\'';
        }
        if(!roomParam.suiteId.IsEmpty()){
            querycondition += ' AND Floor_Suite__c IN :suiSet';
        }
        if(roomParam.searchByName != null){
            queryCondition += ' AND Name LIKE \'%'+roomParam.searchByName+'%\''; 
        }
        
        String roomidquery = 'SELECT Id, Name, Location_n__c, Location_n__r.Name, Student_Capacity__c, Room_Location__c, Floor_Suite__c, Floor_Suite__r.Name,Room_Status__c,'
                             +'Function__c, Ext__c FROM Room__c WHERE (Location_n__r.RecordType.DeveloperName = \'DLS_Site\' OR Location_n__r.RecordType.DeveloperName = \'Online\') AND Room_Status__c != null AND Room_Status__c NOT IN (\'Inactive\',\'Sub-leased\') AND Function__c NOT IN :functionBlackList';
        
        roomidquery += querycondition; 
        roomquery += querycondition+' ORDER BY Name LIMIT '+queryLimit+' OFFSET '+offset+'';
        
        system.debug('::::::roomQuery:::'+roomquery);
        
        List<Room__c> rooms = Database.query(roomquery);
        System.debug('::::rooms:::::'+rooms);
        List<Room__c> roomsForIds = Database.query(roomidquery);
        result.allRooms = rooms;
        for(Room__c r : roomsForIds){
            RoomIds.add(r.Id);  
            roomIdSet.add(r.Id);  
        }
        result.filteredRoomIds = RoomIds;
        result.roomsForCalendar = roomsForIds;
        //system.debug(':::::RoomIds:::::::'+RoomIds);
        //system.debug(':::::RoomIds:::::::'+result.filteredRoomIds);
        if(conflictParameter != null){
            //system.debug(':::::conflictParameter:::::::::'+conflictParameter);
            conflictsMap = getschedulesWithConflicts(conflictParameter, roomIdSet);
            result.conflicts = conflictsMap;
            system.debug('::conflicts::::'+result.conflicts);
        }
        for(Id i : conflictsMap.keySet()){
            conflictsId.add(i);
        }
        String countquery = 'SELECT Count() FROM Room__c WHERE (Location_n__r.RecordType.DeveloperName = \'DLS_Site\' OR Location_n__r.RecordType.DeveloperName = \'Online\') AND Room_Status__c != null AND Room_Status__c NOT IN (\'Inactive\',\'Sub-leased\') AND Function__c NOT IN :functionBlackList';
        countquery += querycondition;
        if(!conflictsMap.IsEmpty()) {
            totalroomsquery += querycondition+' AND Id NOT IN :conflictsId';
        } else {
            totalroomsquery += querycondition;
        }
        //system.debug(':::totalroomsquery:::'+totalroomsquery);
        List<Room__c> roomsWithoutConflicts = Database.query(totalroomsquery);
        //system.debug(':::roomsWithoutConflicts:::'+roomsWithoutConflicts);
        result.allRoomsWithoutConflicts = roomsWithoutConflicts;
        Integer totalCount  = Database.countQuery(countquery);
        result.recordCount = totalCount;
        return result;
    }
    
   

    @RemoteAction
    public static List<String> getTimePicklist() {
        List<String> timeList = new List<String>();
        List<Schema.PicklistEntry> timePickList = Events__c.Start_Time__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : timePickList) {
            timeList.add(entry.getValue());
        }
        return timeList;
    }

    @RemoteAction
    public static List<String> getFloorPicklist() {
        List<String> floorList = new List<String>();
        List<Schema.PicklistEntry> listEntry = Floor_Suite__c.Floor__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : listEntry) {
            floorList.add(entry.getValue());
        }
        return floorList;
    }
    
    @RemoteAction
    public static List<String> getFunctionPicklist() {
        List<String> functionList = new List<String>();
        List<Schema.PicklistEntry> listEntry = Room__c.Function__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : listEntry) {
            if(functionBlackList.contains(entry.getValue()))
                continue;
            functionList.add(entry.getValue());
        }
        return functionList;
    }

    @RemoteAction
    public static void setRoom(Id scheduleId, Id roomId) {
        //Find the scheduleId is null or not
        if(scheduleId == null) {
            throw new AssignRoomException('Schedule Id Should not be null.');
        }
        if(roomId == null) {
            throw new AssignRoomException('Room Id Should not be null.');
        }
        Integer eventCount = [SELECT COUNT() FROM Events__c WHERE Schedule__c = :scheduleId];
        EventManagementController.setRoom(scheduleId, roomId);
    }
    
    @RemoteAction
    public static List<Schedule__c> getSchedulesByInstructor(Id scheduleId) {
        System.debug('::::::scheduleId::::::::'+scheduleId);
        List<Schedule__c> schList = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{scheduleId},',Project__r.Name');
        List<Schedule__c> schedules = new List<Schedule__c>();
        if(schList[0].Instructor__c != null){
            schedules = ScheduleService.getSchedulesByContIds(new Set<Id>{schList[0].Instructor__c},' WHERE Project__r.AcctSeed__Status__c IN (\'Active\',\'Order\') AND Status__c IN (\'Drafted\',\'Active\') AND',',Instructor__r.Name,Project_Task__r.Total_Qty_Planned__c,Project_Task__r.Unit__c,Room__r.Name,Project_Task__r.Name,Project__r.Name');
        }
        return schedules;
    }
    
    @RemoteAction
    public static scheduleEventConflictDetails getSchedulesByRooms(Id roomId) {
        List<Schedule__c> schedules = ScheduleService.getScheduleRec(' WHERE Project__r.AcctSeed__Status__c IN (\'Active\',\'Order\') AND Status__c IN (\'Drafted\',\'Active\') AND Room__c ',',Instructor__r.Name,Project_Task__r.Total_Qty_Planned__c,Project_Task__r.Unit__c,Room__r.Name,Project_Task__r.Name,Project__r.Name',new Set<Id>{roomId});
        
        //Qry schedule related event records to get the related conflict records
        // Added by NS on Oct 23 2018
        Set<Id> eventIds = new Set<Id>();
        Set<Id> schIds = new Set<Id>();
        
        for(Schedule__c sch : schedules){
            schIds.add(sch.Id);
        }
        system.debug('::::::::::schIds::::'+schIds.size());
        for(Events__c eve : [SELECT Id,Name FROM Events__c WHERE Schedule__c IN :schIds AND Room__c = :roomId]){
            eventIds.add(eve.Id);
        }
        system.debug(':::::::eventIds::::::'+eventIds.size());
        
        List<Event_Conflict__c> conflicts = [SELECT Id,Name,Event__c,Event__r.Name,Conflict_Event__c,Conflict_Event__r.Name,Conflict_Event__r.Start_Time__c,Conflict_Event__r.End_Time__c,Conflict_Status__c,Date__c,
                                                    Instructor_Conflict__c,Project__c,Project__r.Name,Schedule__c,Schedule__r.Name,Room_Conflict__c,
                                                    Student_Conflict__c
                                                FROM Event_Conflict__c
                                                WHERE (Event__c IN :eventIds OR Conflict_Event__c IN :eventIds) 
                                                    AND (Event__r.Room__c = :roomId OR Conflict_Event__r.Room__c = :roomId)];
        
        system.debug('::::::::conflicts:::::::'+conflicts.size());
        
        scheduleEventConflictDetails schConflictDetails = new scheduleEventConflictDetails();
        schConflictDetails.scheduleRecords = schedules;
        schConflictDetails.conflictRecords = conflicts;
        
        return schConflictDetails;
    }
    
    @RemoteAction
    public static List<Room__c> getroomsByRoomId(Id roomId) {
        List<Room__c> rooms = SObjectQueryService.SObjectQuery('Room__c',new Set<Id>{roomId},'');
        return rooms;
    }
    
    @RemoteAction
    public static LocationCapacityValues prepopLocationAndCapacity(Id scheduleId, Id returnId) {
        Id locId;
        String locName;
        //List<Schedule__c> schList = [SELECT Id, Start_Date__c,  Opportunity__r.Location__c, Project__r.Training_Location__c, Opportunity__c, Project__c, Opportunity__r.Location__r.Name, Project__r.Training_Location__r.Name,Project__r.Name FROM Schedule__c WHERE Id = :scheduleId];
        List<Schedule__c> schList = SObjectQueryService.SObjectQuery('Schedule__c', new Set<Id>{scheduleId}, ',Opportunity__r.Location__c, Project__r.Training_Location__c, Opportunity__r.Location__r.Name, Project__r.Training_Location__r.Name,Project__r.Name');
        
        //System.debug(':::locId::'+schList[0].Opportunity__r.Location__c);
        if((schList[0].Opportunity__c != Null && schList[0].Project__c != Null) || schList[0].Project__c != Null) {
            locId = schList[0].Project__r.Training_Location__c;
            locName = schList[0].Project__r.Training_Location__r.Name;
        }else if(schList[0].Opportunity__c != Null) {
            locId = schList[0].Opportunity__r.Location__c;
            locName = schList[0].Opportunity__r.Location__r.Name;
        }
        
        //System.debug(':::locId::'+schList[0].Opportunity__r.Location__c);
        //System.debug(':::locName::'+schList[0].Opportunity__r.Location__r.Name);
        
        Integer stuCount = [SELECT Count() FROM Contact_Assignments__c WHERE Project__c = :returnId AND RecordType.DeveloperName = 'Student'];

        LocationCapacityValues locCap = new LocationCapacityValues();
        locCap.locationId = locId;
        locCap.locationName = locName;
        locCap.studentCount = stuCount;
        locCap.startDate = string.ValueOf(schList[0].Start_Date__c);
        locCap.endDate = string.ValueOf(schList[0].End_Date__c);
        locCap.startTime = schList[0].Start_Time__c;
        locCap.endTime = schList[0].End_Time__c;
        locCap.monday = schList[0].Monday__c;
        locCap.tuesday = schList[0].Tuesday__c;
        locCap.wednesday = schList[0].Wednesday__c;
        locCap.thursday = schList[0].Thursday__c;
        locCap.friday = schList[0].Friday__c;
        locCap.saturday = schList[0].Saturday__c;
        locCap.sunday = schList[0].Sunday__c;
        System.debug(':::schList::'+schList);
        return locCap;
    }

    /*
     *  Excpetion class which is used to find the Exception in Room Assignment
     */
    public class AssignRoomException extends Exception {
        public String message;
    }

    @RemoteAction
    public static List<MTT_Location__c> getLocation() {
        
        return [SELECT Id, Name FROM MTT_Location__c WHERE RecordType.DeveloperName = 'DLS_Site' OR RecordType.DeveloperName = 'Online'];
    }

    /*@RemoteAction
    public static List<Floor_Suite__c> getSuite() {
        
        return [SELECT Id, Name FROM Floor_Suite__c];
        
    }
    @RemoteAction
    public static List<Floor_Suite__c> getSuitebylocation(Id locationId) {
        if(locationId != null){
            return [SELECT Id, Name, Location__c FROM Floor_Suite__c WHERE Location__c = :locationId];
        } else {
            return [SELECT Id, Name, Location__c FROM Floor_Suite__c];
        }
    }*/
    
    @RemoteAction
    public static List<Room__c> getFloorsbylocation(Id locationId) {
        if(locationId != null){
            return [SELECT Id, Name, Floor_Suite__r.Floor__c FROM Room__c WHERE Location_n__c = :locationId];
        } else {
            return [SELECT Id, Name, Floor_Suite__r.Floor__c FROM Room__c];
        }
    }
    
    @RemoteAction
    public static List<Room__c> getSuitesbyRoomFloors(List<String> floorName) {
        Set<String> floorSet = new Set<String>();
        for(String f : floorname){
            floorSet.add(f);
        }
        if(floorName != null){
            return [SELECT Id, Name, Floor_Suite__r.Floor__c, Floor_Suite__c, Floor_Suite__r.Name FROM Room__c WHERE Floor_Suite__r.Floor__c IN :floorSet];
        } else {
            return [SELECT Id, Name, Floor_Suite__r.Floor__c, Floor_Suite__c, Floor_Suite__r.Name FROM Room__c];
        }
    }

    @RemoteAction
    public static List<ScheduleDomain.roomRelatedinfo> getRoomDetails(List<Id> roomIds){ 
        system.debug('::::roomIds::::'+roomIds.size()); 
        Set<String> funSet = new Set<String>();
        Set<Id> suiSet = new Set<Id>();
        Set<String> floorSet = new Set<String>();
        Set<Id> roomIdSet = new Set<Id>();
        for(Id i : roomIds){
            roomIdSet.add(i);
        }  
        String parentField = ',Instructor__r.Name,Room__r.Room_Location__c,Room__r.Floor_Suite__c,Room__r.Floor_Suite__r.Name,Opportunity__r.Language__c,'
                             +'Opportunity__r.Name,Project_Task__r.Project_Task_Type__c,Opportunity__r.Section__c,Room__r.Floor_Suite__r.Floor__c,Room__r.Notes__c,Room__r.Name,Project__r.AcctSeed__Opportunity__c,Project__r.AcctSeed__Opportunity__r.Name,Project__r.AcctSeed__Opportunity__r.Section__c,Project__r.AcctSeed__Opportunity__r.Language__c,Project__r.AcctSeed__Status__c,Project__r.Name';
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Schedule__c');
        
        String schedulequery = 'SELECT '+fieldName+parentField+' FROM Schedule__c'+' WHERE Room__c IN :roomIdSet AND Project__r.AcctSeed__Status__c IN (\'Active\',\'Order\') AND Status__c IN (\'Drafted\',\'Active\')';
        //system.debug(':::schedulequery::'+schedulequery);
        List<Schedule__c> scheduleList = Database.query(schedulequery);
        
        //List<Schedule__c> scheduleList = ScheduleService.getScheduleRec(querycondition,parentField,new Set<Id>{});
        system.debug(':::::scheduleList:::::'+scheduleList);
        List<ScheduleDomain.roomRelatedinfo> roomdetails = new List<ScheduleDomain.roomRelatedinfo>();
        roomdetails = ScheduleTranslator.RoomInfoMethod(scheduleList);
        //system.debug('::::::roomdetails'+roomdetails);
        return roomdetails;    

    }
   
    /*@RemoteAction
    public static Map<Id, Integer> getRoomsWithConflicts(ConflictSearchParameter conflictParameter) {
        Map<Id, Integer> conflictMap = new Map<Id, Integer>();
        if(conflictParameter == null || conflictParameter.startDate == null || conflictParameter.endDate == null || conflictParameter.startTime == null || conflictParameter.endTime == null)
            return conflictMap;
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c];
        Date startDate = Date.valueOf(conflictParameter.startDate);
        Date endDate = Date.valueOf(conflictParameter.endDate);
        Integer startTime = EventManagementController.convertToMinutes(conflictParameter.startTime);
        Integer endTime = EventManagementController.convertToMinutes(conflictParameter.endTime);
        List<Events__c> eventList = [SELECT Id, Name, Date__c, Start_Time__c, End_Time__c, Room__c, Room__r.Name FROM Events__c WHERE Date__c >= :startDate AND Date__c <= :endDate AND Status__c = 'Scheduled' AND Room__r.Name != 'Zoom'];
        for(Events__c e : eventList) {
            if(e.Room__c != null) {
                if(e.Start_Time__c == null || e.End_Time__c == null) {
                    continue;
                }
                Integer eventStartTime = EventManagementController.convertToMinutes(e.Start_Time__c);
                Integer eventEndTime = EventManagementController.convertToMinutes(e.End_Time__c);
                System.debug(e.Room__r.Name + ' ' + eventStartTime + ' ' + eventEndTime + ' ' + startTime + ' ' + endTime);
                if((eventStartTime >= startTime && eventStartTime <= endTime) || (eventEndTime >= startTime && eventEndTime < endTime)) {
                    System.debug('Entered.');
                    if(hasDay(e.Date__c, conflictParameter)) {
                        if(!conflictMap.containsKey(e.Room__c)) {
                            System.debug('Conflict ' + e.Room__r.Name);
                            conflictMap.put(e.Room__c, 0);
                        }
                        conflictMap.put(e.Room__c, conflictMap.get(e.Room__c) + 1);
                    }
                }
            }
        }
        return conflictMap;
    }*/
    
    
    public static Map<Id, Integer> getschedulesWithConflicts(ConflictSearchParameter conflictParameter, Set<Id> roomIds) {
    
        Map<Id, Integer> eventconflictMap = new Map<Id, Integer>();
        if(conflictParameter == null || conflictParameter.startDate == null 
            || conflictParameter.endDate == null || conflictParameter.startTime == null 
            || conflictParameter.endTime == null){
            
            return eventconflictMap;
        }
            
        Date startDate = Date.valueOf(conflictParameter.startDate);
        Date endDate = Date.valueOf(conflictParameter.endDate);
        Integer startTime = EventManagementController.convertToMinutes(conflictParameter.startTime);
        Integer endTime = EventManagementController.convertToMinutes(conflictParameter.endTime);
        
        Set<String> daysValues = new Set<String>();
        if(conflictParameter.sunday) {
            daysValues.add('Sunday');
        }
        
        if(conflictParameter.monday) {
            daysValues.add('Monday');
        }
        
        if(conflictParameter.tuesday) {
            daysValues.add('Tuesday');
        }
        
        if(conflictParameter.wednesday) {
            daysValues.add('Wednesday');
        }
        
        if(conflictParameter.thursday) {
            daysValues.add('Thursday');
        }
        
        if(conflictParameter.friday) {
            daysValues.add('Friday');
        }
        
        if(conflictParameter.saturday) {
            daysValues.add('Saturday');
        }
        
        // Room conflict check logic is changed from schedule to events. Events are currently available in production
        // Modified by NS on Oct 22 2018
        
        //List<Schedule__c> scheduleList = [SELECT Id, Name, Start_Date__c,End_Date__c, Start_Time__c, End_Time__c, Room__c, Room__r.Name, Monday__c, Saturday__c, Sunday__c, Thursday__c, Tuesday__c, Wednesday__c,Friday__c,Project__r.Name FROM Schedule__c WHERE Room__r.Name != 'Zoom' AND Room__c IN :roomIds AND Project__r.AcctSeed__Status__c IN ('Active','Order') AND Status__c IN ('Active','Drafted')];
        //system.debug('*****scheduleList'+scheduleList);
        //system.debug('*****scheduleList'+scheduleList.size());
        
        /*List<Events__c> eventRecords = [SELECT Id,Name,Date__c,Duration__c,Start_Time__c,End_Time__c,Status__c,Schedule__c,Room__c,Instructor__c,Project__c
                                            FROM Events__c
                                            WHERE Room__r.Exclude_Conflict_Check__c = false AND Room__c IN :roomIds 
                                                    AND Project__r.AcctSeed__Status__c IN ('Active','Order') AND Status__c = 'Scheduled'];*/
        
        EventHandler eveHandle = new EventHandler();
        
        for(Events__c e : [SELECT Id,Name,Date__c,Duration__c,Start_Time__c,End_Time__c,Status__c,Schedule__c,Room__c,Instructor__c,Project__c
                                            FROM Events__c
                                            WHERE Room__r.Exclude_Conflict_Check__c = false AND Room__c IN :roomIds 
                                                    AND Project__r.AcctSeed__Status__c IN ('Active','Order') AND Status__c = 'Scheduled']) {
            if(e.Room__c != null) {
                if(e.Start_Time__c == null || e.End_Time__c == null) {
                    continue;
                }
                
                Integer ST1,ET1,ST2,ET2;
                
                if(eveHandle.convertToMinutes(conflictParameter.startTime) > eveHandle.convertToMinutes(e.Start_Time__c)) {
                    ST1 = eveHandle.convertToMinutes(e.Start_Time__c);
                    ET1 = eveHandle.convertToMinutes(e.End_Time__c);
                    
                    ST2 = eveHandle.convertToMinutes(conflictParameter.startTime);
                    ET2 = eveHandle.convertToMinutes(conflictParameter.endTime);
                    
                }else {
                    ST1 = eveHandle.convertToMinutes(conflictParameter.startTime);
                    ET1 = eveHandle.convertToMinutes(conflictParameter.endTime);
                    
                    ST2 = eveHandle.convertToMinutes(e.Start_Time__c);
                    ET2 = eveHandle.convertToMinutes(e.End_Time__c);
                }
                
                if(e.Date__c >= startDate && e.Date__c <= endDate ){
                    //System.debug('Entered...1'+e);
                    if(daysValues.contains(eveHandle.getDayValue(e.Date__c))) {
                        //System.debug('Entered....2'+e);
                        if(ET2 >= ST1 && ST2 < ET1) {
                            //System.debug('Entered....3'+e);
                            if(!eventconflictMap.containsKey(e.Room__c)) {
                                //System.debug('Conflict ' + e.Room__r.Name);
                                eventconflictMap.put(e.Room__c, 0);
                            }
                            eventconflictMap.put(e.Room__c, eventconflictMap.get(e.Room__c) + 1);
                        }
                    }
                }
            }
        }
        system.debug('***eventconflictMap****'+eventconflictMap.size());
        return eventconflictMap;
    }
    /*public static Boolean hasDay(Date checkDate, ConflictSearchParameter conflictSearch) {
        String day = ((DateTime) checkDate).format('E');
        System.debug('day ' + day);
        //if(!conflictSearch.sunday && !conflictSearch.monday && !conflictSearch.tuesday && !conflictSearch.wednesday && !conflictSearch.thursday && !conflictSearch.friday && !conflictSearch.saturday)
          //  return true;
        //
        if(day == 'Sun' && conflictSearch.sunday) {
            return true;
        } else if(day == 'Mon' && conflictSearch.monday) {
            return true;
        } else if(day == 'Tue' && conflictSearch.tuesday) {
            return true;
        } else if(day == 'Wed' && conflictSearch.wednesday) {
            return true;
        } else if(day == 'Thu' && conflictSearch.thursday) {
            return true;
        } else if(day == 'Fri' && conflictSearch.friday) {
            return true;
        } else if(day == 'Sat' && conflictSearch.saturday) {
                return true;
        }
        return false;
    }*/
    
    @RemoteAction
    public static void updateRoom(String jsonString){
        //System.debug('jsonString' + jsonString);
        List<Room__c> rooms = (List<Room__c>) System.JSON.deserialize(jsonString, List<Room__c>.class);
        System.debug('rooms' + rooms);
        if(!rooms.isEmpty()){
            update rooms;
        }
    }
    
    // To check whether the logged in user has the permission to Edit/Assign the Room
    @RemoteAction
    public static Boolean checkForRoomEditCP() {
        return FeatureManagement.checkPermission('Permission_to_Edit_Rooms');
    }
    
    public class SearchResult {
        public List<Room__c> allRooms;
        public Map<Id, Integer> conflicts;
        public Integer recordCount;
        public List<Id> filteredRoomIds;
        public List<Room__c> roomsForCalendar;
        public List<Room__c> allRoomsWithoutConflicts;
    }

    public class ConflictSearchParameter {
        public String startDate;
        public String endDate;
        public String startTime;
        public String endTime;
        public Boolean monday = false;
        public Boolean tuesday = false;
        public Boolean wednesday = false;
        public Boolean thursday = false;
        public Boolean friday = false;
        public Boolean saturday = false;
        public Boolean sunday = false;
    }
    
    public class SearchParameter {
        public Id locationId;
        public String[] function;
        public String[] floor;
        public Integer capacity;
        public String roomType;
        public String[] suiteId;
        public Boolean section;
        public Boolean language;
        public Boolean instructor;
        public Integer resultSize;
        public Integer offset;
        public String searchByName;
    }
   
    public class LocationCapacityValues {
        public Id locationId;
        public String locationName;
        public Integer studentCount;
        public String startDate;
        public String endDate;
        public String startTime;
        public String endTime;
        public Boolean monday = false;
        public Boolean tuesday = false;
        public Boolean wednesday = false;
        public Boolean thursday = false;
        public Boolean friday = false;
        public Boolean saturday = false;
        public Boolean sunday = false;
    }
    
    public class scheduleEventConflictDetails {
        public List<Schedule__c> scheduleRecords;
        public List<Event_Conflict__c> conflictRecords;
    }
        
}