{% snapshot salesorderdetail_snapshot %}

{{
    config(
      file_format = "delta",
      target_schema = "snapshots_silver",
      location_root = "abfss://silver@medallionstorageaccount.dfs.core.windows.net/salesorderdetail",
      invalidate_hard_deletes = True,
      unique_key = "SalesOrderDetailID",
      strategy = "check",
      check_cols = "all"
    )
}}

with salesorderdetail_snapshot as (
    SELECT
        SalesOrderID,
        SalesOrderDetailID,
        OrderQty,
        ProductID,
        UnitPrice,
        UnitPriceDiscount,
        LineTotal
    FROM {{ source('saleslt', 'salesorderdetail') }}
)

select * from salesorderdetail_snapshot

{% endsnapshot %}