FROM julia:latest

COPY ./NemaFacilityLocationProblem /app/NemaFacilityLocationProblem
RUN julia -e "using Pkg; Pkg.develop(path=\"/app/NemaFacilityLocationProblem\")"

COPY ./NemaFLPAnalyses /app/NemaFLPAnalyses
RUN julia -e "using Pkg; Pkg.develop(path=\"/app/NemaFLPAnalyses\")"

COPY ./NemaFLPAnalyses/api /api
RUN julia -e "using Pkg; Pkg.add(\"HTTP\")"
WORKDIR /api
CMD julia run_api.jl