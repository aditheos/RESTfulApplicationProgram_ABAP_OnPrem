class ZCL_INTLRA_PB_DATA_GEN definition
  public
  final
  create public .

public section.

  interfaces IF_OO_ADT_CLASSRUN .
protected section.
private section.
ENDCLASS.



CLASS ZCL_INTLRA_PB_DATA_GEN IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    IF out IS BOUND.
      out->write( 'Starting generation of Data' ).
    ENDIF.
    lcl_pb_data_gen=>create( out ).
    IF out IS BOUND.
      out->write( 'Finished generating Data' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
