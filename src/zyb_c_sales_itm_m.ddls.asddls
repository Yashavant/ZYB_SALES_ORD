@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Order Item-Managed'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZYB_C_SALES_ITM_M
  as projection on ZYB_I_SALES_ITM_M
{
  key SalesOrderId,
  key ItemNumber,
      MaterialId,
      MaterialDescription,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      Quantity,
      Uom,
      @Semantics.amount.currencyCode: 'Currency'
      Price,
      Currency,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      _Header :redirected to parent ZYB_C_SALES_HDR_M
}
