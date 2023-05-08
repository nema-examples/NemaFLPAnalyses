function to_dataframe_used_facility_capacity(solution::NemaFacilityLocationProblem.FacilityLocationProblemSolution)

    first_facility_location = first(solution.facility_solutions_per_year)
    IDs = [s.ID for s in first_facility_location.facilities]

    years = [s.year for s in solution.facility_solutions_per_year]

    df_dict = Dict{Symbol,Vector{<:Union{String,Float64}}}(:name => IDs)

    for (idx_year, year) in enumerate(years)

        single_year_solution = solution.facility_solutions_per_year[idx_year]

        df_dict[Symbol(:used_capacity_, year)] = [s.used_capacity for s in single_year_solution.facilities]

    end

    return DataFrame(; df_dict...)

end