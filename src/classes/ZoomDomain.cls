/*******************************************************************************
- class for zoom requests json format
- This will be called from apex class, Trigger
- Created by Dhinesh - W-006013 - Zoom Integration
*******************************************************************************/
public class ZoomDomain{
    
    public static Map<Integer, String> zoomUserTypeMap = new Map<Integer, String>{1 => 'Zoom - Basic', 2 => 'Zoom - Pro'};
    public static Map<String, String> zoomUserStatusMap = new Map<String, String>{'active' => 'Active', 'inactive' => 'In-Active','pending' => 'Pending'};
        
    public class zoomUserWrap{
    
        public string action = 'create';
        public zoomUser user_info;
    }
        
    public class zoomUser{
        public String first_name;
        public String last_name;
        public String email;
        public String type; //Basic => 1, Licensed => 2, On-prem => 3
        
        public zoomUser(String first_name, String last_name, String email, String type){
            this.first_name = first_name;
            this.last_name = last_name;
            this.email = email;
            this.type = type;
        }
        
        public zoomUser(String type){
            this.type = type;
        }
        
        public zoomUser(){           
        }
    }
    
    public class zoomMeeting{
        public String topic;
        public Integer type;
        public String start_time;
        public Integer duration;
        public String schedule_for;
        public String timezone;
        public String password;
        public String agenda;
            /*"recurrence": {
                "type": "integer",
                "repeat_interval": "integer",
                "weekly_days": "string",
                "monthly_day": "integer",
                "monthly_week": "integer",
                "monthly_week_day": "integer",
                "end_times": "integer",
                "end_date_time": "string [date-time]"
            },*/
         public zoomMeetingSettings settings;
    }
    
    public class zoomMeetingSettings{
        public Boolean host_video = false;
        public Boolean participant_video = false;
        public Boolean cn_meeting = false;
        public Boolean in_meeting = false;
        public Boolean join_before_host = false;
        public Boolean mute_upon_entry = false;
        public Boolean watermark = false;
        public Boolean use_pmi = false;
        public Integer approval_type = 2;
                //"registration_type": "integer",
                //"audio": "string",
                //"auto_recording": "string",
                //"enforce_login": "boolean",
                //"enforce_login_domains": "string",
               // "alternative_hosts": "string",
                /*"global_dial_in_countries": [
                    "string"
                ],*/
         public Boolean waiting_room = true;
         public Boolean registrants_confirmation_email = true;
         public Boolean registrants_email_notification = true;
    }
    
    
    public class userReponseWrap{
        public Boolean isZoomUserAvailable;
        public Contact con;
        public ZoomDomain.zoomUser zoomUser;
        public EventDomain.EventCalendarInfo event;
        public String message;
    }
    
    public class zoomUserCreationWrap{
        public ZoomDomain.zoomUser zoomUser;
        public String instructorMailId;
        public Id instructorId;
    }
}