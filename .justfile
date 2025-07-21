make-all:
    just make-stats make-plots make-tables make-stats make-pdf-tables

make-stats: extract-metrics
    Rscript analysis_scripts/training_time.R
    Rscript analysis_scripts/model_stats.R
    quarto render analysis_scripts/annotation_overlap.qmd --to html

make-plots: extract-metrics
    Rscript analysis_scripts/training_history_plot.R
    Rscript analysis_scripts/hpsearch_plot.R
    uv run analysis_scripts/model_structure.py
    just make-prediction-plots
    just make-prediction-plots-pdf

make-tables: extract-metrics 
    Rscript analysis_scripts/snippet_durations_table.R
    Rscript analysis_scripts/confusion_table.R
    Rscript analysis_scripts/misclassification_table.R
    Rscript analysis_scripts/hps_trials_table.R

make-pdf-tables: make-tables
    just render-table table3_filtered_snippets_duration
    just render-table table4_confusion
    just render-table table5_misclassification_combined
    just render-table table5_misclassification_TP
    just render-table table6_misclassification_PT
    just render-table tableSI1_hps_trials
    just render-table all_ms_tables

render-table basename:
    pdflatex -output-directory analysis_scripts/output/tables analysis_scripts/tex_intermediates/{{basename}}.tex
    rm analysis_scripts/output/tables/{{basename}}.aux analysis_scripts/output/tables/{{basename}}.log

extract-metrics:
    echo "Extracting metrics..."
    Rscript analysis_scripts/tidy_model_metrics.R

sample-predictions:
    uv run python analysis_scripts/sample_predictions.py

make-prediction-plots: sample-predictions
    uv run python analysis_scripts/prediction_plots.py

make-prediction-plots-pdf:
    pdflatex -output-directory analysis_scripts/output/figures analysis_scripts/tex_intermediates/all_prediction_figures.tex
    pdflatex -output-directory analysis_scripts/output/figures analysis_scripts/tex_intermediates/all_prediction_figures.tex
    rm analysis_scripts/output/figures/all_prediction_figures.aux analysis_scripts/output/figures/all_prediction_figures.log

start-fresh:
    rm -f analysis_scripts/output/tables/*.pdf
    rm -f analysis_scripts/output/csv/*.csv
    rm -f analysis_scripts/output/figures/*.png
    rm -f analysis_scripts/output/figures/*.pdf
    rm -f analysis_scripts/output/figures/annotations/*.pdf
    rm -f analysis_scripts/output/tex/*.tex
