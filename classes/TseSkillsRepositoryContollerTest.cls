@isTest()
public class TseSkillsRepositoryContollerTest{

    static testmethod void TseSkillsRepositoryContollerTest(){
        skill__c s = new skill__c();
        s.Region__c = 'APAC';
        s.User_Skill_Level__c = 'Beginner';
        s.User__c = UserInfo.getUserId();
        s.SME__c = 'Test';
        s.Sub_Category__c = 'Test';
        s.External_ID__c = 'Sales Engage00538000005VuxVAAS';
        s.Category__c = 'Sales Engage';
        s.Approval_Status__c  = 'Approved';
        Insert s;
        
        
        PageReference pgRef = Page.TseSkillsRepository;
        Test.setCurrentPageReference(pgRef);
        ApexPages.StandardController controller = new ApexPages.StandardController(s);
        TseSkillsRepositoryContoller f = new TseSkillsRepositoryContoller (controller);
        f.saveInfo();
        f.saveInfoDisapprove();
        f.TSEInfo();
    }
    static testmethod void TseSkillsRepositoryContollerTest2(){
        skill__c s = new skill__c();
        s.Region__c = 'APAC';
        s.User_Skill_Level__c = 'Beginner';
        s.User__c = null;
        s.SME__c = 'Test';
        s.Sub_Category__c = 'Test';
        s.External_ID__c = 'Sales Engage00538000005VuxVAAS';
        s.Category__c = 'Sales Engage';
        s.Approval_Status__c  = 'Approved';
        Insert s;
        
        
        PageReference pgRef = Page.TseSkillsRepository;
        Test.setCurrentPageReference(pgRef);
        pgRef.getParameters().put('UserID',s.User__c );
        pgRef.getParameters().put('Region','Apac');
        ApexPages.StandardController controller = new ApexPages.StandardController(s);
        TseSkillsRepositoryContoller f = new TseSkillsRepositoryContoller (controller);
        f.saveInfo();
        f.saveInfoDisapprove();
        f.TSEInfo();
    }
}