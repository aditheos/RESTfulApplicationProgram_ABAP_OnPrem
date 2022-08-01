@AbapCatalog.sqlViewName: 'ZINTIPBUSER'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Phone Book User View'
define view ZINTLRA_I_PB_USER 
as select from usr21 as _User
  association [0..1] to adrp as _Person                   on  _Person.persnumber = $projection.Person
                                                          and _Person.persnumber <> ''
{
      @ObjectModel.text.element : 'UserDescription'
      @Semantics.contact.type: #PERSON
  key _User.bname                                                                                 as OwnerID,
      _User.persnumber                                                                            as Person,

      @Semantics.name.givenName: true
      _Person.name_first                                                                          as FirstName,

      @Semantics.name.familyName: true
      _Person.name_last                                                                           as LastName,
      
      @Semantics.name.fullName: true
      cast(coalesce( _Person.name_text , _User.techdesc ) as ad_namtext preserving type )         as FullName
}
