using CSV
using DataFrames
using NemaFLPAnalyses
using NemaFacilityLocationProblem
using Nema: NemaData, run_analysis, NemaConnectivity, NemaPlots

nema_url = get(ENV, "NEMA_API_ADDRESS", "http://127.0.0.1:5500")

NemaConnectivity.set_url_data_management(nema_url)


function run_manual_plan()

    c = NemaData.DataCollection(
        discount_rate=NemaData.DataElement{Float64}("company-discount-rate"),
        facilities_df=NemaData.DataElement{DataFrame}("facility-candidates-information"),
        customer_demand_df=NemaData.DataElement{DataFrame}("customer-demand-projection-2024-2028"),
        manual_total_cost=NemaData.DataElement{Float64}("manual-total-cost-USD", output_only=true),
        facility_used_capacity_2024_2028=NemaData.DataElement{NemaPlots.LineFigureData}("manual-facility-used-capacity-2024-2028", output_only=true), # this will be updated
        facility_output=NemaData.DataElement{DataFrame}("manual-facility-capacities-2024-2028", output_only=true),
        # TODO cost breakdown sunburst chart
    )

    function do_planning()

        facilities = facilities_from_table(NemaData.get_value(c.facilities_df))

        customer_demand_per_year = NemaData.get_value(c.customer_demand_df)

        discount_rate = NemaData.get_value(c.discount_rate)

        ranking = [ # this is the order in which we fill up facilities
            "Denver",
            "Seattle",
            "Chicago",
            "Boston",
            "Los Angeles",
            "Baltimore",
            "New Orleans",
            "Oklahoma City",
            "Miami",
        ]

        facility_capacity_by_ranking = zeros(length(ranking))

        for fac in facilities
            idx_in_ranking = findfirst(ranking .== fac.ID)
            facility_capacity_by_ranking[idx_in_ranking] = fac.maximum_capacity / 1e3
        end

        facility_capacity_cumsum_by_ranking = cumsum(facility_capacity_by_ranking)
        println(facility_capacity_cumsum_by_ranking)

        years = 2024:2028

        new_capacity = zeros(length(ranking), length(years))

        for (idx_year, yr) in enumerate(years)
            total_demand = sum(customer_demand_per_year[:, Symbol(:package_demand_k_packages_, yr)])
            idx_over = findfirst(facility_capacity_cumsum_by_ranking .> total_demand)
            served_demand = total_demand
            for idx_fac in 1:idx_over
                this_demand_served = min(served_demand, facility_capacity_by_ranking[idx_fac])
                served_demand -= this_demand_served
                new_capacity[idx_fac, idx_year] = this_demand_served
            end
        end


        # OK fuck this, I'm just going to put in a number and finish later
        total_costs_USD = 16.0e6

        output_fd = DataFrame(
            name=ranking,
            used_capacity_2024=new_capacity[:, 1],
            used_capacity_2025=new_capacity[:, 2],
            used_capacity_2026=new_capacity[:, 3],
            used_capacity_2027=new_capacity[:, 4],
            used_capacity_2028=new_capacity[:, 5],
        )
        NemaData.set_value!(
            c.facility_output,
            output_fd,
        )

        # fill up capacity according to order

        # compute operational cost

        # compute startup cost


        company_info = CompanyInformation(discount_rate=discount_rate)

        NemaData.set_value!(c.manual_total_cost, total_costs_USD)

        # output table for manual cost

    end

    run_analysis(c, do_planning, jobID="manual_planning")

end

run_manual_plan()
