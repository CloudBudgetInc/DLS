public class TimezoneUtilClass {
    
    public DateTime getDateTimeInGMT(String timeZoneStr, Date dateValue, String hrStr, Boolean isEndDate) {
        if(timeZoneStr != null &&  timeZoneStr != '' && dateValue != null && hrStr != null && hrStr != '') {
            Timezone tz = Timezone.getTimeZone(timeZoneStr);
            DateTime dtpre = DateTime.newInstance(dateValue.year(), dateValue.month(), dateValue.day(), 0, 0, 0);
            
            Integer offSet = tz.getOffset(dtpre);            
            
            List<String> hrList = String.isNotBlank(hrStr)?hrStr.split(' ')[0].split(':'):new List<String>();
            if(hrList != null && hrList.size() > 0) {
                Integer hr = Integer.valueOf(hrList[0]);
                Integer min = Integer.valueOf(hrList[1]);
                String amOrPm = hrStr.split(' ')[1];
                
                
                if ((amOrPm == 'PM' && hr < 12) || (isEndDate && amOrPm == 'AM' && hr == 12)) {
                    hr += 12;    
                }
                if(!isEndDate && amOrPm == 'AM' && hr == 12){
                    hr = 0;
                }
                
                Integer hrMilliSeconds = hr * 60 * 60 * 1000;
                Integer minMilliSeconds = min * 60 * 1000;
                Integer totMilliSeconds = hrMilliSeconds + minMilliSeconds;
                Integer off = totMilliSeconds - offSet;
                
                Integer totSeconds = off/1000;
                
                Integer remSeconds = Math.mod(totSeconds, 60);
                Integer minutes = totSeconds/60;        
                
                Integer mins = Math.mod(minutes, 60);
                Integer hrs = minutes/60;
                
                DateTime dateTimeVal = DateTime.newInstanceGMT(dateValue.year(), dateValue.month(), dateValue.day(), hrs, mins, remSeconds);
                
                return dateTimeVal;
            }else {
            
                return null;
            }
        } else {
            return null;
        }
    }
    
    public class results{
        public geometry geometry;
    }
   
    public class geometry{
        public location location;
    }
    
    Public Class location{
        Public String Lat;
        Public String Lng;
        Public String status;
    }
    
    public class LocationResponse {
        public list<results> results {get;set;}
        public string status {get;set;}
    }
    
    
    public location geoCode( string Street,String City, String State, String Country, String Zipcode) {
        
        String APIKey = system.Label.Google_API_Key;
        String Address = '';
        if (Street!= null)
            Address += Street;
        if (City!= null)
            Address += ', '+City;
        if (State!= null)
            Address += ', '+State; 
        if (Country!= null)
            Address += ', '+Country; 
        if (Zipcode!= null)
            Address += ', '+Zipcode; 
        system.debug('Address======='+Address );
         
        Http h = new Http();      
        location ll = new location();
        if(Address != '') {
            // Build the request
            HttpRequest req = new HttpRequest();       
            req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?key='+APIKey+'&address=' + EncodingUtil.urlEncode(Address, 'UTF-8') + '&sensor=false');
            req.setMethod('GET');
     
            // Send the request
            HttpResponse res = new HttpResponse();
            if(!Test.isRunningTest()){
                res = h.send(req);
            
            } else {
                
                string resp = '{"results" : [{"address_components" : [{"long_name" : "1600","short_name" : "1600","types" : [ "street_number" ]},{"long_name" : "Amphitheatre Pkwy","short_name" : "Amphitheatre Pkwy","types" : [ "route" ]},{"long_name" : "Mountain View","short_name" : "Mountain View","types" : [ "locality", "political" ]},{"long_name" : "Santa Clara County","short_name" : "Santa Clara County","types" : [ "administrative_area_level_2", "political" ]},{"long_name" : "California","short_name" : "CA","types" : [ "administrative_area_level_1", "political" ]},{"long_name" : "United States",'
                        +'"short_name" : "US","types" : [ "country", "political" ]},{"long_name" : "94043","short_name" : "94043","types" : [ "postal_code" ]}],"formatted_address" : "1600 Amphitheatre Parkway, Mountain View, CA 94043, USA","geometry" : {"location" : {"lat" : 37.4224764,"lng" : -122.0842499},"location_type" : "ROOFTOP",'
                        +'"viewport" : {"northeast" : {"lat" : 37.4238253802915,"lng" : -122.0829009197085},"southwest" : {"lat" : 37.4211274197085,"lng" : -122.0855988802915}}},"place_id" : "ChIJ2eUgeAK6j4ARbn5u_wAGqWA","types" : [ "street_address" ]}],"status" : "OK"}';
                res.setStatus('OK');
                res.setStatusCode(200);
                res.setBody(resp);
            } 
            System.debug('res::::'+res.getBody());
            // Deserialize the response
            LocationResponse resp = (LocationResponse)JSON.deserialize(res.getBody(), LocationResponse.class);         
            System.debug('resp:::::'+resp);
            if(resp.results.size() > 0 ) {
                
                ll.lat = resp.results[0].geometry.location.lat;
                ll.lng = resp.results[0].geometry.location.lng;
                
            } 
            ll.status = resp.status;
        }
        return ll;
    }
    
    // Geo Location Calculation For Location and Contact Object From batch class
    
    public void updateLatLong(String street,String City,String State,String Country,String zipCod,Id recId,String objName,String latField,String lngField,String geoStatusField) {
        
        location latlong = new location();
        latLong = geoCode(street,City,State,Country,zipCod);
        
        sObject sObj = Schema.getGlobalDescribe().get(objName).newSObject() ;
        sObj.Id = recId;
        
        if(latLong.status == 'OK' && latLong.lng != null && latLong.lat != null) {
            
            sObj.put(lngField, Decimal.valueOf(latLong.lng));     
            sObj.put(latField, Decimal.valueOf(latLong.lat));
            sObj.put(geoStatusField, 'Processed');
            System.debug('sObj::::::'+sObj);
            
        } else {
            sObj.put(geoStatusField, 'Invalid Address');
        }
        update sObj;
    } 
    // getTime String From Datetime
    public String getTimeStringFromDatetime(DateTime dtTime) {
        List<String> dateSplitList = new List<String>();
        
        if(dtTime != null){
            String timeValue = dtTime.format('h:mm a');
            dateSplitList = timeValue.split(':');
            
            if(dateSplitList.size() > 0 && Integer.valueOf(dateSplitList[0]) < 10){
                timeValue = '0'+timeValue;
            }
            return timeValue;
        }else{
            return null;
        }
    }
    // Current User Datetime converation by TimeZone
    public DateTime getUserTimeZoneDateTime(DateTime dtTime) {
        String timeZoneStr = UserInfo.getTimeZone().getID();
        
        if(dtTime != null && timeZoneStr != null){
            String dateTimeStr = dtTime.format('yyyy-MM-dd HH:mm:ss', timeZoneStr);
            return DateTime.valueOf((dateTimeStr).replaceAll('/','-'));
        }else{
            return null;
        }
    }
    // User Datetime converation with TimeZone
    public DateTime convertTimeZoneDateTime(DateTime dtTime, String timeZoneStr) {
        
        if(dtTime != null && timeZoneStr != null){
            String dateTimeStr = dtTime.format('yyyy-MM-dd HH:mm:ss', timeZoneStr);
            return DateTime.valueOf((dateTimeStr).replaceAll('/','-'));
        }else{
            return null;
        }
    }
        
}