@IsTest
public class HomePageController_Test {
    
    @IsTest
    static void main(){
        
        /*create custom setting for vf url*/
        
        KISettings__c customSetting = new KISettings__c();
        customSetting.Name = 'Default';
        customSetting.Visualforce_Domain__c = 'test';
        insert customSetting;
        
        HomePageController controller = new HomePageController();
       
        
        /*test showSelectedIssuesByArea()*/
        
        controller.category = 'All';
        controller.showSelectedIssuesByArea();
        controller.category = 'Munchkin';
        controller.showSelectedIssuesByArea();
        
        /*test showSelectedIssuesByStatus()*/
        controller.status = 'All';
        controller.showSelectedIssuesByStatus();
        controller.status = 'Patching';
        controller.showSelectedIssuesByStatus();
        
        /*test showSelectedIssuesByTime()*/
        
        controller.timeO = 'any';
        controller.showSelectedIssuesByTime();
        controller.timeO = 'today';
        controller.showSelectedIssuesByTime();
        controller.timeO = 'this_week';
        controller.showSelectedIssuesByTime();
        controller.timeO = 'this_month';
        controller.showSelectedIssuesByTime();
        controller.timeO = 'last_month';
        controller.showSelectedIssuesByTime();
        
        /*test showSelectedIssuesBySearch()*/
        
        controller.showSelectedIssuesBySearch();
    }
    @IsTest
    public static void KnownIssueExtTest(){
        Known_Issue__c k = new Known_Issue__c();
        k.Title__c = 'Test';
        insert k;
        ApexPages.StandardController sc = new ApexPages.StandardController(k);
        KnownIssueExt ki = new KnownIssueExt(sc);
        ki.addCustomer();
        ki.addNotification();
        ki.removeNotification();
        
    }
}