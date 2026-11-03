{% snapshot productmodel_snapshot %}

{{
    config(
      file_format = "delta",
      target_schema = "snapshots_silver",
      location_root = "abfss://silver@medallionstorageaccount.dfs.core.windows.net/productmodel",
      invalidate_hard_deletes = True,
      unique_key = "ProductModelID",
      strategy = "check",
      check_cols = "all"
    )
}}

with product_snapshot as (
    SELECT
        ProductModelID,
        Name,
        CatalogDescription
    FROM {{ source('saleslt', 'productmodel') }}
)

select * from product_snapshot

{% endsnapshot %}