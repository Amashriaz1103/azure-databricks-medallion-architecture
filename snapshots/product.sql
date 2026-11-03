{% snapshot product_snapshot %}

{{
    config(
      file_format = "delta",
      target_schema = "snapshots_silver",
      location_root = "abfss://silver@medallionstorageaccount.dfs.core.windows.net/product",
      invalidate_hard_deletes = True,
      unique_key = "ProductID",
      strategy = "check",
      check_cols = "all"
    )
}}

with product_snapshot as (
    SELECT
        ProductID,
        Name,
        ProductNumber,
        Color,
        StandardCost,
        ListPrice,
        Size,
        Weight,
        ProductCategoryID,
        ProductModelID,
        SellStartDate,
        SellEndDate,
        DiscontinuedDate,
        ThumbNailPhoto,
        ThumbnailPhotoFileName
    FROM {{ source('saleslt', 'product') }}
)

select * from product_snapshot

{% endsnapshot %}