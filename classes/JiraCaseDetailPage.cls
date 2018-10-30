public class JiraCaseDetailPage {

    public final Case caseDetails { get; private set; }
    

    // SOQL query loads the case, with Case fields and related Contact fields
    public JiraCaseDetailPage(ApexPages.StandardController controller) {
        String qid = ApexPages.currentPage().getParameters().get('id');
        String theQuery = 'SELECT Id, ' + joinList(caseFieldList, ', ') + 
                          ' FROM Case WHERE Id = :qid';
                          system.debug('theQuery==>' + theQuery);
        this.caseDetails = Database.query(theQuery);
    }

    public string accessPwd {get; set;}
    
    public pagereference checkPwd(){        
        //accessPwd = ApexPages.currentPage().getParameters().get('param1');
        return null;    
    }
    
    
    // A list of fields to show on the Visualforce page
    public List<String> caseFieldList { 
        get {
            if (caseFieldList == null) {
                caseFieldList = new List<String>();
                caseFieldList.add('CaseNumber');
                caseFieldList.add('Origin');
                caseFieldList.add('Status');
                //caseFieldList.add('Account_Name_for_Jira__c');  // related field
                caseFieldList.add('Marketo_Prefix__c'); // related field
                //caseFieldList.add('Account_Temperature_For_Jira__c'); // related field
                caseFieldList.add('CreatedDate'); // related field
                caseFieldList.add('Priority');  // related field
                caseFieldList.add('Problem_Type__c'); // related field
                caseFieldList.add('Category__c'); // related field
                caseFieldList.add('Sub_Category__c');  // related field
                caseFieldList.add('ClosedDate'); // related field
                caseFieldList.add('Subject'); // related field
                caseFieldList.add('Description');  // related field
                caseFieldList.add('JIRA_Num__c'); // related field
                caseFieldList.add('Owner.Name'); // related field
                caseFieldList.add('Support_Region__c');  // related field
                caseFieldList.add('Support_Level__c'); // related field
                caseFieldList.add('Subscription_Type__c'); // related field                                
                
            }
            return caseFieldList;
        }
        private set;
    }
    
    // Join an Apex list of fields into a SELECT fields list string
    private static String joinList(List<String> theList, String separator) {

        if (theList == null) {
            return null;
        }
        if (separator == null) {
            separator = '';
        }

        String joined = '';
        Boolean firstItem = true;
        for (String item : theList) {
            if(null != item) {
                if(firstItem){
                    firstItem = false;
                }
                else {
                    joined += separator;               
                }
                joined += item;
            }
        }
        return joined;
    }
}