function facilities_from_table(dataframe)

    # colums for dataframe
    # - latitude
    # - longitude
    # - max capacity
    # - startup_cost
    # - cost_shutdown
    # - transportation cost
    # - is_in_operation?

    return [
        Facility(
            coordinate=Coordinate2D(x, y),
            maximum_capacity=max_facility_capacity,
            yearly_operating_costs=200.0,
            cost_startup=startup_cost_single_facility,
            transportation_costs=SimpleTransportationCosts(tc)
        ) for (x, y, tc) in zip(xf_coordinates, yf_coordinates, transportation_costs)
    ]

end

function customers_from_table(dataframe)

    # colums for dataframe
    # - demand
    # - latitude
    # - longitude
    # - year

    return [
        Customer(
            coordinate=Coordinate2D(x, y),
            demand=d,
        ) for (x, y, d) in zip(xc_coordinates, yc_coordinates, customer_demand)
    ]

end