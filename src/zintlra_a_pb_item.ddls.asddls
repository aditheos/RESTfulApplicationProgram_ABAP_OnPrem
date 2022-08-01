@EndUserText.label: 'Abstract PhoneBook Item'
define abstract entity ZINTLRA_A_PB_ITEM 
{
    key PbItemUuid: sysuuid_x16 ;
    PbUuid: sysuuid_x16;
    Pb_Id: zintlra_de_phonebook_id;
    PbItemId: zintlra_de_phonebook_item;
    PbCategory: zintlra_de_category;
    PbCategoryText: zintlra_de_category;
    PbTelephone: ad_tlnmbr1;
    PbCreatedAt: zintlra_de_created_at;
    PbChangedAt: zintlra_de_changed_at;
    PbDefault: zintlra_de_isdefault;
}
