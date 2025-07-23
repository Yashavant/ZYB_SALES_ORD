@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Order Item-Managed'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZYB_I_SALES_ITM_M
  as select from zyb_sales_itm_m
  association to parent ZYB_I_SALES_HDR_M as _Header on $projection.SalesOrderId = _Header.SalesOrderId
{
  key sales_order_id       as SalesOrderId ,
  key item_number          as ItemNumber,
      material_id          as MaterialId,
      material_description as MaterialDescription,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      quantity             as Quantity,
      uom                  as Uom,
      @Semantics.amount.currencyCode: 'Currency'
      price                as Price,
      currency             as Currency,
      created_by           as CreatedBy,
      created_at           as CreatedAt,
      last_changed_by      as LastChangedBy,
      last_changed_at      as LastChangedAt,
      _Header
}
