@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Phone Book Header Interface View'
define root view entity ZINTLRA_I_PB_HEAD as select from zintlra_pb_d_hdr 
composition [0..*] of ZINTLRA_I_PB_ITEM as _item
association [1..1] to ZINTLRA_I_PB_USER as _owner
                                        on $projection.PbOwner = _owner.OwnerID
association [1..1] to ZINTLRA_I_PB_TAG as _tagText
                   on $projection.PbTagCode = _tagText.PbTagCode
                  and _tagText.PbLanguage = $session.system_language  
{
    key pb_uuid            as PbUuid,
        pb_id              as PbId,
        @Semantics.user.createdBy: true
        pb_owner           as PbOwner,
        _owner.FullName    as PbOwnerName,
        pb_tag_code        as PbTagCode,
        _tagText.PbTagText as PbTagText,
        pb_first_name      as PbFirstName,
        pb_last_name       as PbLastName,
        concat_with_space(pb_first_name, pb_last_name, 1) as PbContactName,
        @Semantics.systemDateTime.createdAt: true
        pb_created_at      as PbCreatedAt,
        @Semantics.systemDateTime.lastChangedAt: true
        pb_changed_at      as PbChangedAt,
        @Semantics.eMail.address: true
        pb_email_id        as PbEmailId,
        pb_favourite       as PbFavourite,
        
        /* Associations */
        _item,
        _owner,
        _tagText
}where pb_owner = $session.user
