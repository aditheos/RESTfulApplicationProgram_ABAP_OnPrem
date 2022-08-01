@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Phone Book Tags'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZINTLRA_I_PB_TAG as select from zintlra_pb_d_tag {
    key pb_tag_code as PbTagCode,
    key pb_spras    as PbLanguage,
    pb_tag_text     as PbTagText
}
