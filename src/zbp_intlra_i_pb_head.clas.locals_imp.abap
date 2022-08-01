CLASS lhc_Contact DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS: BEGIN OF lc_favourite,
                 yes TYPE boolean VALUE 'X',
                 no  TYPE boolean VALUE '',
               END of lc_favourite.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR Contact RESULT result.

    METHODS setFavourite FOR MODIFY
      IMPORTING keys FOR ACTION contact~setfavourite RESULT result.

    METHODS removeFavourite FOR MODIFY
      IMPORTING keys FOR ACTION contact~removefavourite RESULT result.

    METHODS setPhoneBookId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Contact~setPhoneBookId.
    METHODS validateEmail FOR VALIDATE ON SAVE
      IMPORTING keys FOR Contact~validateEmail.

ENDCLASS.

CLASS lhc_Contact IMPLEMENTATION.

  METHOD get_features.

    " Fill the response table
    READ ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
    ENTITY Contact
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(Contacts).

    result = VALUE #( FOR contact IN Contacts
                        LET
                            is_set_as_fav     = COND #( WHEN contact-PbFavourite = lc_favourite-yes
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled  )
                            is_not_set_as_fav = COND #( WHEN contact-PbFavourite = lc_favourite-no
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled  )
                        IN
                            ( %tky                   = contact-%tky
                              %action-setFavourite    = is_set_as_fav
                              %action-removeFavourite = is_not_set_as_fav ) ).

  ENDMETHOD.

  METHOD setFavourite.

    " Set as Favourite
    MODIFY ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
      ENTITY Contact
         UPDATE
           FIELDS ( PbFavourite )
           WITH VALUE #( FOR key IN keys
                           ( %tky      = key-%tky
                             PbFavourite = lc_favourite-yes ) )
    FAILED failed
    REPORTED reported.

    " Fill the response table
    READ ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
    ENTITY Contact
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(Contacts).

    result = VALUE #( FOR contact IN Contacts
                        ( %tky   = contact-%tky
                          %param = contact ) ).
  ENDMETHOD.

  METHOD removeFavourite.

    " Set as Not a Favourite
    MODIFY ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
      ENTITY Contact
         UPDATE
           FIELDS ( PbFavourite )
           WITH VALUE #( FOR key IN keys
                           ( %tky      = key-%tky
                             PbFavourite = lc_favourite-no ) )
    FAILED failed
    REPORTED reported.

    " Fill the response table
    READ ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
    ENTITY Contact
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(Contacts).

    result = VALUE #( FOR contact IN Contacts
                        ( %tky   = contact-%tky
                          %param = contact ) ).
  ENDMETHOD.

  METHOD setPhoneBookId.
    READ ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
    ENTITY Contact
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(Contacts).

    DELETE Contacts WHERE PbId IS NOT INITIAL.

    CHECK Contacts IS NOT INITIAL.

    LOOP AT Contacts ASSIGNING FIELD-SYMBOL(<lfs_contact>).
        " Get Numbers
        TRY.
            cl_numberrange_runtime=>number_get(
              EXPORTING
                nr_range_nr       = '01'
                object            = 'ZPBID'
              IMPORTING
                number            = DATA(lv_number)
            ).
            <lfs_contact>-PbId = lv_number.
          CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        ENDTRY.
    ENDLOOP.

    MODIFY ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
    ENTITY Contact
    UPDATE
    FROM VALUE #( FOR contact IN Contacts INDEX INTO i (
    %tky = contact-%tky
    PbId = contact-PbID
    %control-PbId = if_abap_behv=>mk-on ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD validateEmail.
    DATA: go_regex   TYPE REF TO cl_abap_regex,
          go_matcher TYPE REF TO cl_abap_matcher,
          go_match   TYPE c LENGTH 1.

      CREATE OBJECT go_regex
        EXPORTING
          pattern     = '\w+(\.\w+)*@(\w+\.)+(\w{2,4})'
          ignore_case = abap_true.

      " Read E-Mail ID's
      READ ENTITIES OF zintlra_i_pb_head
      ENTITY Contact
      FIELDS ( PbEmailId ) WITH CORRESPONDING #( keys )
      RESULT DATA(Contacts).

      LOOP AT Contacts INTO DATA(contact).
         " Validate E-Mail
         go_matcher = go_regex->create_matcher( text = contact-PbEmailId ).

         APPEND VALUE #( %tky = contact-%tky %state_area = 'VALIDATE_EMAIL' ) TO reported-contact.
         IF go_matcher->match( ) IS INITIAL.
           " Invalid
           APPEND VALUE #( %tky = contact-%tky ) TO failed-contact.
           APPEND VALUE #( %tky = contact-%tky
                           %state_area = 'VALIDATE_EMAIL'
                           %msg = NEW zcm_intlra_pb(
                                    severity = if_abap_behv_message=>severity-error
                                    textid   = zcm_intlra_pb=>invalid_email
                                    email    = contact-PbEmailId
                                  )
                          %element-PbEmailId = if_abap_behv=>mk-on )
                     TO reported-contact.
         ENDIF.
      ENDLOOP.
  ENDMETHOD.

ENDCLASS.
