set -e

## Prepare
cd /home/ubuntu/irtx-jsprit-matsim-connector
mkdir /home/ubuntu/irtx-jsprit-matsim-connector/output

## Create environment
conda env create -f environment.yml -n jsprit2matsim

## Activate environment
conda activate jsprit2matsim

## Run connector
for scenario in baseline_2022 ucc_2022 ucc_2030; do
	python3 convert_routes.py \
	  --scenario-path /home/ubuntu/irtx-jsprit/output/scenario_${scenario}.json \
	  --solution-path /home/ubuntu/irtx-jsprit/output/solution_${scenario}.json \
	  --output-path /home/ubuntu/irtx-jsprit-matsim-connector/output/traces_${scenario}.json \
	  --crs EPSG:2154 \
	  --start-time 28800
done
