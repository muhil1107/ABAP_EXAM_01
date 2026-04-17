@EndUserText.label: 'Exam Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_EDU_ATTEND
  as projection on ZI_EDU_ATTEND
{
  key AttendUuid,
      SectionUuid,
      ExamDate,
      StudentId,
      Marks,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Association to parent projection */
      _Section : redirected to parent ZC_EDU_SECTION
}
