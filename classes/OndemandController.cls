public with sharing class OndemandController {
    public String Var01 { get; set; }
    public String TSE { get; set; }
    public List<case> CaseList{ get; set; }
    public List<wrapCase> wrapCaseList{get; set;}
    public Boolean Bool{ get; set; }
    public boolean disablebutton {get;set;}
    public case usr {get; set;}
    public Boolean Bool1{ get; set;}
    Public id TSEName {get; set;}
    Public string username {get; set;} 
    public list<case> selectedcaseList = new list<case>();
    Set<wrapcase> selectedcaseIdSet = new Set<wrapcase>();    
    
    public OndemandController(){
        
        usr = new case();    
        Var01 = Apexpages.currentPage().getParameters().get('MyVariable'); 
        //CaseList = new List<Case>([select id, owner.name, CaseNumber, status, priority, entitlement.type, CreatedDate, LastModifiedDate from Case where status != 'Closed' And ownerid =: Var01 ]);   
        //TSE = Caselist[0].owner.name;    
        GetCases();    
        Bool = false; 
        Bool1 = false;  
        //disablebutton =false;  
    }
    
    Public list<wrapCase> GetCases() {
        if(wrapCaseList == null) {
            wrapCaseList = new List<wrapCase>();
            system.debug('i am in heaven');
            CaseList = new List<Case>([select id, owner.name, CaseNumber, status, priority, entitlement.type, CreatedDate, LastModifiedDate from Case where status != 'Closed' And ownerid =: Var01 And recordtype.id = '01250000000UJwx']);   
            if(CaseList.isempty()){ 
                //ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.CONFIRM, 'No cases found for the selected TSE' );
                disablebutton =true;
                return null;
            }
            TSE = Caselist[0].owner.name;  
            for(Case c : CaseList) {
                // As each Account is processed we create a new wrapAccount object and add it to the wrapAccountList
                //if(selectedcaseIdSet != Null && !selectedcaseIdSet.contains(c.id)){
                    wrapCaseList.add(new wrapCase(c));
                //}
            }
        }

        if(selectedcaseIdSet != Null){
            Set<wrapcase> tmpSet = new set<wrapcase>();
            tmpSet.addAll(wrapCaseList);
            tmpset.removeAll(selectedcaseIdSet );
            wrapCaseList.clear();
            wrapCaseList.addAll(tmpset);
            
        }
        return wrapCaseList;
    }
     
    public class wrapCase {
        public Case Cas {get; set;}
        public Boolean selected {get; set;} 
        //This is the contructor method. When we create a new wrapCase object we pass a Case that is set to the cas property. We also set the selected value to false
        public wrapCase(Case c) {
            Cas = c;
            selected = false;
        }
    }
    
    public PageReference AssignToQueue() {
        bool1=false;
        selectedcaseList = new list<case>();
        for(wrapCase temp: GetCases()){
            if(temp.selected ==true){
                selectedcaseList.add(temp.cas);
                selectedcaseIdSet.add(temp);
                
            }
        }               
        if(selectedcaseList.isempty()) {
         Bool = true;            
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'No Record Selected' );
            ApexPages.addmessage(msg);                   
        }else {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true; 
            for(case tmp : selectedcaseList) {
                tmp.setOptions(dmo);
            } 
            Update selectedcaseList;          
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.CONFIRM, selectedcaseList.size() +' case Assigned to queue successfully.' );
            ApexPages.addmessage(msg);
        }
        GetCases();        
        return null; 
    } 
    
    public PageReference AssignToMe() {
    bool1=false;
    selectedcaseList = new list<case>();
        //list<case> selectedcaseList = new list<case>();
        for(wrapCase temp: GetCases()) {
            if(temp.selected ==true) {
                selectedcaseList.add(temp.cas);
                selectedcaseIdSet.add(temp);
            }
        }        
        if(selectedcaseList.isempty()) {
            Bool = true;
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'No Record Selected!');
            ApexPages.addmessage(msg);            
        }else {   
            for(case tmp : selectedcaseList) {
                tmp.ownerid =userinfo.getUserId();
            }  
            update selectedcaseList;      
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.CONFIRM,selectedcaseList.size() +' case Assigned to you successfully.' );
            ApexPages.addmessage(msg);
        }  
        GetCases();      
        return null; 
    }
    
    Public PageReference AssignToTSE() {
        Bool1 = true;     
        return null;
    }
    
    Public PageReference Assign() {
        //list<case> selectedcaseList = new list<case>();
        selectedcaseList = new list<case>();
        for(wrapCase temp: GetCases()) {
            if(temp.selected ==true) {
                selectedcaseList.add(temp.cas);
                selectedcaseIdSet.add(temp);
            }
        }        
        if(selectedcaseList.isempty()) {
            Bool = true;
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'No Record Selected!');
            ApexPages.addmessage(msg);            
        }else {   
            for(case tmp : selectedcaseList) {
                  TSEname = usr.ownerid;
                tmp.ownerid = TSEname;
            }  
            update selectedcaseList;  
            username = [select id, name from user where id =:TSEname].name;    
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.CONFIRM,selectedcaseList.size() +' case Assigned to '+username  +' successfully.' );
            ApexPages.addmessage(msg);
        } 
        GetCases();      
        return null;        
    }  
}