/*
 * Class Name : YTDBlendedDiscountCalculator
 * Author : JadeGlobal Inc.
 * Created Date : 22nd July 2016
 * This class will be used to calculate the Prior Blended Discount on Renewal Quote
 * There will be two events on which the blended discount will be calculated:
 *     before Insert of Renewal Quote AND after Update [When Upsell gets closed won]
*/
public class YTDBlendedDiscountCalculator {  
  
  public static set<id> AccountIds = new set<id>();
  public static set<id> UpsellQuoteIds = new set<id>();
  
  public static void UpsellClosedWonPriorBlendedDiscountCall(list<Opportunity> Opportunitylist, map<id,Opportunity> OldMap){

        list<SBQQ__Quote__c> FinalQuoteList = new list<SBQQ__Quote__c>();
        
    if(!Opportunitylist.isEmpty()){
      for(Opportunity oppo : Opportunitylist){
         if(OldMap.containsKey(oppo.id)){
           Opportunity OppoInOldMap = OldMap.get(oppo.id);
            if(oppo.Type == 'Upsell/Crossell' && oppo.isWon  == TRUE && (oppo.Type != OppoInoldMap.Type || oppo.isWon != OppoInoldMap.isWon) && oppo.Prior_Opportunity__c != null){
              AccountIds.add(oppo.AccountId);
          }//End of IF
        }//End Of IF
      }//End of FOR
    }//End of IF
    System.debug('@@@@@@@@ AccountIds @@@@@@@@ : '+AccountIds);
  
    //Call to method to calculate YTD Blended Discount
    if(!AccountIds.isEmpty()){
      FinalQuoteList = calculateYTDBlendedDiscount(AccountIds,TRUE);
      
      if(!FinalQuoteList.isEmpty()){
        Update FinalQuoteList;
      }
    }
  }//End of UpsellClosedWonPriorBlendedDiscountCall()
  
  /*public static void populatePriorBlendedDiscoutFieldOnRNWLQuote(List<SBQQ__Quote__c> newQuotesList){
    
        list<SBQQ__Quote__c> FinalQuoteList = new list<SBQQ__Quote__c>();
        
    //Extractting all the Account Ids of incoming Quotes
    for(SBQQ__Quote__c q : newQuotesList){
            if(q.SBQQ__Account__c != null && q.Opportunity_Type__c == 'Renewal'){
                AccountIds.add(q.SBQQ__Account__c);
            }
        }
    //Call to method to calculate YTD Blended Discount
    if(!AccountIds.isEmpty()){
      FinalQuoteList = calculateYTDBlendedDiscount(AccountIds,FALSE);
    }
  
  }//End of populatePriorBlendedDiscoutFieldOnRNWLQuote()
  */

  public static list<SBQQ__Quote__c> calculateYTDBlendedDiscount(set<id> Accid, boolean OpportunityTriggerflag){
    
        list<SBQQ__Quote__c> RNWLQuotesList = new list<SBQQ__Quote__c>();
        
        list<Opportunity> ListOfrelevantOpptys = new list<Opportunity>();
        map<id,SBQQ__Quote__c> MapOppAndPrimaryQuote = new map<id,SBQQ__Quote__c>();
        map<id,Opportunity> mapOppIdAndPriorOpportunity = new map<id,Opportunity>();
        map<id,list<Opportunity>> MapAccountIdClosedupsells = new map<id,list<Opportunity>>();
        map<id,List<opportunity>> mapAccIdAndRenewalOpptys = new map<id,List<opportunity>>();
        set<id> setOfIdsToHandleRecursion = new set<id>();
        
        list<SBQQ__Quote__c> listOfQuotesToBeReturned = new list<SBQQ__Quote__c>();
        Double SubscriptionDiscTotal;
        Double SubscriptionTotal;
        Date CloseDateOfRenewal;
        
        list<SBQQ__Quote__c> listOfUpsellsToBeUpdated = new list<SBQQ__Quote__c>();
        
        list<SBQQ__Quote__c> ListOfUpsellQuotes = new list<SBQQ__Quote__c>();
        Id priorOfUpsellOpptyId;
  
    if(!AccountIds.isEmpty()){ 
    
      ListOfrelevantOpptys = [SELECT id, isWon, Type, CloseDate, AccountId,Prior_Opportunity__c, Prior_Opportunity__r.id, Prior_Opportunity__r.CloseDate, (SELECT id, Subscription_Total__c, Subscription_Discount_Total__c, SBQQ__Primary__c, SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Type,SBQQ__Opportunity2__r.isWon,Prior_Blended_Discount__c,SBQQ__Opportunity2__r.Prior_Opportunity__r.id FROM SBQQ__Quotes2__r) FROM Opportunity WHERE AccountId IN : AccountIds AND (isWon = TRUE OR (isWon = FALSE AND Type = 'Renewal'))Order By CloseDate Desc];
      
      //This FOR loop will get all the related Primary Quotes to the respective opportunities
      for(Opportunity oppo : ListOfrelevantOpptys){
                for(SBQQ__Quote__c qt : oppo.SBQQ__Quotes2__r){
                    if(qt.SBQQ__Primary__c == TRUE){
                        MapOppAndPrimaryQuote.put(oppo.Id,qt);
                    }
                }
            }
            System.debug('%%%%%%%% MapOppAndPrimaryQuote %%%%%% : '+MapOppAndPrimaryQuote);
      
      //This IF loop will set the RENEWAL Quote List to Fetched Quotes from SOQL for After Update Event on Opportunity
      if(OpportunityTriggerflag){
        
        if(!MapOppAndPrimaryQuote.isEmpty()){
          
          for(SBQQ__Quote__c quote : MapOppAndPrimaryQuote.values()){
          
            //Getting All Renewal Quotes of OPEN Renewal Oppty
            if(quote.SBQQ__Primary__c == TRUE && quote.SBQQ__Opportunity2__r.Type == 'Renewal' && quote.SBQQ__Opportunity2__r.isWon == FALSE){
              RNWLQuotesList.add(quote);
            }//End of IF
            
            //Getting All Upsell Quotes
            if(quote.SBQQ__Primary__c == TRUE && quote.SBQQ__Opportunity2__r.Type == 'Upsell/Crossell' && quote.SBQQ__Opportunity2__r.isWon == TRUE){
                ListOfUpsellQuotes.add(quote);
            }//End of IF
            
          }//End of FOR
        }//End of IF
      }
      //This ELSE loop will set the RENEWAL Quote List to Trigger.new for Before Insert Event on SB Quote
      else{
        RNWLQuotesList = Trigger.new;
      }
      
      for(Opportunity oppp : ListOfrelevantOpptys){
                
                //Populating map to access Opportunity and it's prior opportunity
                mapOppIdAndPriorOpportunity.put(oppp.id,oppp);

                if(MapAccountIdClosedupsells.containsKey(oppp.Accountid) && oppp.Type == 'Upsell/Crossell'){
                    MapAccountIdClosedupsells.get(oppp.Accountid).add(oppp);
                }//End of IF
                else if(!MapAccountIdClosedupsells.containsKey(oppp.Accountid) && oppp.Type == 'Upsell/Crossell'){
                    MapAccountIdClosedupsells.put(oppp.AccountId,new list<Opportunity> {oppp});
                }//End of ElseIF
    
                if(mapAccIdAndRenewalOpptys.containsKey(oppp.Accountid) && (oppp.Type == 'Renewal' || oppp.Type == 'New Business')){
                    mapAccIdAndRenewalOpptys.get(oppp.Accountid).add(oppp);
                }//End of IF
                else if(!mapAccIdAndRenewalOpptys.containsKey(oppp.Accountid) && (oppp.Type == 'Renewal' || oppp.Type == 'New Business')){
                    mapAccIdAndRenewalOpptys.put(oppp.AccountId,new list<Opportunity> {oppp});
                }//End of ElseIF
                

            }//End Of FOR
            
            System.debug('$$$$$$$$ MapAccountIdClosedupsells $$$$$$ : '+MapAccountIdClosedupsells);
            System.debug('%%%%%%%% mapAccIdAndRenewalOpptys %%%%%% : '+mapAccIdAndRenewalOpptys);
      
            System.debug('$%^$%^$^%$^%$^% RNWLQuotesList: '+RNWLQuotesList);
      
      if(!RNWLQuotesList.isEmpty()){
        for(SBQQ__Quote__c tempQuote : RNWLQuotesList) {
        
          id QuoteIdInTriggerNew = tempQuote.id != null ? tempQuote.id : null;
          
          if(!setOfIdsToHandleRecursion.contains(QuoteIdInTriggerNew)){
            if(QuoteIdInTriggerNew != null){
              setOfIdsToHandleRecursion.add(QuoteIdInTriggerNew);
            }
            if(!mapAccIdAndRenewalOpptys.isEmpty()){
              for(Id accountId :mapAccIdAndRenewalOpptys.keySet()){
                if(MapAccountIdClosedupsells.containsKey(accountId) ){  
                  SubscriptionDiscTotal = 0.0;
                  SubscriptionTotal = 0.0;
                  
                  Opportunity op = mapAccIdAndRenewalOpptys.get(accountId)[0];
                  System.debug('******* Renewal Oppty Id : ******** '+op.id);
                  System.debug('******* Renewal Oppty isWon : ******** '+op.isWon);
                  if(mapOppIdAndPriorOpportunity.containskey(op.id) && tempQuote.SBQQ__Opportunity2__c == op.id){
                    
                    Opportunity QuoteOppty = mapOppIdAndPriorOpportunity.get(op.id);
                    
                    if(QuoteOppty.Prior_Opportunity__c != null && op.Prior_Opportunity__c == QuoteOppty.Prior_Opportunity__c){
                      CloseDateOfRenewal = QuoteOppty.Prior_Opportunity__r.CloseDate;
                      
                      system.debug('@@@@@@@@@@@ CloseDateOfRenewal @@@@@@@@@@@@'+CloseDateOfRenewal);
                      //Begin of Upsell Oppty Loop
                      if(!MapAccountIdClosedupsells.isEmpty() && MapAccountIdClosedupsells.containskey(accountId)){
                        for(Opportunity opp :MapAccountIdClosedupsells.get(accountId)){
                        System.debug('%%%%%%% Upsell Id %%%%%% : '+opp.id);
                        system.debug('@@@@@@@@@@@ Upsell opp.CloseDate @@@@@@@@@@@@'+opp.CloseDate);
                        
                          if(opp.CloseDate >= CloseDateOfRenewal){
                            
                            if(MapOppAndPrimaryQuote.containskey(opp.id)){
                              SBQQ__Quote__c sbq = MapOppAndPrimaryQuote.get(opp.id);
                              
                              //Adding upsell quote in list of upsell quotes to be updated
                              //Added by Jade on 20th June 2016
                              listOfUpsellsToBeUpdated.add(sbq);
                              
                              system.debug('@@@@@@@@@@@ sbq.Subscription_Discount_Total__c @@@@@@@@@@ : '+sbq.Subscription_Discount_Total__c);
                              system.debug('@@@@@@@@@@@ sbq.Subscription_Total__c @@@@@@@@@@ : '+sbq.Subscription_Total__c);
                              
                              if(sbq.Subscription_Discount_Total__c!=null)
                                SubscriptionDiscTotal += sbq.Subscription_Discount_Total__c;
                              if(sbq.Subscription_Total__c!=null)
                                SubscriptionTotal += sbq.Subscription_Total__c;
                            }
          
                          }//End Of IF
                        }//End Of FOR   
                      }//End Of upsell Loop
                      
                      system.debug('####### SubscriptionDiscTotal 111 ##########: '+SubscriptionDiscTotal );
                      system.debug('####### SubscriptionTotal 111 ##########: '+SubscriptionTotal );
                      //Begin of Prior Oppty loop
                      for(Opportunity opp :mapAccIdAndRenewalOpptys.get(accountId)){
                        if(opp.CloseDate >= CloseDateOfRenewal && opp.iswon==true){
                        
                        if(MapOppAndPrimaryQuote.containskey(opp.id)){
                            SBQQ__Quote__c sbq = MapOppAndPrimaryQuote.get(opp.id);
                            
                            system.debug('@@@@@@@@@@@ sbq.Subscription_Discount_Total__c @@@@@@@@@@ : '+sbq.Subscription_Discount_Total__c);
                            system.debug('@@@@@@@@@@@ sbq.Subscription_Total__c @@@@@@@@@@ : '+sbq.Subscription_Total__c);
                            
                            //Added below IF Loop by Jade on 20th June 2016
                            //Copying the Prior_Blended_Discount__c value on every related upsell opportunity from it's Prior Opportunity [Prior Oppty --> New Business Or Renewal]
                            if(!listOfUpsellsToBeUpdated.isEmpty() && sbq.Subscription_Total__c != 0){
                                for(SBQQ__Quote__c upsellQt : listOfUpsellsToBeUpdated){
                                    if(!UpsellQuoteIds.contains(upsellQt.id)){
                                        UpsellQuoteIds.add(upsellQt.id);
                                        upsellQt.Prior_Blended_Discount__c = (sbq.Subscription_Discount_Total__c/sbq.Subscription_Total__c)*100;
                                    }
                                }
                            }
                            
                            if(sbq.Subscription_Discount_Total__c!=null)
                              SubscriptionDiscTotal += sbq.Subscription_Discount_Total__c;
                            if(sbq.Subscription_Total__c!=null)
                              SubscriptionTotal += sbq.Subscription_Total__c;
                              
                            break;
                        }

                        }//End Of IF
                      }//End Of FOR   
                      //End of Prior Oppty Loop
                      system.debug('####### SubscriptionDiscTotal 2 ##########: '+SubscriptionDiscTotal );
                      system.debug('####### SubscriptionTotal 2 ##########: '+SubscriptionTotal );
                      
                      if(SubscriptionTotal != 0){
                        tempQuote.Prior_Blended_Discount__c = (SubscriptionDiscTotal/SubscriptionTotal)*100;
                      }
                      
                      system.debug('####### tempQuote.Prior_Blended_Discount__c ##########: '+tempQuote.Prior_Blended_Discount__c);  
                      
                    }//End Of If
                  }//End of IF
                }//End of IF
              }//End Of FOR
            }//End Of IF
            
            //Adding Renewal Quote being processed in a list to be updated
            listOfQuotesToBeReturned.add(tempQuote);
            
            //Added this if loop in 20th June 2016 by Jade
            //Adding Related Upsell Quotes in a list to be updated
            if(!listOfUpsellsToBeUpdated.isEmpty()){
                for(SBQQ__Quote__c upsellQt : listOfUpsellsToBeUpdated){
                    listOfQuotesToBeReturned.add(upsellQt);
                }
            }
          // Clearing the list of Upsell Quotes immediately after adding all the Quotes in the Final list being returned
          listOfUpsellsToBeUpdated.clear();
          }//End Of IF
          
        }//End Of FOR
      }//End of IF
      
      //For Upsells being closed WITHOUT a Renewal Quote on related Renewal Opportunity
      else if(!ListOfUpsellQuotes.isEmpty()){
        for(SBQQ__Quote__c upsellqt : ListOfUpsellQuotes){
            //getting the Prior Opportunity Id of the Upsell Oppty
            if(mapOppIdAndPriorOpportunity.containsKey(upsellqt.SBQQ__Opportunity2__r.Prior_Opportunity__r.id)){
                priorOfUpsellOpptyId = mapOppIdAndPriorOpportunity.get(upsellqt.SBQQ__Opportunity2__r.Prior_Opportunity__r.id).id;
            }//End of IF
            //Getting the Primary Quote of the prior opportunity
            if(MapOppAndPrimaryQuote.containsKey(priorOfUpsellOpptyId)){
                SBQQ__Quote__c priorPrimaryQuote = MapOppAndPrimaryQuote.get(priorOfUpsellOpptyId);
                
                System.Debug('@@@@@@@@@@@ priorPrimaryQuote.Subscription_Discount_Total__c : '+priorPrimaryQuote.Subscription_Discount_Total__c);
                
                System.Debug('@@@@@@@@@@@ priorPrimaryQuote.Subscription_Total__c : '+priorPrimaryQuote.Subscription_Total__c);
                
                upsellqt.Prior_Blended_Discount__c = (priorPrimaryQuote.Subscription_Discount_Total__c/priorPrimaryQuote.Subscription_Total__c)*100;
                
                listOfQuotesToBeReturned.add(upsellQt);
                
            }//End of IF
        }//End of FOR
      }//End of Else-If
      
    }//End of MAIN IF
    return listOfQuotesToBeReturned;
  }//End of Method calculateYTDBlendedDiscount()
   
  //Method to carry forward the blended discount from prior opportunity to current quote [Upsell/Renewal]
  //Added on 19th Sep 2016
  //Author: Jade Global, Inc.
  public static void populatePriorBlendedDiscoutFieldOnRenewalAndUpsellQuote(List<SBQQ__Quote__c> newQuotesList){
      set<string> setOfOpptyIds = new set<string>();
      list<Opportunity> OpptyAndPriorOpptys = new list<Opportunity>();
      Map<id,Opportunity> MapOpptyWithPriorOppty = new Map<id,Opportunity>();
      
      if(!newQuotesList.isEmpty()){
          for(SBQQ__Quote__c qt : newQuotesList){
              if(qt.SBQQ__Opportunity2__c != null){
                  setOfOpptyIds.add(qt.SBQQ__Opportunity2__c);
              }//End of IF
          }//End of FOR          
          
          if(!setOfOpptyIds.isEmpty()){
             
              OpptyAndPriorOpptys = [SELECT id,Name,Prior_Opportunity__c,Prior_Opportunity__r.Blended_Discount__c FROM Opportunity WHERE id IN:setOfOpptyIds];
              
              if(!OpptyAndPriorOpptys.isEmpty()){
                  for(Opportunity opp: OpptyAndPriorOpptys){
                      if(!MapOpptyWithPriorOppty.containsKey(opp.id)){
                          MapOpptyWithPriorOppty.put(opp.Id,opp);
                      }//End of IF
                  }//End of FOR
              }//End of IF
              
              if(!MapOpptyWithPriorOppty.isEmpty()){         
                  for(SBQQ__Quote__c Q : newQuotesList){
                      if(MapOpptyWithPriorOppty.containsKey(Q.Opportunity_ID__c)){
                          Double priorBlendedDisc = MapOpptyWithPriorOppty.get(Q.Opportunity_ID__c).Prior_Opportunity__r.Blended_Discount__c;
                          Q.Prior_Blended_Discount__c = priorBlendedDisc == null ? 0 : priorBlendedDisc;
                      }//End of IF
                  }//End of FOR  
              }//End of IF
              
          }//End of IF
      }//End of IF
  }//End of populatePriorBlendedDiscoutFieldOnRenewalAndUpsellQuote()
    
}//End of Class YTDBlendedDiscountCalculator