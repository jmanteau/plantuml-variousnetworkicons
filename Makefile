.DEFAULT_GOAL := help
.PHONY: help
## -- Help Section --

## This help message
## (can be triggered either by make or make help)
help:
	@printf "Usage\n";

	@awk '{ \
			if ($$0 ~ /^.PHONY: [a-zA-Z\-\_0-9\%]+$$/) { \
				helpCommand = substr($$0, index($$0, ":") + 2); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^[a-zA-Z\-\_0-9.\%]+:/) { \
				helpCommand = substr($$0, 0, index($$0, ":")); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^##/) { \
				if (helpMessage) { \
					helpMessage = helpMessage"\n                     "substr($$0, 3); \
				} else { \
					helpMessage = substr($$0, 3); \
				} \
			} else { \
				if (helpMessage) { \
					print "\n                     "helpMessage"\n" \
				} \
				helpMessage = ""; \
			} \
		}' \
		$(MAKEFILE_LIST)


# The Env file contains the variables to adjust and/or the AWS authentication method
# https://lithic.tech/blog/2020-05/makefile-dot-env
ifneq (,$(wildcard ./.env))
    include .env
    export
    ENV_FILE_PARAM = --env-file .env # Used for docker-compose
else
    $(error Env file does not exist! 'cp .env.template .env' and edit accordingly )
endif

# Optionnal Function
ifneq (,$(wildcard ./.env_Makefile))
    include .env_Makefile
    export
endif

# Check that the command exists
cmd-exists-%:
	@hash $(*) > /dev/null 2>&1 || \
		(echo "ERROR: '$(*)' must be installed and available on your PATH."; exit 1)

# Check that the variable exists
guard-%:
	if [ -z '${${*}}' ]; then echo 'ERROR: variable $* not set' && exit 1; fi


# VARIABLES

PLANTUML_JAR_URL = https://sourceforge.net/projects/plantuml/files/plantuml.jar/download

RAWICONS_DIR = raw-icons
RESIZEDICONS_DIR = resized-icons
RAWICONS = $(notdir $(wildcard $(RAWICONS_DIR)/*.png))


PLANTUML_BIN = bin/plantuml.jar

PUML_OUTPUT= plantuml-variousnetworkicons.puml

width=48    # Width  of PNG to generate   
height=48    # Height of PNG to generate     
graylevel=16z    # Number of grayscale colors    

## -- Initial Setup --

##    Download latest Plantuml and create_sprites.sh
dl_binaries:
		curl -sSfL $(PLANTUML_JAR_URL) -o $(PLANTUML_BIN)

## -- Create sprites --

## Convert the raw square-sized png icons to sprites
convertpng2sprites:
	rm $(PUML_OUTPUT)
	for icon in $(RAWICONS); do \
		convert $(RAWICONS_DIR)/$${icon} -resize 48x48 -quality 95 -depth 8 $(RESIZEDICONS_DIR)/$${icon}; \
		java -Djava.awt.headless=true -jar ${PLANTUML_BIN} -encodesprite $(graylevel) $(RESIZEDICONS_DIR)/$${icon} >> $(PUML_OUTPUT) ; \
	done 

## Create the listing png with all the sprites
createlisting:
	java -Djava.awt.headless=true -jar $(PLANTUML_BIN) -tpng listing/listing.puml ; \

	 
        