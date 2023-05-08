function facilities_from_table(
    dataframe::AbstractDataFrame;
    national_transportation_cost_USD_per_package_per_km::Float64=0.001458
)

    return [
        Facility(
            ID=string(row.name),
            coordinate=CoordinateLatLong(
                latitude=row.latitude,
                longitude=row.longitude,
            ),
            maximum_capacity=row.max_yearly_capacity_k_packages * 1e3,
            is_already_in_operation=row.is_in_operation == "True",
            yearly_operating_costs=row.yearly_operating_cost_k_USD * 1e3,
            cost_startup=row.startup_cost_k_USD * 1e3,
            cost_shutdown=row.cost_shutdown_k_USD * 1e3,
            transportation_costs=LocalVsNationalTransportationCosts(
                local_cost_per_m=row.local_transportation_cost_USD_per_package_per_km * 1e-3,
                national_cost_per_m=national_transportation_cost_USD_per_package_per_km * 1e-3,
                local_threshold_km=300.0,
            ),
        ) for row in eachrow(dataframe)
    ]

end

function customers_from_table(dataframe::AbstractDataFrame)

    col_names = names(dataframe)
    filter_func(name) = name[1:4] == "pack"
    package_demand_names = filter(filter_func, col_names)
    years = [parse(Int64, split(n, "_")[end]) for n in package_demand_names]

    return [
        YearlyCustomerDemand(
            [
                Customer(
                    ID=string(row.name),
                    coordinate=CoordinateLatLong(
                        latitude=row.latitude,
                        longitude=row.longitude,
                    ),
                    demand=row[Symbol(:package_demand_k_packages_, yr)] * 1e3,
                ) for row in eachrow(dataframe)
            ], yr
        ) for yr in years
    ]

end