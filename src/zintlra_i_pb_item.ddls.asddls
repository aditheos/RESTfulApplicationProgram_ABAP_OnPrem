@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Phone Book Items Interface View'
define view entity ZINTLRA_I_PB_ITEM as select from zintlra_pb_d_itm 
association to parent ZINTLRA_I_PB_HEAD as _hdr
                   on $projection.PbUuid = _hdr.PbUuid
association [1..1] to ZINTLRA_I_PB_CAT as _catText
                   on $projection.PbCategory = _catText.PbCategory
                  and _catText.PbLanguage = $session.system_language                
{
    key pb_item_uuid  as PbItemUuid,
    pb_uuid           as PbUuid,
    pb_id             as PbId,
    pb_item_id        as PbItemId,
    pb_category       as PbCategory,
    @Semantics.text: true
    _catText.PbCategoryText,
    pb_telephone      as PbTelephone,
    @Semantics.systemDateTime.createdAt: true
    pb_created_at     as PbCreatedAt,
    @Semantics.systemDateTime.lastChangedAt: true
    pb_changed_at     as PbChangedAt,
    pb_default        as PbDefault,
    
    /* Associations */
    _hdr,
    _catText
}
