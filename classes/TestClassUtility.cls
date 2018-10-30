/*
   09-03-11 vishals@grazitti.com
   Created utility class for test classes.
*/
public with sharing class TestClassUtility {
	//Replace it with your portal user profile name
	public static string PORTAL_PROFILE = 'Session Marketo Community';
	public static string PORTAL_COMMUNITY_NAME = 'Marketo Community';
	public static string PORTAL_COMMUNITY_ID = '09a50000000PNNr';
	//Create portal user for testing
	public static User createTestUser() {
    	User testUser;
        // Existing user
        User existingUser = [select Id, LastName, Email, ContactId, Alias, TimeZoneSidKey,
                LocaleSidKey, EmailEncodingKey, LanguageLocaleKey
                from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        try {
        	Account acc = new Account();
        	acc.Name = 'TestAccount';
        	
        	insert acc;
        	
        	Contact conn = new Contact();
        	conn.AccountId = acc.Id;
        	conn.LastName = 'testContact';
        	conn.FirstName = acc.Name;
        	insert conn;
        	
        	system.debug('Contact Id :::: ' + conn.Id);
            // Set fields of user and insert it
            testUser = new User();
            testUser.Username = 'testUser@xyz.com';
            testUser.LastName = existingUser.LastName;
            testUser.Email = 'testUser@xyz.com';
            testUser.ContactId = conn.Id;
            testUser.Alias = existingUser.Alias;
            testUser.CommunityNickname = 'testUser';
            testUser.TimeZoneSidKey = existingUser.TimeZoneSidKey;
            testUser.LocaleSidKey = existingUser.LocaleSidKey;
            testUser.EmailEncodingKey = existingUser.EmailEncodingKey;
            testUser.LanguageLocaleKey = existingUser.LanguageLocaleKey;
            testUser.ProfileId = [select Id from Profile where Name = :PORTAL_PROFILE limit 1].Id;
            
            insert testUser;
        } catch(Exception ex) {
            // If was unsuccessful in creating new user then use existing one
            System.debug('Debug: Error while creating test user - ' + ex.getMessage());
            testUser = existingUser;
        }
        
        return testUser;
    }
    
    public static testMethod void testController() {
    	User tUser = TestClassUtility.createTestUser();
    	//String s = TestClassUtiility.PORTAL_PROFILE;
    	//String s1 = TestClassUtiility.PORTAL_COMMUNITY_NAME;
    	//String s2 = TestClassUtiility.PORTAL_COMMUNITY_ID;
    }
}