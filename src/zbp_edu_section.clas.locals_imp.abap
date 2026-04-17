CLASS lhc_section DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    " 1. Global Auth: Controls overall app permissions
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Section
      RESULT result.

    " 2. Instance Features: Controls row-level UI
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Section RESULT result.

    " 3. Custom Actions: Lock and Unlock
    METHODS locksection FOR MODIFY
      IMPORTING keys FOR ACTION Section~lockSection RESULT result.

    METHODS unlocksection FOR MODIFY
      IMPORTING keys FOR ACTION Section~unlockSection RESULT result.

    " 4. Determination: Set default status to 'O' on creation
    METHODS setDefaultStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Section~setDefaultStatus.

ENDCLASS.

CLASS lhc_section IMPLEMENTATION.

  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%action-lockSection = if_abap_behv=>mk-on.
      result-%action-lockSection = if_abap_behv=>auth-allowed.
    ENDIF.
    IF requested_authorizations-%action-unlockSection = if_abap_behv=>mk-on.
      result-%action-unlockSection = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_edu_section IN LOCAL MODE
      ENTITY Section
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_sections).

    result = VALUE #( FOR ls_section IN lt_sections
                      ( %tky = ls_section-%tky
                        %update               = COND #( WHEN ls_section-Status = 'L' THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                        %delete               = COND #( WHEN ls_section-Status = 'L' THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                        %action-lockSection   = COND #( WHEN ls_section-Status = 'L' THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )

                        " Unlock is ONLY enabled if the status is Locked ('L')
                        %action-unlockSection = COND #( WHEN ls_section-Status = 'L' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
                      ) ).
  ENDMETHOD.

  METHOD locksection.
    READ ENTITIES OF zi_edu_section IN LOCAL MODE
      ENTITY Section
        FIELDS ( SectionUuid Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_sections) FAILED DATA(ls_failed).

    DATA lt_update TYPE TABLE FOR UPDATE zi_edu_section\\Section.

    LOOP AT lt_sections INTO DATA(ls_section).
      IF ls_section-Status <> 'L'.
        APPEND VALUE #(
          %tky        = ls_section-%tky
          Status      = 'L'
          %control    = VALUE #( Status = if_abap_behv=>mk-on )
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_edu_section IN LOCAL MODE
        ENTITY Section UPDATE FIELDS ( Status ) WITH lt_update
        REPORTED DATA(ls_mod_reported) FAILED DATA(ls_mod_failed).

      reported = CORRESPONDING #( DEEP ls_mod_reported ).
      failed   = CORRESPONDING #( DEEP ls_mod_failed   ).
    ENDIF.

    READ ENTITIES OF zi_edu_section IN LOCAL MODE
      ENTITY Section ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result ( %tky = ls_res-%tky %param = ls_res ) ).
  ENDMETHOD.

  METHOD unlocksection.
    READ ENTITIES OF zi_edu_section IN LOCAL MODE
      ENTITY Section
        FIELDS ( SectionUuid Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_sections) FAILED DATA(ls_failed).

    DATA lt_update TYPE TABLE FOR UPDATE zi_edu_section\\Section.

    LOOP AT lt_sections INTO DATA(ls_section).
      IF ls_section-Status = 'L'.
        APPEND VALUE #(
          %tky        = ls_section-%tky
          Status      = 'O' " Set back to Open
          %control    = VALUE #( Status = if_abap_behv=>mk-on )
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_edu_section IN LOCAL MODE
        ENTITY Section UPDATE FIELDS ( Status ) WITH lt_update
        REPORTED DATA(ls_mod_reported) FAILED DATA(ls_mod_failed).

      reported = CORRESPONDING #( DEEP ls_mod_reported ).
      failed   = CORRESPONDING #( DEEP ls_mod_failed   ).
    ENDIF.

    READ ENTITIES OF zi_edu_section IN LOCAL MODE
      ENTITY Section ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result ( %tky = ls_res-%tky %param = ls_res ) ).
  ENDMETHOD.

  METHOD setDefaultStatus.
    READ ENTITIES OF zi_edu_section IN LOCAL MODE
      ENTITY Section
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_sections).

    DATA lt_update TYPE TABLE FOR UPDATE zi_edu_section\\Section.

    LOOP AT lt_sections INTO DATA(ls_section).
      IF ls_section-Status IS INITIAL.
        APPEND VALUE #(
          %tky        = ls_section-%tky
          Status      = 'O'
          %control    = VALUE #( Status = if_abap_behv=>mk-on )
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_edu_section IN LOCAL MODE
        ENTITY Section UPDATE FIELDS ( Status ) WITH lt_update.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_attendance DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Attendance RESULT result.

    METHODS validateRules FOR VALIDATE ON SAVE
      IMPORTING keys FOR Attendance~validateRules.

    METHODS calculatePercentages FOR DETERMINE ON SAVE
      IMPORTING keys FOR Attendance~calculatePercentages.

ENDCLASS.

CLASS lhc_attendance IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zi_edu_section IN LOCAL MODE
      ENTITY Attendance BY \_Section
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_sections).

    DATA(lv_parent_locked) = COND #( WHEN line_exists( lt_sections[ Status = 'L' ] )
                                     THEN if_abap_behv=>fc-o-disabled
                                     ELSE if_abap_behv=>fc-o-enabled ).

    result = VALUE #( FOR key IN keys
                      ( %tky    = key-%tky
                        %update = lv_parent_locked
                        %delete = lv_parent_locked ) ).
  ENDMETHOD.

  METHOD validateRules.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    READ ENTITIES OF zi_edu_section IN LOCAL MODE
      ENTITY Attendance
        FIELDS ( AttendUuid Marks ExamDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_attend).

    LOOP AT lt_attend INTO DATA(ls_attend).

      IF ls_attend-Marks < 0 OR ls_attend-Marks > 100.
        APPEND VALUE #( %tky = ls_attend-%tky ) TO failed-attendance.
        APPEND VALUE #( %tky           = ls_attend-%tky
                        %state_area    = 'VALIDATE_MARKS'
                        %msg           = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Marks must be between 0 and 100' )
                        %element-Marks = if_abap_behv=>mk-on
                      ) TO reported-attendance.
      ENDIF.

      IF ls_attend-ExamDate > lv_today AND ls_attend-ExamDate IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_attend-%tky ) TO failed-attendance.
        APPEND VALUE #( %tky              = ls_attend-%tky
                        %state_area       = 'VALIDATE_DATE'
                        %msg              = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Exam date cannot be in the future' )
                        %element-ExamDate = if_abap_behv=>mk-on
                      ) TO reported-attendance.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD calculatePercentages.
    READ ENTITIES OF zi_edu_section IN LOCAL MODE
      ENTITY Attendance BY \_Section
        FIELDS ( SectionUuid ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_sections).

    SORT lt_sections BY SectionUuid.
    DELETE ADJACENT DUPLICATES FROM lt_sections COMPARING SectionUuid.

    LOOP AT lt_sections INTO DATA(ls_section).

      READ ENTITIES OF zi_edu_section IN LOCAL MODE
        ENTITY Section BY \_Attendance
        FIELDS ( Marks ) WITH VALUE #( ( %tky = ls_section-%tky ) )
        RESULT DATA(lt_exams).

      DATA: lv_total  TYPE f,
            lv_passed TYPE f,
            lv_failed TYPE f.

      lv_total = lines( lt_exams ).
      lv_passed = 0.
      lv_failed = 0.

      IF lv_total > 0.
        LOOP AT lt_exams INTO DATA(ls_exam).
          IF ls_exam-Marks >= 35.
            lv_passed = lv_passed + 1.
          ELSE.
            lv_failed = lv_failed + 1.
          ENDIF.
        ENDLOOP.

        DATA(lv_pass_pct) = ( lv_passed / lv_total ) * 100.
        DATA(lv_fail_pct) = ( lv_failed / lv_total ) * 100.
      ELSE.
        lv_pass_pct = 0.
        lv_fail_pct = 0.
      ENDIF.

      MODIFY ENTITIES OF zi_edu_section IN LOCAL MODE
        ENTITY Section
        UPDATE FIELDS ( PassPercentage FailPercentage )
        WITH VALUE #( ( %tky           = ls_section-%tky
                        PassPercentage = lv_pass_pct
                        FailPercentage = lv_fail_pct ) ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
