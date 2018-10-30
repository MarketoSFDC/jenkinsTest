public class EmbededDashboardOnAccountController{
    
    public string fromDate {get;set;}
    public string toDate {get;set;}
    public string dateFilter {get;set;}
    public Boolean isNotRenderedAsPdf {get;set;}
    public Boolean isClassic{get;set;}
    
    
    
    Account acc;
   

    public EmbededDashboardOnAccountController(ApexPages.StandardController controller) {
        
        
        
        if(UserInfo.getUiThemeDisplayed() == 'Theme3' && ApexPages.currentPage().getParameters().get('beLightning') == null)
        {
            isClassic =true;
        }
        this.acc = (Account)controller.getRecord();
        system.debug('===='+(Account)controller.getRecord());
        if(apexpages.currentpage().getparameters().get('renderAsPdf')=='true'){
            isNotRenderedAsPdf = false;
            if(apexpages.currentpage().getparameters().get('summarizeAs')!= null && apexpages.currentpage().getparameters().get('summarizeAs')!= '' ){
                dateFilter = apexpages.currentpage().getparameters().get('summarizeAs');
                defineDateRangeBasedOnFilter(dateFilter);
            }else{dateFilter = 'Quarterly';
                  defineDateRangeBasedOnFilter(dateFilter);}
        }else{
            isNotRenderedAsPdf = true;
            dateFilter = 'Quarterly';
            defineDateRangeBasedOnFilter(dateFilter);
        }
    }

    public List<SelectOption> getDateFilters() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Monthly','Monthly'));
        options.add(new SelectOption('Quarterly','Quarterly'));
        options.add(new SelectOption('Annual','Annual'));
        options.add(new SelectOption('Prev Month','Prev Month'));
        options.add(new SelectOption('Prev Quarter','Prev Quarter'));
        options.add(new SelectOption('Prev Year','Prev Year'));         
        options.add(new SelectOption('Prev Bi-Annual','Prev Bi-Annual'));
        options.add(new SelectOption('Curr Month','Curr Month'));
        options.add(new SelectOption('Curr Quarter','Curr Quarter'));
        options.add(new SelectOption('Curr Bi-Annual','Curr Bi-Annual'));
        options.add(new SelectOption('Curr Year','Curr Year'));
        return options;
    }
    
    public void changeFilterCriteria(){
        if(dateFilter != null) defineDateRangeBasedOnFilter(dateFilter);
    }
      
    public void defineDateRangeBasedOnFilter(string filterDate){
        system.debug('filterDate==>' + filterDate);
        toDate   = DateTime.now().format('yyyy-MM-dd');                 
        if(filterDate == 'Prev Month'){
            Period P1 = [Select StartDate, EndDate From Period Where type = 'Month' and StartDate = LAST_MONTH Limit 1];
            fromDate  = datetime.newInstance(P1.StartDate.year(),P1.StartDate.month(), P1.StartDate.day()).format('yyyy-MM-dd');
            toDate    = datetime.newInstance(P1.EndDate.year(),P1.EndDate.month(), P1.EndDate.day()).format('yyyy-MM-dd'); 
        } else if(filterDate == 'Prev Quarter'){
            Period P1 = [Select StartDate, EndDate From Period Where type = 'Quarter' and StartDate = LAST_QUARTER Limit 1];
            toDate    = datetime.newInstance(P1.EndDate.year(),P1.EndDate.month(), P1.EndDate.day()).format('yyyy-MM-dd'); 
            fromDate  = datetime.newInstance(P1.StartDate.year(),P1.StartDate.month(), P1.StartDate.day()).format('yyyy-MM-dd');
        } else if(filterDate == 'Prev Year'){
            Period P1 = [Select StartDate, EndDate From Period Where type = 'Year' and StartDate = LAST_YEAR Limit 1];
            toDate    = datetime.newInstance(P1.EndDate.year(),P1.EndDate.month(), P1.EndDate.day()).format('yyyy-MM-dd'); 
            fromDate  = datetime.newInstance(P1.StartDate.year(),P1.StartDate.month(), P1.StartDate.day()).format('yyyy-MM-dd');
        } else if(filterDate == 'Prev Bi-Annual'){          
            if(Date.Today().Month() > 6){
                Period P1 = [Select StartDate, EndDate From Period Where type = 'Year' and StartDate = THIS_YEAR Limit 1];
                fromDate  = datetime.newInstance(P1.StartDate.year(),P1.StartDate.month(), P1.StartDate.day()).format('yyyy-MM-dd');
                toDate    = datetime.newInstance(P1.StartDate.year(),P1.StartDate.month(), P1.StartDate.day()).AddMonths(6).AddDays(-1).format('yyyy-MM-dd'); 
            } else {
                Period P1 = [Select StartDate, EndDate From Period Where type = 'Year' and StartDate = LAST_YEAR Limit 1];
                fromDate  = datetime.newInstance(P1.StartDate.year(),P1.StartDate.month(), P1.StartDate.day()).AddMonths(6).format('yyyy-MM-dd');
                toDate    = datetime.newInstance(P1.EndDate.year(),P1.EndDate.month(), P1.EndDate.day()).format('yyyy-MM-dd'); 
            }                
        } else if(filterDate == 'Curr Month'){
            Period P1 = [Select StartDate, EndDate From Period Where type = 'Month' and StartDate = THIS_MONTH Limit 1];
            fromDate  = datetime.newInstance(P1.StartDate.year(),P1.StartDate.month(), P1.StartDate.day()).format('yyyy-MM-dd');
            toDate    = datetime.newInstance(P1.EndDate.year(),P1.EndDate.month(), P1.EndDate.day()).format('yyyy-MM-dd'); 
        } else if(filterDate == 'Curr Quarter'){
            Period P1 = [Select StartDate, EndDate From Period Where type = 'Quarter' and StartDate = THIS_QUARTER Limit 1];
            fromDate  = datetime.newInstance(P1.StartDate.year(),P1.StartDate.month(), P1.StartDate.day()).format('yyyy-MM-dd');
            toDate    = datetime.newInstance(P1.EndDate.year(),P1.EndDate.month(), P1.EndDate.day()).format('yyyy-MM-dd'); 
        } else if(filterDate == 'Curr Year'){
            Period P1 = [Select StartDate, EndDate From Period Where type = 'Year' and StartDate = THIS_YEAR Limit 1];
            fromDate  = datetime.newInstance(P1.StartDate.year(),P1.StartDate.month(), P1.StartDate.day()).format('yyyy-MM-dd');
            toDate    = datetime.newInstance(P1.EndDate.year(),P1.EndDate.month(), P1.EndDate.day()).format('yyyy-MM-dd'); 
        } else if(filterDate == 'Curr Bi-Annual'){            
            Period P1 = [Select StartDate, EndDate From Period Where type = 'Year' and StartDate = THIS_YEAR Limit 1];
            if(Date.Today().Month() > 6){
                fromDate  = datetime.newInstance(P1.StartDate.year(),P1.StartDate.month(), P1.StartDate.day()).AddMonths(6).format('yyyy-MM-dd');
                toDate    = datetime.newInstance(P1.EndDate.year(),P1.EndDate.month(), P1.EndDate.day()).format('yyyy-MM-dd'); 
            } else {             
                fromDate  = datetime.newInstance(P1.StartDate.year(),P1.StartDate.month(), P1.StartDate.day()).format('yyyy-MM-dd');
                toDate    = datetime.newInstance(P1.StartDate.year(),P1.StartDate.month(), P1.StartDate.day()).AddMonths(6).AddDays(-1).format('yyyy-MM-dd'); 
            }
        } else if(filterDate == 'Quarterly'){
            fromDate = DateTime.now().addMonths(-3).format('yyyy-MM-dd'); 
        } else if(filterDate == 'Monthly'){
            fromDate = DateTime.now().addMonths(-1).format('yyyy-MM-dd'); 
        } else {
            fromDate = DateTime.now().addMonths(-12).format('yyyy-MM-dd'); 
        }
        system.debug(fromDate+'<--->'+toDate );
    }
    
    public PageReference renderAsPDF()
    {
        PageReference ref = new PageReference('/apex/EmbedDashboardOnAccount?Id='+acc.Id+'&renderAsPdf=true&summarizeAs='+dateFilter);
        return ref;
    }
    public Boolean getIsClassic() {
        
        return (UserInfo.getUiThemeDisplayed() == 'Theme3' && ApexPages.currentPage().getParameters().get('beLightning') == null);
    }
    
    @isTest(SeeAllData = true)
    public static void TestEmbededDashboardOnAccountController() {
        Account ac = Utility.insertAccountInTestClasses();
        insert ac;
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        EmbededDashboardOnAccountController testAccPlan = new EmbededDashboardOnAccountController(sc);
        
        PageReference pageRef = Page.EmbedDashboardOnAccount;
        pageRef.getParameters().put('id', String.valueOf(ac.Id));
        Test.setCurrentPage(pageRef);
    }
        
}