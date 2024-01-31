public with sharing class BoxUtilDomain {
    public class BodyWrapper{
        public String type;
        public String status;
        public String code;
        public ContextWrapper context_info;
    }
    public class ContextWrapper{
        public List<ConflictsWrapper> conflicts;
    }
    public class ConflictsWrapper{
        public String etag;
        public String name;
        public String sequence_id;
        public String type;
        public String id;
        public String size;
        public String content_created_at;
        public String created_at;
    }
    public class FileListWrapper{
        public String total_count;
        public List<ConflictsWrapper> entries;
    }
    public class BoxFolderWrapper{
        public String boxFolderId;
        public String boxSharedURL;
    }
    public class FilesWrapper{
        public String fileName;
        public String base64;
        public String size;
        public Boolean isResumeType; 
    }
}