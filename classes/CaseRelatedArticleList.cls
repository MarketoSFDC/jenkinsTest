public class CaseRelatedArticleList {

    public Case_Related_Article_List__c caseDetails { get; private set; }

    public CaseRelatedArticleList (ApexPages.StandardController controller) {
        //Case temp = (Case)controller.getRecord(); 
        Id parentId = controller.getId();                               
        String theQuery = 'SELECT Id,Article_Link1__c,Article_Link2__c,Article_Link3__c,Article_Link4__c,Article_Link5__c,Article_Link6__c,Article_Link7__c,Article_Link8__c,';
        theQuery += 'Article_Title1__c,Article_Title2__c,Article_Title3__c,Article_Title4__c,Article_Title5__c,Article_Title6__c,Article_Title7__c,Article_Title8__c FROM Case_Related_Article_List__c WHERE Case__r.Id = :parentId';
        system.debug('theQuery==>' + theQuery);       
        try {
            this.caseDetails = Database.query(theQuery);
        } catch (Exception ex) { }                
    }
}