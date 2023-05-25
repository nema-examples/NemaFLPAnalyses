FROM julia:1.7

COPY ./NemaFacilityLocationProblem /app/NemaFacilityLocationProblem
RUN julia -e "using Pkg; Pkg.add(path=\"/app/NemaFacilityLocationProblem\")"

COPY ./NemaFLPAnalyses/build/Nema /app/Nema
RUN julia -e "using Pkg; Pkg.add(path=\"/app/Nema\")"

COPY ./NemaFLPAnalyses /app/NemaFLPAnalyses
RUN julia -e "using Pkg; Pkg.add(path=\"/app/NemaFLPAnalyses\")"

# dependencies for just API
RUN julia -e "using Pkg; Pkg.add(\"HTTP\"); Pkg.add(\"CSV\"); Pkg.add(\"DataFrames\")"

# Add nema-cli executable
WORKDIR /bin
COPY ./NemaFLPAnalyses/build/nema-cli /bin/nema-cli
ENV PATH="$PATH:/bin"

WORKDIR /app/NemaFLPAnalyses
CMD julia api/run_api.jl