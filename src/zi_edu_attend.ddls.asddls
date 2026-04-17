@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Exam BO Interface View'
define view entity ZI_EDU_ATTEND
  as select from zedu_attend
  association to parent ZI_EDU_SECTION as _Section
    on $projection.SectionUuid = _Section.SectionUuid
{
  key attend_uuid         as AttendUuid,
      section_uuid        as SectionUuid,
      exam_date           as ExamDate,
      student_id          as StudentId,
      marks               as Marks,
      
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
      _Section
}
