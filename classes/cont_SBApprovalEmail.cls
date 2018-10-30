public class cont_SBApprovalEmail {
	public String qId {get; set; }
	
	public String getRequestType() {
		return '';
	} 
	
	private string nonStandardTerms;
	
	public String getNonStandardTerms() {
		if(String.isBlank(qId))
			return '';
		if(!String.isBlank(this.nonStandardTerms))
			return nonStandardTerms;		
		List<StandardTerms__c> stdTerms = [select Name,ApprovedTerms__c from standardterms__c];
		Map<String,Set<String>> stMap = new Map<String,Set<String>>();
		Map<String,String> labelMap = new Map<String,String>();
		List<String> apiNames = new List<String>();
		for(StandardTerms__c st : [select Name,APIName__c,ApprovedTerms__c from standardterms__c]) {
		    List<String> at = stdterms[0].ApprovedTerms__c.split('[\n\r]');
			Set<String> sat = new Set<String>();
		    for(String s: at)
		       if(!String.isBlank(s))
		        	sat.add(s);
		    stMap.put(st.APIName__c, sat);
		    
		    labelMap.put(st.APIName__c,st.Name);
		    apiNames.add(st.APIName__c);
		}
		String soql = 'select '+string.join(apiNames,', ')+' from SBQQ__Quote__c where id=\''+qId+'\'';
		List<SObject> sObj = Database.query(soql);
		System.debug(sobj[0]);
		nonStandardTerms = '';
		for(String fName:apiNames) {
		    string val = (string)sObj[0].get(fname);
		    if(!stMap.get(fname).contains(val)) 
		        nonStandardTerms+='<b>'+labelMap.get(fname)+'</b>:&nbsp;'+val+'<br/>';
		    
		}		
		return nonStandardTerms;
	}
	
}