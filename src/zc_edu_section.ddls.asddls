@EndUserText.label: 'Section Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_EDU_SECTION
  provider contract transactional_query
  as projection on ZI_EDU_SECTION
{
  key SectionUuid,
      SectionId,
      CourseName,
      FacultyId,
      Status,
      PassPercentage,
      FailPercentage,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Composition to child projection */
      _Attendance : redirected to composition child ZC_EDU_ATTEND
}
