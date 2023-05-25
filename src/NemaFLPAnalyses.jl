module NemaFLPAnalyses

using DataFrames
using NemaFacilityLocationProblem
using Nema: NemaPlots
using Dates

include("input_handling.jl")

export facilities_from_table, customers_from_table

include("output_handling.jl")

export to_dataframe_used_facility_capacity, to_sunburst_facility_demand, to_linefigure_facility_demand

end # module
