@AbapCatalog.sqlViewName: 'ZINTIPBCAT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@VDM.viewType: #BASIC
@EndUserText.label: 'Contact Category View'
define view ZINTLRA_I_PB_CAT as select from zintlra_pb_d_cnt {
    key pb_category  as PbCategory,
    key pb_spras     as PbLanguage,
    pb_category_text as PbCategoryText
}
