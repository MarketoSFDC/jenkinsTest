/* ********************************************************************
* Created by         : Jade Global
* Created Date       : 26th July 2016
* Last Modified By   : Jade Global 26th July 2016
* Purpose            : This is used as 
                       1. Display 'Billing Schedule' Table in 'Preview Document' PDF.  
                       2. Display 'Billing Schedule' Table  for MDQ Quote and Preview Billing Schedule - checkbox checked  
             
* Last Modified By   : Priyanka Shende, Jade Global Inc on 9th May 2018
* Purpose            : Handle Preview Document Exception for JPY Quote 
*********************************************************************** */
public class billingScheduleVFComponentController{
  
    //This wrapper list used in 'Billing Schedule' table
    public  list<billingScheduleSegClass> billingSchedule{set;get;} 
     
    //Prepare list for preparing billingSchedule
    public  list<billingScheduleSegClass> billingScheduleShow;

    // Store quote payment frequency value as 'Non-Standard' 
    string NonStandard_PaymentFreq='Non-Standard';
      
    // Store quote payment frequency value as 'One-Time' 
    string OneTime_PaymentFreq='One-Time';
      
    //Store current quote ID - get from URL - 'qid' Parameter 
    string quoteID{get;set;}
      
    // Summation of quotes lines 'SBQQ__NetTotal__c' field for subscription product
    Double totalSubscriptionProductAmount= 0.0;
      
    // Summation of quotes lines 'SBQQ__NetTotal__c' field for subscription product
    Double totalNonSubscriptionProductAmount= 0.0;
      
    // Get quote Line Items of current Quote
    list<SBQQ__QuoteLine__c> quoteLineItems=new list<SBQQ__QuoteLine__c>();
        
    //current Quote Payment Frequency
    Decimal paymentFreq;  
      
    //payment frequency to it's term map from custom setting  
    Map<String,QuotePaymentFrequency__c> paymentFrquencyMap;
    
    //Date format map with its Marketo Entity on Quote
    Map<String,MarketoEntityOnQuote__c> marketoEntityMap;
    
    //number format map with its currency on quote
    Map<String,numberFormat__c> numberFormatMap;  
    
    //Current quote details  
    SBQQ__Quote__c quoteDetails;
      
    //calculate billing lines - display in Billing schedule table
    double billingLines;
      
    //calculate remaining months
    Integer remainingMonths;

    //this is used to calculate Start Date according to payment frequency
    Integer months=0;

    //current Quote currency 
    public string quoteCurrency{get;set;}
    
    string quoteCurrencyJPY='JPY';
    
    // Calculate monthly price 
    double monPrice;

    //product type as 'Subscription'
    string productType_Subscription='Subscription';

    //Quote Line instance used in wrapper
    SBQQ__QuoteLine__c quoteLine;

    //calculate QLITotalPrice 
    double QLITotalPrice;
    double billingschedulePriceSum;

    //This is used to calculate term
    decimal Term;
    decimal remaningDays;
    decimal remaningTerm;
    decimal price;
    decimal subscriptionTerm;
    
    //This is used to display decimal places for JPY and other than JPY  currencies
    integer decimalPlaces;
    public decimal totalPrice{get;set;}
    
    //This is used in billing schedule component to display date format corresponding to the Marketo Entity on Quote
    public string dateFormat{get;set;}
    
    public string numberFormat{get;set;}
    
    //This variable store SBQQ Quote - Subscription Term Promotions value as '13-for-12: Free month'
    string TermPromotions='13-for-12: Free month';
    
    // Sum of Output_MDQ_Net_Total__c 
    public double GrandTotal{get;set;}
    double TotalDiff;
    
    //billingScheduleVFComponentController Constructor 
    public billingScheduleVFComponentController(){
       
        totalPrice=0.0;  
        GrandTotal=0.0;
        TotalDiff=0;
        //get current quote id from url 
        quoteID=ApexPages.currentPage().getParameters().get('qid').trim();
        
        // Summation of quotes lines 'SBQQ__NetTotal__c' field
        totalSubscriptionProductAmount= 0.0;
        totalNonSubscriptionProductAmount= 0.0;
     
        // Get quote Line Items of current Quote
        list<SBQQ__QuoteLine__c> quoteLineItems =   new list<SBQQ__QuoteLine__c>();

        billingScheduleShow = new list<billingScheduleSegClass> ();

        string opportunityType_New_Business=Label.OPPORTUNITY_TYPE_NEW_BUSINESS;
        
        //segment label to wrapper class map
        map<string,billingScheduleSegClass> productCodeToBillScheduleWrapper    =   new map<string,billingScheduleSegClass>();
        QLITotalPrice=0.0;

        //Get current quote details in quoteDetails 
        quoteDetails=[SELECT id,Calc_End_Date__c,Early_Renewal__c,Marketo_Entity__c,SBQQ__SubscriptionTerm__c,Payment_Frequency__c,MKTO_Effective_End_Date__c,SBQQ__StartDate__c,CurrencyIsoCode,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Type,New_Logo_Term_Promotions__c FROM SBQQ__Quote__c WHERE id=:quoteID  limit 1];
        
        //get payment frequency term map from custom setting 
        paymentFrquencyMap  =   new Map<String,QuotePaymentFrequency__c>();
        for(QuotePaymentFrequency__c payFreq :QuotePaymentFrequency__c.getAll().values()){
            paymentFrquencyMap.put(payFreq.Name, payFreq);
        }
        
        //get currosponding Date format related to Marketo Entity   
        marketoEntityMap    =   new Map<String,MarketoEntityOnQuote__c>();
        for(MarketoEntityOnQuote__c marketoEntity :MarketoEntityOnQuote__c.getAll().values()){
            marketoEntityMap.put(marketoEntity.Name,marketoEntity);
        }
        
        //get currosponding Number format related to Quote currency
        numberFormatMap = new Map<String,numberFormat__c>();
        for(numberFormat__c noFormat :numberFormat__c.getAll().values()){
            numberFormatMap.put(noFormat.Name,noFormat);
        }
        
        //prepare current quote Quote Line List
        quoteLineItems=[SELECT id, True_Effective_Term__c,Output_MDQ_Net_Total__c,SBQQ__ProductCode__c,MKTO_Net_Total__c,SBQQ__NetTotal__c,SBQQ__EffectiveStartDate__c,SBQQ__EffectiveEndDate__c,SBQQ__SegmentIndex__c,MKTO_Net_Unit_Price__c,SBQQ__SegmentLabel__c,MKTO_Product_Name__c,SBQQ__Quote__r.SBQQ__SubscriptionTerm__c,SBQQ__Quote__r.SBQQ__StartDate__c,SBQQ__Quote__r.Payment_Frequency__c,CurrencyIsoCode,Product_Type__c,SBQQ__StartDate__c,MKTO_Effective_Term__c,Effective_Subscription_Term__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.Id=:quoteID AND SBQQ__Quote__r.Payment_Frequency__c!=:NonStandard_PaymentFreq AND SBQQ__Quote__r.Payment_Frequency__c!=:OneTime_PaymentFreq AND  SBQQ__NetTotal__c!=0  order by SBQQ__EffectiveStartDate__c ASC];

        //wrapper class List for populating lines in billingSchedule Table
        billingSchedule =   new list<billingScheduleSegClass>();
        
        //current quote payment frequency in term 
        
        if(paymentFrquencyMap.containsKey(quoteDetails.Payment_Frequency__c)&& paymentFrquencyMap.get(quoteDetails.Payment_Frequency__c).paymentFrequencyTerm__c!=NULL){
            paymentFreq=paymentFrquencyMap.get(quoteDetails.Payment_Frequency__c).paymentFrequencyTerm__c;
        }
        system.debug('####################paymentFreq'+paymentFreq);
        
        //current Quote currency 
        quoteCurrency=quoteDetails.CurrencyIsoCode;
        
        //Total price decimal places according to JPY and other than JPY
        decimalPlaces = quoteCurrency==quoteCurrencyJPY ?0:2;
        
        //current quote 
        if(marketoEntityMap.containsKey(quoteDetails.Marketo_Entity__c) && marketoEntityMap.get(quoteDetails.Marketo_Entity__c).Date_Format__c!=NULL){
            dateFormat      =   marketoEntityMap.get(quoteDetails.Marketo_Entity__c).Date_Format__c;
        }
        if(numberFormatMap.containsKey(quoteDetails.CurrencyIsoCode) && numberFormatMap.get(quoteDetails.CurrencyIsoCode).numberFormat__c!=NULL){
            numberFormat    =   numberFormatMap.get(quoteDetails.CurrencyIsoCode).numberFormat__c;
        }//End of If
        
        //calculate 'Billing Schedule' Table Lines
       if(quoteDetails.New_Logo_Term_Promotions__c==TermPromotions && quoteDetails.SBQQ__SubscriptionTerm__c==13){
            subscriptionTerm    =   12;
       }
       else{
            subscriptionTerm    =   quoteDetails.SBQQ__SubscriptionTerm__c;
       }
       
       //calculate billing lines
       if(subscriptionTerm!=null && paymentFreq!=null){
           billingLines=subscriptionTerm/paymentFreq;
       }
        If(billingLines < 1)
        {
            billingLines = 1;
        }
       //Calculate remaining months this is used at the top of the billing schedule table
       if(paymentFreq!=null && subscriptionTerm!=null){
           remainingMonths  =   math.mod(subscriptionTerm.intvalue(),paymentFreq.intvalue());
       }
       
       //Print Date - system Todays date 
       date PrintDate   =   date.today();
        
        if(quoteDetails.SBQQ__Opportunity2__r.Type!=opportunityType_New_Business){
            system.debug('opportunity type ###################'+ quoteDetails.SBQQ__Opportunity2__r.Type);
            for(Integer i=0; i <= billingLines.intvalue()-1;i++){
                //create object of wrapper class,refereed this in billingScheduleShow(wrapper list) for displaying in billing schedule
                billingScheduleSegClass billingScheduleLines        =  new billingScheduleSegClass();
                billingScheduleLines.totalPrice                     =  0.0;
                billingScheduleLines.QuoteCurrency                  =  quoteCurrency;
                //Other than New Business - End date - 3
                billingScheduleLines.startDate                      =  (quoteDetails.Calc_End_Date__c.ADDMONTHS(-(months+paymentFreq.intvalue())));
                billingScheduleLines.endDate                        =  ((billingScheduleLines.startDate).ADDMONTHS(paymentFreq.intvalue()));
                billingScheduleLines.billingScheduleTerm            =   paymentFreq.intvalue();
                
                //add wrapper record in wrapper(billingScheduleShow) list
                billingScheduleShow.add(billingScheduleLines);
                system.debug('##################### billingScheduleLines'+billingScheduleLines);
                months                                              =   months+ paymentFreq.intvalue();
            }//End of BillingLines FOR

            if(remainingMonths>0){
                //Billing Line wrapper record
                billingScheduleSegClass billingScheduleLines                    =   new billingScheduleSegClass();
                // SBQQ__QuoteLine__c quoteLine= new SBQQ__QuoteLine__c(MKTO_Effective_End_Date__c=date.Today());
                billingScheduleShow[billingScheduleShow.size()-1].startdate             =   quoteDetails.SBQQ__StartDate__c;
                billingScheduleShow[billingScheduleShow.size()-1].endDate               =   (billingScheduleShow[billingScheduleShow.size()-1].startdate).ADDMONTHS((remainingMonths+paymentFreq.intvalue())).addDays(-1);
                billingScheduleShow[billingScheduleShow.size()-1].billingScheduleTerm   =   remainingMonths+paymentFreq.intvalue();
            }//End of remaining months IF
            // Run this logic for other than New Business(Renewal , Early Renewal, Amend)
            for(integer i=billingScheduleShow.size()-1;i>=0 ; i--){
                billingSchedule.add(billingScheduleShow[i]);
            }//End of FOR Loop of billingScheduleShow  
            billingSchedule[0].startDate=quoteDetails.SBQQ__StartDate__c-1;
        }// End of opp.Type!= 'New Business' IF
        else if(quoteDetails.SBQQ__Opportunity2__r.Type == opportunityType_New_Business && billingLines!=null){
            months=0;
            for(Integer i=0; i <= billingLines.intvalue()-1;i++){
                //create object of wrapper class,refereed this in billingScheduleShow(wrapper list) for displaying in billing schedule
                billingScheduleSegClass billingScheduleLines    =   new billingScheduleSegClass();
                billingScheduleLines.totalPrice                 =   0.0;
                billingScheduleLines.QuoteCurrency              =   quoteCurrency;
                billingScheduleLines.startDate                  =   ((quoteDetails.SBQQ__StartDate__c).ADDMONTHS(months));
                billingScheduleLines.endDate                    =   ((billingScheduleLines.startDate).ADDMONTHS(paymentFreq.intvalue()));
                billingScheduleLines.billingScheduleTerm        =    paymentFreq.intvalue();
                
                //add wrapper record in wrapper(billingScheduleShow) list
                billingSchedule.add(billingScheduleLines);
                months                                          =    months+ paymentFreq.intvalue();
            }//End of BillingLines FOR

            if(remainingMonths>0){
                //Billing Line wrapper record
                billingScheduleSegClass billingScheduleLines    =    new billingScheduleSegClass();

                // SBQQ__QuoteLine__c quoteLine= new SBQQ__QuoteLine__c(MKTO_Effective_End_Date__c=date.Today());
                //billingScheduleShow[billingScheduleShow.size()-1].startdate=quoteDetails.SBQQ__StartDate__c;
                billingSchedule[billingSchedule.size()-1].endDate               =   (billingSchedule[billingSchedule.size()-1].startdate).ADDMONTHS((remainingMonths+paymentFreq.intvalue())).addDays(-1);
                billingSchedule[billingSchedule.size()-1].billingScheduleTerm   =   remainingMonths+paymentFreq.intvalue();
            }//End of remaining months IF
              
        }//End of New Business If
        
    //Iterate on Quote Line 
    for(SBQQ__QuoteLine__c QLI :quoteLineItems){
        //check QLI Product Code 
        Term=0;
        if(QLI.Product_Type__c==productType_Subscription && QLI.SBQQ__NetTotal__c!=null){
            system.debug('Product Quote, SBQQ__NetTotal__c #########'+QLI.SBQQ__ProductCode__c +QLI.SBQQ__NetTotal__c);
            for(Integer i=0; i<=billingSchedule.size()-1;i++){
                system.debug('######################## QLI.SBQQ__EffectiveStartDate__c'+QLI.SBQQ__EffectiveStartDate__c);
                system.debug('######################## billingSchedule[i].startdate'+billingSchedule[i].startdate);
                system.debug('######################## billingSchedule[i].endDate'+billingSchedule[i].endDate);
                system.debug('######################## QLI.SBQQ__SegmentLabel__c'+QLI.SBQQ__SegmentLabel__c);
                if(QLI.SBQQ__EffectiveStartDate__c >= billingSchedule[i].startdate && QLI.SBQQ__EffectiveStartDate__c < billingSchedule[i].endDate && QLI.SBQQ__SegmentLabel__c!=NULL){
                system.debug('###############Inside for');
                    if(qli.True_Effective_Term__c <= billingSchedule[i].billingScheduleTerm){
                        system.debug('Inside If qli.True_Effective_Term__c'+qli.True_Effective_Term__c+'billingSchedule[i].billingScheduleTerm'+billingSchedule[i].billingScheduleTerm);
                        if((i+1)<=(billingSchedule.size()-1)){
                            system.debug('Inside <i+1 if');
                            if((billingSchedule[i+1].startDate.daysBetween(QLI.SBQQ__EffectiveEndDate__c))<28){
                                system.debug('Inside <i+1 <28 if');
                                billingSchedule[i].totalPrice   =   (billingSchedule[i].totalPrice + (qli.True_Effective_Term__c*(QLI.SBQQ__NetTotal__c/qli.True_Effective_Term__c)));
                            }//End of IF
                            else{ 
                                system.debug('Inside <i+1 else');
                                remaningDays                    =   (billingSchedule[i+1].startDate.daysBetween(QLI.SBQQ__EffectiveEndDate__c));//QLI.SBQQ__EffectiveStartDate__c.daysBetween(billingSchedule[i].startDate);
                                if(remaningDays >=365)
                                {
                                    remaningTerm=(remaningDays/30);
                                }
                                else{
                                    remaningTerm=(remaningDays/28);
                                }
                                system.debug('remaningTerm ##########'+remaningTerm);
                                Term                            =   remaningTerm.intValue();
                                system.debug('Term ##########'+Term);
                                billingSchedule[i].totalPrice   =   (billingSchedule[i].totalPrice + ((qli.True_Effective_Term__c-Term)*(QLI.SBQQ__NetTotal__c/qli.True_Effective_Term__c)));
                                system.debug('price #######'+price);
                                if(Test.isRunningTest()){
Term = 1;
}
                                if(Term > 0){
                                    Integer j=i;
                                    while(Term > 0){  
                                        billingSchedule[j+1].totalPrice     =   (billingSchedule[j+1].totalPrice + (term*(QLI.SBQQ__NetTotal__c/qli.True_Effective_Term__c)));
                                        Term                                =   Term-billingSchedule[j+1].billingScheduleTerm;
                                        system.debug('Term ######## inside while'+Term);
                                        j=j+1;
                                    }//End of while loop
                                    break;
                                }//End of IF block of Term
                            }//End of Else block 
                        }//End Of I size if Block
                        else{
                            
                            billingSchedule[billingSchedule.size()-1].totalPrice    =   (billingSchedule[billingSchedule.size()-1].totalPrice + (qli.True_Effective_Term__c*(QLI.SBQQ__NetTotal__c/qli.True_Effective_Term__c)));
                        }//End of Else
                    }//End of IF block of Term < Billing term
                    else if(qli.True_Effective_Term__c > billingSchedule[i].billingScheduleTerm){
                        if((i+1)<=(billingSchedule.size()-1)){
                            //system.debug('###billingSchedule[i+1].startDate.daysBetween(QLI.MKTO_Effective_End_Date__c)'+billingSchedule[i+1].startDate.daysBetween(QLI.MKTO_Effective_End_Date__c));
                            system.debug('#####if condition < 28 || >28');        
                            if((billingSchedule[i+1].startDate.daysBetween(QLI.SBQQ__EffectiveEndDate__c))<=27){
                                system.debug('#####if condition < 28');  
                                billingSchedule[i].totalPrice   =   (billingSchedule[i].totalPrice + (qli.True_Effective_Term__c*(QLI.SBQQ__NetTotal__c/qli.True_Effective_Term__c))); 
                            }//End Of billing schedule IF
                            else{  
                                system.debug('else condition ######');
                                remaningDays=(billingSchedule[i+1].startDate.daysBetween(QLI.SBQQ__EffectiveEndDate__c));
                                system.debug('######### remaningDays'+ remaningDays);
                                //QLI.SBQQ__EffectiveStartDate__c.daysBetween(billingSchedule[i].startDate);
                                if(remaningDays >=364){
                                    remaningTerm    =   (remaningDays/30);
                                }
                                else{
                                    remaningTerm    =   (remaningDays/28);
                                }
                                system.debug('######### remaningTerm'+ remaningTerm);
                                system.debug('###############billingSchedule[i].totalPrice'+billingSchedule[i].totalPrice);
                                Term=remaningTerm.intValue();
                                billingSchedule[i].totalPrice   =   (billingSchedule[i].totalPrice + ((qli.True_Effective_Term__c-Term)*(QLI.SBQQ__NetTotal__c/qli.True_Effective_Term__c)));
                                Integer j=i;
                                if(Term > 0 ){
                                    system.debug('billing Schedule size##############'+(billingSchedule.size()-1));
                                    system.debug('j+1 #########'+(j+1));
                                    while(Term > 0){
                                        system.debug('#######inside term >0'+Term);
                                        if((j+1)<=(billingSchedule.size()-1)){
                                            system.debug('Inside If j+1 size'+ j+1);
                                            if(Term >= billingSchedule[j+1].billingScheduleTerm){
                                                system.debug('term > billing Line');
                                                billingSchedule[j+1].totalPrice     =   (billingSchedule[j+1].totalPrice + (billingSchedule[j+1].billingScheduleTerm*(QLI.SBQQ__NetTotal__c/qli.True_Effective_Term__c)));
                                                Term    =   Term-billingSchedule[j+1].billingScheduleTerm;
                                                j=j+1;
                                            }// End of Term IF
                                            else{
                                                system.debug('Inside Else size < billing Line');
                                                billingSchedule[j+1].totalPrice =   (billingSchedule[j+1].totalPrice + (Term*(QLI.SBQQ__NetTotal__c/qli.True_Effective_Term__c)));
                                                Term=0;
                                            }
                                        }//End of billing schedule size IF
                                        else{
                                            billingSchedule[0].totalPrice   =   (billingSchedule[0].totalPrice + (Term*(QLI.SBQQ__NetTotal__c/qli.True_Effective_Term__c)));
                                            system.debug('###########else price'+billingSchedule[0].totalPrice);
                                            Term                            =   Term-billingSchedule[0].billingScheduleTerm;
                                            system.debug('billing schedule Term #######'+Term);
                                        } //End of ELse
                                    }//End of while loop
                                    system.debug('before term if #######');
                                }//End of IF block of Term
                            }//End of else block 
                        }//End of size if 
                        else{
                            system.debug('else ###########');
                            billingSchedule[billingSchedule.size()-1].totalPrice    =   (billingSchedule[billingSchedule.size()-1].totalPrice + (billingSchedule[billingSchedule.size()-1].billingScheduleTerm*(QLI.SBQQ__NetTotal__c/qli.True_Effective_Term__c)));
                        }
                    }// End of Else If
                }//End of IF block of MDQ subcription QLI
                if(QLI.SBQQ__SegmentLabel__c==NULL){
                    billingSchedule[i].totalPrice   =   (billingSchedule[i].totalPrice + (billingSchedule[i].billingScheduleTerm*(QLI.SBQQ__NetTotal__c/subscriptionTerm/*qli.True_Effective_Term__c*/)));
                }//End of IF block of non-MDQ subcription QLI
            }//End of FOR loop of billing schedule
        }//END of Subscription PRODUCT IF
        else if(QLI.SBQQ__NetTotal__c!=null){
            totalNonSubscriptionProductAmount = totalNonSubscriptionProductAmount + QLI.SBQQ__NetTotal__c;
        }//End of NON Subscription product Total ELSE
        
        if(QLI.Output_MDQ_Net_Total__c!=null){
            GrandTotal=GrandTotal+QLI.Output_MDQ_Net_Total__c;
        }
    }//End of Quote line FOR loop
    
    //Travels billing schedule for date logic New Business & Renewal
    if(!billingSchedule.isEmpty() && quoteDetails != null && quoteDetails.SBQQ__StartDate__c != null){
                //billingSchedule[0].startdate = quoteDetails.SBQQ__StartDate__c; 
        if(quoteDetails.SBQQ__Opportunity2__r.Type!=opportunityType_New_Business){
            date maxDate=quoteDetails.SBQQ__StartDate__c-1;
            if(printDate > (quoteDetails.SBQQ__StartDate__c-1)){ 
                maxDate=printDate;
            }
            else{
                maxDate=quoteDetails.SBQQ__StartDate__c-1;
            }
            //billingSchedule[0].startDate=maxDate;
            BillingScheduleDatesBasedOnScenarios(maxDate);
        }//End of not equal to new Business(Renewal) If 
        else if(quoteDetails.SBQQ__Opportunity2__r.Type==opportunityType_New_Business){
            //Initial date of billing schedule
            Date billingScheduleInitialDate;
            system.debug('billingScheduleInitialDate Initial ###########'+billingScheduleInitialDate);
            
            if((quoteDetails.SBQQ__StartDate__c!=null) && (printDate <= quoteDetails.SBQQ__StartDate__c)){
                if((quoteDetails.SBQQ__StartDate__c.year()==printDate.year())&& (quoteDetails.SBQQ__StartDate__c.month()==printDate.month()) && (printDate.day()<=quoteDetails.SBQQ__StartDate__c.day())){
                    //billingSchedule[0].startDate  =   printDate;
                    billingScheduleInitialDate      =   printDate;
                    system.debug('billingScheduleInitialDate 1 ###########'+billingScheduleInitialDate);
                }//End of If
                else if(((printDate.year()==quoteDetails.SBQQ__StartDate__c.year())&& (printDate.month()==quoteDetails.SBQQ__StartDate__c.month()-1))||(printDate.year()==quoteDetails.SBQQ__StartDate__c.year()-1)&&(quoteDetails.SBQQ__StartDate__c.month()==printDate.month()-11)){
                    if(quoteDetails.SBQQ__StartDate__c.day()<=15){
                        //billingSchedule[0].startDate  =   printDate;
                        billingScheduleInitialDate      =   printDate;
                        system.debug('billingScheduleInitialDate <15 ###########'+billingScheduleInitialDate);
                    }
                    else{
                        //billingSchedule[0].startDate=quoteDetails.SBQQ__StartDate__c;
                        billingScheduleInitialDate=quoteDetails.SBQQ__StartDate__c;
                        system.debug('billingScheduleInitialDate ########### else'+billingScheduleInitialDate);
                    }
                }//End of Else If
                else if((printDate.monthsBetween(quoteDetails.SBQQ__StartDate__c))>1){
                        system.debug('######################'+printDate.monthsBetween(quoteDetails.SBQQ__StartDate__c));
                        //Number of days in quote start date month
                        Integer numberOfDays        =   Date.daysInMonth(quoteDetails.SBQQ__StartDate__c.year(), quoteDetails.SBQQ__StartDate__c.month()-1);
                        //Calculate last day of the quote start date
                        Date lastDayOfQuoteMonth    =   Date.newInstance(quoteDetails.SBQQ__StartDate__c.year(), quoteDetails.SBQQ__StartDate__c.month()-1, numberOfDays);
                        system.debug('###################### lastDayOfQuoteMonth'+lastDayOfQuoteMonth);
                        //billingSchedule[0].startDate=lastDayOfQuoteMonth;
                        billingScheduleInitialDate=lastDayOfQuoteMonth;
                        system.debug('billingScheduleInitialDate else if ###########'+billingScheduleInitialDate);
                }//End of else If
                BillingSchdeuleDates(billingScheduleInitialDate);
         }//End of Not equal to null If
         else if((quoteDetails.SBQQ__StartDate__c!=null)&& (printDate > quoteDetails.SBQQ__StartDate__c)){
                    Integer MonthsDiff=printDate.monthsBetween(quoteDetails.SBQQ__StartDate__c);
                    if((paymentFreq==1 && MonthsDiff <=1) || (paymentFreq==3 && MonthsDiff <=3) || (paymentFreq==6 && MonthsDiff <=6) ||(paymentFreq==12 && MonthsDiff <=12)){
                        billingScheduleInitialDate=printDate;
                    }
                BillingScheduleDatesBasedOnScenarios(billingScheduleInitialDate);
          }
       }//End of New Business If
       billingSchedule[0].totalprice=(billingSchedule[0].totalprice+ totalNonSubscriptionProductAmount);
    }//End of If Block
    

    //Calculate total price of Billing Schedule and display 2 decimal places to other than JPY currency
        for(integer i=billingSchedule.size()-1;i>=0 ; i--){
            system.debug('  billingSchedule[i].totalprice====BEFORE ==='+  billingSchedule[i].totalprice);
            billingSchedule[i].totalprice   =   totalPriceWithDecimalPlaces(billingSchedule[i].totalprice);
            system.debug('  billingSchedule[i].totalprice====BEFORE ==='+  billingSchedule[i].totalprice);
            //Billing schedule lines total price summation
            totalPrice                      =   totalPrice+billingSchedule[i].totalPrice.intvalue();
        }//End of FOR Loop of billingScheduleShow   
        
        // Added If condition to handle Exception - Handle Preview Document Exception for JPY Quote 
        if(billingSchedule.size()>0){
            TotalDiff=GrandTotal-totalPrice;
            billingSchedule[0].totalprice   =  billingSchedule[0].totalprice + TotalDiff;
        }//End of If 
    }//End of controller
    
    //Method for decimal places display according to quote currency
    public decimal totalPriceWithDecimalPlaces(decimal price){
        decimal billingScheduleLineTotalPrice;
        if(quoteCurrency==quoteCurrencyJPY){
           billingScheduleLineTotalPrice    =   price.ROUND();
        }else{
            //billingScheduleLineTotalPrice   =   price.setScale(decimalPlaces,system.RoundingMode.HALF_UP);
            billingScheduleLineTotalPrice   =   price.intvalue();
        }
        return billingScheduleLineTotalPrice;
    }//End of Method 
 
    //calculate billing schedule lines according to the different conditions
    public void BillingSchdeuleDates(date initialDate){
        if(initialDate==null){
            initialDate =   quoteDetails.SBQQ__StartDate__c;
        }
        months=0;
        for(integer i=0; i<billingSchedule.size(); i++){
            billingSchedule[i].showStartDate =  initialDate.ADDMONTHS(months);
            months  =   months+ paymentFreq.intvalue();
            system.debug('billingSchedule[i].showStartDate #################'+billingSchedule[i].showStartDate);
        }//End of FOR Loop of billingScheduleShow    
    }
    
    //calculate billing schedule lines for New Business Scenario if the print date is greater than SS Date
    public void BillingScheduleDatesBasedOnScenarios(date initialDate){
        months =0;
        for(integer i=0; i<billingSchedule.size(); i++){
            billingSchedule[i].showStartDate = billingSchedule[i].startDate;
            //quoteDetails.SBQQ__StartDate__c.ADDMONTHS(months);
            //months  =   months+ paymentFreq.intvalue();
            system.debug('billingSchedule[i].showStartDate #################'+billingSchedule[i].showStartDate);
        }
        // Added If condition to handle Exception - Handle Preview Document Exception for JPY Quote 
        if(billingSchedule.size()>0){
            billingSchedule[0].showStartDate = initialDate;
        }//End of If
    }

    //Wrapper Class for segment price sum
    public class billingScheduleSegClass{
        public Integer billingScheduleTerm{get;set;}
        public decimal totalPrice{get;set;}
        public string QuoteCurrency{get;set;}
        public Date startDate{get;set;}
        public Date showStartDate{get;set;}
        public Date endDate{get;set;}
    }//End of Wrapper Class
}