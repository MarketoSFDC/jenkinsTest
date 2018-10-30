/**
 * 09-03-11 vishals@grazitti.com
 * This class contains unit tests for validating the behavior of 
 * trigger RecordQuestion.
 */
@isTest
private class TestRecordQuestion {

    static testMethod void myUnitTest() {
        //Query Portal User
        List<User> listUsers = [select id, Name, Email from User where ContactId != null and IsActive = true and Profile.Name =: TestClassUtility.PORTAL_PROFILE order by CreatedDate desc limit 1];
        User portaluser;
        if(listUsers != null && listUsers.size() > 0){
        	portaluser = listUsers.get(0);
        }else{  
        	portaluser = TestClassUtility.createTestUser();
        }
        List<Community> listCommunity = [Select c.Name, c.IsActive, c.Id From Community c where IsActive=true and name=:TestClassUtility.PORTAL_COMMUNITY_NAME limit 1];
        System.debug('========community====='+listCommunity);
        System.debug('========portaluser====='+portaluser);
        //System.runAs(portaluser){
        	Question myQues = new Question(CommunityId = listCommunity.get(0).Id);
        	myQues.title = 'Test question';
        	myQues.Body = ' first portal question';
        	insert myQues;
        //}
    }
}