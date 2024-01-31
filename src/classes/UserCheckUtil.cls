//Crated by Melbin on 28 Apr, 2016
global without sharing class UserCheckUtil {

    //Store the result.
    public UserType type;
    //To store the serialized json string.
    public String typeJson {get; set;}

    //Constructor. Excecuted at the start of the page.
    global UserCheckUtil() {
        //Get the type of the user and the contact id of the user.
        this.type = UserCheckUtil.getUserType();
        //Serialize the userType to json string.
        this.typeJson = System.JSON.serialize(this.type);
    }


    //Method to get type of the user. ex, Instructor, Student, etc.
    //Created on 28 Apr, 2016, Melbin
    @RemoteAction
    global static UserType getUserType() {
        Id userId = userinfo.getUserId();
        String[] roles = new String[]{};
        String currentRole;
        List<User> userList = [SELECT Id, Name, Instructor_Access__c, Student_Access__c, Partner_Access__c, Client_Access__c, Staff_Access__c, ContactId, Current_Previlege__c FROM User WHERE Id = :userId];
        if(userList.size() > 0) {
            System.debug('userList[0].Current_Previlege__c' + userList[0].Current_Previlege__c);
            System.debug('Student' + userList[0].Student_Access__c);
            System.debug('Instructor' + userList[0].Instructor_Access__c);
            System.debug('Staff' + userList[0].Staff_Access__c);
            if(userList[0].Student_Access__c != null && userList[0].Student_Access__c) {
                roles.add('Student');
                currentRole = 'STUDENT';
            }
            if(userList[0].Partner_Access__c != null && userList[0].Partner_Access__c) {
                roles.add('Partner');
                currentRole = 'PARTNER';
            }
            if(userList[0].Client_Access__c != null && userList[0].Client_Access__c) {
                roles.add('Client');
                currentRole = 'CLIENT';
            }
            if(userList[0].Instructor_Access__c) {
                roles.add('Instructor');
                currentRole = 'INSTRUCTOR';
            }
            if(userList[0].Staff_Access__c) {
                roles.add('Staff');
                currentRole = 'STAFF';
            }

            if(hasElement(roles, userList[0].Current_Previlege__c)) {
                currentRole = userList[0].Current_Previlege__c;
            }
            if(currentRole == null) {
                return new UserType('UNAUTHORIZED');
            }
            currentRole = currentRole.toUpperCase();

            return new UserType(currentRole, userList[0].contactId, userList[0].Name, roles, getNotification(userList[0].contactId));
        }
        return new UserType('UNAUTHORIZED');
    }


    //Method to get all the notification
    global static List<Notification> getNotification(Id contactId) {
        List<Notification> notificationList = new List<Notification>();
        System.debug('ContactId ' + contactId);
        if(contactId != null) {
            //Query the task object with the contact Id.
            List<Notification__c> allNotificationList = [SELECT Id, Title__c, Content__c FROM Notification__c WHERE Contact__c = :contactId];
            System.debug('taskList ' + allNotificationList);
            for(Notification__c note : allNotificationList) {
                notificationList.add(new Notification(note.Title__c, note.Content__c));
            }
        }
        return notificationList;
    }

    //Method to find check the list has the element
    global static Boolean hasElement(List<String> stringList, String element) {
        for(String listElement : stringList) {
            if(listElement == element) {
                return true;
            }
        }
        return false;
    }

    //Nottification Inner Class
    global class Notification {
        public String title;
        public String content;
        public Notification(String title, String content) {
            this.title = title;
            this.content = content;
        }
    }

    global class UserType {
        public String type;
        public Id userContactId;
        public String[] roles;
        public Notification[] notificationList;
        public String userName;
        public UserType(String type, Id userContactId, String userName, String[] roles, Notification[] notificationList) {
            this.type = type;
            this.userContactId = userContactId;
            this.roles = roles;
            this.notificationList = notificationList;
            this.userName = userName;
        }

        public UserType(String type) {
            this.type = type;
        }

    }

    //Change the current previlage of the User
    @RemoteAction
    global static void changePrevilege(String previlage) {
        User currentUser = [SELECT Id, Name, Instructor_Access__c, Student_Access__c, Partner_Access__c, Client_Access__c, Staff_Access__c, ContactId, Current_Previlege__c FROM User WHERE Id = :userinfo.getUserId()];
        if(currentUser != null) {
            //Find the previlage
            if(previlage == 'Student' || previlage == 'Instructor' || previlage == 'Client' || previlage == 'Partner' || previlage == 'Staff') {
                currentUser.Current_Previlege__c = previlage;
            }
            update currentUser;
        }
    }

}