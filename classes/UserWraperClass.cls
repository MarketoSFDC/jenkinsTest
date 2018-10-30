public class UserWraperClass {
        public class Entities {
        public String id;
        public ClzCurrency RevenueRegularRate;
        public C_ContractorType C_ContractorType;
        public ClzCurrency CostOvertimeRate;
        public ClzCurrency CostRegularRate;
        public C_ContractorType CreatedBy;
        public String CreatedOn;
        public C_ContractorType C_Department;
        public C_ContractorType DirectManager;
        public String Email;
        public String C_EmployeeID;
        public String FirstName;
        public String C_HireDate;
        public Boolean C_IncludeinUtilizationCalc;
        public Boolean C_IncludetoUtilizationReport;
        public String C_clzV2_IntacctEmployeeID;
        public C_ContractorType C_clzV2_IntacctDepartmentUser;
        public C_ContractorType C_clzV2_IntacctLocationUser;
        public Double C_clzV2_IntacctTimesheetsQuantity;
        public String InternalId;
        public String EntityType;
        public C_ContractorType JobTitle;
        public C_ContractorType Language;
        public String LastLogin;
        public String LastName;
        public String C_LastTimesheetDate;
        public C_ContractorType LastUpdatedBy;
        public String LastUpdatedOn;
        public Double C_MaxUtilizationHours;
        public String DisplayName;
        public string Profile;
        public Boolean SubscribeToProjectNotifications;
        public C_ContractorType Region;
        public C_ContractorType State;
        public Double C_TargetUtilizationHours;
        public C_ContractorType C_TeamLead;
        public C_ContractorType TimeZone;
        public Boolean C_TimesheetRequired;
        public String UserName;
        public C_ContractorType LicenseType;
        public string C_UtilEndDate;
        public string C_UtilStartDate;
        public C_ContractorType C_UtilTeam;
        public string C_EmployeeEndDate;
    }

    public class Paging {
        public Integer ffrom;
        public Integer flimit;
        public Boolean hasMore;
    }
    

    public class C_ContractorType {
        public String id;
    }
    
    public class ClzCurrency {
        public String ccurrency;
        public Decimal value;
    }

    public List<Entities> entities;
    public Paging paging;

    
    public static UserWraperClass parse(String json) {
        return (UserWraperClass) System.JSON.deserialize(json, UserWraperClass.class);
    }
    
}