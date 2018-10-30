public class LeadConvert {
    private Lead l;
    public LeadConvert(ApexPages.StandardController stdController) {
        l = (Lead)stdController.getRecord();
        
    }
    public PageReference action() {
        if (l.IsConverted) {
            return sendToBOFU(l);
        } else {
            return sendToConvertPage(l,isRevisit());
        }
    }
    @TestVisible
    private static PageReference sendToConvertPage(Lead l,Boolean isRevisit) {      
        String saveUrlParam ='';
        if(isRevisit == false){
            String saveUrl = '/apex/LeadConvert?id='+l.Id+'&ret=1';
            saveUrl = EncodingUtil.urlEncode(saveUrl, 'UTF-8');
            saveUrlParam = '&saveURL='+saveUrl;
        }
        return new PageReference(
        	'/lead/leadconvert.jsp?id='+l.Id+'&nooverride=1'+saveUrlParam
        );
    }
    @TestVisible
    private static PageReference sendToBOFU(Lead l) {
        PageReference pageRef;
        if(l.ConvertedOpportunityId != NULL){
            //setting parameter cn=0 removes the cancel button from Bofu page
            pageRef =  new PageReference(
                        	'/apex/OpportunityCreateBOFU?id='+l.ConvertedOpportunityId+'&cn=0'
                        );
        }
        else{
            pageRef =  new PageReference(
                            '/'+l.ConvertedAccountId
                        );
        }

        return pageRef;
    }

    private  Boolean isRevisit(){
        String ret = ApexPages.currentPage().getParameters().get('ret');
        return String.isNotBlank(ret) && ret == '1';
    }
}