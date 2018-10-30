/* 
   This is a Utility class to hold all classes that could be shared between all other classes as needed.
   Add to this Utility class any class that could be shared by other classes across our SFDC Org.
      Date of Initial Creation: 02/14/2013
 */

/*
   Convert language to standard language code
      Date of Initial creation: 02/14/2013
*/
public class CommonUtils
{

   public static String getLangCode(String lang){
      Map<String, Language_Code__c> languageCodeMap = Language_Code__c.getAll();
      if(languageCodeMap.get(lang) != null)
          return languageCodeMap.get(lang).Language_Code__c;
      else
          return lang;    
   }

/*
   Convert locale to standard locale code
      Date of Initial creation: 02/14/2013
*/
   public static String getLocCode(String loc){
      Map<String, String> localeMap = new Map<String, String>();
      for(Locale_Code__c lc :Locale_Code__c.getAll().values()){
          localeMap.put(lc.Locale_Name__c, lc.Locale_Code__c);
      }
      
      if(localeMap.get(loc) != null)
          return localeMap.get(loc);
      else
          return loc;
   }

/*
   Convert timezone to standard timezone code
      Date of Initial creation: 02/14/2013
*/
   public static String getTzoneCode(String tzone){
      Map<String, String> timeZoneMap = new Map<String, String>();
      for(Time_Zone_Code__c tz :Time_Zone_Code__c.getAll().Values()){
          timeZoneMap.put(tz.Time_Zone_Name__c, tz.Time_Zone_Code__c);
      }
      
      if(timeZoneMap.get(tzone) != null)
          return timeZoneMap.get(tzone);
      else
          return tzone;
   }


}