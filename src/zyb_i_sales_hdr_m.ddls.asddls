@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Order Header-Managed'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZYB_I_SALES_HDR_M
  as select from zyb_sales_hdr_m
  composition[1..*] of ZYB_I_SALES_ITM_M as _Item 
{
  key sales_order_id     as SalesOrderId,
      order_created_date as OrderCreatedDate,
      order_created_user as OrderCreatedUser,
      category           as Category,
      description        as Description,
      customer_id        as CustomerId,
      @Semantics.user.createdBy: true
      created_by         as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at         as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by    as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at    as LastChangedAt,
      _Item
}
