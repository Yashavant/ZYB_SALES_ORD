@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Order Header-Managed'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZYB_C_SALES_HDR_M
  provider contract transactional_query
  as projection on ZYB_I_SALES_HDR_M
{
  key SalesOrderId,
      OrderCreatedDate,
      OrderCreatedUser,
      Category,
      Description,
      CustomerId,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      _Item :redirected to composition child ZYB_C_SALES_ITM_M
}
