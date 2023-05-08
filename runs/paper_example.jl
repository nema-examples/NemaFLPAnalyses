# deal with inputs
# - facility locations
# - customer locations and data

# outputs
# - demand served by each facility

using CSV
using DataFrames
using NemaFLPAnalyses
using NemaFacilityLocationProblem
using Nema: NemaData, run_analysis, NemaConnectivity

nema_url = get(ENV, "NEMA_API_ADDRESS", "http://127.0.0.1:5500")

NemaConnectivity.set_url_data_management(nema_url)


function run_paper_example()

    c = NemaData.DataCollection(
        facilities_df=NemaData.DataElement{DataFrame}("paper-example-facilities-info"),
        customer_demand_df=NemaData.DataElement{DataFrame}("paper-example-customer-demand"),
        paper_example_facility_output=NemaData.DataElement{DataFrame}("paper-example-facility-capacity-result", output_only=true),
    )

    function do_computations()

        facilities = facilities_from_table(NemaData.get_value(c.facilities_df))

        customer_demand_per_year = customers_from_table(NemaData.get_value(c.customer_demand_df))

        company_info = CompanyInformation(discount_rate=0.15)

        sol = solve_flp(
            facilities,
            customer_demand_per_year,
            company_info,
        )

        output_df = to_dataframe_used_facility_capacity(sol)

        NemaData.set_value!(c.paper_example_facility_output, output_df)

    end

    run_analysis(c, do_computations, jobID="paper_example")

end

run_paper_example()
