
{{
    config(
        materialized = "table",
        file_format = "delta",
        schema = "gold"
    )
}}

with product_snapshot as (

    select
        ProductID,
        Name,
        StandardCost,
        ListPrice,
        Size,
        Weight,
        ProductCategoryID,
        ProductModelID,
        SellStartDate,
        SellEndDate,
        DiscontinuedDate
    from {{ ref("product_snapshot") }}
    where dbt_valid_to is null

),

product_model_snapshot as (

    select
        ProductModelID,
        Name,
        CatalogDescription
    from {{ ref("productmodel_snapshot") }}
    where dbt_valid_to is null

),

transformed as (

    select
        row_number() over (
            order by p.ProductID
        ) as product_sk,

        p.ProductID,
        p.Name as product_name,
        p.StandardCost,
        p.ListPrice,
        p.Size,
        p.Weight,
        p.ProductCategoryID,
        p.ProductModelID,
        pm.Name as model,
        pm.CatalogDescription as description,
        p.SellStartDate,
        p.SellEndDate,
        p.DiscontinuedDate

    from product_snapshot p

    left join product_model_snapshot pm
        on p.ProductModelID = pm.ProductModelID

)

select *
from transformed
