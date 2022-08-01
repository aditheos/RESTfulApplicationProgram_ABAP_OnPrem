@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Phone Book Item Consumption View'
@Search.searchable: true
@Metadata.allowExtensions: true

define view entity ZINTLRA_C_PB_ITEM as projection on ZINTLRA_I_PB_ITEM {
    
    key PbItemUuid,
    PbUuid,
    PbId,
    PbItemId,
    
    @Search.defaultSearchElement: true
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZINTLRA_I_PB_CAT', element: 'PbCategory' } }]
    @ObjectModel.text.element: ['PbCategoryText']
    PbCategory,
    PbCategoryText,
    
    @Search.defaultSearchElement: true
    PbTelephone,
    PbCreatedAt,
    PbChangedAt,
    PbDefault,
    
    /* Associations */
    _catText,
    _hdr:redirected to parent ZINTLRA_C_PB_HEAD
}
