//Generated by wsdl2apex

public class AsyncRchilliResumeParser {
    public class parseResumeResponse_elementFuture extends System.WebServiceCalloutFuture {
        public String getValue() {
            RchilliResumeParser.parseResumeResponse_element response = (RchilliResumeParser.parseResumeResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.return_x;
        }
    }
    public class parseResumeBinaryWithCountryResponse_elementFuture extends System.WebServiceCalloutFuture {
        public String getValue() {
            RchilliResumeParser.parseResumeBinaryWithCountryResponse_element response = (RchilliResumeParser.parseResumeBinaryWithCountryResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.return_x;
        }
    }
    public class buildReleaseResponse_elementFuture extends System.WebServiceCalloutFuture {
        public String getValue() {
            RchilliResumeParser.buildReleaseResponse_element response = (RchilliResumeParser.buildReleaseResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.return_x;
        }
    }
    public class ParseResumeWithCountryResponse_elementFuture extends System.WebServiceCalloutFuture {
        public String getValue() {
            RchilliResumeParser.ParseResumeWithCountryResponse_element response = (RchilliResumeParser.ParseResumeWithCountryResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.return_x;
        }
    }
    public class parseResumeBinaryResponse_elementFuture extends System.WebServiceCalloutFuture {
        public String getValue() {
            RchilliResumeParser.parseResumeBinaryResponse_element response = (RchilliResumeParser.parseResumeBinaryResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.return_x;
        }
    }
    public class AsyncRChilliParserHttpSoap11Endpoint {
        public String endpoint_x = 'http://java.rchilli.com/RChilliParser/services/RChilliParser.RChilliParserHttpSoap11Endpoint/';
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://RchilliResumeParser', 'RchilliResumeParser'};
        public AsyncRchilliResumeParser.parseResumeResponse_elementFuture beginParseResume(System.Continuation continuation,String url,String userkey,String version,String subUserId) {
            RchilliResumeParser.parseResume_element request_x = new RchilliResumeParser.parseResume_element();
            request_x.url = url;
            request_x.userkey = userkey;
            request_x.version = version;
            request_x.subUserId = subUserId;
            return (AsyncRchilliResumeParser.parseResumeResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncRchilliResumeParser.parseResumeResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'urn:parseResume',
              'http://RchilliResumeParser',
              'parseResume',
              'http://RchilliResumeParser',
              'parseResumeResponse',
              'RchilliResumeParser.parseResumeResponse_element'}
            );
        }
        public AsyncRchilliResumeParser.parseResumeBinaryWithCountryResponse_elementFuture beginParseResumeBinaryWithCountry(System.Continuation continuation,String filedata,String fileName,String userkey,String version,String CountryKey,String subUserId) {
            RchilliResumeParser.parseResumeBinaryWithCountry_element request_x = new RchilliResumeParser.parseResumeBinaryWithCountry_element();
            request_x.filedata = filedata;
            request_x.fileName = fileName;
            request_x.userkey = userkey;
            request_x.version = version;
            request_x.CountryKey = CountryKey;
            request_x.subUserId = subUserId;
            return (AsyncRchilliResumeParser.parseResumeBinaryWithCountryResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncRchilliResumeParser.parseResumeBinaryWithCountryResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'urn:parseResumeBinaryWithCountry',
              'http://RchilliResumeParser',
              'parseResumeBinaryWithCountry',
              'http://RchilliResumeParser',
              'parseResumeBinaryWithCountryResponse',
              'RchilliResumeParser.parseResumeBinaryWithCountryResponse_element'}
            );
        }
        public AsyncRchilliResumeParser.buildReleaseResponse_elementFuture beginBuildRelease(System.Continuation continuation) {
            RchilliResumeParser.buildRelease_element request_x = new RchilliResumeParser.buildRelease_element();
            return (AsyncRchilliResumeParser.buildReleaseResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncRchilliResumeParser.buildReleaseResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'urn:buildRelease',
              'http://RchilliResumeParser',
              'buildRelease',
              'http://RchilliResumeParser',
              'buildReleaseResponse',
              'RchilliResumeParser.buildReleaseResponse_element'}
            );
        }
        public AsyncRchilliResumeParser.ParseResumeWithCountryResponse_elementFuture beginParseResumeWithCountry(System.Continuation continuation,String url,String userkey,String version,String CountryKey,String subUserId) {
            RchilliResumeParser.ParseResumeWithCountry_element request_x = new RchilliResumeParser.ParseResumeWithCountry_element();
            request_x.url = url;
            request_x.userkey = userkey;
            request_x.version = version;
            request_x.CountryKey = CountryKey;
            request_x.subUserId = subUserId;
            return (AsyncRchilliResumeParser.ParseResumeWithCountryResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncRchilliResumeParser.ParseResumeWithCountryResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'urn:ParseResumeWithCountry',
              'http://RchilliResumeParser',
              'ParseResumeWithCountry',
              'http://RchilliResumeParser',
              'ParseResumeWithCountryResponse',
              'RchilliResumeParser.ParseResumeWithCountryResponse_element'}
            );
        }
        public AsyncRchilliResumeParser.parseResumeBinaryResponse_elementFuture beginParseResumeBinary(System.Continuation continuation,String filedata,String fileName,String userkey,String version,String subUserId) {
            RchilliResumeParser.parseResumeBinary_element request_x = new RchilliResumeParser.parseResumeBinary_element();
            request_x.filedata = filedata;
            request_x.fileName = fileName;
            request_x.userkey = userkey;
            request_x.version = version;
            request_x.subUserId = subUserId;
            return (AsyncRchilliResumeParser.parseResumeBinaryResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncRchilliResumeParser.parseResumeBinaryResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'urn:parseResumeBinary',
              'http://RchilliResumeParser',
              'parseResumeBinary',
              'http://RchilliResumeParser',
              'parseResumeBinaryResponse',
              'RchilliResumeParser.parseResumeBinaryResponse_element'}
            );
        }
    }
}