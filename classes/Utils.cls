public without sharing class Utils {
    /**
     * Helper method to check field value is changed or not.
     * 
     * @return boolean
     */
    public static Boolean hasChanges(String field, SObject oldRecord, SObject newRecord) {
        if (oldRecord == null && newRecord.get(field) != null) {
            return true;
        }
        return ((oldRecord != null && newRecord != null) &&  oldRecord.get(field) != newRecord.get(field));
    }   
    
    public static Boolean isSite { get { return !isBlank(Site.getName()); } }
    
    public static Boolean isBlank(String s) {
        return ( s == null || s == '');
    }
}