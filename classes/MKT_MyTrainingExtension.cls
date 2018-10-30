/****************************************************
Class Name: MKT_MyTrainingExtension
Author: Vrp
Created Date: 2/13/2013
Usage: This controller used for display all assigned learning objects for current user, also gives the chance to play courses.
*****************************************************/
public without sharing class MKT_MyTrainingExtension {

	public class DebugException extends Exception {}
	public NewCourses LeftLandingCourse {get;set;}
	public NewCourses CenterLandingCourse {get;set;}
	public NewCourses RightLandingCourse {get;set;}
	public Boolean CalView { get; set; }
	public MKT_CalendarController calendar { get; set; }
	public Boolean Show_module_in_new_window { get; set; }
	public Integer CartCount { get; set; }
	public Id EventIdDetails {
		get;
		set;
	}
	public Id ClassIdDetails {
		get;
		set;
	}

	public lmsilt__Event__c EventDetails {
		get;
		set;
	}
	public List <lmsilt__Class__c> ClassesList {
		get;
		set;
	}
	public List <lmsilt__Session__c> SessionsList {
		get;
		set;
	}
	public lmsilt__Roster__c Roster {
		get;
		set;
	}
	public List <lmsilt__Material__c> MaterialsList {
		get;
		set;
	}
	public Integer MaterialsSize {
		get;
		set;
	}
	public Integer SessionsDetailSize {
		get;
		set;
	}
	public Integer ClassSize {
		get;
		set;
	}
	public map <Id, String> idLO_DescLO {
		get;
		set;
	}

	public map < Id, Boolean> PreReqMap {
		get;
		set;
	}

	public Id AssignId {
		get;
		set;
	}

	private String ClassId;
	public String getClassId() {
		return this.ClassId;
	}

	public void setClassId(String ClassId) {
		this.ClassId = ClassId;
	}


	public Double preProgress;
	public Boolean preProgressZero = false;
	public Boolean NotAllComplete = false;
	public String preTitle = 'Start';
	public String preType;
	public String preDesc;
	public String preDescSeq;
	public Decimal preSequence;
	public Decimal preSequenceR;
	public Boolean EnforceSequence;
	public Boolean EnforceSequenceLP;
	public Boolean EnforceSequenceCu;
	public String tmpTitle;
	public Integer i = 0;

	public Id ActId {
		get;
		set;
	}

	public lmsilt__Development_Plan_Task__c SelectedTask {
		get;
		set;
	}
	public lmscons__Transcript_Line__c SelectedTranscriptLine {
		get;
		set;
	}
	public Id TaskId {
		get;
		set;
	}
	public Id TrLineId {
		get;
		set;
	}

	/*
	/Constructor
	*/
	public MKT_MyTrainingExtension() {
		idLO_DescLO = new map < Id, String> ();
		//GetNewCoursesOnThePage();
		Show_module_in_new_window = true;
		if (!HelperWithoutSharing.isAccessUser()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.MKT_AccessDeniedError));
		}
		else {
			if (ApexPages.currentPage().getParameters().get('calView') != NULL) {
				calView();
			}
			else {
				CalView = false;
				GenerateMyTraining();
			}

		}
	}
	/*
	/Show Calendar
	*/
	public void calView() {
		CalView = true;
		calendar = new MKT_CalendarController();
		calendar.showAssignmentSession = true;
		calendar.ShowScreen();
	}

	/*
	/Navigation on a calendar
	*/
	public void ThisMonth() {
		calendar.ThisMonth();
	}

	public void MonthBack() {
		calendar.MonthBack();
	}

	public void MonthForward() {
		calendar.MonthForward();
	}

	public Integer SelectedTab {
		get;
		set;
	}

	public List <MyTrainingExtension.CurriculumEntry> TrainingList2 {
		get;
		set;
	}

	//Filling Landing section (not used)
	public void GetNewCoursesOnThePage () {
		List<MKT_CourseOnThePage__c> NewCoursesList = [SELECT Id, Name, Description__c, Course__c, Image__c, Page__c, Position__c FROM MKT_CourseOnThePage__c WHERE Page__c = 'My Learning' AND Image__c != NULL AND Position__c != NULL];
		for (MKT_CourseOnThePage__c NewCourse :NewCoursesList) {
			if (NewCourse.Position__c == 'Left' && LeftLandingCourse == NULL) {
				LeftLandingCourse = new NewCourses(NewCourse);
			}
			else if (NewCourse.Position__c == 'Center' && CenterLandingCourse == NULL) {
				CenterLandingCourse = new NewCourses(NewCourse);
			}
			else if (NewCourse.Position__c == 'Right' && RightLandingCourse == NULL) {
				RightLandingCourse = new NewCourses(NewCourse);
			}
		}
	}

	public class NewCourses {
		public String Position {get;set;}
		public String Title {get;set;}
		public String Image {get;set;}
		public String EventId {get;set;}
		public String Description {get;set;}

		public NewCourses(MKT_CourseOnThePage__c NewCourse) {
			Position = NewCourse.Position__c;
			Title = NewCourse.Name;
			Image = 'img/' + NewCourse.Image__c;
			EventId = NewCourse.Course__c;
			Description  = NewCourse.Description__c;
		}
	}

	//Filling mytraining structure(using MyTrainingExtension class)
	public PageReference GenerateMyTraining() {
		SelectedTab = 1;
		CartCount = HelperWithoutSharing.getCurrentCartItemsCount();
		MyTrainingExtension mte = new MyTrainingExtension();
		TrainingList2 = mte.TrainingList;
		idLO_DescLO = mte.idLO_DescLO;
		PreReqMap = new map < Id, boolean> ();
		PreReqMap = mte.PreReqMap;
		return null;
	}

	//-----------------------------------------------------------------------
	//--                          TEST METHODS                            ---
	//-----------------------------------------------------------------------

		private static testMethod void testPrerequisitesMKT_MyTrainingExtension2() {

		lmscons__LMS_Consumer_Settings__c LCS = new lmscons__LMS_Consumer_Settings__c(lmscons__Default_License_Period__c='Months', lmscons__Default_License_Term__c = 12, lmscons__Cornerstone_Callback_URL__c='dep', lmscons__CyberUSecretSignKey__c='dep');
		insert LCS;


		lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
		insert tr;

		lmscons__Training_Content__c TC = new lmscons__Training_Content__c(lmscons__Description__c = 'TEST', lmscons__Cornerstone_ID__c ='tc1');
		lmscons__Training_Content__c TCD = new lmscons__Training_Content__c();
		insert new List<lmscons__Training_Content__c> {TC,TCD};

		Date d = Date.valueOf(system.now());
		lmscons__Training_Content_License__c tcl = new lmscons__Training_Content_License__c(lmscons__Training_Content__c=TC.Id, lmscons__Expiration_Date__c=d, lmscons__Seats__c = 100);
		insert tcl;
		lmscons__Training_User_License__c tul = new lmscons__Training_User_License__c( lmscons__Content_License__c = tcl.Id, lmscons__User__c = UserInfo.getUserId(), lmscons__Cornerstone_ID__c = 'af' );
		insert tul;

		lmscons__Quiz__c q= new lmscons__Quiz__c(lmscons__Description__c = 'TEST');
		lmscons__Quiz__c q2 = new lmscons__Quiz__c();
		lmscons__Quiz__c q3 = new lmscons__Quiz__c(lmscons__Description__c = 'TEST');
		insert new List<lmscons__Quiz__c> {q,q2,q3};

		lmscons__Training_Content__c tcQ2 = new lmscons__Training_Content__c(lmscons__Quiz__c=q2.Id,lmscons__Title__c = 'Training me', lmscons__Cornerstone_ID__c = 'af', lmscons__Description__c = 'TEST');
		insert tcQ2;

		lmscons__Prerequisites__c preQuiz1 = new lmscons__Prerequisites__c(lmscons__Quiz__c = q2.Id, lmscons__Quiz_Child__c = q.Id);
		insert  preQuiz1;

		lmsilt__Event__c e2 = new lmsilt__Event__c( lmsilt__Languages__c = 'English', Name='Test Event');
		insert e2;
		lmsilt__Event__c e4 = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
		insert e4;

		lmscons__Prerequisites__c preEvent1 = new lmscons__Prerequisites__c(lmsilt__Event__c = e2.Id, lmscons__Quiz_Child__c = q.Id);
		insert preEvent1;

		lmscons__Training_Content__c tc2 = new lmscons__Training_Content__c(lmsilt__Event__c=e2.Id,lmscons__Title__c = 'Training me', lmscons__Cornerstone_ID__c = 'af', lmscons__Description__c = 'TEST');
		insert tc2;

		lmsilt__Meeting__c m = new lmsilt__Meeting__c(lmsilt__Meetingkey__c='123');
		insert m;

		lmsilt__Class__c cls = new lmsilt__Class__c(lmsilt__Event__c = e2.Id);
		insert cls;

		lmsilt__Material__c matir = new lmsilt__Material__c(lmsilt__Sequence__c = 'after', lmsilt__Class__c = cls.Id);
		insert matir;

		lmsilt__Material__c matir2 = new lmsilt__Material__c(lmsilt__Sequence__c = 'before', lmsilt__Class__c = cls.Id);
		insert matir2;

		//lmsilt__Session__c ss = new lmsilt__Session__c(lmsilt__Meeting__c = m.Id, lmsilt__ILT_vILT__c = 'vILT', lmsilt__Meeting_Type__c='GoToTraining', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(2), lmsilt__End_Date_Time__c=system.now().addDays(3));
		//insert ss;

		lmsilt__Session__c ss2 = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(6), lmsilt__End_Date_Time__c=system.now().addDays(7));
		insert ss2;

		lmscons__Training_Path__c tp = new lmscons__Training_Path__c(Name = 'testPath', lmscons__Enforce_Curriculum_Sequence__c=true, lmscons__Description__c = 'TEST');
		insert tp;

		lmscons__Training_Path_Assignment_Progress__c tpa = new lmscons__Training_Path_Assignment_Progress__c(lmscons__Training_Path__c = tp.Id, lmscons__Transcript__c = tr.Id);
		insert tpa;

		lmscons__Training_Path__c tp2 = new lmscons__Training_Path__c(Name = 'testPath2', lmscons__Enforce_Curriculum_Sequence__c=true);
		insert tp2;

		Id RCModule = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Training_Path_Item__c' AND DeveloperName='Module' limit 1].Id;
		Id RCEvent = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Training_Path_Item__c' AND DeveloperName='Event' limit 1].Id;
		Id RCQuiz = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Training_Path_Item__c' AND DeveloperName='Quiz' limit 1].Id;

		List<lmscons__Training_Path_Item__c> ICIs = new List<lmscons__Training_Path_Item__c>();
		lmscons__Training_Path_Item__c ICI = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c=TC.Id, RecordTypeId=RCModule, lmscons__Sequence__c = 1);
		ICIs.add(ICI);

		lmscons__Training_Path_Item__c ICI2 = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c = tc2.Id ,lmsilt__Event__c = e2.Id, RecordTypeId=RCEvent, lmscons__Sequence__c = 3);
		ICIs.add(ICI2);

		lmscons__Training_Path_Item__c ICI3 = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c = tcQ2.Id ,lmscons__Quiz__c = q2.Id, RecordTypeId=RCQuiz, lmscons__Sequence__c = 2);
		ICIs.add(ICI3);
		lmscons__Training_Path_Item__c ICI4 = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c = TCD.Id, RecordTypeId=RCQuiz, lmscons__Sequence__c = 2);
		ICIs.add(ICI4);
		insert ICIs;

		lmscons__Learning_Path__c lp = new lmscons__Learning_Path__c(Name='TestLP 1', lmscons__Enforce_Sequence__c=true, lmscons__Description__c = 'TEST');
		insert lp;

		lmscons__Learning_Path__c lp2 = new lmscons__Learning_Path__c(Name='TestLP 1', lmscons__Enforce_Sequence__c=true);
		insert lp2;

		lmscons__Learning_Path_Assignment__c lpa = new lmscons__Learning_Path_Assignment__c(lmscons__Transcript__c = tr.Id, lmscons__Learning_Path__c = lp.Id);
		insert lpa;
		lmscons__Learning_Path_Assignment__c lpa2 = new lmscons__Learning_Path_Assignment__c(lmscons__Transcript__c = tr.Id, lmscons__Learning_Path__c = lp2.Id, lmscons__Learning_Path_Progress__c = 100);
		insert lpa2;


		Id RCModule3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Module' limit 1].Id;
		Id RCEvent3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Event' limit 1].Id;
		Id RCCourse3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Course' limit 1].Id;

		List<lmscons__Learning_Path_Item__c> LPIs = new List<lmscons__Learning_Path_Item__c>();
		lmscons__Learning_Path_Item__c LPI3 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmsilt__Event__c=e2.Id, RecordTypeId=RCEvent3, lmscons__Sequence__c = 1);
		LPIs.add(LPI3);
		lmscons__Learning_Path_Item__c LPI4 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Module__c=tc.Id, RecordTypeId=RCModule3, lmscons__Sequence__c = 2);
		LPIs.add(LPI4);
		lmscons__Learning_Path_Item__c LPI5 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Course__c=tp.Id, RecordTypeId=RCCourse3, lmscons__Sequence__c = 3);
		LPIs.add(LPI5);
		lmscons__Learning_Path_Item__c LPI6 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Course__c=tp2.Id, RecordTypeId=RCCourse3, lmscons__Sequence__c = 5);
		LPIs.add(LPI6);
		lmscons__Learning_Path_Item__c LPI7 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Quiz__c=q3.Id, RecordTypeId=RCModule3, lmscons__Sequence__c = 5);
		LPIs.add(LPI7);
		insert LPIs;

		lmscons__Curriculum__c cur = new lmscons__Curriculum__c(Name='Test Cur 1', lmscons__Enforce_Sequence__c = true, lmscons__Description__c = 'TEST');
		lmscons__Curriculum__c cur2 = new lmscons__Curriculum__c(Name='Test Cur 1', lmscons__Enforce_Sequence__c = true);
		insert new List<lmscons__Curriculum__c> {cur, cur2};

		lmscons__Curriculum_Assignment__c cura = new lmscons__Curriculum_Assignment__c(lmscons__Transcript__c = tr.Id, lmscons__Curriculum__c = cur.Id);
		lmscons__Curriculum_Assignment__c cura2 = new lmscons__Curriculum_Assignment__c(lmscons__Transcript__c = tr.Id, lmscons__Curriculum__c = cur2.Id, lmscons__Curriculum_Progress__c = 100);
		insert new List<lmscons__Curriculum_Assignment__c> {cura, cura2};

		LIST<lmscons__Curriculum_Item__c> CIList = new LIST<lmscons__Curriculum_Item__c>();

		Id RCModule5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Module' limit 1].Id;
		Id RCEvent5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Event' limit 1].Id;
		Id RCLP5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Learning_Path2' limit 1].Id;
		Id RCCourse5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Course' limit 1].Id;


		List<lmscons__Curriculum_Item__c> CIs = new List<lmscons__Curriculum_Item__c>();
		lmscons__Curriculum_Item__c ci = new lmscons__Curriculum_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCLP5, lmscons__Sequence__c = 1);
		CIs.add(ci);

		lmscons__Curriculum_Item__c ci2 = new lmscons__Curriculum_Item__c(lmscons__Course__c=tp.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCCourse5, lmscons__Sequence__c = 3);
		CIs.add(ci2);

		lmscons__Curriculum_Item__c ci3 = new lmscons__Curriculum_Item__c(lmscons__Module__c=tc.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCModule5, lmscons__Sequence__c = 2);
		CIs.add(ci3);

		lmscons__Curriculum_Item__c ci4 = new lmscons__Curriculum_Item__c(lmsilt__Event__c=e2.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCEvent5, lmscons__Sequence__c = 4);
		CIs.add(ci4);

		lmscons__Curriculum_Item__c ci5 = new lmscons__Curriculum_Item__c(lmscons__Quiz__c=q3.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCModule5, lmscons__Sequence__c = 5);
		CIs.add(ci5);
		insert CIs;

		lmscons__Transcript_Line__c trl_mod = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Training_Content__c = tc.Id,lmscons__Cornerstone_ID__c = 'af');
		lmscons__Transcript_Line__c trl_mod2 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Training_Content__c = tcD.Id,lmscons__Cornerstone_ID__c = 'af1');
		lmscons__Transcript_Line__c trl_quiz = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Quiz__c = q.Id,lmscons__Cornerstone_ID__c = 'af2',lmscons__Training_Content__c = tc.Id);
		lmscons__Transcript_Line__c trl_quiz2 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Quiz__c = q2.Id,lmscons__Cornerstone_ID__c = 'af3',lmscons__Training_Content__c = tc.Id);
		lmscons__Transcript_Line__c trl_event = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmsilt__Event__c = e2.Id,lmscons__Cornerstone_ID__c = 'af4',lmscons__Training_Content__c = tc.Id);
		lmscons__Transcript_Line__c trl_event2 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmsilt__Event__c = e4.Id,lmscons__Cornerstone_ID__c = 'af5',lmscons__Training_Content__c = tc.Id);
		lmscons__Transcript_Line__c trl_lp = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Learning_Path_Assignment__c  = lpa.Id,lmscons__Cornerstone_ID__c = 'af6',lmscons__Training_Content__c = tc.Id);
		lmscons__Transcript_Line__c trl_lp2 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Learning_Path_Assignment__c  = lpa2.Id,lmscons__Cornerstone_ID__c = 'af7',lmscons__Training_Content__c = tc.Id, lmscons__Learning_Path_Item__c = LPI3.Id);
		lmscons__Transcript_Line__c trl_lp3 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Learning_Path_Assignment__c  = lpa.Id,lmscons__Cornerstone_ID__c = 'af61',lmscons__Training_Content__c = tc.Id, lmscons__Learning_Path_Item__c = LPI4.Id);
		lmscons__Transcript_Line__c trl_lp4 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Learning_Path_Assignment__c  = lpa.Id,lmscons__Cornerstone_ID__c = 'af62',lmscons__Training_Content__c = tc.Id, lmscons__Learning_Path_Item__c = LPI5.Id);
		lmscons__Transcript_Line__c trl_lp5 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Learning_Path_Assignment__c  = lpa.Id,lmscons__Cornerstone_ID__c = 'af63',lmscons__Training_Content__c = tc.Id, lmscons__Learning_Path_Item__c = LPI6.Id);
		lmscons__Transcript_Line__c trl_lp6 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Learning_Path_Assignment__c  = lpa.Id,lmscons__Cornerstone_ID__c = 'af64',lmscons__Training_Content__c = tc.Id, lmscons__Learning_Path_Item__c = LPI7.Id);
		lmscons__Transcript_Line__c trl_cur = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Curriculum_Assignment__c = cura.Id,lmscons__Cornerstone_ID__c = 'af8',lmscons__Training_Content__c = tc.Id, lmscons__Curriculum_Item__c = ci.Id);
		lmscons__Transcript_Line__c trl_cur2 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Curriculum_Assignment__c = cura2.Id,lmscons__Cornerstone_ID__c = 'af9',lmscons__Training_Content__c = tc.Id );
		lmscons__Transcript_Line__c trl_cur3 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Curriculum_Assignment__c = cura.Id,lmscons__Cornerstone_ID__c = 'af91',lmscons__Training_Content__c = tc.Id, lmscons__Curriculum_Item__c = ci2.Id);
		lmscons__Transcript_Line__c trl_cur4 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Curriculum_Assignment__c = cura.Id,lmscons__Cornerstone_ID__c = 'af92',lmscons__Training_Content__c = tc.Id, lmscons__Curriculum_Item__c = ci3.Id);
		lmscons__Transcript_Line__c trl_cur5 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Curriculum_Assignment__c = cura.Id,lmscons__Cornerstone_ID__c = 'af93',lmscons__Training_Content__c = tc.Id, lmscons__Curriculum_Item__c = ci4.Id);
		lmscons__Transcript_Line__c trl_course = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Training_Path_Item__c = ICI.Id,lmscons__Cornerstone_ID__c = 'af10',lmscons__Training_Content__c = tc.Id);
		lmscons__Transcript_Line__c trl_course2 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Cornerstone_ID__c = 'af11',lmscons__Training_Content__c = tc.Id, lmscons__Training_Path_Item__c = ICI.Id);
		lmscons__Transcript_Line__c trl_course3 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Cornerstone_ID__c = 'af12',lmscons__Training_Content__c = tc.Id, lmscons__Training_Path_Item__c = ICI2.Id);
		lmscons__Transcript_Line__c trl_course4 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Cornerstone_ID__c = 'af13',lmscons__Training_Content__c = tc.Id, lmscons__Training_Path_Item__c = ICI3.Id);
		lmscons__Transcript_Line__c trl_course5 = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Cornerstone_ID__c = 'af14',lmscons__Training_Content__c = tc.Id, lmscons__Training_Path_Item__c = ICI4.Id);
		insert new List<lmscons__Transcript_Line__c> {trl_mod ,trl_mod2 ,trl_quiz ,trl_quiz2 ,trl_event , trl_event2 ,trl_course, trl_course2,trl_course3,trl_course4,trl_course5,trl_lp,trl_lp2,trl_lp3,trl_lp4,trl_lp5,trl_lp6, trl_cur,trl_cur2,trl_cur3,trl_cur4,trl_cur5 };

		Account testAcc = new Account(Name = 'test');
		insert testAcc;
		Test.startTest();
			MKT_MyTrainingExtension contr = new MKT_MyTrainingExtension();
			trl_mod.lmscons__Percent_Complete__c = 100;
			trl_mod2.lmscons__Percent_Complete__c = 10;
			trl_quiz.lmscons__Percent_Complete__c = 100;
			trl_quiz2.lmscons__Percent_Complete__c = 5;
			trl_event.lmscons__Percent_Complete__c = 100;
			trl_event.lmscons__Percent_Complete__c = 8;
			trl_lp.lmscons__Percent_Complete__c = 10;
			trl_lp2.lmscons__Percent_Complete__c = 15;
			trl_lp3.lmscons__Percent_Complete__c = 75;
			trl_lp4.lmscons__Percent_Complete__c = 89;
			trl_lp5.lmscons__Percent_Complete__c = 66;
			trl_lp6.lmscons__Percent_Complete__c = 40;
			trl_cur.lmscons__Percent_Complete__c = 100;
			trl_cur2.lmscons__Percent_Complete__c = 100;
			trl_cur3.lmscons__Percent_Complete__c = 90;
			trl_cur4.lmscons__Percent_Complete__c = 5;
			trl_cur5.lmscons__Percent_Complete__c = 6;
			trl_course.lmscons__Percent_Complete__c = 10;
			trl_course2.lmscons__Percent_Complete__c = 90;
			trl_course3.lmscons__Percent_Complete__c = 80;
			trl_course4.lmscons__Percent_Complete__c = 50;
			trl_course5.lmscons__Percent_Complete__c = 75;
			update new List<lmscons__Transcript_Line__c> {trl_mod ,trl_mod2 ,trl_quiz ,trl_quiz2 ,trl_event , trl_event2 ,trl_course, trl_course2,trl_course3,trl_course4,trl_course5,trl_lp,trl_lp2,trl_lp3,trl_lp4,trl_lp5,trl_lp6, trl_cur,trl_cur2,trl_cur3,trl_cur4,trl_cur5 };
			MKT_MyTrainingExtension contr2 = new MKT_MyTrainingExtension();
			System.assert(contr.TrainingList2.size() > 0);
			Test.stopTest();
		}

		private static testMethod void testLandingCoursesMKT_MyTrainingExtension() {
			lmsilt__Event__c e2 = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
			insert e2;
			MKT_CourseOnThePage__c CourseOnThePage1 = new MKT_CourseOnThePage__c(Description__c = 'Test', Course__c = e2.Id, Image__c = 'img.png', Page__c = 'My Learning', Position__c = 'Left');
			MKT_CourseOnThePage__c CourseOnThePage2 = new MKT_CourseOnThePage__c(Description__c = 'Test', Course__c = e2.Id, Image__c = 'img.png', Page__c = 'My Learning', Position__c = 'Center');
			MKT_CourseOnThePage__c CourseOnThePage3 = new MKT_CourseOnThePage__c(Description__c = 'Test', Course__c = e2.Id, Image__c = 'img.png', Page__c = 'My Learning', Position__c = 'Right');

			MKT_CourseOnThePage__c CourseOnThePage5 = new MKT_CourseOnThePage__c(Description__c = 'Test', Course__c = e2.Id, Image__c = 'img.png', Page__c = 'Courses', Position__c = 'Left', Type__c = 'Featured');
			MKT_CourseOnThePage__c CourseOnThePage6 = new MKT_CourseOnThePage__c(Description__c = 'Test', Course__c = e2.Id, Image__c = 'img.png', Page__c = 'Courses', Position__c = 'Center', Type__c = 'Featured');
			MKT_CourseOnThePage__c CourseOnThePage7 = new MKT_CourseOnThePage__c(Description__c = 'Test', Course__c = e2.Id, Image__c = 'img.png', Page__c = 'Courses', Position__c = 'Right', Type__c = 'Featured');
			MKT_CourseOnThePage__c CourseOnThePage8 = new MKT_CourseOnThePage__c(Description__c = 'Test', Course__c = e2.Id, Image__c = 'img.png', Page__c = 'Courses', Position__c = 'Left Top', Type__c = 'Featured');
			MKT_CourseOnThePage__c CourseOnThePage9 = new MKT_CourseOnThePage__c(Description__c = 'Test', Course__c = e2.Id, Image__c = 'img.png', Page__c = 'Courses', Position__c = 'Right Top', Type__c = 'Featured');
			MKT_CourseOnThePage__c CourseOnThePage10 = new MKT_CourseOnThePage__c(Description__c = 'Test', Course__c = e2.Id, Image__c = 'img.png', Page__c = 'Courses', Position__c = 'Left Bottom', Type__c = 'Featured');
			MKT_CourseOnThePage__c CourseOnThePage11 = new MKT_CourseOnThePage__c(Description__c = 'Test', Course__c = e2.Id, Image__c = 'img.png', Page__c = 'Courses', Position__c = 'Right Bottom', Type__c = 'Featured');
			List<MKT_CourseOnThePage__c> MKT_CourseOnThePageList = new List<MKT_CourseOnThePage__c> {CourseOnThePage1,CourseOnThePage2,CourseOnThePage3,CourseOnThePage5,CourseOnThePage6,CourseOnThePage7,CourseOnThePage8,CourseOnThePage9,CourseOnThePage10,CourseOnThePage11};
			insert MKT_CourseOnThePageList;
			Test.startTest();
				ApexPages.currentPage().getParameters().put('calView', '1');
				MKT_MyTrainingExtension contr = new MKT_MyTrainingExtension();
				contr.GetNewCoursesOnThePage();
				contr.MonthBack();
				contr.MonthForward();
				contr.ThisMonth();
				MKT_MyLearningCoursesController contr2 = new MKT_MyLearningCoursesController();
				contr2.GetNewCoursesOnThePage();
				MKT_Courses contr3 = new MKT_Courses();
				contr3.GetNewCoursesOnThePage();
				System.assert(contr3.LeftLandingCourse != NULL);
			Test.stopTest();
		}
}