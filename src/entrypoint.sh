#!/bin/bash

#Set fonts
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function show_usage () {
    echo -e "${BOLD}Basic usage:${NORM} entrypoint.sh [-vh] FIN_SCENARIO FIN_SOLUTION CRS START_TIME OUT_PATH"
}

function show_help () {
    echo -e "${BOLD}eentrypoint.sh${NORM}: Runs the Parcels Model"\\n
    show_usage
    echo -e "\n${BOLD}Required arguments:${NORM}"
    echo -e "${REV}FIN_SCENARIO${NORM}\t the scenario json input file"
    echo -e "${REV}FIN_SOLUTION${NORM}\t the solution json input file"
    echo -e "${REV}CRS${NORM}\t the crs to transform to (e.g. EPSG:2154)"
    echo -e "${REV}START_TIME${NORM}\t the starting time"
    echo -e "${REV}OUT_PATH${NORM}\t the output path"\\n
    echo -e "${BOLD}Optional arguments:${NORM}"
    echo -e "${REV}-v${NORM}\tSets verbosity level"
    echo -e "${REV}-h${NORM}\tShows this message"
    echo -e "${BOLD}Examples:${NORM}"
    echo -e "entrypoint.sh -v sample-data/input/scenario.json sample-data/input/solution.json EPSG:2154 0 sample-data/output"
}

##############################################################################
# GETOPTS                                                                    #
##############################################################################
# A POSIX variable
# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Initialize vars:
verbose=0

# while getopts
while getopts 'hv' OPTION; do
    case "$OPTION" in
        h)
            show_help
            kill -INT $$
            ;;
        v)
            verbose=1
            ;;
        ?)
            show_usage >&2
            kill -INT $$
            ;;
    esac
done

shift "$(($OPTIND -1))"

leftovers=(${@})
FIN_SCENARIO=${leftovers[0]}
FIN_SOLUTION=${leftovers[1]}
CRS=${leftovers[2]}
OUT_PATH=${leftovers[3]}
START_TIME=""
if [ ${#leftovers[@]} -eq "5" ]; then
    START_TIME=${leftovers[3]}
    OUT_PATH=${leftovers[4]}
fi
##############################################################################
# Input checks                                                               #
##############################################################################
if [ ! -f "${FIN_SCENARIO}" ]; then
     echo -e "Give a ${BOLD}valid${NORM} scenario file path\n"; show_usage; exit 1
fi
if [ ! -f "${FIN_SOLUTION}" ]; then
     echo -e "Give a ${BOLD}valid${NORM} solution file \n"; show_usage; exit 1
fi

if [ ! -d "${OUT_PATH}" ]; then
     echo -e "Give a ${BOLD}valid${NORM} output directory\n"; show_usage; exit 1
fi

##############################################################################
# Execution                                                                  #
##############################################################################
START_TIME_ARG=""
if [ ! -n ${START_TIME} ]; then
    START_TIME_ARG "--start-time ${START_TIME}"
fi

python ${CURDIR}/convert_routes.py \
    --scenario-path ${FIN_SCENARIO} \
    --solution-path ${FIN_SOLUTION} \
    --output-path ${OUT_PATH} \
    --crs ${CRS} \
    ${START_TIME_ARG}
