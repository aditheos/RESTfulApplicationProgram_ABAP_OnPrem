*&---------------------------------------------------------------------*
*& Report ZINTLRA_PB_DATA_GEN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zintlra_pb_data_gen.

PARAMETERS: p_user1 TYPE sy-uname DEFAULT sy-uname.

CLASS lcl_pb_data_gen DEFINITION.
  PUBLIC SECTION.
    METHODS: create.
  PROTECTED SECTION.
    DATA: mt_head  TYPE STANDARD TABLE OF zintlra_pb_d_hdr,
          mt_items TYPE STANDARD TABLE OF zintlra_pb_d_itm,
          mt_cat   TYPE STANDARD TABLE OF zintlra_pb_d_cnt,
          mt_tag   TYPE STANDARD TABLE OF zintlra_pb_d_tag.

    METHODS set_data.
ENDCLASS.

CLASS lcl_pb_data_gen IMPLEMENTATION.
  METHOD create.
    " Delete
    WRITE:/ 'Deleting Old Records'.
    DELETE FROM zintlra_pb_d_hdr.
    DELETE FROM zintlra_pb_d_itm.
    DELETE FROM zint_pb_d_hdrtmp.
    DELETE FROM zint_pb_d_itmtmp.
    DELETE FROM zintlra_pb_d_cnt.
    DELETE FROM zintlra_pb_d_tag.

    " Set Data
    WRITE:/ 'Building New Records'.
    set_data( ).

    " Insert
    WRITE:/ 'Updating New Records'.
    INSERT zintlra_pb_d_hdr FROM TABLE mt_head.
    INSERT zintlra_pb_d_itm FROM TABLE mt_items.
    INSERT zintlra_pb_d_cnt FROM TABLE mt_cat.
    INSERT zintlra_pb_d_tag FROM TABLE mt_tag.
  ENDMETHOD.

  METHOD set_data.

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    CLEAR: mt_head, mt_items, mt_cat.


    APPEND INITIAL LINE TO mt_head ASSIGNING FIELD-SYMBOL(<lfs_head>).
    <lfs_head>-pb_uuid       = lo_uuid->create_uuid_x16( ).
    <lfs_head>-pb_owner      = p_user1.
    <lfs_head>-pb_tag_code   = 'FR'.
    <lfs_head>-pb_first_name = 'JOHN'.
    <lfs_head>-pb_last_name  = 'SMITH'.
    <lfs_head>-pb_email_id   = 'JOHN.SMITH@INTELIRA.TECH'.
    GET TIME STAMP FIELD <lfs_head>-pb_created_at.
    <lfs_head>-pb_changed_at = <lfs_head>-pb_created_at.

    " Get Numbers
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZPBID'
          IMPORTING
            number            = DATA(lv_number)
        ).
        <lfs_head>-pb_id = lv_number.
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
    ENDTRY.

    APPEND INITIAL LINE TO mt_head ASSIGNING <lfs_head>.
    <lfs_head>-pb_uuid       = lo_uuid->create_uuid_x16( ).
    <lfs_head>-pb_owner      = p_user1.
    <lfs_head>-pb_tag_code   = 'WO'.
    <lfs_head>-pb_first_name = 'SMITH'.
    <lfs_head>-pb_last_name  = 'JOHN'.
    <lfs_head>-pb_email_id   = 'SMITH.JOHN@INTELIRA.TECH'.
    GET TIME STAMP FIELD <lfs_head>-pb_created_at.
    <lfs_head>-pb_changed_at = <lfs_head>-pb_created_at.

    " Get Numbers
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZPBID'
          IMPORTING
            number            = lv_number
        ).
        <lfs_head>-pb_id = lv_number.
      CATCH cx_number_ranges INTO lx_number_ranges.
    ENDTRY.

    UNASSIGN <lfs_head>.
    DATA(lo_telho) = cl_abap_random_int8=>create( min = 200000000
                                                  max = 299999990 ).
    DATA(lo_telmo) = cl_abap_random_int8=>create( min = 400000000
                                                  max = 499999990 ).
    LOOP AT mt_head ASSIGNING <lfs_head>.
      APPEND INITIAL LINE TO mt_items ASSIGNING FIELD-SYMBOL(<lfs_item>).
      <lfs_item>-pb_uuid       = <lfs_head>-pb_uuid.
      <lfs_item>-pb_id         = <lfs_head>-pb_id.
      <lfs_item>-pb_item_id    = '10'.
      <lfs_item>-pb_created_at = <lfs_head>-pb_created_at.
      <lfs_item>-pb_changed_at = <lfs_head>-pb_changed_at.
      <lfs_item>-pb_category   = 'HO'.
      <lfs_item>-pb_item_uuid  = lo_uuid->create_uuid_x16( ).
      <lfs_item>-pb_telephone  = lo_telho->get_next( ).
      CONDENSE <lfs_item>-pb_telephone.
      <lfs_item>-pb_telephone  = | +61 0{ <lfs_item>-pb_telephone }|.

      APPEND INITIAL LINE TO mt_items ASSIGNING <lfs_item>.
      <lfs_item>-pb_uuid       = <lfs_head>-pb_uuid.
      <lfs_item>-pb_id         = <lfs_head>-pb_id.
      <lfs_item>-pb_item_id    = '20'.
      <lfs_item>-pb_created_at = <lfs_head>-pb_created_at.
      <lfs_item>-pb_changed_at = <lfs_head>-pb_changed_at.
      <lfs_item>-pb_category   = 'MO'.
      <lfs_item>-pb_item_uuid  = lo_uuid->create_uuid_x16( ).
      <lfs_item>-pb_telephone  = lo_telmo->get_next( ).
      CONDENSE <lfs_item>-pb_telephone.
      <lfs_item>-pb_telephone  = | +61 0{ <lfs_item>-pb_telephone }|.
    ENDLOOP.

    APPEND INITIAL LINE TO mt_cat ASSIGNING FIELD-SYMBOL(<lfs_cat>).
    <lfs_cat>-pb_category = 'HO'.
    <lfs_cat>-pb_category_text = 'HOME'.
    <lfs_cat>-pb_spras = 'E'.

    APPEND INITIAL LINE TO mt_cat ASSIGNING <lfs_cat>.
    <lfs_cat>-pb_category = 'MO'.
    <lfs_cat>-pb_category_text = 'MOBILE'.
    <lfs_cat>-pb_spras = 'E'.

    APPEND INITIAL LINE TO mt_cat ASSIGNING <lfs_cat>.
    <lfs_cat>-pb_category = 'OF'.
    <lfs_cat>-pb_category_text = 'OFFICE'.
    <lfs_cat>-pb_spras = 'E'.

    APPEND INITIAL LINE TO mt_cat ASSIGNING <lfs_cat>.
    <lfs_cat>-pb_category = 'WO'.
    <lfs_cat>-pb_category_text = 'WORK'.
    <lfs_cat>-pb_spras = 'E'.

    APPEND INITIAL LINE TO mt_tag ASSIGNING FIELD-SYMBOL(<lfs_tag>).
    <lfs_tag>-pb_tag_code = 'FM'.
    <lfs_tag>-pb_tag_text = 'Family'.
    <lfs_tag>-pb_spras = 'E'.

    APPEND INITIAL LINE TO mt_tag ASSIGNING <lfs_tag>.
    <lfs_tag>-pb_tag_code = 'FR'.
    <lfs_tag>-pb_tag_text = 'Friend'.
    <lfs_tag>-pb_spras = 'E'.

    APPEND INITIAL LINE TO mt_tag ASSIGNING <lfs_tag>.
    <lfs_tag>-pb_tag_code = 'WO'.
    <lfs_tag>-pb_tag_text = 'Work'.
    <lfs_tag>-pb_spras = 'E'.


    APPEND INITIAL LINE TO mt_tag ASSIGNING <lfs_tag>.
    <lfs_tag>-pb_tag_code = 'OT'.
    <lfs_tag>-pb_tag_text = 'Others'.
    <lfs_tag>-pb_spras = 'E'.
  ENDMETHOD.

ENDCLASS.

DATA: lo_data_gen TYPE REF TO lcl_pb_data_gen.

START-OF-SELECTION.
  CREATE OBJECT lo_data_gen.

  " Generate Data
  lo_data_gen->create( ).
