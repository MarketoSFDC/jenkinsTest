@isTest
public class TestTrigger_Survey{
     static testmethod void mytest(){

         Account acc = new Account(name ='TestACCCC');
         insert acc;
                  Contact cc = new Contact(Firstname ='TestContact',Lastname ='TestContact', email = 'test@test.com',AccountId = acc.id);
         insert cc;
         
         List<QualtricsSurvey__c>  qc1 = new List<QualtricsSurvey__c>();
              qc1.add(new QualtricsSurvey__c(NPS_Type__c='90 Days Survey',
                    Email__c='ayub.a@grazitti.com',
                    Q1__c='1.  Based on your first 90 days as a Marketo customer, how likely are you to recommend Marketo to a friend or colleague?</span></span>',
                    Answer1__c='71.a.  Please tell us the primary reason you gave us this score. </span></span>=</b>',
                    Q2__c='2.  Please rate how well you were able to achieve the goals that you set for the first 90 days?</span></span></o=p></p>',
                    Answer2__c='12.a. </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q3__c='3.  Relative to your original expectations, please rate the amount of effort/resources required to use Marketo in the first 90 days.</span></span>',
                    Answer3__c='63.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q4__c='4.  Based on your achievements in the first 90 days, how confident are you in meeting your first year goals/objectives?</span></span>',
                    Answer4__c='54.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q5__c='5.  I am connected/engaged with someone at Marketo who is ultimately accountable for my long term success.</span></span>',
                    Answer5__c='65.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q6__c='6.  Please rate your satisfaction with Customer Support during your first 90 days.   </span></span>',
                    Answer6__c='46.a. </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q7__c='7.  Please rate your satisfaction with </span>Training, </span>Education and Learning during your first 90 days.</span></span>',
                    Answer7__c='67.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q8__c='8.  Please rate your satisfaction with Consulting/Enablement during your first 90 days.</span></span>',
                    Answer8__c='78.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q9__c='9.  Please rate how satisfied you are with the Marketo product.  </span></span>',
                    Answer9__c='69.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q10__c='10.  If there was one thing we could have done differently in the first 90 days, what would it be?</span></font>',
                    Answer10__c='personal issue took our manager off work for a bit - we met with someone in the interim but it screwup up our mojo - meanwhile our own struggles with getting SFDC off the ground. Wish we would have been more proactive about what we could be doing without SFDC integration.',
                    Contact__c= cc.Id,
                    CAM_Owner__c='',
                    Account_Name__c='')
                    );
          insert qc1;
          
         List<QualtricsSurvey__c>  qc2 = new List<QualtricsSurvey__c>();
         qc2.add(new QualtricsSurvey__c(NPS_Type__c='90 Days Survey',
                Email__c='',
                Q1__c='1.  Based on your first 90 days as a Marketo customer, how likely are you to recommend Marketo to a friend or colleague?</span></span>',
                Answer1__c='71.a.  Please tell us the primary reason you gave us this score. </span></span>=</b>',
                Q2__c='2.  Please rate how well you were able to achieve the goals that you set for the first 90 days?</span></span></o=p></p>',
                Answer2__c='12.a. </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q3__c='3.  Relative to your original expectations, please rate the amount of effort/resources required to use Marketo in the first 90 days.</span></span>',
                Answer3__c='63.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q4__c='4.  Based on your achievements in the first 90 days, how confident are you in meeting your first year goals/objectives?</span></span>',
                Answer4__c='54.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q5__c='5.  I am connected/engaged with someone at Marketo who is ultimately accountable for my long term success.</span></span>',
                Answer5__c='65.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q6__c='6.  Please rate your satisfaction with Customer Support during your first 90 days.   </span></span>',
                Answer6__c='46.a. </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q7__c='7.  Please rate your satisfaction with </span>Training, </span>Education and Learning during your first 90 days.</span></span>',
                Answer7__c='67.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q8__c='8.  Please rate your satisfaction with Consulting/Enablement during your first 90 days.</span></span>',
                Answer8__c='78.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q9__c='9.  Please rate how satisfied you are with the Marketo product.  </span></span>',
                Answer9__c='69.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q10__c='10.  If there was one thing we could have done differently in the first 90 days, what would it be?</span></font>',
                Answer10__c='personal issue took our manager off work for a bit - we met with someone in the interim but it screwup up our mojo - meanwhile our own struggles with getting SFDC off the ground. Wish we would have been more proactive about what we could be doing without SFDC integration.',
                Contact__c= cc.Id,
                CAM_Owner__c='',
                Account_Name__c='')
                );
                insert qc2;
         
        
    }
    static testmethod void mytest2(){

         Account acc = new Account(name ='TestACCCC');
         insert acc;
                  Contact cc = new Contact(Firstname ='TestContact',Lastname ='TestContact', email = 'test@test.com',AccountId = acc.id);
         insert cc;
         
         List<QualtricsSurvey__c>  qc1 = new List<QualtricsSurvey__c>();
              qc1.add(new QualtricsSurvey__c(NPS_Type__c='Marketo NPS Survey',
                    Email__c='ayub.a@grazitti.com',
                    Q1__c='1.  Based on your first 90 days as a Marketo customer, how likely are you to recommend Marketo to a friend or colleague?</span></span>',
                    Answer1__c='71.a.  Please tell us the primary reason you gave us this score. </span></span>=</b>',
                    Q2__c='2.  Please rate how well you were able to achieve the goals that you set for the first 90 days?</span></span></o=p></p>',
                    Answer2__c='12.a. </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q3__c='3.  Relative to your original expectations, please rate the amount of effort/resources required to use Marketo in the first 90 days.</span></span>',
                    Answer3__c='63.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q4__c='4.  Based on your achievements in the first 90 days, how confident are you in meeting your first year goals/objectives?</span></span>',
                    Answer4__c='54.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q5__c='5.  I am connected/engaged with someone at Marketo who is ultimately accountable for my long term success.</span></span>',
                    Answer5__c='65.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q6__c='6.  Please rate your satisfaction with Customer Support during your first 90 days.   </span></span>',
                    Answer6__c='46.a. </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q7__c='7.  Please rate your satisfaction with </span>Training, </span>Education and Learning during your first 90 days.</span></span>',
                    Answer7__c='67.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q8__c='8.  Please rate your satisfaction with Consulting/Enablement during your first 90 days.</span></span>',
                    Answer8__c='78.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q9__c='9.  Please rate how satisfied you are with the Marketo product.  </span></span>',
                    Answer9__c='69.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                    Q10__c='10.  If there was one thing we could have done differently in the first 90 days, what would it be?</span></font>',
                    Answer10__c='personal issue took our manager off work for a bit - we met with someone in the interim but it screwup up our mojo - meanwhile our own struggles with getting SFDC off the ground. Wish we would have been more proactive about what we could be doing without SFDC integration.',
                    CAM_Owner__c='',
                    Account_Name__c='')
                    );
          insert qc1;
          
         List<QualtricsSurvey__c>  qc2 = new List<QualtricsSurvey__c>();
         qc2.add(new QualtricsSurvey__c(NPS_Type__c='Marketo NPS Survey',
                Email__c='',
                Q1__c='1.  Based on your first 90 days as a Marketo customer, how likely are you to recommend Marketo to a friend or colleague?</span></span>',
                Answer1__c='71.a.  Please tell us the primary reason you gave us this score. </span></span>=</b>',
                Q2__c='2.  Please rate how well you were able to achieve the goals that you set for the first 90 days?</span></span></o=p></p>',
                Answer2__c='12.a. </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q3__c='3.  Relative to your original expectations, please rate the amount of effort/resources required to use Marketo in the first 90 days.</span></span>',
                Answer3__c='63.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q4__c='4.  Based on your achievements in the first 90 days, how confident are you in meeting your first year goals/objectives?</span></span>',
                Answer4__c='54.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q5__c='5.  I am connected/engaged with someone at Marketo who is ultimately accountable for my long term success.</span></span>',
                Answer5__c='65.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q6__c='6.  Please rate your satisfaction with Customer Support during your first 90 days.   </span></span>',
                Answer6__c='46.a. </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q7__c='7.  Please rate your satisfaction with </span>Training, </span>Education and Learning during your first 90 days.</span></span>',
                Answer7__c='67.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q8__c='8.  Please rate your satisfaction with Consulting/Enablement during your first 90 days.</span></span>',
                Answer8__c='78.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q9__c='9.  Please rate how satisfied you are with the Marketo product.  </span></span>',
                Answer9__c='69.a.  </span></span>Please tell us the primary reason you gave us this score. </span>=</b>',
                Q10__c='10.  If there was one thing we could have done differently in the first 90 days, what would it be?</span></font>',
                Answer10__c='personal issue took our manager off work for a bit - we met with someone in the interim but it screwup up our mojo - meanwhile our own struggles with getting SFDC off the ground. Wish we would have been more proactive about what we could be doing without SFDC integration.',
                Contact__c= cc.Id,
                CAM_Owner__c='',
                Account_Name__c='')
                );
                insert qc2;
         
        
    }
}