using CSV
using DataFrames
using NemaFLPAnalyses
using NemaFacilityLocationProblem
using Nema: NemaData, run_analysis, NemaConnectivity, NemaPlots

nema_url = get(ENV, "NEMA_API_ADDRESS", "http://127.0.0.1:5500")

NemaConnectivity.set_url_data_management(nema_url)


function run_final_analysis()

    c = NemaData.DataCollection(
        discount_rate=NemaData.DataElement{Float64}("company-discount-rate"),
        facilities_df=NemaData.DataElement{DataFrame}("facility-candidates-information"),
        customer_demand_df=NemaData.DataElement{DataFrame}("customer-demand-projection-2024-2028"),
        paper_example_facility_output=NemaData.DataElement{DataFrame}("optimized-facility-capacities-2024-2028", output_only=true),
        number_facilities_2024=NemaData.DataElement{Int64}("optimized-number-facilities-operational-2024", output_only=true),
        number_facilities_2025=NemaData.DataElement{Int64}("optimized-number-facilities-operational-2025", output_only=true),
        number_facilities_2026=NemaData.DataElement{Int64}("optimized-number-facilities-operational-2026", output_only=true),
        number_facilities_2027=NemaData.DataElement{Int64}("optimized-number-facilities-operational-2027", output_only=true),
        number_facilities_2028=NemaData.DataElement{Int64}("optimized-number-facilities-operational-2028", output_only=true),
        total_cost=NemaData.DataElement{Float64}("optimized-total-cost-USD", output_only=true),
        facility_demand_breakdown_2024=NemaData.DataElement{NemaPlots.SunburstData}("optimized-facility-demand-breakdown-2024", output_only=true), # this will be updated
        facility_demand_breakdown_2028=NemaData.DataElement{NemaPlots.SunburstData}("optimized-facility-demand-breakdown-2028", output_only=true), # this will be updated
        facility_used_capacity_2024_2028=NemaData.DataElement{NemaPlots.LineFigureData}("optimized-facility-used-capacity-2024-2028", output_only=true), # this will be updated
        # TODO cost breakdown sunburst chart
    )

    function do_computations()

        facilities = facilities_from_table(NemaData.get_value(c.facilities_df))

        customer_demand_per_year = customers_from_table(NemaData.get_value(c.customer_demand_df))

        discount_rate = NemaData.get_value(c.discount_rate)
        company_info = CompanyInformation(discount_rate=discount_rate)

        sol = solve_flp(
            facilities,
            customer_demand_per_year,
            company_info,
        )

        output_df = to_dataframe_used_facility_capacity(sol)

        NemaData.set_value!(c.paper_example_facility_output, output_df)

        NemaData.set_value!(c.total_cost, sol.total_costs)

        operational_facilities_per_year = Dict(fsol.year => count(fs.is_active for fs in fsol.facilities) for fsol in sol.facility_solutions_per_year)

        NemaData.set_value!(c.number_facilities_2024, operational_facilities_per_year[2024])
        NemaData.set_value!(c.number_facilities_2025, operational_facilities_per_year[2025])
        NemaData.set_value!(c.number_facilities_2026, operational_facilities_per_year[2026])
        NemaData.set_value!(c.number_facilities_2027, operational_facilities_per_year[2027])
        NemaData.set_value!(c.number_facilities_2028, operational_facilities_per_year[2028])

        NemaData.set_value!(
            c.facility_demand_breakdown_2024,
            to_sunburst_facility_demand(sol, year_idx=1),
        )

        NemaData.set_value!(
            c.facility_demand_breakdown_2028,
            to_sunburst_facility_demand(sol, year_idx=length(sol.customer_solutions_per_year)),
        )

        years = Vector(2024:2028)

        NemaData.set_value!(
            c.facility_used_capacity_2024_2028,
            to_linefigure_facility_demand(
                sol,
                years,
            )
        )

    end

    run_analysis(c, do_computations, jobID="final_analysis")

end

run_final_analysis()
