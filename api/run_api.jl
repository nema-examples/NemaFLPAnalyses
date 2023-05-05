using HTTP


function final_analysis(req)

    cmd = `cd /app/NemaFLPAnalyses; nema-cli run final-analysis`

    run(cmd)

    return HTTP.Response(200, "Success")
end

function paper_example(req)

    cmd = `cd /app/NemaFLPAnalyses; nema-cli run paper-example`

    run(cmd)

    return HTTP.Response(200, "Success")
end

router = HTTP.Router()
HTTP.register!(router, "GET", "/final-analysis", final_analysis)
HTTP.register!(router, "GET", "/paper-example", paper_example)

# set up asynchronously because otherwise REPL freezes
HTTP.serve(router, "0.0.0.0", 8000)
