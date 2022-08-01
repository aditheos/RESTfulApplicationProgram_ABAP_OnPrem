CLASS zcm_intlra_pb DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA: email    TYPE zintlra_pb_d_hdr-pb_email_id,
          phone    TYPE zintlra_pb_d_itm-pb_telephone.

    CONSTANTS:
        BEGIN OF invalid_email,
            msgid TYPE symsgid VALUE 'ZINTLRA_PB_MESG',
            msgno TYPE symsgno VALUE '001',
            attr1 TYPE scx_attrname VALUE 'EMAIL',
            attr2 TYPE scx_attrname VALUE '',
            attr3 TYPE scx_attrname VALUE '',
            attr4 TYPE scx_attrname VALUE '',
        END OF   invalid_email,
        BEGIN OF invalid_phone,
            msgid TYPE symsgid VALUE 'ZINTLRA_PB_MESG',
            msgno TYPE symsgno VALUE '002',
            attr1 TYPE scx_attrname VALUE 'PHONE',
            attr2 TYPE scx_attrname VALUE '',
            attr3 TYPE scx_attrname VALUE '',
            attr4 TYPE scx_attrname VALUE '',
        END OF   invalid_phone.
    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    METHODS constructor
      IMPORTING
        severity TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        textid   LIKE if_t100_message=>t100key OPTIONAL
        previous LIKE previous OPTIONAL
        email    TYPE zintlra_pb_d_hdr-pb_email_id  OPTIONAL
        phone    TYPE zintlra_pb_d_itm-pb_telephone OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_intlra_pb IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->if_abap_behv_message~m_severity = severity.
    me->email                           = email.
    me->phone                           = phone.
  ENDMETHOD.
ENDCLASS.
