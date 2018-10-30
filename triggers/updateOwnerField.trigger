trigger updateOwnerField on Case_Confluence_Article__c (Before insert) {
    
    try{
        for(Case_Confluence_Article__c  cca : trigger.new){
            cca.DOC_USER__c = UserInfo.getUserId();
        }
    }catch (Exception e){system.debug('Exception==>>>'+e);}
    
}