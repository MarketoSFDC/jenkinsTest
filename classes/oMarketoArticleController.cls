public with sharing class oMarketoArticleController {
	public PageReference init() {
		
		String oldId = ApexPages.currentPage().getParameters().get('oid');
		
		if (oldId == null) return null;
		
		List<KnowledgeArticleVersion> articles = new List<KnowledgeArticleVersion>([
			SELECT Id FROM KnowledgeArticleVersion WHERE (UrlName = :oldId) AND (PublishStatus = 'Online')
		]); 
		
		if (!articles.IsEmpty()) {
			String newId = articles[0].Id;
			
			PageReference newReference = new PageReference('https://marketo.my.salesforce.com/knowledge/publishing/articleOnlineDetail.apexp');
			newReference.getParameters().put('id', newId);
			newReference.setRedirect(true);
			
			return newReference;
		}
		
		return null;
	}
	
	private static testMethod void testInit() {
		
		PageReference testPage = Page.oMarketoArticle;
		testPage.getParameters().put('oid', '12345');
		
		Test.setCurrentPage(testPage);
		
		Test.StartTest();
		
		oMarketoArticleController controller = new oMarketoArticleController();
		
		controller.init();
		
		Test.StopTest();
	}
}