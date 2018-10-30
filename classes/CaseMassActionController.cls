public class CaseMassActionController {

    String buttonInfo;
    Set<String> caseIds= new Set<String>();
    PageReference returnUrl = null;

    public String selectedSalesCategory{get;set;}
    public String selectedStatus{get;set;}
    public String selectedPriority{get;set;}

    public CaseMassActionController(ApexPages.StandardController controller) {
      
        buttonInfo = ApexPages.currentPage().getParameters().get('CaseMassTask');
        caseIds.addAll(ApexPages.currentPage().getParameters().get('key').split(','));
        returnUrl = new PageReference(ApexPages.currentPage().getParameters().get('retUrl'));
    }

    public List<SelectOption> getsalesCategoryOptions() {
        List<SelectOption> sCateg = new List<SelectOption>();
        Schema.DescribeFieldResult sCase = Case.Sales_Ops_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = sCase.getPicklistValues();                
            for( Schema.PicklistEntry f : ple){
                sCateg.add(new SelectOption(f.getLabel(), f.getValue()));
            }      
        return sCateg;
    }

  public List<SelectOption> getPriorityOptions() {
        List<SelectOption> pCateg = new List<SelectOption>();
        Schema.DescribeFieldResult pCase = Case.Priority.getDescribe();
        List<Schema.PicklistEntry> ple = pCase.getPicklistValues();                
            for( Schema.PicklistEntry f : ple){
                pCateg.add(new SelectOption(f.getLabel(), f.getValue()));
            }      
        return pCateg;
    }
  public List<SelectOption> getStatusOptions() {
        List<SelectOption> sCateg = new List<SelectOption>();
        Schema.DescribeFieldResult sCase = Case.Status.getDescribe();
        List<Schema.PicklistEntry> ple = sCase.getPicklistValues();                
            for( Schema.PicklistEntry f : ple){
                sCateg.add(new SelectOption(f.getLabel(), f.getValue()));
            }      
        return sCateg;
    }

    
    public PageReference save(){
        List<Case> cases = new List<Case>([SELECT Sales_Ops_Category__c,status,priority FROM Case WHERE Id IN : caseIds and recordtype.name='Sales Cases']);
        if(buttonInfo == 'CASE_CHANGE_SALES_CATEGORY'){
            for(Case cas : cases){
                cas.Sales_Ops_Category__c = selectedSalesCategory ;
                cas.status = selectedStatus; 
                cas.priority  = selectedPriority;
            }
        }
        try{
        update cases;  
        }
        catch(Exception e){
          ApexPages.addMessages(e); 
          return null;
        }
         return returnUrl;  
    }

    public PageReference cancel(){
        return returnUrl;
    }
}