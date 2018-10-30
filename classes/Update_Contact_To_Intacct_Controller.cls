/* Name: Update_Contact_To_Intacct_Controller
     Description : Controller for Update_Contact_To_Inacct_Component LEX
     Author : LK
     History:
     VERSION     AUTHOR               DATE                            DETAIL                                    UserStory/Req#
     1.0 -             
       */
public class Update_Contact_To_Intacct_Controller {
    
    public Update_Contact_To_Intacct_Controller()
    {
        
    }
    //Get current user profile name
    @AuraEnabled
    public static String retriveCurrentUserProfileName()
    {
        
        Id profileId=userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        return profileName;
    }
    
    //Method for updating Contact To Intacct
    @AuraEnabled
    public static void updateContactToIntacct(String ContactId)
    {
        SFContactToIntacct.UpdateContactToIntacct(contactId);
    }
    
    //Method for send opportunities  To Intacct 
    @AuraEnabled
    public static void sendContactDetailsToIntacct(String oppId)
    {
        //sforce.apex.execute("SFContactToIntacct", "sendContactDetailsToIntacct", {
        List<Id> oppIdsLst = new List<Id>();
        oppIdsLst.add(oppId);
        SFContactToIntacct.sendContactDetailsToIntacct(oppIdsLst);
    }

}