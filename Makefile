
default:
	rm -rf build
	mkdir build

	# add core Nema package
	cp -r ../../../code/Nema.jl build/Nema

	# adding nema-cli executable
	cp ../../../code/nema-cli/executables/nema-cli-linux-arm64 build/nema-cli

	cd .. && docker build --no-cache -t nema-flp-julia:latest -f ./NemaFLPAnalyses/Dockerfile .

linux:
	rm -rf build
	mkdir build

	# add core Nema package
	cp -r ../../../code/Nema.jl build/Nema
	
	# adding nema-cli executable
	cp ../../../code/nema-cli/executables/nema-cli-linux-amd64 build/nema-cli

	cd .. && docker buildx build --no-cache --platform=linux/amd64 -t nema-flp-julia-linux -f ./NemaFLPAnalyses/Dockerfile .