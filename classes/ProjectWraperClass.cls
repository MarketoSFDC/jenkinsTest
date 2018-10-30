public class ProjectWraperClass {

    public class Entities {
        public String id;
        public Double C_Completehours;
        public String C_CloseNotes;
        public String C_ProjectEndDate;
        public string C_120overLPLastTimesheetDate;
        public String C_AccountName;
        public string C_AccountType;
        public string C_AccountAccountOwner;
        public string C_AccountEngagementManager;
        public Currvalue ActualCost;
        public Duration ActualDuration;

        public ActualEffort ActualEffort;
        public Decimal C_ActualEffortH;
        public String ActualEndDate;
        public Double C_ActualREV;
        public Currvalue ActualRevenue;
        public String ActualStartDate;
        public Double C_BacklogHours;
        public Currvalue C_RevenueBacklog;
        public Boolean Billable;
       // public Double C_BudgetRevenue;
        public String C_BusinessUnit;
        public string C_CAMOwner;
        public String C_CloseWonDate;
        public String ClosingNotes;
        public Currvalue CostBalance;
        public CreatedBy CostCurrencyType;
        public string C_LastGreenDate;
        public CreatedBy C_BaselineCaptured;
        public Currvalue CostVariance;
        public CreatedBy CreatedBy;
        public String CreatedOn;
        public String C_CRMSystem;
        public String C_CSMEmail;
        public String C_DealType;
        public CreatedBy C_Department;
        public String Description;
        public String DueDate;
        public ActualEffort Duration;
        public string C_EngagementManagerEmail;
        public CreatedBy C_EnterpriseHealth;
        public CreatedBy C_ExcessHoursRequested;
        public CreatedBy C_EXPExpirationNotice;
        public Currvalue PlannedRevenue;
        public Boolean C_ExtensionApproved;
        public CreatedBy C_ExtensionReason;
        public Currvalue FixedCost;
        public Currvalue FixedPrice;
        public String SYSID;
        public Boolean C_IncompleteExpired;
        public Double C_clzV2_IntacctComplete;
        public CreatedBy C_clzV2_IntacctActiveStatus;
        public Boolean C_clzV2_IntacctShouldsyncWorkItem;
        public Boolean C_clzV2_IntacctIsfirstlevel;
        public Boolean C_clzV2_IsMilstoneIntacct;
        public string C_clzV2_IntacctIsSynced;
        public CreatedBy C_clzV2_IntacctItemTypeWorkItem;
        public CreatedBy C_clzV2_IntacctMainCustomer;
        public string C_clzV2_Intacctprojectcurrency;
        public CreatedBy C_clzV2_IntacctTaskStatus;
        public string C_IntacctCustomerIDProj;
        public CreatedBy C_clzV2_IntacctDepartmentProject;
        public string C_IntacctEntity;
        public CreatedBy C_clzV2_IntacctProjectCategory;
        public string C_IntacctProjectLocation;
        public CreatedBy C_clzV2_IntacctProjectStatus;
        public CreatedBy C_clzV2_IntacctProjectType;
        public string C_clzV2_IntacctSalesOrderID;
        public CreatedBy Pending;
        public String InternalId;
        public Boolean C_Investment;
        public Boolean C_InvestmentProject;
        public CreatedBy C_InvestmentProjectType;
        public ActualEffort PendingTimeTrackingEffort;
        public Duration C_pendingtimesubmitted;
        public CreatedBy C_InvestmentReason;
        public CreatedBy C_InvoiceMethod;
        public String EntityType;
        public CreatedBy C_SMBProblemCategory;
        public String ProjectGoals;
        public string C_LastENThealthupdate;
        public string C_LastExtensionApprovalDate;
        public string C_LastRedIdentifiedDate;
        public string C_RedYellowDate;
        public CreatedBy C_LastSMBHealthUpdateby;
        public CreatedBy LastUpdatedBy;
        public Double C_ItemRate;
        public String LastUpdatedOn;
        public CreatedBy C_LaunchPackCoordinator;
        public String C_LaunchPackExpirationDate2;
        public CreatedBy Manager;
        public String C_MLMSubscriptionStartDate;
        public String Name;
        public String C_OpportunityID;
        public String C_OpportunityName;
        public String C_OpportunityNumber;
        public String C_AccountOwner;
        public String C_AccountOwnerEmail;
        public string C_OpportunityOwnerRole;
        public CreatedBy C_OpportunityType;
        public CreatedBy Parent;
        public CreatedBy ParentProject;
        public string C_PartnerName;
        public string C_PMEmail;
        public String C_PrimaryCustomerContact;
        public String C_PrimaryCustomerContactEmail;
        public CreatedBy Project;
        public string C_SMBChgReason;
        public CreatedBy C_ProjectClass;
        public String C_ProjectFamily;
        public string C_SMBHealthAuditTrail;
        public CreatedBy ProjectManager;
        public String C_ProjectManagerEmail;
        public Boolean C_SuspendEmail;
        public CreatedBy C_ProjectState;
        public CreatedBy ProjectType;
        public string C_PurchaseOrderNumber;
        public String C_QuoteNumber;
        public Boolean Reportable;
        public string C_RevRecNotes;
        public Currvalue RevenueBalance;
        public CreatedBy C_RevenueBaselineStatus;
        public Currvalue C_RevOpportunityValue;
        public CreatedBy C_RevRecMethod;
        public String C_ServiceNotes;
        public string C_SFDCEdition;
        public String C_InitialPM;
        public String C_SMBProjectGroup;
        public CreatedBy C_ProjectHealth;
        public string C_SOWExpiration;
        public Duration C_SOWHrs;
        public Duration C_SOWHrsActHrDiff;
        public Duration C_SOWWorkDiff;
        public CreatedBy C_SOWOwner;
        public Currvalue C_SOWREV;
        public Currvalue C_SOWREVExpRevDiff;
        public CreatedBy C_SprintType;
        public string C_StallDate;
        public String C_StalledOnHoldReason;
        public Double C_StandardConsultantRate;
        public String StartDate;//
        public CreatedBy State;
        public CreatedBy TrackStatus;
        public string C_SubContractorEmailID;
        public string C_SubContractorName;
        public string C_SubcontractorPONumber;
        public CreatedBy C_SubContractorType;
        public Boolean FloatingTask;
        public Currvalue TotalEstimatedCost;
        public Currvalue C_TotalServicesOpptyAmount;
        public String C_UtilCalc;
        public ActualEffort Work;
        public CreatedBy C_WorkBaselineStatus;
        public CreatedBy C_WorkItemStatus;
        public ActualEffort WorkVariance;
        public Double C_Workh;
        public Double C_WorkHours; 
        public string C_AccountID;
    }

    public class Paging {
        public Integer ffrom;
        public Integer llimit;
        public Boolean hasMore;
    }

    public List<Entities> entities;
    public Paging paging;

    public class Duration {
        public String unit;
        public Double value;
        public String durationType;
    }

    public class CreatedBy {
        public String id;
    }

    public class ActualEffort{
        public String unit;
        public Double value;
    }
    
    public class Currvalue{
        public String ycurrency;
        public Double value;
    }

    
    public static ProjectWraperClass parse(String json) {
        system.debug('----json---------'+(ProjectWraperClass) System.JSON.deserialize(json, ProjectWraperClass.class));
        return (ProjectWraperClass) System.JSON.deserialize(json, ProjectWraperClass.class);
    }
    
}