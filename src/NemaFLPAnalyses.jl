module NemaFLPAnalyses

using DataFrames
using NemaFacilityLocationProblem

include("input_handling.jl")

export facilities_from_table, customers_from_table

include("output_handling.jl")

export to_dataframe_used_facility_capacity

end # module
