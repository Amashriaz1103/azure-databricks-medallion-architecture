
{{
    config(
        materialized = "table",
        file_format = "delta",
        schema = "gold"
    )
}}

with address_snapshot as (

    select
        AddressID,
        AddressLine1,
        AddressLine2,
        City,
        StateProvince,
        CountryRegion,
        PostalCode
    from {{ ref('address_snapshot') }}
    where dbt_valid_to is null

),

customeraddress_snapshot as (

    select
        CustomerId,
        AddressId,
        AddressType
    from {{ ref('customeraddress_snapshot') }}
    where dbt_valid_to is null

),

customer_snapshot as (

    select
        CustomerId,
        trim(concat_ws(' ',
            nullif(FirstName, ''),
            nullif(MiddleName, ''),
            nullif(LastName, '')
        )) as FullName
    from {{ ref('customer_snapshot') }}
    where dbt_valid_to is null

),

transformed as (

    select
        row_number() over (
            order by customer_snapshot.CustomerId,
                     customeraddress_snapshot.AddressId
        ) as customer_sk,

        customer_snapshot.CustomerId,
        customer_snapshot.FullName,
        customeraddress_snapshot.AddressId,
        customeraddress_snapshot.AddressType,
        address_snapshot.AddressLine1,
        address_snapshot.City,
        address_snapshot.StateProvince,
        address_snapshot.CountryRegion,
        address_snapshot.PostalCode

    from customer_snapshot

    inner join customeraddress_snapshot
        on customer_snapshot.CustomerId =
           customeraddress_snapshot.CustomerId

    inner join address_snapshot
        on customeraddress_snapshot.AddressId =
           address_snapshot.AddressID

)

select *
from transformed
