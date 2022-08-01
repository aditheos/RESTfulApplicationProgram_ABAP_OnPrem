@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Phone Book Header Consumption View'
@Search.searchable: true
@Metadata.allowExtensions: true

@ObjectModel.semanticKey: ['PbUuid']

define root view entity ZINTLRA_C_PB_HEAD 
    as projection on ZINTLRA_I_PB_HEAD
 {
    @Search.defaultSearchElement: true
   key PbUuid,
    PbId,    
    PbOwner,
    PbOwnerName,
    
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZINTLRA_I_PB_TAG', element: 'PbTagCode' } }]
    @ObjectModel.text.element: ['PbTagText']
    @Search.defaultSearchElement: true
    PbTagCode,
    
    PbTagText,
    @Search.defaultSearchElement: true
    PbFirstName,
    @Search.defaultSearchElement: true
    PbLastName,
    PbContactName,    
    PbCreatedAt,
    PbChangedAt,
    PbEmailId,
    PbFavourite,
    
    /* Associations */
    _item: redirected to composition child ZINTLRA_C_PB_ITEM,
    _owner
} 
