CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Header RESULT result.
    METHODS CreateNew FOR MODIFY
      IMPORTING keys FOR ACTION Header~CreateNew.
    METHODS DefaultValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Header~DefaultValues.
    METHODS earlynumbering_cba_Item FOR NUMBERING
      IMPORTING entities FOR CREATE Header\_Item.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Header.

ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    LOOP AT entities INTO DATA(ls_entity).
    "Work for both Draft and without Draft Number creation for Header
        APPEND CORRESPONDING #( ls_entity ) TO mapped-header ASSIGNING FIELD-SYMBOL(<ls_mapped>).
        IF <ls_mapped> IS ASSIGNED.
          DATA: lv_order_id TYPE zyb_sales_hdrd_m-salesorderid.
          IF <ls_mapped>-SalesOrderId IS INITIAL.
            SELECT MAX( sales_order_id ) FROM zyb_sales_hdr_m INTO @DATA(lv_Order_id_O).
            SELECT MAX( salesorderid ) FROM zyb_sales_hdrd_m INTO @DATA(lv_Order_id_D).
            IF lv_Order_id_O < lv_Order_id_D.
              lv_order_id = lv_Order_id_D.
            ELSE.
              lv_order_id = lv_Order_id_O.
            ENDIF.
            lv_order_id += 1.
            lv_order_id = |{ lv_order_id ALPHA = IN }|.
            <ls_mapped>-SalesOrderId = lv_order_id.

          ENDIF.

        ENDIF.

    ENDLOOP.

  ENDMETHOD.
  METHOD earlynumbering_cba_Item.

    "Work for both Draft and without Draft Number creation for Line Item

    READ ENTITIES OF zyb_i_sales_hdr_m IN LOCAL MODE
    ENTITY Header BY \_Item
    ALL FIELDS WITH CORRESPONDING #( entities )
    LINK DATA(lt_existing_ord_item_link)
    RESULT DATA(lt_res).
    DATA: lv_max_item_no TYPE zyb_sales_itm_m-item_number.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>) GROUP BY <ls_entity>-SalesOrderId.

      "Get Max Serial from linkage table
      lv_max_item_no = REDUCE #(
      INIT lv_max = CONV zyb_sales_itm_m-item_number( '0' )
      FOR ls_link IN lt_existing_ord_item_link USING KEY entity WHERE ( source-SalesOrderId = <ls_entity>-SalesOrderId )
      NEXT lv_max = COND zyb_sales_itm_m-item_number(  WHEN lv_max < ls_link-target-ItemNumber THEN ls_link-target-ItemNumber ELSE lv_max )
      ).

      "Get Max No form Entities

      lv_max_item_no = REDUCE #(
      INIT lv_max = lv_max_item_no
      FOR ls_entities IN entities USING KEY entity WHERE ( SalesOrderId = <ls_entity>-SalesOrderId )
      FOR ls_item IN ls_entities-%target USING KEY entity
      NEXT lv_max = COND zyb_sales_itm_m-item_number( WHEN lv_max < ls_item-ItemNumber THEN ls_item-ItemNumber ELSE lv_max  )
      ).

      "Update Item No for Order Items
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_curr_ord>) USING KEY entity WHERE SalesOrderId = <ls_entity>-SalesOrderId.

        "Loop for Order Item
        LOOP AT <ls_curr_ord>-%target ASSIGNING FIELD-SYMBOL(<ls_curr_item>).
          APPEND CORRESPONDING #( <ls_curr_item> ) TO mapped-item ASSIGNING FIELD-SYMBOL(<ls_mapped_item>).
          IF <ls_mapped_item> IS ASSIGNED.

            IF <ls_mapped_item>-ItemNumber IS INITIAL.
              lv_max_item_no += 10.
              <ls_mapped_item>-ItemNumber = lv_max_item_no.
            ENDIF.
          ENDIF.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.


    "Old Logic to set Item
*    LOOP AT entities INTO DATA(ls_entity).
*      IF ls_entity-SalesOrderId IS NOT INITIAL.
*        DATA(lt_item) = ls_entity-%target[].
*        DELETE lt_item WHERE ItemNumber IS INITIAL.
*        SORT lt_item BY ItemNumber DESCENDING.
*        DATA(ls_Item_no) = VALUE #( lt_item[ 1 ] OPTIONAL ).
*        LOOP AT ls_entity-%target ASSIGNING FIELD-SYMBOL(<ls_item>) WHERE ItemNumber IS INITIAL.
*          ls_Item_no-ItemNumber += 1.
*          <ls_item>-ItemNumber = ls_Item_no-ItemNumber.
*          <ls_item>-SalesOrderId = ls_entity-SalesOrderId.
*          APPEND INITIAL LINE TO mapped-item ASSIGNING FIELD-SYMBOL(<ls_item_1>).
*          <ls_item_1> = CORRESPONDING #(  <ls_item> ).
*
*        ENDLOOP.
*
*      ENDIF.
*
*    ENDLOOP.


  ENDMETHOD.
  METHOD CreateNew.
*  READ ENTITIES OF zyb_i_sales_hdr_m IN LOCAL MODE
*  ENTITY Header ALL FIELDS WITH CORRESPONDING #( keys )
*  RESULT DATA(lt_ord_h).
*LOOP AT lt_ord_h INTO DATA(ls_ord_h).
*
*ENDLOOP.

    MODIFY ENTITIES OF zyb_i_sales_hdr_m IN LOCAL MODE
    ENTITY Header CREATE
    FROM VALUE #(
    FOR ls_order IN keys (
    %cid = ls_order-%cid
    %data = VALUE #( Category = 'S' OrderCreatedUser = sy-uname OrderCreatedDate = sy-datum  )
    %control = VALUE #( Category = if_abap_behv=>mk-on  OrderCreatedUser = if_abap_behv=>mk-on  OrderCreatedDate = if_abap_behv=>mk-on )
    )
    )
    MAPPED mapped FAILED failed REPORTED reported.

  ENDMETHOD.

  METHOD DefaultValues.

*    DATA(lv_date_1)  = cl_abap_context_info=>get_system_date( ).
*    GET TIME STAMP FIELD DATA(lv_timestamp).
*    DATA: lv_date TYPE zyb_i_sales_hdr_m-CreatedAt,
*          lv_user TYPE zyb_i_sales_hdr_m-OrderCreatedUser.
*    lv_date = lv_date_1.
*    lv_user = sy-uname.
*    READ ENTITIES OF zyb_i_sales_hdr_m IN LOCAL MODE
*    ENTITY Header ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_header).
*
*    "Passed default values
*    LOOP AT lt_header INTO DATA(ls_header).
*      MODIFY ENTITIES OF zyb_i_sales_hdr_m IN LOCAL MODE
*      ENTITY Header
*      UPDATE  FIELDS ( CreatedAt CreatedBy OrderCreatedDate OrderCreatedUser )
*      WITH VALUE #( (  %tky = ls_header-%tky
*                       %data-CreatedAt = lv_timestamp  %data-CreatedBy = lv_user  %data-OrderCreatedDate = lv_date  %data-OrderCreatedUser = lv_user
*                       %control-CreatedAt = if_abap_behv=>mk-on %control-CreatedBy = if_abap_behv=>mk-on %control-OrderCreatedDate = if_abap_behv=>mk-on %control-OrderCreatedUser = if_abap_behv=>mk-on
*
*                        ) ).
*    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
