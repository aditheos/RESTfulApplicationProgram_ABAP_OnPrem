CLASS lhc_phonenumber DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.
    CONSTANTS: BEGIN OF lc_default,
                 yes TYPE boolean VALUE 'X',
                 no  TYPE boolean VALUE ' ',
               END of lc_default.
    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR PhoneNumber RESULT result.

    METHODS setDefault FOR MODIFY
      IMPORTING keys FOR ACTION PhoneNumber~setDefault RESULT result.
    METHODS setPhoneBookItemId FOR DETERMINE ON SAVE
      IMPORTING keys FOR PhoneNumber~setPhoneBookItemId.
    METHODS setNotDefault FOR MODIFY
      IMPORTING keys FOR ACTION PhoneNumber~setNotDefault.
    METHODS validatePhone FOR VALIDATE ON SAVE
      IMPORTING keys FOR PhoneNumber~validatePhone.

ENDCLASS.

CLASS lhc_phonenumber IMPLEMENTATION.
  METHOD get_features.

    " Fill the response table
    READ ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
    ENTITY PhoneNumber
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(PhoneNumbers).
    result = VALUE #( FOR Number IN PhoneNumbers
                                                  LET
                            is_set_as_default = COND #( WHEN Number-PbDefault = lc_default-yes
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled  )
                        IN
                            ( %tky                 = Number-%tky
                              %action-setDefault = is_set_as_default ) ).

  ENDMETHOD.

  METHOD setDefault.
    DATA: lt_no_default TYPE TABLE FOR UPDATE zintlra_i_pb_item.

    " Get Parent Keys
    READ ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
    ENTITY PhoneNumber BY \_hdr
    FIELDS ( PbUuid ) WITH CORRESPONDING #( keys )
    RESULT DATA(ParentKeys).

    READ TABLE keys INTO DATA(key1) INDEX 1.
    CLEAR lt_no_default.
    LOOP AT ParentKeys INTO DATA(parentkey).
        " Get Parent Keys
        READ ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
        ENTITY Contact BY \_item
        FIELDS ( PbItemUuid ) WITH VALUE #( ( %tky = parentkey-%tky ) )
        RESULT DATA(Phonekeys).

        LOOP AT Phonekeys INTO DATA(pk).
            IF pk-%tky NE key1-%tky.
                APPEND INITIAL LINE TO lt_no_default ASSIGNING FIELD-SYMBOL(<lfs_nodef>).
                <lfs_nodef> = CORRESPONDING #( pk ).
            ENDIF.
        ENDLOOP.
    ENDLOOP.

    " Set the Default status
    MODIFY ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
      ENTITY PhoneNumber
         UPDATE
           FIELDS ( PbDefault )
           WITH VALUE #( FOR key IN keys
                           ( %tky      = key-%tky
                             PbDefault = lc_default-yes ) )
    FAILED failed
    REPORTED DATA(reported1).

    " Set the  NOT Default status
    IF NOT lt_no_default IS INITIAL.
        MODIFY ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
          ENTITY PhoneNumber
          EXECUTE setNotDefault
          FROM CORRESPONDING #( lt_no_default ).
    ENDIF.

    " Fill the response table
    READ ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
    ENTITY PhoneNumber
    ALL FIELDS WITH CORRESPONDING #( phonekeys )
    RESULT DATA(PhoneNumbers).

    result = VALUE #( FOR Number IN PhoneNumbers
                          ( %tky   = Number-%tky
                            %param = Number ) ).
  ENDMETHOD.

  METHOD setPhoneBookItemId.

    READ ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
    ENTITY PhoneNumber
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(PhoneNumbers).

    DELETE PhoneNumbers WHERE PbItemId IS NOT INITIAL.

    CHECK PhoneNumbers IS NOT INITIAL.

    READ ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
    ENTITY PhoneNumber BY \_hdr
    FIELDS ( PbUuid PbId ) WITH CORRESPONDING #( keys )
    RESULT DATA(Contacts).

    READ TABLE Contacts INTO DATA(Contact) INDEX 1.

    " Get Current Max Item#
    SELECT max( pb_item_id ) FROM zintlra_pb_d_itm
     WHERE pb_uuid = @Contact-PbUuid
      INTO @DATA(lv_current_item).

    LOOP AT PhoneNumbers ASSIGNING FIELD-SYMBOL(<lfs_number>).
        lv_current_item += 10.
        <lfs_number>-PbId = Contact-PbId.
        <lfs_number>-PbItemId = lv_current_item.
    ENDLOOP.

    MODIFY ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
    ENTITY PhoneNumber
    UPDATE
    FROM VALUE #( FOR Number IN PhoneNumbers INDEX INTO i (
    %tky = Number-%tky
    PbId     = Number-PbId
    PbItemId = Number-PbItemId
    %control-PbItemId = if_abap_behv=>mk-on
    %control-PbId = if_abap_behv=>mk-on ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD setNotDefault.
    " Set the NOT Default status
    MODIFY ENTITIES OF zintlra_i_pb_head IN LOCAL MODE
      ENTITY PhoneNumber
         UPDATE
           FIELDS ( PbDefault )
           WITH VALUE #( FOR key IN keys
                           ( %tky      = key-%tky
                             PbDefault = lc_default-no ) )
    FAILED failed
    REPORTED DATA(reported1).
  ENDMETHOD.

  METHOD validatePhone.
      DATA lv_phone TYPE string.
      " Read Phone Numbers
      READ ENTITIES OF zintlra_i_pb_head
      ENTITY PhoneNumber
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(PhoneNumbers).

      LOOP AT PhoneNumbers INTO DATA(phonenumber).
         " Validate Phone
         APPEND VALUE #( %tky = phonenumber-%tky %state_area = 'VALIDATE_PHONE' ) TO reported-phonenumber.
         CLEAR lv_phone.
         lv_phone = phonenumber-PbTelephone.
         REPLACE ALL OCCURRENCES OF ` ` IN lv_phone  WITH ''.
         IF lv_phone CN '+-1234567890'.
           " Invalid
           APPEND VALUE #( %tky = phonenumber-%tky ) TO failed-phonenumber.
           APPEND VALUE #( %tky = phonenumber-%tky
                           %state_area = 'VALIDATE_PHONE'
                           %msg = NEW zcm_intlra_pb(
                                    severity = if_abap_behv_message=>severity-error
                                    textid   = zcm_intlra_pb=>invalid_phone
                                    phone    = phonenumber-PbTelephone
                                  )
                          %element-PbTelephone = if_abap_behv=>mk-on
                          %path = VALUE #( contact-PbUuid    = phonenumber-PbUuid )
                         )
                     TO reported-phonenumber.
         ENDIF.
      ENDLOOP.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
