function to_dataframe_used_facility_capacity(solution::NemaFacilityLocationProblem.FacilityLocationProblemSolution)

    first_facility_location = first(solution.facility_solutions_per_year)
    IDs = [s.ID for s in first_facility_location.facilities]

    years = [s.year for s in solution.facility_solutions_per_year]

    df = DataFrame(name=IDs)

    for (idx_year, year) in enumerate(years)

        single_year_solution = solution.facility_solutions_per_year[idx_year]

        df[!, Symbol(:used_capacity_, year)] = [s.used_capacity for s in single_year_solution.facilities]

    end

    return df

end


function to_sunburst_dict_facility_demand(
    solution::NemaFacilityLocationProblem.FacilitySolution,
    customer_names::Vector{String},
)

    d = Dict{String,Float64}()

    for (idx, cname) in enumerate(customer_names)
        v = solution.volume_to_customers[idx]
        if v > 0.0
            d[cname] = v
        end
    end

    return d

end


function to_sunburst_facility_demand(solution::NemaFacilityLocationProblem.FacilityLocationProblemSolution; year_idx::Int64=1)

    facility_solutions = solution.facility_solutions_per_year[year_idx].facilities
    customer_names = [c.ID for c in solution.customer_solutions_per_year[year_idx].customers]

    d = Dict{String,Any}()

    for f in facility_solutions

        if f.used_capacity > 0.5
            d[f.ID] = to_sunburst_dict_facility_demand(f, customer_names)
        end

    end

    return NemaPlots.SunburstData(d)

end

year_to_date_str(x::Int64) = Dates.format(DateTime(x, 1, 1, 0, 0, 0), ISODateTimeFormat)

function to_linefigure_facility_demand(
    solution::NemaFacilityLocationProblem.FacilityLocationProblemSolution,
    years::Vector{Int64},
)

    arr = NemaPlots.SingleLineFigureDataSeries[]

    number_facilities = length(solution.facility_solutions_per_year[1].facilities)

    mltplr = 1e-3

    for idx_f in 1:number_facilities

        final_year_facility = solution.facility_solutions_per_year[end].facilities[idx_f]
        if final_year_facility.used_capacity < 1.0
            continue
        end

        used_capacity = [fs.facilities[idx_f].used_capacity for fs in solution.facility_solutions_per_year] .* mltplr
        facility_id = final_year_facility.ID

        years_date_format = [year_to_date_str(y) for y in years]

        println(years_date_format)

        append!(
            arr,
            [NemaPlots.SingleLineFigureDataSeries(
                years=years_date_format,
                used_capacity_k_packages=used_capacity,
                label=facility_id,
            )],
        )

    end

    return NemaPlots.LineFigureData(arr)

end