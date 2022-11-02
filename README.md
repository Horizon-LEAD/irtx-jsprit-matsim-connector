# IRTX JSprit to MATSim connector

## Introduction

This model is a connector between the upstream route optimization model JSprit
and the agent-based transport simulator MATSim.

The connector takes a predefined scenario for JSprit (with vehicle characteristics
such as their speed) and a solution including the optimized routes. The data is
transformed into a format that will later be read by MATSim to integrate the
vehicles and their movements into a city-scale transport simulation.

## Requirements

### Software requirements

The converter is packaged in a Python script. All dependencies to run the model
have been collected in a `conda` environment, which is available in the LEAD
repository as `environment.yml`.

### Input / Output

#### Input

To run the model, a predefined scenario and its solution from the upstream
JSprit model is needed.

#### Output

The output of the model is a JSON file describing the vehicles and their routes
to be integrated into MATSim. For details on the format and the contained
information, refer to the input data for the downstream MATSim model.

The location of the resulting JSON file can be configured (see below).

## Running the model

To run the model, the `conda` environment needs to be prepared and entered. After,
one can call `convert_routes.py` as follows:

```bash
python3 convert_routes.py \
  --scenario-path /path/to/jsprit_scenario.json \
  --solution-path /path/to/jsprit_solution.json \
  --output-path /path/to/output_traces.json \
  --crs EPSG:2154 \
  --start-time 28800
```

The **mandatory** parameters are detailed in the following table:

Parameter             | Values                            | Description
---                   | ---                               | ---
`--scenario-path`          | String                            | Path to the scenario file that was used as input to JSprit
`--solution-path`          | String                            | Path to the solution file created by JSprit
`--output-path`         | String                            | Path to were the converted data will be saved
`--crs`         | String                            | Coordinate Reference System to convert the longitude/latitude information. *Must be compatible with the CRS of the MATSim simulation.*

The following **optional** parameters exist that can be configured. See the JSprit model for a detailed description of their meaning in the delivery process of the operator:

Parameter             | Values                            | Description
---                   | ---                               | ---
`--start-time`         | `int` (default `28800`, i.e., 08:00am)                           | JSprit does not consider time of day, but starts the first delivery at `0`. The present parameter shifts the movements to define a common earliest shift shart time for the operators.

## Standard scenarios

For the Lyon living lab, JSprit generates three scenarios: Baseline 2022, UCC 2022,
and UCC 2030. Based on the file names defined in the JSprit model, the outputs can
be converted as follows:

```bash
python3 convert_routes.py \
  --scenario-path /irtx-jsprit/output/scenario_{scenario}.json \
  --solution-path /irtx-jsprit/output/solution_{scenario}.json \
  --output-path /irtx-jsprit-matsim-connector/output/solution_{scenario}.json \
  --crs EPSG:2154 \
  --start-time 28800
```

Here, replace `{scenario} = baseline_2022 | ucc_2022 | ucc_2023`.
