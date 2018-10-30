/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
********************************************************************************************************************* */
@isTest(SeeAllData=True)
public class Marketo_CasetoAccountUpdate_Test2{

    public static testmethod void Clz_Project_Manager_Team() {
        Profile p = [select Id,name from Profile where UserType = 'Standard' limit 1];
        User u2 = createTestUser(p.Id, 'testUser', 'Mkto', 'cfsId') ;
        insert u2;
        
		/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
		clzV5__Clarizen_Resource__c cr = new clzV5__Clarizen_Resource__c(clzV5__CLZ_Email__c= u2.email);
        insert cr;
        Clz_Project_Manager_Team__c cmm = new Clz_Project_Manager_Team__c(Related_User__c = u2.id,Team_Member__c=cr.Id);
        insert cmm;
		********************************************************************************************************************* */
         
    }
    public static User createTestUser(String ProfId, string fName, String lName, String cfsId) {
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User tuser = new User(  firstname = fName,
                                    lastName = lName,
                                    email = uniqueName + '@test' + orgId + '.org',
                                    Username = uniqueName + '@test' + orgId + '.org',
                                    EmailEncodingKey = 'ISO-8859-1',
                                    Alias = uniqueName.substring(18, 23),
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    ProfileId = profId,
                                    lmscons__Cornerstone_ID__c = 'cfsId'
                                    );
            return tuser;
    } 

}