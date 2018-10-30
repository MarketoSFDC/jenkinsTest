public Class jiveUser {
    Public String Jive_ID ; //JIve Mandatory fields
    Public String External_ID ;
    Public String Contact_ID ;
    Public String Account_ID ;        
    Public String Federated ;
    Public String UserName ;
    Public String Company ;     
    Public String AltEmail ;  

    Public String First_Name ;//Contact fields started
    Public String jive_location;
    Public String jive_state;
    Public String jive_points;
    Public String Last_Name ;
    Public String Email ;
    Public String NewEmail;
    Public String Munchkin_ID ;
    Public String title ;
    Public String Phone ;
    Public String POD ;
    Public String Jive_Street;
    Public String MobilePhone ;
    Public String Twitter_Username ;
    Public String jive_city;
    Public String jive_country;
    Public String jive_zip;
    Public String jive_Certification;
    Public String jive_Expertise;
    Public String jive_Accomplishments;
    Public String Jive_Entitlement;
    Public String Jive_Asset;
    Public String Jive_IsAUthCon;
    Public String Jive_SupportLevel;
    
    Public String Type ; //account fields started
    Public String PartnerType ;
    Public String CAMowner ;
    Public String EngagementMgrOwner ;
    Public String AccountSpendGrade ;
    Public String SalesRegion ;
    Public String SupportRegion ;//Entitlement fields started
    Public String NSE ;
    Public String NSM ;
    Public String TAM ;

    Public String Language ; 
    Public String Website;
    Public String Country;

    Public jiveUser() {
        First_Name = ''; Last_Name=''; Email = ''; AltEmail = ''; External_ID = ''; Contact_ID  = ''; title = ''; Phone = ''; 
        Company = ''; Account_ID = ''; Munchkin_ID = ''; Jive_ID = ''; Federated = ''; Username = ''; MobilePhone = ''; Twitter_Username='';   
        Type =''; PartnerType=''; CAMowner=''; EngagementMgrOwner=''; AccountSpendGrade=''; SalesRegion =''; SupportRegion='';
        NSE=''; NSM='';  TAM=''; Language =''; Website = ''; Country = ''; jive_Certification ='';jive_Expertise='';jive_Accomplishments='';
        Jive_Asset ='';Jive_IsAUthCon='';Jive_SupportLevel='';jive_location =''; jive_state =''; jive_points = '0'; NewEmail =''; POD =''; Jive_Street =''; jive_city =''; jive_country =''; jive_zip =''; Jive_Entitlement ='';
    }
}