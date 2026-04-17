@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Section BO Interface View'
define root view entity ZI_EDU_SECTION
  as select from zedu_section
  composition [0..*] of ZI_EDU_ATTEND as _Attendance
{
  key section_uuid        as SectionUuid,
      section_id          as SectionId,
      course_name         as CourseName,
      faculty_id          as FacultyId,
      status              as Status,
      pass_percentage     as PassPercentage,
      fail_percentage     as FailPercentage,
      
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* Association */
      _Attendance
}
