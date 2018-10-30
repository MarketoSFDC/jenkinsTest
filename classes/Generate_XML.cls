/* ***********************************************************************************************
Created By  : Priyanka Shende, Jade Global Inc.
Created On  : 10th Feb 2018
Description : Forming xml[header + body + footer]based on record with the help of custom metadata
Header - Authentication details - refering Integration Authentication Custom Metadata -> Header field
        e.g.<?xml version="1.0" encoding="UTF-8"?> 
        <request> 
            <control> 
            <senderid>marketo</senderid> 
Body  - 1. Based on Object Serialization(string) and Custom Metadata Xml format prepare Body 
        Custom Metadata Xml format - <PROJECTRESOURCES><EMPLOYEEID>[[int_Intacct_Employee_ID__c]]</EMPLOYEEID></PROJECTRESOURCES>
        2. Object serialization convert into HashMap <Key, Value>, Key-> APIName and Value as field value
        3. Replace [[int_Intacct_Employee_ID__c]] with matching API value
             <PROJECTRESOURCES><EMPLOYEEID>1234</EMPLOYEEID></PROJECTRESOURCES>
Footer - </control> </request> 

Last Modified By: Priyanka Shende on 19th May 2018, APPS-18581
Purpose         : 1. Handle special charachter('―'(em dash)) scenario in XML Generation
                  2. locationid(int_Intacct_Entity_Name__c) is removed hardcoded value while forming Authentication Header 
          
Last Modified By: Jade Global Inc On 19th May 2018
Updated for: Added as part of Collection Lock Requirement, added seesion token.

Last Modified By: Priyanka Shende on 4th July 2018
Purpose         : Handle special charachter scenario in XML Generation - APPS-20766
                
*****************************************************************************************************/
public class Generate_XML{
  static Integration_Authentication__mdt IntegrationAuth;
    public static string xmlBuild(String xmlbody,String payload,String APIVersion){
        IntegrationAuth = [Select Footer_Tags__c,Header_tags__c,DeveloperName From Integration_Authentication__mdt where  DeveloperName =: APIVersion  limit 1];
        Map<String,String> HashMap = ReplaceMap(payload);
        String xml = HeaderXML(HashMap) + BodyXML(xmlbody) + FooterXML();
        String sessionIdToken=Label.OAP_endpoint_token;
        for (String key: HashMap.keySet()){
            String kValue = HashMap.get(key);
            xml = xml.replace('[['+key+']]',kValue);
        }//End of for

        
        
        if(xml.contains('[[/*EndPoint_Token*/]]') && !string.isBlank(sessionIdToken)){
            xml = xml.replace('[[/*EndPoint_Token*/]]',sessionIdToken);
            system.debug('xml EndPoint_Token @@@'+xml);
        }

        // clean up any leftover tokens and replace with blanks
        xml = xml.replaceAll('\\[\\[(.*?)\\]\\]','');
          
       
        
        
        system.debug('xml@@@'+xml);
        
        return xml;
    }//End of xmlBuild
    
    public static Map<String,String> ReplaceMap(String payload){
        system.debug('payload==='+payload);
        JSONParser parser = JSON.createParser(payload);
        Map<String,String> HashMap = new Map<String,String>();
        Map<String,String> SpecialCharacters = new Map<String,String>();
        system.debug('parser===='+parser);
        system.debug('############ HashMap '+HashMap );
        // Special Charachter Custom Setting
        for(Intacct_Special_Foreign_Character__c SpecialChar : Intacct_Special_Foreign_Character__c.getall().values() ){
            SpecialCharacters.put(SpecialChar.Name,SpecialChar.Convert_Special_Foreign_Character__c);
        }//End of For
        system.debug('SpecialCharacters ##############'+SpecialCharacters);
        while(parser.nextToken() != null){
            
            String key = null;
            String kValue = null;
            
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                // Get the value.
                key = parser.getText();
                parser.nextToken();
                kValue = parser.getText(); 
                
                //Last Modified By: Priyanka Shende on 4th July 2018
                // Purpose        : Handle special charachter scenario in XML Generation - APPS-20766
                for(string Specialchar : SpecialCharacters.keySet()){
                    kValue = kValue.replace(Specialchar,SpecialCharacters.get(Specialchar));
                    system.debug('########## kValue'+kValue);
                }
                
                System.debug('kValue before Encoding=='+kValue);
                kValue = kValue.escapeHtml4();

                if(key != null && kValue != null && !HashMap.containsKey(key))
                    HashMap.put(key,kValue);
                
            }//End of If
        }//End of While
         
        return HashMap;  
    }//End of ReplaceMap Method
    
        //Get authentication details from the 
      
    //Prepare the header of the xml
    private static string HeaderXML(Map<String,String> HashMap){
        String IntacctHeader='';
        if(IntegrationAuth!=null && IntegrationAuth.Header_tags__c!=null){
               IntacctHeader = IntegrationAuth.Header_tags__c;
             
                // locationid(int_Intacct_Entity_Name__c) is removed hardcoded value while forming Authentication Header 
                for (String key: HashMap.keySet()){
                    //String kValue = HashMap.get(key);
                    if(IntegrationAuth.Header_tags__c.contains(key)){
                        string intacctEntity = HashMap.get(key);
                        IntacctHeader = IntacctHeader.replace('[['+key+']]',intacctEntity);
                    }
                    //xml = xml.replace('[['+key+']]',kValue);
                }
             
              /*  if(IntegrationAuth.Header_tags__c.contains('locationid') && HashMap.containsKey('int_Intacct_Entity_Name__c')){
                   string intacctEntity = HashMap.get('int_Intacct_Entity_Name__c');
                   IntacctHeader = IntacctHeader.replace('[[int_Intacct_Entity_Name__c]]',intacctEntity);
               }*/

        }//End of If
        return IntacctHeader;
    }//End of the header method
    
    //Prepare the footer of the xml
    private static string FooterXML(){
        String IntacctFooter='';
        if(IntegrationAuth!=null && IntegrationAuth.Footer_Tags__c!=null){
                IntacctFooter = IntegrationAuth.Footer_Tags__c;
        }//End of If
        return IntacctFooter;
    }//End of footer
    
     // prepare the body of the xml
    private static string BodyXML(String xmlBody){
        return  xmlBody;
    }//End of the method
    
}//End of Generate_XML class