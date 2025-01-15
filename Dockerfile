#Base image
FROM julia:1.11.2

#Set the working directory
WORKDIR /home

#Copy the Project.toml and Manifest.toml files into the image to manage dependencies
COPY Project-container.toml ./Project.toml
COPY Manifest.toml ./

#Enable multithreading for Julia
ENV JULIA_NUM_THREADS=4

#Install the dependencies in a separate layer to improve caching
RUN julia --project -e 'using Pkg; Pkg.instantiate()'

#Copy the source code into the image
COPY src/ ./src
COPY test/ ./test
COPY web-server.jl/ ./

RUN julia --project -e 'using Pkg; Pkg.precompile()'

RUN julia --project -e 'using Pkg; Pkg.test()'

#Expose the desired port
EXPOSE 8080

#Set the entrypoint to start the application
ENTRYPOINT ["julia", "--project=.", "web-server.jl"]