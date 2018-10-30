public class UniversityVideoController {

    public UniversityVideoController(){}
    
    public String getUrl() {
        String currentPageUrl = ApexPages.currentPage().getUrl();
        return currentPageUrl;              
    }
    
    public String getSource(){
        String src = ApexPages.currentPage().getParameters().get('src');
        return src;
    }
    
    public String getVideoTitle(){
        String videoTitle = ApexPages.currentPage().getParameters().get('video_title');
        return videoTitle;      
    }
    
    public String getCategoryTitle(){
        String categoryTitle = ApexPages.currentPage().getParameters().get('category_title');
        return categoryTitle;       
    }
    
    /**TEST CODE**/
    public static testMethod void UniversityVideoController() {
        UniversityVideoController control = new UniversityVideoController();
        PageReference pageRef = Page.EmbedDashboardOnAccount;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('video_title', 'test_vid');
        ApexPages.currentPage().getParameters().put('category_title', 'test_vid');
        ApexPages.currentPage().getParameters().put('src', 'mkt_vid');
        control.getUrl();
        control.getSource();
        control.getVideoTitle();
        control.getCategoryTitle();
    }
}